; kate: indent-width 8; replace-tabs false; syntax Motorola 68k (VASM/Devpac); tab-width 8;

;==================================================================================================
;
;	Container format
;
;==================================================================================================

CONTAINER_INCREASE_STEP	equ	0	; 2	Number of new entries allocated when reallocating
CONTAINER_ENTRY_SIZE	equ	2	; 2	Size of one entry
CONTAINER_COUNT		equ	4	; 2	Current number of entries
CONTAINER_MAX_COUNT	equ	6	; 2	Number of entries that the container can contain before automatic reallocation
CONTAINER.sizeof	equ	8	; 	Size of a container header

