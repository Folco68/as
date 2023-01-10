; kate: replace-tabs false; syntax M68k for Folco; tab-width 8;

;==================================================================================================
;
;	print::PrintToStdout
;
;	Print a formatted string on stdout, without destroying any register
;
;	in	like printf
;
;	out	nothing
;
;	destroy	nothing
;
;==================================================================================================

print::PrintToStdout:

	movem.l	d0-d2/a0-a1,STD_REGS(fp)	; Save destroyed registers
	move.l	(sp)+,RETURN_VALUE(fp)		; Pop the return value, to get args at (sp)
	jsr	PRINTF(fp)			; Call pedrom::printf
	move.l	RETURN_VALUE(fp),-(sp)		; Restore return value
	movem.l	STD_REGS(fp),d0-d2/a0-a1	; Restore destryed registers
	rts


;==================================================================================================
;
;	print::PrintToStderr
;
;	Print a formatted string on stderr, without destroying any register
;
;	in	like printf
;
;	out	nothing
;
;	destroy	nothing
;
;==================================================================================================

print::PrintToStderr:

	movem.l	d0-d2/a0-a1,STD_REGS(fp)	; Save destroyed registers
	move.l	(sp),RETURN_VALUE(fp)		; Save the return value, to get args at (sp)
	move.l	STDERR(fp),(sp)			; Set the error stream
	jsr	FPRINTF(fp)			; Print
	move.l	RETURN_VALUE(fp),(sp)		; Restore return value
	movem.l	STD_REGS(fp),d0-d2/a0-a1	; Restore destroyed registers
	rts


;==================================================================================================
;
;	print::PrintSourceContext
;
;	Print the list of files currently assembled, to locate the current error
;
;	in	fp		frame pointer
;		FILE_LIST_HD	must be up-to-date, so if needed, call assembly::SaveFileData
;				before calling this function
;
;	out	nothing
;
;	destroy	nothing
;
;==================================================================================================

print::PrintSourceContext:

	movem.l	d0-d3/a0-a2,-(sp)
	movea.w	FILE_LIST_HD(fp),a0				; File list
	trap	#3						; Deref it
	movea.l	a0,a2

	;------------------------------------------------------------------------------------------
	;	Print base file name and line
	;------------------------------------------------------------------------------------------

	move.w	ASSEMBLY_HD.sizeof+FILE.Handle(a2),d0		; Handle of the base file
	bsr	mem::Hd2FullName
	move.w	ASSEMBLY_HD.sizeof+FILE.LineNumber(a2),-(sp)
	pea	FILENAME_BUFFER(fp)
	pea	StrPrintBasefile(pc)
	bsr	print::PrintToStderr
	lea	10(sp),sp

	;------------------------------------------------------------------------------------------
	;	Prepare counter to display file hierarchy
	;------------------------------------------------------------------------------------------

	move.w	ASSEMBLY_HD.Count(a2),d3			; Number of opened files
	subq.w	#1+1,d3						; 1 to remove base file + 1 for dbf counter
	lea	ASSEMBLY_HD.sizeof(a2),a2			; Point to the first file (base file)
	bmi.s	\PrintLine					; There is only a base file

	;------------------------------------------------------------------------------------------
	;	Print every file. Format string depends on file type
	;------------------------------------------------------------------------------------------

\FilesLoop:
	lea	FILE.sizeof(a2),a2
	move.w	FILE.Handle(a2),d0
	bsr	mem::Hd2FullName
	move.w	FILE.LineNumber(a2),-(sp)
	pea	FILENAME_BUFFER(fp)

	cmpi.w	#FILE_TYPE_INCLUDED,FILE.Type(a2)
	bne.s	\NotIncluded
		pea	StrPrintIncludedFile(pc)
		bra.s	\PrintFile
\NotIncluded:
	cmpi.w	#FILE_TYPE_MACRO,FILE.Type(a2)
	bne.s	\NotMacro
		pea	StrPrintMacroFile(pc)
		bra.s	\PrintFile
\NotMacro:
	pea	StrPrintMacroParamFile(pc)

\PrintFile:
	bsr	print::PrintToStderr
	lea	10(sp),sp
	dbra.w	d3,\FilesLoop

	;------------------------------------------------------------------------------------------
	;	Print the guilty line
	;	(print char by char, this is dirty, but it's the simplest way)
	;------------------------------------------------------------------------------------------

\PrintLine:
	movea.w	FILE.Handle(a2),a0
	trap	#3
	move.w	FILE.LineStart(a2),d0
	lea	0(a0,d0.w),a0					; First char of the line

\LineLoop:
	move.b	(a0)+,d0
	bne.s	\NoEOF
		move.b	#EOL,d0
\NoEOF:	move.w	d0,-(sp)
	bsr.s	\Push
	dc.b	"%c",0
	even
\Push:	bsr	print::PrintToStderr
	addq.l	#6,sp
	cmpi.b	#EOL,d0
	bne.s	\LineLoop

	;------------------------------------------------------------------------------------------
	;	Exit
	;------------------------------------------------------------------------------------------

	movem.l	(sp)+,d0-d3/a0-a2
	rts
