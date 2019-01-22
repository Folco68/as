; kate: indent-width 8; replace-tabs false; syntax Motorola 68k (VASM/Devpac); tab-width 8;

;==================================================================================================
;
;	mem::Alloc
;
;	Alloc a memory block.
;	If it fails, call the swap handler then try again
;
;	input	d0.l	size to allocate
;		a6	frame pointer
;
;	output	d0.w	handle
;
;	destroy	std
;
;==================================================================================================

mem::Alloc:

	movem.l	d0-d2/a0-a1,-(sp)			; Save regs

	;------------------------------------------------------------------------------------------
	;	Push args twice, because we try to allocate twice
	;------------------------------------------------------------------------------------------

	move.l	d0,-(sp)				; Push size twice
	move.l	d0,-(sp)
	ROMC	HeapAlloc				; And try to allocate
	addq.l	#4,sp					; Pop first arg
	tst.w	d0					; Test success
	bne.s	\AllocOk				; Ok, we can leave

		;----------------------------------------------------------------------------------
		;	First attempt failed, try to swap in data and retry to re-allocate
		;----------------------------------------------------------------------------------

		bsr	mem::NeedRAM				; Else try to swap in data
		ROMC	HeapAlloc			; And retry to allocate
		tst.w	d0				; Test success
		beq	ErrorMemory			; Throw an error if it failed

	;------------------------------------------------------------------------------------------
	;	Success
	;------------------------------------------------------------------------------------------

\AllocOk:
	addq.l	#4,sp					; Pop the second arg
	movem.l	(sp)+,d0-d2/a0-a1			; Restore registers
	rts


;==================================================================================================
;
;	mem::Free
;
;	Delete a memory block, swapping it out first if necessary.
;	Support H_NULL in input
;
;	input	d0.w	handle
;		a6	frame pointer
;
;	output	nothing
;
;	destroy	std
;
;==================================================================================================


mem::Free:

	movem.l	d0-d2/a0-a1,-(sp)
	move.w	d0,-(sp)
	ROMC	HeapFree
	addq.l	#2,sp
	movem.l	(sp)+,d0-d2/a0-a1
	rts


;==================================================================================================
;
;	mem::Realloc
;
;	Reallocate a handle. Throw a fatal error if it fails
;
;	input	d0.w	size
;		d1.l	handle
;		a6	frame pointer
;
;	output	nothing
;
;	destroy	nothing
;
;==================================================================================================

mem::Realloc:

	movem.l	d0-d2/a0-a1,-(sp)			; Save regs

	;------------------------------------------------------------------------------------------
	;	Push args twice, because we try to re-allocate twice
	;------------------------------------------------------------------------------------------

	move.l	d0,-(sp)				; Push size
	move.w	d1,-(sp)				; And handle
	move.l	d0,-(sp)				; Twice
	move.w	d1,-(sp)
	jsr	REALLOC					; Realloc with pedrom::realloc, support size > 64 ko
	addq.l	#6,sp					; Pop args of the first call
	tst.w	d0					; And test realloc result
	bne.s	\ReallocOk

		;----------------------------------------------------------------------------------
		;	First attempt failed, try to swap in data and retry to re-allocate
		;----------------------------------------------------------------------------------

		move.w	(sp),d0				; We don't want to swap in this handle
		bsr	mem::NeedRAM
		jsr	REALLOC
		tst.w	d0
		beq	ErrorMemory

	;------------------------------------------------------------------------------------------
	;	Success
	;------------------------------------------------------------------------------------------

\ReallocOk:
	addq.l	#6,sp
	movem.l	(sp)+,d0-d2/a0-a1
	rts


;==================================================================================================
;
;	mem::NeedRAM
;
;	Alloc a memory block.
;	If it fails, call the swap handler then try again
;
;	input	d0.w	handle which musn't be swapped in (if we need RAM to realloc one)
;		a6	frame pointer
;
;	output	nothing
;
;	destroy	nothing
;
;==================================================================================================

mem::NeedRAM:

	movem.l	d0-d2/a0-a1,-(sp)
	move.l	GLOBAL_FLAGS(fp),d0
	btst.l	#BIT_SWAP,d0
	beq.s	\NotAllowed

	nop

\NotAllowed:
	movem.l	(sp)+,d0-d2/a0-a1
	rts
