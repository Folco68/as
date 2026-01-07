;==================================================================================================
;
;	SWAP_OUT
;
;	Macro ensuring that a handle is not archived before reallocation or writing
;
;	input	any reg		handle to swap out
;		fp		frame pointer
;
;	output	nothing
;
;	destroy	nothing
;
;==================================================================================================

SWAP_OUT	macro
	pea	(a0)
	movea.w	\1,a0
	trap	#3					; Dereference
	cmpa.l	ROM_BASE(fp),a0				; Is it in flash ?
	bcs.s	\\@AlreadyInRAM				; No, so nothing to do
		bsr	mem::SwapOut
\\@AlreadyInRAM:
	movea.l	(sp)+,a0
		endm

	;------------------------------------------------------------------------------------------
	;	Function called by the macro if the file is in flash
	;------------------------------------------------------------------------------------------

mem::SwapOut:
	movem.l	d0-d2/a1,-(sp)				; Save std regs
	RAMC	kernel_Ptr2Hd				; Get handle in d0
	bsr	mem::Hd2FullName			; Get its filename
	lea	FILENAME_BUFFER(fp),a0			; Full name buffer
	jsr	UNARCHIVE_FILE(fp)			; Unarchive the file
	tst.w	d0					; Check for success
	beq	ErrorMemory				; Fail -> memory error
	movem.l	(sp)+,d0-d2/a1				; Else restore std regs
	rts

;==================================================================================================
;
;	mem::Alloc
;
;	Alloc a memory block.
;	If it fails, the function calls the swap handler then try again
;
;	input	d0.l	size to allocate
;		a6	frame pointer
;
;	output	d0.w	handle
;
;	destroy	d0
;
;==================================================================================================

mem::Alloc:

	movem.l	d1-d2/a0-a1,-(sp)			; Save regs

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
	movem.l	(sp)+,d1-d2/a0-a1			; Restore registers
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
	SWAP_OUT d0
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
	ROMC	HeapRealloc
	addq.l	#6,sp					; Pop args of the first call
	tst.w	d0					; And test realloc result
	bne.s	\ReallocOk

		;----------------------------------------------------------------------------------
		;	First attempt failed, try to swap in data and try to re-allocate
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

	nop					; TODO: move RAM data to flash

\NotAllowed:
	movem.l	(sp)+,d0-d2/a0-a1
	rts


;==================================================================================================
;
;	mem::Hd2FullName
;
;	Copy the full name (folder + filaneme) of a handle in a stack frame buffer (FILENAME_BUFFER)
;
;	input	d0.w	handle
;		a6	frame pointer
;
;	output	Full name in FILENAME_BUFFER. In case of error, first byte of the buffer is 0
;
;	destroy	std
;
;==================================================================================================

mem::Hd2FullName:

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
		ROMC	SymFindNext			; Else get the next SYM_ENTRY*
		move.l	a0,d0				; And test it
		bne.s	\Search				; Ok, one more to test
			clr.b	FILENAME_BUFFER(fp)	; Else not found
			bra.s	\Fail

	;------------------------------------------------------------------------------------------
	;	SYM_ENTRY found. Retrieve the name of the containing folder
	;------------------------------------------------------------------------------------------

\Found:	pea	(a0)					; Save SYM_ENTRY* of the handle
	ROMC	SymFindFoldername
	lea	FILENAME_BUFFER(fp),a1			; Buffer where we write the full filename

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


;==================================================================================================
;
;	mem::AddToSwappableFileHd
;
;	When a file is found in the CLI, it is put in this handle if:
;	- swap is allowed
;	- the file is in RAM
;	No error if the file can't be swaped in
;	Files of this list are swaped out on exit (TODO)
;
;	input	a0	filename
;		a6	frame pointer
;
;	output	nothing
;
;	destroy	nothing
;
;	TODO: Prevent to add twice the same file
;
;==================================================================================================

mem::AddToSwappableFileHd:

	movem.l	d0-d3/a0-a1,-(sp)

	;------------------------------------------------------------------------------------------
	;	Check if swap is allowed
	;------------------------------------------------------------------------------------------

	move.l	GLOBAL_FLAGS(fp),d0				; Read global flags
	btst.l	#BIT_SWAP,d0					; Check if swap in is allowed
	beq.s	\End						; Else, no need to create the list handle

	;------------------------------------------------------------------------------------------
	;	Check if the file is in RAM
	;------------------------------------------------------------------------------------------

	movea.l	4*4(sp),a0					; Read filename
	jsr	GET_FILE_PTR(fp)				; And get a ptr to its data
	cmpa.l	ROM_BASE(fp),a0					; Compare with ROM base
	bcc.s	\End						; Don't add the file if it is already in ROM

	;------------------------------------------------------------------------------------------
	;	Add the file handle to the list
	;	Check if the handle already exists
	;------------------------------------------------------------------------------------------

	move.w	SWAPPABLE_FILE_HD(fp),d0
	bne.s	\Initialized

		;----------------------------------------------------------------------------------
		;	Handle not initialized yet, let's do it
		;----------------------------------------------------------------------------------

		pea	6
		ROMC	HeapAlloc
		addq.l	#4,sp
		move.w	d0,SWAPPABLE_FILE_HD(fp)
\Memory:	beq	ErrorMemory
			movea.w	d0,a0
			trap	#3
			clr.w	(a0)				; No file registered yet

	;------------------------------------------------------------------------------------------
	;	Check if the file handle already exists in the handle
	;------------------------------------------------------------------------------------------
	
	movea.l	4*4(sp),a0
	jsr	GET_FILE_HANDLE(fp)
	move.w	d0,d3
	movea.w	SWAPPABLE_FILE_HD(fp),a0
	trap	#3
	move.w	(a0)+,d0					; # entry
	subq.w	#1,d0						; Counter
\Loop:	cmp.w	(a0)+,d3
	beq.s	\End


	;------------------------------------------------------------------------------------------
	;	Reallocate the handle
	;------------------------------------------------------------------------------------------

\Initialized:
	movea.w	SWAPPABLE_FILE_HD(fp),a0
	trap	#3						; Deref it
	moveq	#1,d1						; Clear upper word. 1 is the count for one new file
	add.w	(a0),d1						; Add number of registered files
	add.l	d1,d1						; Table of handles
	addq.l	#2,d1						; Header size
	move.l	d1,-(sp)					; Push new size
	move.w	d0,-(sp)					; Push handle
	ROMC	HeapRealloc					; Realloc it
	addq.l	#6,sp						; Pop args
	tst.w	d0						; And test success
	beq.s	\Memory

	;------------------------------------------------------------------------------------------
	;	Update the handle (count + file handle)
	;------------------------------------------------------------------------------------------

	movea.w	d0,a0						; Read handle
	trap	#3						; Deref it
	addq.w	#1,(a0)						; Update file count
	move.w	(a0),d1						; Read count
	add.w	d1,d1						; Table of handles
	move.w	d3,0(a0,d1.w)					; Register new file

\End:	movem.l	(sp)+,d0-d3/a0-a1
	rts
