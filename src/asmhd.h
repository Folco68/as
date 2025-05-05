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
;	Structure stored in FILE_LIST_HD
;	Describe a file which may be:
;	- a base file (found in CLI)
;	- an included file
;	- a macro file (virtual)
;	- an argument of macro file (virtual)
;
;==================================================================================================

FILE.Handle		equ	0	; 2	Handle of the file
FILE.Type		equ	2	; 1	Type of the file
FILE.Offset		equ	4	; 2	Offset where the file is currently read
FILE.LineStart		equ	6	; 2	Offset of the beginning of the current line
FILE.LineNumber		equ	8	; 2	Current line during parsing
FILE.sizeof		equ	10	; 	Size of the structure

FILE_TYPE_BASE		equ	0	; File found in the command line
FILE_TYPE_INCLUDED	equ	1	; File found in an include directive
FILE_TYPE_MACRO		equ	2	; Temporary file used during macro parsing
FILE_TYPE_MACRO_PARAM	equ	3	; Temporary file used during macro parameters parsing

;==================================================================================================
;
;	SYMBOL
;
;	Structure stored in SYMBOL_LIST_HD
;	Describe a symbol and its location
;
;==================================================================================================

SYMBOL.Handle		equ	0	; 2	Handle of the file contaning the symbol
SYMBOL.Offset		equ	2	; 2	Offset of the symbol, starting from the first byte of the file
SYMBOL.Length		equ	4	; 2	Number of characters of the symbol
SYMBOL.Checksum		equ	6	; 2	Checksum of the symbol
SYMBOL.Flags		equ	8	; 2	Type of symbol
SYMBOL.BinOffset	equ	10	; 2	Offset of the symbol in the binary
SYMBOL.sizeof		equ	12	; 	Size of the structure

SYMBOL_FLAG_LABEL	equ	1
SYMBOL_FLAG_LOCAL	equ	2
SYMBOL_FLAG_EQU		equ	4
SYMBOL_FLAG_MACRO	equ	8
SYMBOL_FLAG_EXPORTED	equ	16



;	label
;	label local
;	label local macro
;	macro
;	equ
;	exported

; a constant (equ) has a global/local context
; a local label may be exported, but still follows scope rules

; macro and equ directives need a symbol on the same line

; a macro symbol defines a scope
; a local macro doesn't follow scope rules
