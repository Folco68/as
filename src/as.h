;==================================================================================================
;
;	Constants
;
;==================================================================================================

OS_VERSION			equ	$30	; Address in RAM
OS_SIGNATURE			equ	$32
PEDROM_MINIMUM_VERSION		equ	$0083
PEDROM_SIGNATURE		equ	$524F	; "RO" is the PedroM's signature
PDTLIB_VERSION			equ	2	; Minimum version of Pdtlib
LIBC_VERSION			equ	1	; Minimum version of the PedroM's libc
BINARY_SIZE_INC			equ	100	; Increment size of the binary handle

;==================================================================================================
;
;	ROM call macro. It's ROM_THROW, but shorter to avoid breaking indentation
;
;==================================================================================================

ROMC	macro
	ROM_THROW	\1
	endm

;==================================================================================================
;
;	Source parsing
;
;==================================================================================================

HTAB			equ	$09
EOL			equ	$0D
SPACE			equ	$20
CONFIG_FILE_COMMENT	equ	'#'
ASM_FILE_COMMENT	equ	';'
EOF			equ	0

IFEQU	macro					; Parameters: value, register, label
	ifeq	\1
		tst.b	\2
	endif
	ifne	\1
		cmpi.b	#\1,\2
	endif
	beq	\3
	endm

;==================================================================================================
;
;	TIOS file tag
;
;==================================================================================================

TEXT_TAG		equ	$E0
OTH_TAG			equ	$F8
