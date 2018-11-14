;==================================================================================================
;	PrintToStdout
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
;	PrintToStderr
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
	movem.l	STD_REGS(fp),d0-d2/a0-a1	; Restore destryed registers
	rts
