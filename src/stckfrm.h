; kate: indent-width 8; replace-tabs false; syntax Motorola 68k (VASM/Devpac); tab-width 8;

;==================================================================================================
;
;	Offsets of global variables in the stack frame
;
;==================================================================================================

ARGC				equ	0	; 2
ARGV				equ	2	; 4
PDTLIB_DESCRIPTOR		equ	6	; 4
LIBC_DESCRIPTOR			equ	10	; 4
INSTALL_TRAMPOLINES		equ	14	; 6
INIT_CMDLINE			equ	20	; 6
RESET_CMDLINE			equ	26	; 6
GET_CURRENT_ARG			equ	32	; 6
GET_NEXT_ARG			equ	38	; 6
PARSE_CMDLINE			equ	44	; 6
GLOBAL_FLAGS			equ	50	; 4
LOCAL_FLAGS			equ	54	; 4
FLAGS_PTR			equ	58	; 4
CONFIG_BUFFER_HD		equ	62	; 2
STD_REGS			equ	64	; 20
RETURN_VALUE			equ	84	; 4
PRINTF				equ	88	; 6
FPRINTF				equ	94	; 6
CMDLINE				equ	100	; 8
STDERR				equ	108	; 6
CUSTOM_CONFIG_FILENAME_PTR	equ	114	; 4
DEFAULT_CONFIG_FILENAME_BUFFER	equ	118	; 20
GET_FILE_PTR			equ	138	; 6
ARGV_BUFFER_HD			equ	144	; 2
REALLOC				equ	146	; 6

; Size of the stack frame
STACK_FRAME_SIZE		equ	152
