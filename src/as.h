; kate: indent-width 8; replace-tabs false; syntax Motorola 68k (VASM/Devpac); tab-width 8;

;==================================================================================================
;
;	Constants used for system check at boot
;
;==================================================================================================

OS_VERSION			equ	$30	; Address in RAM
OS_SIGNATURE			equ	$32

PEDROM_MINIMUM_VERSION		equ	$0083
PEDROM_SIGNATURE		equ	$524F	; "RO" is the PedroM's signature

PDTLIB_VERSION			equ	2	; Minimum version of Pdtlib
LIBC_VERSION			equ	1	; Minimum version of the PedroM's libc

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
;	Parsing constants
;
;==================================================================================================
EOL			equ	$0D
SPACE			equ	$20
HTAB			equ	$09
CONFIG_FILE_COMMENT	equ	'#'

;==================================================================================================
;
;	TIOS file tag
;
;==================================================================================================

TEXT_TAG		equ	$E0
OTH_TAG			equ	$F8


;==================================================================================================
;
;	Structures
;
;==================================================================================================

ASSEMBLY_HD.Size	equ	0	; 2	Size of an entry
ASSEMBLY_HD.Count	equ	2	; 2	Number of entries in the handle
ASSEMBLY_HD.sizeof	equ	4	;	Size of the assembly handle header

;==================================================================================================
;
;	FILE
;
;	Structured stored in FILE_LIST_HD.
;	Describe a file which may be a base file, an included file, a macro file or an argument of macro
;
;==================================================================================================

FILE.Handle		equ	0	; 2	Handle of the file
FILE.Type		equ	2	; 1	Type of the file
FILE.Offset		equ	4	; 2	Offset where the file is currently read
FILE.sizeof		equ	6	; 	Size of the structure

FILE_TYPE_BASE		equ	0	; File found in the command line
FILE_TYPE_INCLUDED	equ	1	; File found in an include directive
FILE_TYPE_MACRO		equ	2	; Temporary file used during macro parsing
FILE_TYPE_MACRO_ARG	equ	3	; Temporary file used during macro argument parsing
