; kate: replace-tabs false; syntax M68k for Folco; tab-width 8;

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
;	input	d0.b	sign. May be '+' or '-'
;		d1	rank of the flag in the bitfield
;		a0	frame pointer
;
;	output	nothing
;
;	destroy	nothing
;
;==================================================================================================

flags::SetFlag:

	;------------------------------------------------------------------------------------------
	;	Read the current flags
	;------------------------------------------------------------------------------------------

	movem.l	d2/a0,-(sp)
	movea.l	FLAGS_PTR(a0),a0
	move.l	(a0),d2

	;------------------------------------------------------------------------------------------
	;	Default: enable the flag. Else disable it if the sign is '-', then quit
	;------------------------------------------------------------------------------------------

	bset.l	d1,d2
	cmpi.b	#'+',d0
	beq.s	\Enabled
		bclr.l	d1,d2
\Enabled:
	move.l	d2,(a0)
	movem.l	(sp)+,d2/a0
	rts


;==================================================================================================
;
;	FlagStrict
;
;	Callback for Pdtlib::ParseCmdline
;
;	input	d0.b	sign. May be '+' or '-'
;		a0	(void*)data (actually, frame pointer)
;
;	output	d0 = PDTLIB_CONTINUE_PARSING
;
;	destroy	d0
;
;==================================================================================================

flags::FlagStrict:
	moveq	#BIT_STRICT,d1
Set:	bsr.s	flags::SetFlag
	moveq	#PDTLIB_CONTINUE_PARSING,d0
	rts


;==================================================================================================
;
;	FlagXan
;
;	Callback for Pdtlib::ParseCmdline
;
;	input	d0.b	sign. May be '+' or '-'
;		a0	(void*)data (actually, frame pointer)
;
;	output	d0 = PDTLIB_CONTINUE_PARSING
;
;	destroy	d0
;
;==================================================================================================

flags::FlagXan:
	moveq	#BIT_XAN,d1
	bra.s	Set
