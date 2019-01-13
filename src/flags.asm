; kate: indent-width 8; replace-tabs false; syntax Motorola 68k (VASM/Devpac); tab-width 8;

;==================================================================================================
;
;	Flags
;
;==================================================================================================

CompilationFlags:	dc.l	FLAG_STRICT<<BIT_STRICT+FLAG_XAN<<BIT_XAN+FLAG_SWAP<<BIT_SWAP


;==================================================================================================
;
;	SetFlag
;
;	Set a flag according to the given sign. The flag may be local or global
;
;	input	d0.b	sign. May be #'+' or #'-'
;		d1	rank of the flag in the bitfield
;		a6	frame pointer
;
;	output	nothing
;
;	destroy	nothing
;
;==================================================================================================

flags::SetFlag

	;------------------------------------------------------------------------------------------
	;	Read the current flags
	;------------------------------------------------------------------------------------------

	movem.l	d2/a0,-(sp)
	movea.l	FLAGS_PTR(fp),a0
	move.l	(a0),d2

	;------------------------------------------------------------------------------------------
	;	Default: enable the flag. Else disable it if the sign is #'-', then quit
	;------------------------------------------------------------------------------------------

	bset.l	d1,d2
	cmpi.b	#'+',d0
	beq.s	\Enabled
		bclr.l	d1,d2
\Enabled:
	movem.l	(sp)+,d2/a0
	rts
