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

container::Create

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
