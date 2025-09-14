;==================================================================================================
;
;	assembly::AssembleFileFromCLI
;
;	Assemble a file found in CLI, after its local flags have been parsed
;	Don't return in case of an error, throw it
;
;	Algo:
;		if (there is already a source in hold) {
;			parse it;
;		}
;		put the current source in hold;
;		reset local flags with global flags value;
;		return to parse its local flags;
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
	;	Assemble the file in hold if there is one
	;------------------------------------------------------------------------------------------

	move.l	CURRENT_SRC_FILENAME_PTR(fp),d0			; Is there a source in hold ?
	beq.s	\NoCurrentSource				; No
		bsr	assembly::AssembleBaseFile		; Else assemble it
\NoCurrentSource:

	;------------------------------------------------------------------------------------------
	;	Replace the file in hold with the current one
	;------------------------------------------------------------------------------------------

	lea	CLI_CMDLINE(fp),a0				; Get current source filename
	jsr	GET_CURRENT_ARG(fp)
	move.l	a0,CURRENT_SRC_FILENAME_PTR(fp)			; And put it in hold


	;------------------------------------------------------------------------------------------
	;	Set local flags as the current ones, and return to Pdtlib
	;------------------------------------------------------------------------------------------

	lea	LOCAL_FLAGS(fp),a0				; After the first source file is found in CLI, flags must affect local flags
	move.l	a0,FLAGS_PTR(fp)				; (this setting is usefull only when the first source is found, because it won't change anymore)
	move.l	GLOBAL_FLAGS(fp),LOCAL_FLAGS(fp)		; Reset local flags
	movea.l	(sp)+,a6					; Restore a6
	moveq	#PDTLIB_CONTINUE_PARSING,d0			; Return value for Pdtlib
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
	;	Make the file swappable
	;------------------------------------------------------------------------------------------

	bsr	mem::AddToSwappableFileHd

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
;	d6	offset of the beginning of the current line (used for print::PrintToStderr)
;	d7	line number
;	a2	point to the file entry in the Assembly Handle
;	a3	colon counter during symbol parsing
;
;==================================================================================================

AssembleCurrentFile:

	bra	*

	movem.l	d3-d7/a2-a3,-(sp)

	;------------------------------------------------------------------------------------------
	;	Read data of current file
	;------------------------------------------------------------------------------------------

	bsr	assembly::SetFileData

	;------------------------------------------------------------------------------------------
	;	Main loop of the assembly process. Parse one line per loop
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
	move.l	d5,d6						; Save line beginning offset if case of error

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
	;	If it's not a valid symbol, the parser terminates with an error
	;------------------------------------------------------------------------------------------

	lea	StrSymbolFirstChar(pc),a1			; Chars allowed to be at the beginning of a symbol
	bsr	IsCharValid					; Test current char
	tst.b	d1						; And check success
	beq	ErrorInvalidSymbolName

	lea	SYMBOL_LIST_HD(fp),a1				; Else we add a new symbol to the tables
	bsr	asmhd::AddEntryToAssemblyHandle
	movea.l	a0,a2						; a2 is the entry ptr
	move.w	d3,SYMBOL.Handle(a2)				; Fill the fields
	move.w	d5,SYMBOL.Offset(a2)
	clr.w	SYMBOL.Length(a2)
	clr.w	SYMBOL.Checksum(a2)
	move.l	BINARY_OFFSET(fp),d0
	move.l	d0,SYMBOL.BinOffset(a2)

	;------------------------------------------------------------------------------------------
	;	Prepare symbol parsing. d0 contains the current char
	;	Like specified for A68k (even if it's stupid) a label containing only ':' chars is valid,
	;	but not addressable.
	;------------------------------------------------------------------------------------------

	movea.w	d3,a0						; File handle
	trap	#3						; Deref it
	moveq	#0,d0						; Clear upper byte of lower word (for checksum)
	suba.w	a3,a3						; Consecutive colon counter
	move.b	0(a0,d5.l),d0					; Read the first char again
	bra.s	\SymbolLoopEntry				; Entry point is in the middle of the loop

	;------------------------------------------------------------------------------------------
	;	Read the symbol
	;	While the trailing colons are not taken in account, a3 stores the number of
	;	consecutive colons. If another char appears after some colons, a3 is added to the
	;	symbol length, then it's reset until another colon appears
	;------------------------------------------------------------------------------------------

\SymbolLoop:
	move.b	0(a0,d5.l),d0					; Read a char
	lea	StrSymbolOtherChars(pc),a1			; Prepare the list of valid chars
	bsr	IsCharValid					; Check the char
	tst.b	d1
	beq.s	\EndOfSymbol					; This char is not part of the symbol
\SymbolLoopEntry:						; The loop starts here with the first char
		add.w	d0,SYMBOL.Checksum(a2)			; Update checksum
		addq.l	#1,d5					; Advance to the next char
		cmpi.b	#':',d0					; A colon is handled in a special way
		beq.s	\Colon					; Symbol length is not modified if this is a colon, because terminal colons are discarded
			move.w	a3,d0				; Else read the number of consecutive colon, because now they are significant
			addq.w	#1,d0				; Add the current char
			add.w	d0,SYMBOL.Length(a2)		; And update symbol length
			suba.w	a3,a3				; Reset a3 for future colons
			bra.s	\SymbolLoop
\Colon:		addq.w	#1,a3
		bra.s	\SymbolLoop
\EndOfSymbol:

	;------------------------------------------------------------------------------------------
	;	Discard the symbol if it contains only colons
	;------------------------------------------------------------------------------------------

	tst.w	SYMBOL.Length(a2)				; Is there something else than colons in the symbol?
	bne.s	\SymbolIsAddressable				; Yes, so the symbol is addressable
		lea	SYMBOL_LIST_HD(fp),a1			; If no, discard the symbol
		bsr	asmhd::RemoveLastEntry
\SymbolIsAddressable:

	;------------------------------------------------------------------------------------------
	;	After a symbol, we need SPACE, HTAB, EOL, EOF or a comment, else the symbol is invalid
	;------------------------------------------------------------------------------------------

	move.b	0(a0,d5.l),d0
	beq	\EOF
	IFEQU	HTAB,d0,\BlankSpace
	IFEQU	SPACE,d0,\BlankSpace
	IFEQU	EOL,d0,\SkipEndOfLine
	IFEQU	ASM_FILE_COMMENT,d0,\SkipEndOfLine
	bra	ErrorInvalidSymbolName

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
	;	An instruction.
	;	We copy it at (sp), 7 bytes max + terminal 0 (needed for GetOpcodeOffset)
	;------------------------------------------------------------------------------------------
	
	clr.l	-(sp)						; 8 bytes buffer, 0 terminated
	clr.l	-(sp)

	moveq.l	#7-1,d0						; Counter. Maximum length of an instruction (illegal)
	movea.l	sp,a1						; Writer in the stack
	adda.l	d5,a0						; First char of the instruction
	
\CopyInstruction:
	move.b	(a0)+,d1					; Read a char
	ori.b	#1<<5,d1					; Lower case
	cmpi.b	#'a',d1						; Lower bound
	bcs.s	\CopyInstructionEnd
	cmpi.b	#'z',d1						; Upper bound
	bhi.s	\CopyInstructionEnd
	move.b	d1,(a1)+					; Write the char inside the stack	
	dbra	d0,\CopyInstruction
		bra.s	\InstructionNotFound			; End of the loop reached, end of symbol not found
\CopyInstructionEnd:
	bsr	GetOpcodeOffset
	tst.w	d0
	bmi.s	\InstructionNotFound

	; Validate the instruction in the source, by updating the registers.
	; It will allow the parser to read the size, operands etc...
	nop


\InstructionNotFound:
	addq.l	#8,sp

	;------------------------------------------------------------------------------------------
	;	6. Skip the end of the line and loop
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
	;	EOL found, skip char and loop to parse the next line
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

\EOF:	;	TODO: consistency checks (macros, parenthesis, etc, especially at the end of a base file)

	;------------------------------------------------------------------------------------------
	;	Remove file from list
	;------------------------------------------------------------------------------------------

	lea	FILE_LIST_HD(fp),a1				; Remove current file from list
	bsr	asmhd::RemoveLastEntry

	;------------------------------------------------------------------------------------------
	;	Reload data of previous file if one exists
	;------------------------------------------------------------------------------------------

	movea.w	FILE_LIST_HD(fp),a0				; File list handle
	trap	#3						; Deref it
	tst.w	ASSEMBLY_HD.Count(a0)				; Remaining files?
	movem.l	(sp)+,d3-d7/a2-a3
	bne	assembly::SetFileData				; Yes, reload its data and return

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
	moveq	#0,d5						; Clear upper part
	move.w	FILE.Offset(a0),d5				; Current offset
	moveq	#0,d6						; Clear upper part
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


;==================================================================================================
;
;	GetOpcodeOffset
;
;	Binary search (tail recursion)
;
;	input	4(sp)	Instruction in the source, null terminated. Must be <= 8 bytes, including the terminal 0
;
;	output	d0.w	Offset of the opcode in the table. Negative value if the opcode doesn't exist
;
;	destroy	d0-d2/a0
;
;==================================================================================================

GetOpcodeOffset:

	movem.l	d3-d5/a2-a3,-(sp)
	lea	InstructionTable(pc),a2		; Read table boundaries
	lea	InstructionTableEnd(pc),a3
	move.l	a3,d1
	sub.l	a2,d1				; Size of the table
	divu	#INSTRUCTION.sizeof,d1		; Element count
	subq.w	#1,d1				; Offset of the last element
	moveq	#0,d0				; Offset of the first element

\Loop:	cmp.w	d0,d1				; Test terminal condition (lower bound > upper bound)
	bcc.s	\NotEnd
		moveq	#-1,d0			; The instruction does not exist
		bra.s	\End
\NotEnd:
	move.w	d1,d2
	add.w	d0,d2				; Lower + upper
	lsr.w	#1,d2				; /2 = middle of the range
	move.w	d2,d5				; Save it
	mulu	#INSTRUCTION.sizeof,d2		; Offset of the middle instruction
	lea	InstructionTable(pc,d2.w),a0	; Address of the middle instruction
	movem.l	(a0)+,d3-d4			; Read instruction
	cmp.l	20+4(sp),d3			; 4 first bytes. +20: resgisters
	bcs.s	\IncreaseLower
	bhi.s	\DecreaseUpper
	cmp.l	20+4+4(sp),d4			; 4 last bytes. +20: registers
	bcs.s	\IncreaseLower
	bhi.s	\DecreaseUpper

	;------------------------------------------------------------------------------------------
	;	Found
	;------------------------------------------------------------------------------------------

		move.w	(a0),d0			; Read the opcode offset in the instruction table
\End:		movem.l	(sp)+,d3-d5/a2-a3	; Restore regs
		rts

	;------------------------------------------------------------------------------------------
	;	Adjust bounds
	;------------------------------------------------------------------------------------------

\IncreaseLower:
	move.w	d5,d0				; Increase lower bound
	addq.w	#1,d0				; And discard the current value
	bra.s	\Loop

\DecreaseUpper:
	move.w	d5,d1				; Decrease upper bound
	subq.w	#1,d1				; And discard the current value
	bra.s	\Loop
