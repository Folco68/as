; kate: indent-width 8; replace-tabs false; syntax Motorola 68k (VASM/Devpac); tab-width 8;

;==================================================================================================
;
;	SWAP_OUT
;
;	Macro allowing to ensure that a handle is not archived before reallocation or writing
;
;	input	any reg		handle to swap out. Can't be a0
;		fp		frame pointer
;
;	output	nothing
;
;	destroy	a0
;
;==================================================================================================

SWAP_OUT	macro

	;------------------------------------------------------------------------------------------
	;	Check fi the file is in RAM or in flash
	;------------------------------------------------------------------------------------------

	movea.w	\1,a0
	trap	#3					; Dereference
	cmpa.l	ROM_BASE(fp),a0				; Is it in flash ?
	bcs.s	\\@AlreadyInRAM				; No, so nothing to do
	
		;------------------------------------------------------------------------------------------
		;	If the file is in flash, unarchive it
		;------------------------------------------------------------------------------------------

		movem.l	d0-d2/a1,-(sp)			; Save std regs
		move.w	\1,d0				; Read handle
		lea	-(8+1+8+1)(sp),sp		; Buffer to store the filename
		bsr	Hd2FullName			; Get its filename
		movea.l	sp,a0				; Buffer ptr
		jsr	UNARCHIVE_FILE(fp)		; Unarchive the file
		tst.w	d0				; Check for success
		beq	ErrorMemory			; Fail -> memory error
		lea	8+1+8+1(sp),sp			; Pop buffer
		movem.l	(sp)+,d0-d2/a1			; Else restore std regs
	
\\@AlreadyInRAM:
		endm


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
		;	First attempt failed, try to swap in data and retry to allocate
		;----------------------------------------------------------------------------------

		bsr	mem::NeedRAM			; Else try to swap in data
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
	beq.s	\No
	ROMC	HeapFree
\No:	addq.l	#2,sp
	movem.l	(sp)+,d0-d2/a0-a1
	rts


;==================================================================================================
;
;	mem::Realloc
;
;	Reallocate a handle. Throw a fatal error if it fails
;
;	input	d0.l	size
;		d1.w	handle
;		a6	frame pointer
;
;	output	nothing
;
;	destroy	nothing
;
;==================================================================================================

mem::Realloc:

	movem.l	d0-d2/a0-a1,-(sp)			; Save regs
	SWAP_OUT	d1				; Swap out the handle in RAM if necessary
	
	;------------------------------------------------------------------------------------------
	;	Push args twice, because we try to re-allocate twice
	;------------------------------------------------------------------------------------------

	move.l	d0,-(sp)				; Push size
	move.w	d1,-(sp)				; And handle
	move.l	d0,-(sp)				; Twice
	move.w	d1,-(sp)
	ROMC	HeapRealloc				; Realloc with pedrom::realloc, support size > 64 ko
	addq.l	#6,sp					; Pop args of the first call
	tst.w	d0					; And test realloc result
	bne.s	\ReallocOk

		;----------------------------------------------------------------------------------
		;	First attempt failed, try to swap in data and retry to re-allocate
		;----------------------------------------------------------------------------------

		move.w	(sp),d0				; We don't want to swap in this handle
		bsr	mem::NeedRAM
		ROMC	HeapRealloc
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


;==================================================================================================
;
;	Hd2FullName
;
;	Copy the full name (folder + filaneme) of a handle in a buffer located at 4(sp)
;
;	input	d0.w	handle
;		a6	frame pointer
;
;	output	4(a0) = 0 if the file couldn't be found
;
;	destroy	std
;
;==================================================================================================

Hd2FullName:

	;------------------------------------------------------------------------------------------
	;	Initialize VAT parsing
	;------------------------------------------------------------------------------------------

	move.w	d0,-(sp)				; Save handle
	move.w	#2,-(sp)				; FO_RECURSE, to go through all variables of all folders
	clr.l	-(sp)					; No SYM_STR
	ROMC	SymFindFirst				; Initialize
	addq.l	#6,sp					; And pop args
	
	;------------------------------------------------------------------------------------------
	;	Look for the SYM_ENTRY containing our handle. Return 0 as the first byte of the buffer
	;	if the file couldn't be found
	;------------------------------------------------------------------------------------------

\Search:
	move.w	(sp),d0					; Read handle
	cmp.w	12(a0),d0				; And compare it with the one of the current SYM_ENTRY
	beq.s	\Found					; We got it!
	ROMC	SymFindNext				; Else get the next SYM_ENTRY*
	move.l	a0,d0					; And test it
	bne.s	\Search					; Ok, one more to test
	clr.b	2+4(a0)					; Else not found. +2: handle. +4: return address. Clear the first byte of the buffer
	bra.s	\Fail
	
	;------------------------------------------------------------------------------------------
	;	SYM_ENTRY found. Retrieve the name of the containing filder
	;------------------------------------------------------------------------------------------

\Found:	pea	(a0)					; Save SYM_ENTRY* of the handle
	ROMC	SymFindFolderName
	lea	4+2+4(sp),a1				; SYM_ENTRY* + handle + return address = buffer ptr

	;------------------------------------------------------------------------------------------
	;	Copy the folder name + path separator in the buffer
	;------------------------------------------------------------------------------------------

\Folder:
	move.b	(a0)+,(a1)+				; Copy folder name
	bne.s	\Folder
	move.b	#'\',-1(a1)				; Path separator

	;------------------------------------------------------------------------------------------
	;	Read SYM_ENTRY ptr and copy the filename
	;------------------------------------------------------------------------------------------

	movea.l	(sp)+,a0				; SYM_ENTRY*
\File:	move.b	(a0)+,(a1)+
	bne.s	\File
		
	;------------------------------------------------------------------------------------------
	;	Pop the handle and quit
	;------------------------------------------------------------------------------------------

\Fail:	addq.l	#2,sp					; Pop handle
	rts
