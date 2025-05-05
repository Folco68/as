;==================================================================================================
;	Export macro
;==================================================================================================

pdtlib_export	macro
pdtlib::\2	equ	pdtlib@\1
PDTLIB_\3	equ	$\1
		endm

;==================================================================================================
;	Library exports
;==================================================================================================

	; Libraries
	pdtlib_export	0000,InstallTrampolines,INSTALL_TRAMPOLINES
	pdtlib_export	0008,InstallTrampolines_C,INSTALL_TRAMPOLINES_C

	; Command line
	pdtlib_export	0001,InitCmdline,INIT_CMDLINE
	pdtlib_export	0002,RewindCmdlineParser,REWIND_CMDLINE_PARSER
	pdtlib_export	0003,GetNextArg,GET_NEXT_ARG
	pdtlib_export	0004,GetCurrentArg,GET_CURRENT_ARG
	pdtlib_export	0005,ParseCmdline,PARSE_CMDLINE
	pdtlib_export	0009,DisableCurrentArg,DISABLE_CURRENT_ARG
	pdtlib_export	000D,ResetCmdlineParser,RESET_CMDLINE_PARSER

	; Files
	pdtlib_export	0006,GetFilePtr,GET_FILE_PTR
	pdtlib_export	0007,CheckFileType,CHECK_FILE_TYPE
	pdtlib_export	000A,GetFileHandle,GET_FILE_HANDLE
	pdtlib_export	000B,ArchiveFile,ARCHIVE_FILE
	pdtlib_export	000C,UnarchiveFile,UNARCHIVE_FILE


;==================================================================================================
;	Constants
;==================================================================================================

; Size of a CMDLINE structure
PDTLIB_CMDLINE.SIZEOF		equ	8

; Return values of CLI callbacks
PDTLIB_CONTINUE_PARSING		equ	0	; Warning: value hardcoded in source! (SR flags, value must be 0)
PDTLIB_STOP_PARSING		equ	1	; Warning: value hardcoded in source! (value must be 1)

; Return values of ParseCmdline
PDTLIB_END_OF_PARSING		equ	0
PDTLIB_INVALID_SWITCH		equ	1
PDTLIB_SWITCH_NOT_FOUND		equ	2
PDTLIB_INVALID_RETURN_VALUE	equ	3
PDTLIB_STOPPED_BY_CALLBACK	equ	4
