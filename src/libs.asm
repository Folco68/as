; kate: indent-width 8; replace-tabs false; syntax Motorola 68k (VASM/Devpac); tab-width 8;

;==================================================================================================
;
;	Table of functions of Pdtlib
;
;==================================================================================================

PdtlibFunctionTable:
	dc.w	PDTLIB_INSTALL_TRAMPOLINES
	dc.w	PDTLIB_INIT_CMDLINE
	dc.w	PDTLIB_RESET_CMDLINE
	dc.w	PDTLIB_GET_CURRENT_ARG
	dc.w	PDTLIB_GET_NEXT_ARG
	dc.w	PDTLIB_PARSE_CMDLINE
	dc.w	PDTLIB_GET_FILE_PTR
	dc.w	PDTLIB_CHECK_FILE_TYPE
	dc.w	PDTLIB_REMOVE_CURRENT_ARG
	dc.w	PDTLIB_GET_FILE_HANDLE
	dc.w	-1				; End of table

;==================================================================================================
;
;	Offsets of Pdtlib trampolines in the stack frame
;
;==================================================================================================

PdtlibOffsetTable:
	dc.w	INSTALL_TRAMPOLINES
	dc.w	INIT_CMDLINE
	dc.w	RESET_CMDLINE
	dc.w	GET_CURRENT_ARG
	dc.w	GET_NEXT_ARG
	dc.w	PARSE_CMDLINE
	dc.w	GET_FILE_PTR
	dc.w	CHECK_FILE_TYPE
	dc.w	REMOVE_CURRENT_ARG
	dc.w	GET_FILE_HANDLE

;==================================================================================================
;
;	Table of functions of the PedroM's libc
;
;==================================================================================================

LibcFunctionTable:
	dc.w	PEDROM_RAMDATATABLE		; To get stderr
	dc.w	PEDROM_PRINTF
	dc.w	PEDROM_FPRINTF
	dc.w	PEDROM_REALLOC
	dc.w	-1				; End of table

;==================================================================================================
;
;	Offsets of the libc trampolines in the stack frame
;
;==================================================================================================

LibcOffsetTable:
	dc.w	STDERR
	dc.w	PRINTF
	dc.w	FPRINTF
	dc.w	REALLOC
