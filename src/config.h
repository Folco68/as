; kate: indent-width 8; replace-tabs false; syntax Motorola 68k (VASM/Devpac); tab-width 8;

;==================================================================================================
;
;	Default flag values. Change them to modify the default behaviour of as
;
;==================================================================================================

FLAG_STRICT	equ	1	; If 1, don't allow fallbacks when parsing instructions
FLAG_XAN	equ	0	; If 1, replace x(an) with (an) when x = 0
FLAG_SWAP	equ	0	; If 1, source files and handles used by as may be swapped in flash
				; if the RAM is exhausted
