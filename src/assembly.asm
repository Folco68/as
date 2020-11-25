; kate: indent-width 8; replace-tabs false; syntax Motorola 68k (VASM/Devpac); tab-width 8;

;==================================================================================================
;
;	assembly::AssembleFileFromCLI
;
;	Assemble a file found in CLI, after these local flags have been parsed
;	Don't return in case of an error, throw it
;
;	Algo:
;	if (there is already a source in hold) {
;		parse it;
;	}
;	put the current source in hold;
;	reset local flags with global flags value;
;	return to parse its local flags;
;
;	input	a0	frame pointer
;
;	output	nothing
;
;	destroy	std
;
;==================================================================================================

assembly::AssembleFileFromCLI:

	pea	(a6)						; Save fp
	movea.l	a0,fp						; And set frame pointer

	;------------------------------------------------------------------------------------------
	;	Assemble the file in hold id there is one
	;------------------------------------------------------------------------------------------

	move.l	CURRENT_SRC_FILENAME_PTR(fp),d0			; Is there a source in hold ?
	beq.s	\NoCurrentSource				; No
		bsr	assembly::AssembleBaseFile		; Else assemble it
\NoCurrentSource:

	;------------------------------------------------------------------------------------------
	;	Replace the file in hold with the current one
	;------------------------------------------------------------------------------------------

	lea	CMDLINE(fp),a0					; Get current source filename
	jsr	GET_CURRENT_ARG(fp)
	move.l	a0,CURRENT_SRC_FILENAME_PTR(fp)			; And put it in hold


	;------------------------------------------------------------------------------------------
	;	Set local flags as the current ones, and return to Pdtlib
	;------------------------------------------------------------------------------------------

	lea	LOCAL_FLAGS(fp),a0				; After the first source file is found in CLI, flags must affect local flags
	move.l	a0,FLAGS_PTR(fp)				; (this setting is usefull only when the first source is found, because it won't change anymore)
	move.l	GLOBAL_FLAGS(fp),LOCAL_FLAGS(fp)		; Reset local flags
	movea.l	(sp)+,a6					; Restore a6
	moveq.l	#PDTLIB_CONTINUE_PARSING,d0			; Return value for Pdtlib
	rts


;==================================================================================================
;
;	assembly::AssembleBaseFile
;
;	Entry point of assembly of base files
;	Assemble the file which filename is pointed to by d0. File may not exist
;
;	input	d0	filename ptr
;		a6	frame pointer
;
;	output	nothing
;
;	destroy	std
;
;==================================================================================================

assembly::AssembleBaseFile:

	;------------------------------------------------------------------------------------------
	;	Check if the file exists and is a text
	;------------------------------------------------------------------------------------------

	move.l	d0,-(sp)					; Save filename ptr
	movea.l	d0,a0						; Filename ptr
	move.b	#TEXT_TAG,d2					; TIOS extension
	jsr	CHECK_FILE_TYPE(fp)
	movea.l	(sp),a0						; Get filename to print in case of error
	tst.w	d0
	bne	ErrorFileNotFound				; Throw the same error for file not found/wrong file type

	;------------------------------------------------------------------------------------------
	;	Make the file swapable
	;------------------------------------------------------------------------------------------

	bsr	mem::AddToSwapableFileHd

	;------------------------------------------------------------------------------------------
	;	Prepare handles needed for assembly
	;------------------------------------------------------------------------------------------

	bsr	asmhd::AllocAssemblyHandles			; Prepare all handles needed to assemble a file
	lea	FILE_LIST_HD(fp),a1				; Read file handle, because we need to add the base file
	bsr	asmhd::AddEntryToAssemblyHandle			; Add one entry. Get its ptr in a0
	movea.l	a0,a1						; And save it

	;------------------------------------------------------------------------------------------
	;	Set up the file in the file list handle
	;------------------------------------------------------------------------------------------

	movea.l	(sp),a0						; Read filename
	jsr	GET_FILE_HANDLE(fp)				; And get its handle
	move.w	d0,FILE.Handle(a1)				; Set handle
	move.w	#FILE_TYPE_BASE,FILE.Type(a1)			; Set type
	move.w	#2+2,FILE.Offset(a1)				; Set offset: +2 for file size, +2 for AMS header
	move.w	#1,FILE.LineNumber(a1)				; Current line

	;------------------------------------------------------------------------------------------
	;	Print a message
	;------------------------------------------------------------------------------------------

	pea	StrAssemblingFile(pc)				; Filename already at (sp)
	bsr	print::PrintToStdout
	addq.l	#8,sp						; Remove string + filename

	;------------------------------------------------------------------------------------------
	;	Assemble the file, then remove it from the file list
	;------------------------------------------------------------------------------------------

	bsr.s	AssembleCurrentFile

	; TODO: create the object file

	rts


;==================================================================================================
;
;	AssembleCurrentFile
;
;	Entry point of assembly of all files. Assemble the last file of File List handle
;
;	input	fp	frame pointer
;
;	output	nothing
;
;	destroy	std
;
;	Registers usage. These registers are initialized at the beginning, and updated in FILE_LIST_HD only
;	when starting the assembly of a new file (macro, include, etc...)
;
;	d3	file handle
;	d4	file type
;	d5	offset of the reader mark in the file
;	d6	offset of the beginning of the current line
;	d7	line number
;
;==================================================================================================

AssembleCurrentFile:

	movem.l	d3-d7/a2,-(sp)

	;------------------------------------------------------------------------------------------
	;	Read data of current file
	;------------------------------------------------------------------------------------------

	bsr	assembly::SetFileData

	;------------------------------------------------------------------------------------------
	;	Main loop of the assembly process. Parse one line per cycle
	;------------------------------------------------------------------------------------------

\MainLoop:

	;------------------------------------------------------------------------------------------
	;	1. Skip the first char of lines for all files, except for macro parameters,
	;	because the parameters don't start at the real line beginning.
	;	For other files, we must skip the TIOS reserved char
	;------------------------------------------------------------------------------------------

	cmpi.w	#FILE_TYPE_MACRO_PARAM,d4
	beq.s	\NoSkipFirstChar
		addq.l	#1,d5					; This char is reserved by the OS
\NoSkipFirstChar:
	move.l	d5,d6						; Save line offset if case of error

	;------------------------------------------------------------------------------------------
	;	2. The line may begin with:
	;	- a symbol (label or macro definition)
	;	- blank spaces (mixed htab or spaces)
	;	- EOL/EOF/comment
	;
	;	Anything else is a junk, and will be intercepted by the symbol parser
	;------------------------------------------------------------------------------------------

	movea.w	d3,a0						; File handle
	trap	#3						; Deref it
	move.b	0(a0,d5.l),d0					; Current char
	beq	\EOF						; EOF
	IFEQU	HTAB,d0,\BlankSpace				; HTAB
	IFEQU	SPACE,d0,\BlankSpace				; SPACE
	IFEQU	EOL,d0,\EOL					; EOL
	IFEQU	ASM_FILE_COMMENT,d0,\SkipEndOfLine		; Comment

	;------------------------------------------------------------------------------------------
	;	3. Something which can be a symbol is found at the beginning of the line. It can be:
	;	- a label
	;	- a macro definition
	;
	;	A symbol looks like ^[A-Za-z_:\@][A-Za-z0-9_:\@]*
	;	See specs.txt to know how a symbol is defined
	;	If it's not a valid symbol, parsing terminates with an error
	;------------------------------------------------------------------------------------------

	lea	StrSymbolFirstChar(pc),a1			; Chars allowed to be at the beginning of a symbol
	bsr	IsCharValid					; Test current char
	tst.b	d1						; And check success
	beq	ErrorInvalidSymbolName

	lea	SYMBOL_LIST_HD(fp),a1
	bsr	asmhd::AddEntryToAssemblyHandle
	movea.l	a0,a2
	move.w	d3,SYMBOL.Handle(a2)
	move.w	d5,SYMBOL.Offset(a2)
	move.w	#1,SYMBOL.Length(a2)
	clr.w	SYMBOL.Checksum(a2)

	movea.w	d3,a0
	trap	#3
	moveq.l	#0,d5						; Clear upper byte of lower word
	move.b	0(a0,d5.l),d0
	add.w	d5,SYMBOL.Checksum(a2)

	;------------------------------------------------------------------------------------------
	;	Like specified, even if it's stupid, a label containing only ':' chars is valid,
	;	but not addressable. (sp).w is false if chars different from ':' are found
	;------------------------------------------------------------------------------------------

	moveq.l	#1,d2						; True
\SymbolLoop:



	;------------------------------------------------------------------------------------------
	;	4. Skip blank spaces, maybe after a symbol, or at the beginning of the line
	;------------------------------------------------------------------------------------------

\BlankSpace:
	addq.l	#1,d5						; Skip first blank space
	move.b	0(a0,d5.l),d0					; Current char
	IFEQU	HTAB,d0,\BlankSpace				; HTAB
	IFEQU	SPACE,d0,\BlankSpace				; SPACE

	;------------------------------------------------------------------------------------------
	;	5. Something found, not at the beginning of the line. It can be:
	;	- an instruction
	;	- a directive
	;	- a macro
	;	- EOL/EOF/comment
	;------------------------------------------------------------------------------------------


	;------------------------------------------------------------------------------------------
	;	Skip the end of the line and loop
	;------------------------------------------------------------------------------------------

\SkipEndOfLine:
	movea.w	d3,a0						; File handle
	trap	#3						; Deref it
\SkipEOL:
	move.b	0(a0,d5.l),d0					; Current char
	beq.s	\EOF						; EOF?
	IFEQU	EOL,d0,\EOL					; EOL?
		addq.l	#1,d5					; Else skip char
		bra.s	\SkipEOL				; And loop

	;------------------------------------------------------------------------------------------
	;	EOL found, skip char and loop to parse next line
	;------------------------------------------------------------------------------------------

\EOL:	addq.l	#1,d5						; Mark offset
	addq.l	#1,d7						; Current line
	bra	\MainLoop

	;------------------------------------------------------------------------------------------
	;	EOF found:
	;	- check context consistency
	;	- remove file from list
	;	- reload data of previous file if one exists
	;	- else return
	;------------------------------------------------------------------------------------------

\EOF:	;	TODO: consistency checks

	lea	FILE_LIST_HD(fp),a1				; Remove current file from list
	bsr	asmhd::RemoveLastEntry

	movea.w	FILE_LIST_HD(fp),a0				; File list handle
	trap	#3						; Deref it
	tst.w	ASSEMBLY_HD.Count(a0)				; Remaining files?
	bne	assembly::SetFileData				; Yes, reload its data and return
		movem.l	(sp)+,d3-d7/a2
		rts


;==================================================================================================
;
;	assembly::SetFileData
;
;	Set some registers, used globally when assembling a file
;
;	input	fp	frame pointer
;
;	output	d3	current file handle
;		d4	file type
;		d5.l	reader mark (offset)
;		d6.l	offset ot the beginning of the current line
;		d7.w	line number
;
;	destroy	a0-a1/d0/d3-d6
;
;==================================================================================================

assembly::SetFileData:

	lea	FILE_LIST_HD(fp),a1				; List handle*
	bsr	asmhd::GetLastEntryPtr				; FILE*
	move.w	FILE.Handle(a0),d3				; Handle
	move.w	FILE.Type(a0),d4				; Type
	moveq.l	#0,d5						; Clear upper part
	move.w	FILE.Offset(a0),d5				; Current offset
	moveq.l	#0,d6						; Clear upper part
	move.w	FILE.LineStart(a0),d6				; Offset of the beginning of the line
	move.w	FILE.LineNumber(a0),d7				; Line number
	rts


;==================================================================================================
;
;	assembly::SaveFileData
;
;	Save current file data in the File List handle
;
;	input	d3	current file handle
;		d4	file type
;		d5.l	reader mark (offset)
;		fp	frame pointer
;
;	destroy	a0-a1
;
;==================================================================================================

assembly::SaveFileData:

	lea	FILE_LIST_HD(fp),a1				; List handle*
	bsr	asmhd::GetLastEntryPtr				; FILE*
	move.w	d3,FILE.Handle(a0)				; Handle
	move.w	d4,FILE.Type(a0)				; Type
	move.w	d5,FILE.Offset(a0)				; Current offset
	move.w	d6,FILE.LineStart(a0)				; Offset of the beginning of the line
	move.w	d7,FILE.LineNumber(a0)				; Line number
	rts


;==================================================================================================
;
;	IsCharValid
;
;	Check if a char is part of a list containing single chars and ranges
;	See strings.asm/StrSymbolFirstChar to see a formated list
;
;	input	d0.b	Char to test
;		a1	List of valid symbols
;
;	output	d1.b	0 if char is not part of the list
;
;	destroy	d1-d2/a1
;
;==================================================================================================

IsCharValid:

	move.b	(a1)+,d1	; Terminal 0 of the list?
	beq.s	\End		; Yes, so char doesn't belong to the list
	cmp.b	d0,d1		; Single char test
	beq.s	\End
	move.b	(a1)+,d2	; Read likely upper range limit
	beq.s	IsCharValid	; It was not a range, so it was a single char, so it's not this one due to previous test
	addq.l	#1,a1		; Skip terminal 0 of the range
	cmp.b	d0,d1		; Test with lower range limit
	bhi.s	IsCharValid	; Invalid if below the lower range limit
	cmp.b	d0,d2		; Test with upper range limit
	bcs.s	IsCharValid	; Not in this range
\End:	rts
