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
REWIND_CMDLINE_PARSER		equ	26	; 6
GET_CURRENT_ARG			equ	32	; 6
GET_NEXT_ARG			equ	38	; 6
PARSE_CMDLINE			equ	44	; 6
GLOBAL_FLAGS			equ	50	; 4
LOCAL_FLAGS			equ	54	; 4
FLAGS_PTR			equ	58	; 4
FILE_LIST_HD			equ	62	; 2
STD_REGS			equ	64	; 5*4
RETURN_VALUE			equ	84	; 4
PRINTF				equ	88	; 6
FPRINTF				equ	94	; 6
CMDLINE				equ	100	; 8
STDERR				equ	108	; 6
CUSTOM_CONFIG_FILENAME_PTR	equ	114	; 4
DEFAULT_CONFIG_FILENAME_BUFFER	equ	118	; 20
GET_FILE_PTR			equ	138	; 6
SWAPPABLE_FILE_HD		equ	144	; 2
BINARY_HD			equ	146	; 2
BINARY_SIZE			equ	148	; 4
CHECK_FILE_TYPE			equ	152	; 6
DISABLE_CURRENT_ARG		equ	158	; 6
CURRENT_SRC_FILENAME_PTR	equ	164	; 4
GET_FILE_HANDLE			equ	168	; 6
ROM_BASE			equ	174	; 4
UNARCHIVE_FILE			equ	178	; 6
ARCHIVE_FILE			equ	184	; 6
FILENAME_BUFFER			equ	190	; 18 (8 + 1 + 8 + 1)
SYMBOL_LIST_HD			equ	208	; 2
BINARY_OFFSET			equ	210	; 4

; Size of the stack frame
STACK_FRAME_SIZE		equ	214
