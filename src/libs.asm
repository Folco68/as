;==================================================================================================
;
;	Table of functions of Pdtlib
;
;==================================================================================================

PdtlibFunctionTable:
	dc.w	PDTLIB_INSTALL_TRAMPOLINES
	dc.w	PDTLIB_INIT_CMDLINE
	dc.w	PDTLIB_REWIND_CMDLINE_PARSER
	dc.w	PDTLIB_GET_CURRENT_ARG
	dc.w	PDTLIB_GET_NEXT_ARG
	dc.w	PDTLIB_PARSE_CMDLINE
	dc.w	PDTLIB_GET_FILE_PTR
	dc.w	PDTLIB_CHECK_FILE_TYPE
	dc.w	PDTLIB_DISABLE_CURRENT_ARG
	dc.w	PDTLIB_GET_FILE_HANDLE
	dc.w	PDTLIB_UNARCHIVE_FILE
	dc.w	PDTLIB_ARCHIVE_FILE
	dc.w	-1				; End of table

;==================================================================================================
;
;	Offsets of Pdtlib trampolines in the stack frame
;
;==================================================================================================

PdtlibOffsetTable:
	dc.w	INSTALL_TRAMPOLINES
	dc.w	INIT_CMDLINE
	dc.w	REWIND_CMDLINE_PARSER
	dc.w	GET_CURRENT_ARG
	dc.w	GET_NEXT_ARG
	dc.w	PARSE_CMDLINE
	dc.w	GET_FILE_PTR
	dc.w	CHECK_FILE_TYPE
	dc.w	DISABLE_CURRENT_ARG
	dc.w	GET_FILE_HANDLE
	dc.w	UNARCHIVE_FILE
	dc.w	ARCHIVE_FILE

;==================================================================================================
;
;	Table of functions of the PedroM's libc
;
;==================================================================================================

LibcFunctionTable:
	dc.w	PEDROM_RAMDATATABLE		; To get stderr
	dc.w	PEDROM_PRINTF
	dc.w	PEDROM_FPRINTF
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
