; kate: indent-width 8; replace-tabs false; syntax Motorola 68k (VASM/Devpac); tab-width 8;

;==================================================================================================
;
;	AssembleFileFromCLI
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
;	input	a6	frame pointer
;
;	output	nothing
;
;	destroy	std
;
;==================================================================================================

assembly::AssembleFileFromCLI:

	move.l	CURRENT_SRC_FILENAME_PTR(fp),d0			; Is there a source in hold ?
	beq.s	\NoCurrentSource				; No
		bsr	assembly::AssembleBaseFile		; Else assemble it		
\NoCurrentSource:
	lea	CMDLINE(fp),a0					; Get current source filename
	jsr	GET_CURRENT_ARG(fp)
	move.l	a0,CURRENT_SRC_FILENAME_PTR(fp)			; And put it in hold

	lea	LOCAL_FLAGS(fp),a0				; After the first source file is found in CLI, flags must affect local flags
	move.l	a0,FLAGS_PTR(fp)				; (this setting is usefull only when the first source is found, because it won't change anymore)
	move.l	GLOBAL_FLAGS(fp),LOCAL_FLAGS(fp)		; Reset local flags
	rts


;==================================================================================================
;
;	AssembleFile
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

		move.l	d0,-(sp)					; Save filename ptr
		movea.l	d0,a0						; Filename ptr
		move.b	#TEXT_TAG,d2					; TIOS extension
		jsr	CHECK_FILE_TYPE(fp)
		tst.w	d0
		bne	ErrorFileNotFound				; Throw the same error for file not found/wrong file type

		bsr	asmhd::AllocAssemblyHandles			; Prepare all handles needed to assemble a file
		lea	FILE_LIST_HD(fp),a1				; Read file handle, because we need to add the base file
		bsr	asmhd::AddEntryToAssemblyHandle			; Add one entry
		
		movea.l	(sp)+,a0					; Read filename
		jsr	GET_FILE_HANDLE(fp)				; And get its handle
		
;		bra	AssembleCurrentFile
