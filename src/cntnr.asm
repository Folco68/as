; kate: indent-width 8; replace-tabs false; syntax Motorola 68k (VASM/Devpac); tab-width 8;

;==================================================================================================
;
;	container::Create
;
;	Create a container using provided informations. This function may cause swap if necessary
;
;	input	a0	container data, described in containr.h. Only the first two members of the structuer are used
;		a1	HANDLE* where the container handle must be saved
;		a6	frame pointer
;
;	output	d0.w	handle of the container, or H_NULL
;
;	destroy	std
;
;==================================================================================================

container::Create:

	movem.l	a0-a1,-(sp)					; Save data

	;------------------------------------------------------------------------------------------
	;	Compute the size of the container to create
	;------------------------------------------------------------------------------------------

	move.w	CONTAINER_ENTRY_SIZE(a0),d0			; Size of one entry
	mulu.w	CONTAINER_INCREASE_STEP(a0),d0			; Size of all the entries
	addq.l	#CONTAINER.sizeof,d0				; Add the size of the header
	move.l	d0,-(sp)					; Push container size
	bsr	mem::Alloc					; Request allocation
	movem.l	(sp)+,d1-d2/a1					; Trash d1 with pushed size, d2 is container data*, a1 is HANDLE*
	move.w	d0,(a1)						; Save the handle
	movea.w	d0,a0
	trap	#3						; Dereference the container
	movea.l	d2,a1						; Container data*

	;------------------------------------------------------------------------------------------
	;	Initialize container data
	;------------------------------------------------------------------------------------------

	move.w	CONTAINER_INCREASE_STEP(a1),CONTAINER_INCREASE_STEP(a0)
	move.w	CONTAINER_ENTRY_SIZE(a1),CONTAINER_ENTRY_SIZE(a0)
	clr.w	CONTAINER_COUNT(a0)
	clr.w	CONTAINER_MAX_COUNT(a0)

	rts


;==================================================================================================
;
;	container::AddString
;
;	Add a string to a dedicated container
;
;	input	d0	handle of a container
;		a0	first byte of the string to add
;		a1	list of separators which terminate the string (C-string). NULL if there is no separator
;		a6	frame pointer
;
;	output	d0.l	strlen(string)
;
;	destroy	std
;
;==================================================================================================

container::AddString:

	pea	(a2)						; Save a2
	move.w	d0,-(sp)					; Save buffer handle
	movea.l	a0,a2						; a2 points to the string to copy
	moveq.l	#0,d2						; Contain strlen(string)

	;------------------------------------------------------------------------------------------
	;	Algo:
	;	1. get destination pointer (buffer size is increased if necessary)
	;	2. write the new char, stop if it is \0
	;	3. check if the char is a separator, stop if it is one, else loop
	;------------------------------------------------------------------------------------------

	;------------------------------------------------------------------------------------------
	;	1. Get destination pointer (buffer size is increased if necessary)
	;------------------------------------------------------------------------------------------

\StringLoop:
	movea.w	(sp),a0						; Read handle
	trap	#3						; Deref it
	move.w	CONTAINER_COUNT(a0),d0				; Read current number of entries
	cmp.w	CONTAINER_MAX_COUNT(a0),d0			; Max reached?
	bhi.s	\NoRealloc					; No
		move.w	(sp),d0					; Else provide handle
		bsr	container::IncreaseSize			; To resize it
		bra.s	\StringLoop				; And get again a destination pointer
\NoRealloc:
	addq.w	#1,CONTAINER_COUNT(a0)				; Update now the container header, because we are sure that we add a char
	addq.l	#1,d2
	lea	CONTAINER.sizeof(a0,d0.l),a0			; a0 = destination pointer

	;------------------------------------------------------------------------------------------
	;	2. Write the new char, stop if it is \0
	;------------------------------------------------------------------------------------------

	move.b	(a2)+,d0					; Char to copy
	move.b	d0,(a0)						; Write it into the buffer
	bne.s	\CheckSeparator
\EndOfString:	clr.b	(a0)					; Write end of string in the buffer (in case of a separator was used)
		move.l	d2,d0					; Return strlen(string)
		addq.l	#2,sp					; Pop handle
		movea.l	(sp)+,a2				; Restore a2
		rts						; And quit

	;------------------------------------------------------------------------------------------
	;	3. Check if the char is a separator, stop if it is one
	;------------------------------------------------------------------------------------------

\CheckSeparator:
	move.l	a1,d1						; Pointer to separator list
	beq.s	\StringLoop					; No separator, continue with the next char
		movea.l	a1,a0					; Temp pointer, don't trash a1
\SeparatorLoop:
		move.b	(a0)+,d1				; Separator character
		beq.s	\StringLoop				; End of separator list
			cmp.b	d0,d1
			bne.s	\SeparatorLoop			; Not a separator char, try with the next one
				bra.s	\EndOfString		; Else it's the end of the string


;==================================================================================================
;
;	container::IncreaseSize
;
;	Resize a container, adding space according to its header
;
;	input	d0.w	handle of a container
;		a6	frame pointer
;
;	output	nothing
;
;	destroy	nothing
;
;==================================================================================================

container::IncreaseSize:

	movem.l	d0-d1/a0,-(sp)
	move.w	d0,d1						; Handle in d1.w
	movea.w	d0,a0						; Read handle
	trap	#3						; Deref it
	move.w	CONTAINER_MAX_COUNT(a0),d0			; Number of entries
	add.w	CONTAINER_INCREASE_STEP(a0),d0			; Updated number of entries
	mulu.w	CONTAINER_ENTRY_SIZE(a0),d0			; Size of all the entries
	addq.l	#CONTAINER.sizeof,d0				; Add header size
	bsr	mem::Realloc					; Realloc it
	movea.w	d0,a0						; Read handle
	trap	#3						; Derefi it
	move.w	CONTAINER_INCREASE_STEP(a0),d1			; Read increase count
	add.w	d1,CONTAINER_MAX_COUNT(a0)			; Update max count
	movem.l	(sp)+,d0-d1/a0
	rts


;==================================================================================================
;
;	container::GetCount
;
;	Return the current number of entries in a container
;
;	input	d0.w	handle of a container
;		a6	frame pointer
;
;	output	number of objects in the container
;
;	destroy	a0
;
;==================================================================================================

container::GetCount:

	movea.w	d0,a0
	trap	#3
	move.w	CONTAINER_COUNT(a0),d0
	rts


;==================================================================================================
;
;	container::AddEntry
;
;	Add an entry pointed to by a1, in the container whose handle is in d0
;
;	input	d0.w	handle of a container
;		a6	frame pointer
;
;	output	number of objects in the container
;
;	destroy	a0
;
;==================================================================================================

container::AddEntry:

	rts


container::GetEntryPtr:

	rts
