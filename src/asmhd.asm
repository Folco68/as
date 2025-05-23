;==================================================================================================
;
;	asmhd::AllocAssemblyHandles
;
;	Alloc and initialize the handles needed to assemble a file
;
;	input	a6	frame pointer
;
;	output	nothing
;
;	destroy	std
;
;==================================================================================================

asmhd::AllocAssemblyHandles:

	bsr.s	asmhd::FreeAssemblyHandles			; First, clear handles

	moveq.l	#BINARY_SIZE_INC,d0				; Read binary base size
	move.l	d0,BINARY_SIZE(fp)				; Save it
	clr.l	BINARY_OFFSET(fp)				; Initial offset
	bsr	mem::Alloc					; Alloc the handle
	move.w	d0,BINARY_HD(fp)				; And save it
	
	lea	FILE_LIST_HD(fp),a0				; File list
	moveq	#FILE.sizeof,d1
	bsr.s	AllocAssemblyHandle

	lea	SYMBOL_LIST_HD(fp),a0				; Symbol list
	moveq	#SYMBOL.sizeof,d1
;	bsr.s	AllocAssemblyHandle


;==================================================================================================
;
;	AllocAssemblyHandle
;
;	Alloc a handle, and store it in the location pointed to by a0
;
;	input	a0	HANDLE*
;		d1.w	Size of an entry
;
;	output	nothing
;
;	destroy	std
;
;==================================================================================================

AllocAssemblyHandle:

	moveq	#6,d0						; Minimum size of a handle
	bsr	mem::Alloc
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

	lea	BINARY_HD(fp),a0
	bsr.s	FreeAssemblyHandle

	lea	FILE_LIST_HD(fp),a0
	bsr.s	FreeAssemblyHandle

	lea	SYMBOL_LIST_HD(fp),a0
;	bsr.s	FreeAssemblyHandle


;==================================================================================================
;
;	FreeAssemblyHandle
;
;	Delete a handle pointed to by a0, if it exists, and clear its reference
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


;==================================================================================================
;
;	asmhd::AddEntryToAssemblyHandle
;
;	Add an entry to an assembly handle, and return a pointer to that entry
;
;	input	a1	HANDLE*
;
;	output	a0	Entry*
;
;	destroy	a0/d0-d1
;
;==================================================================================================

asmhd::AddEntryToAssemblyHandle:

	movea.w	(a1),a0						; Read handle
	trap	#3						; Deref it
	move.w	ASSEMBLY_HD.Count(a0),d0			; Current count of entries
	addq.w	#1,d0						; Add the new one
	mulu.w	ASSEMBLY_HD.Size(a0),d0				; Size of all entries
	addq.l	#ASSEMBLY_HD.sizeof,d0				; Add handle header
	move.w	(a1),d1						; Read handle
	bsr	mem::Realloc					; And reallocate it
	movea.w	(a1),a0						; Read handle again
	trap	#3						; Deref it
	addq.w	#1,ASSEMBLY_HD.Count(a0)			; Update entry count
;	bra.s	asmhd::GetLastEntryPtr				; And get a pointer to it


;==================================================================================================
;
;	asmhd::GetLastEntryPtr
;
;	Return a pointer to the last entry of an assembly handle pointed to by a1
;
;	input	a1	HANDLE*
;
;	output	a0	Entry*. NULL if the handle doesn't contain any entry
;
;	destroy	a0/d0
;
;==================================================================================================

asmhd::GetLastEntryPtr

	movea.w	(a1),a0						; Read handle
	trap	#3						; Deref it
	move.w	ASSEMBLY_HD.Count(a0),d0			; Read number of entries
	bne.s	\Get						; Ok, there is at least one
		suba.l	a0,a0					; Else return NULL
		rts
\Get:	subq.w	#1,d0
	mulu.w	ASSEMBLY_HD.Size(a0),d0
	lea	ASSEMBLY_HD.sizeof(a0,d0.l),a0			; Pointer to the last entry
	rts


;==================================================================================================
;
;	asmhd::RemoveLastEntry
;
;	Remove the last entry of an assembly handle pointed to by a1.
;	The handle must contain at least one element
;
;	input	a1	HANDLE*
;
;	output	nothing
;
;	destroy	a0/d0
;
;==================================================================================================

asmhd::RemoveLastEntry:

	movem.l	d0-d1/a0,-(sp)
	movea.w	(a1),a0
	trap	#3
	subq.w	#1,ASSEMBLY_HD.Count(a0)	; Update counter
	move.w	ASSEMBLY_HD.Count(a0),d0	; Entry count
	mulu.w	ASSEMBLY_HD.Size(a0),d0		; Size of all entries
	addq.l	#ASSEMBLY_HD.sizeof,d0		; Total size
	move.w	(a1),d1				; Handle
	bsr	mem::Realloc
	movem.l	(sp)+,d0-d1/a0
	rts
