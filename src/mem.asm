; kate: indent-width 8; replace-tabs false; syntax Motorola 68k (VASM/Devpac); tab-width 8;

;==================================================================================================
;
;	mem::Alloc
;
;	Alloc a memory block. Call the swap handler if necessary and if allowed.
;	Throw a fatal error if memory couldn't be allocated
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


	rts
