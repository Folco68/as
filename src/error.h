;==================================================================================================
;
;	Offsets of Pdtlib trampolines in the stack frame
;
;==================================================================================================

ERROR_NO_ERROR				equ	0	; Return value when as terminates normally
ERROR_BOOT				equ	1	; Wrong OS or insufficient version
ERROR_PDTLIB				equ	2	; Couldn't load Pdtlib
ERROR_LIBC				equ	3	; Couldn't load the PedroM's libc
ERROR_INVALID_SWITCH			equ	4	; Invalid switch in the CLI
ERROR_SWITCH_NOT_FOUND			equ	5	; Unknown switch in the CLI
ERROR_INVALID_RETURN_VALUE		equ	6	; Invalid return value from a callback
;ERROR_		equ	7	; 
ERROR_UNHANDLED_PDTLIB_RETURN_VALUE	equ	8	; Invalid return value from Pdtlib
ERROR_NO_ARG_FOR_CONFIG			equ	9	; No arg provided after the switch "config"
ERROR_CONFIG_FILE_NOT_FOUND		equ	10	; The config file specified in the command line was not found
ERROR_MEMORY				equ	11	; Not enough memory to (re)alloc
ERROR_INVALID_ARG_IN_CONFIG_FILE	equ	12	; Something without +/- found in the config file
ERROR_FILE_NOT_FOUND			equ	13	; Source file not found (CLI or inclusion)
ERROR_INVALID_SYMBOL			equ	14	; Invalid character found in a symbol
