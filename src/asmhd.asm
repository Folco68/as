;==================================================================================================
;
;	asmhd::AllocAssemblyHandles
;
;	Alloc and initialize the handles needed to assemble a file
;
;	input	d0.w	handle of the file to assemble (so, a base file)
;		a6	frame pointer
;
;	output	nothing
;
;	destroy	std
;
;==================================================================================================

asmhd::AllocAssemblyHandles:

	bsr.s	asmhd::FreeAssemblyHandles			; First, clear handles

	lea	FILE_LIST_HD(fp),a0
	moveq	#FILE_LIST.sizeof,d1				; Size of an entry
;	bsr.s	AllocAssemblyHandle


;==================================================================================================
;
;	AllocAssemblyHandle
;
;	Alloc an handle, and store it in the location pointed to by a0
;
;	input	a0	HANDLE*
;
;	output	nothing
;
;	destroy	std
;
;==================================================================================================

AllocAssemblyHandle:

	pea	6						; Minimum size of a handle
	bsr	mem::Alloc
	addq.l	#4,sp
	move.w	d0,(a0)						; Save it
	movea.w	d0,a0						; Read it
	trap	#3						; Dereference it
	move.w	d1,ASSEMBLY_HD.Size(a0)				; Size of an entry
	clr.w	ASSEMBLY_HD.Count(a0)				; Initialize with 0 entry
	rts


;==================================================================================================
;
;	asmhd::FreeAssemblyHandles
;
;	Delete handles used when assembling a file. Handles may be H_NULL
;
;	input	a6	frame pointer
;
;	output	nothing
;
;	destroy	std
;
;==================================================================================================

asmhd::FreeAssemblyHandles:
	
	lea	FILE_LIST_HD(fp),a0
;	bsr.s	FreeAssemblyHandle


;==================================================================================================
;
;	FreeAssemblyHandle
;
;	Delete an handle pointed to by a0, if it exists, and clear its reference
;
;	input	a0	HANDLE*
;
;	output	nothing
;
;	destroy	d0.w
;
;==================================================================================================

FreeAssemblyHandle:

	move.w	(a0),d0
	bsr	mem::Free
	clr.w	(a0)
	rts


asmhd::AddEntryToAssemblyHandle:

	movea.w	(a1),a0
	trap	#3
	move.w	ASSEMBLY_HD.Count(a0),d0
	addq.w	#1,d0
	mulu.w	#ASSEMBLY_HD.Size,d0
	addq.l	#ASSEMBLY_HD.sizeof,d0
	move.w	(a1),d1
	bsr	mem::Realloc
	movea.w	(a1),a0
	trap	#3
	addq.w	#1,ASSEMBLY_HD.Count(a0)
