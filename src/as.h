; kate: indent-width 8; replace-tabs false; syntax Motorola 68k (VASM/Devpac); tab-width 8;

;==================================================================================================
;	Constants used for system check at boot
;==================================================================================================

OS_VERSION			equ	$30
OS_SIGNATURE			equ	$32

PEDROM_MINIMUM_VERSION		equ	$0083
PEDROM_SIGNATURE		equ	$524F	; "RO" is the PedroM's signature

PDTLIB_VERSION			equ	2	; Minimum version of Pdtlib
LIBC_VERSION			equ	1	; Minimum version of the PedroM's libc

;==================================================================================================
;	ROM call macro. It's ROM_THROW, but shorter to avoid breaking indentation
;==================================================================================================

ROMC	macro
	ROM_THROW	\1
	endm

;==================================================================================================
;	Parsing constants
;==================================================================================================

EOL	equ	$0D
