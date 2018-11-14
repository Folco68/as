	include "tios.h"
	include "romcalls.h"
	include "as.h"
	include "config.h"
	include "error.h"
	include "flags.h"
	include "krnlramc.h"
	include "pdtlib.h"
	include "pdrmramc.h"
	include "stckfrm.h"
	
	xdef	_ti89
	xdef	_ti89ti
	xdef	_ti92plus
	xdef	_v200

	DEFINE	_main					; Entry point
	DEFINE	_flag_2					; No redraw screen
	DEFINE	_flag_3					; Read-only
	
;==================================================================================================
;	Check the OS and its version
;==================================================================================================

	cmpi.w	#PEDROM_SIGNATURE,OS_SIGNATURE		; We can't run on AMS (too many limitations)
	beq.s	\OSok
\WrongOS:	pea	StrErrorWrongOS(pc)
		ROMC	ST_helpMsg			; The libc is not loaded yet, we can't throw to stderr
		moveq.l	#ERROR_BOOT,d0
		RAMC	kernel_exit
	
\OSok:	cmpi.w	#PEDROM_MINIMUM_VERSION,OS_VERSION	; We need at least PedroM 0.83 with a patched kernel::LibsExec
	bcs.s	\WrongOS

;==================================================================================================
;	Create the stack frame, and begin to populate it
;==================================================================================================
	
	lea	-STACK_FRAME_SIZE(sp),sp		; Create the stack frame
	movea.l	sp,fp					; a6 is used as a global pointer in the whole program
	move.w	4+STACK_FRAME_SIZE(sp),ARGC(fp)		; argc
	move.l	6+STACK_FRAME_SIZE(sp),ARGV(fp)		; argv

;==================================================================================================
;	Load Pdtlib
;==================================================================================================

	;------------------------------------------------------------------------------------------
	;	Args of pdtlib::InstallTrampolines
	;------------------------------------------------------------------------------------------
	moveq.l	#PDTLIB_VERSION,d1			; Version
	lea	PdtlibFilename(pc),a0			; Lib name
	lea	PdtlibFunctionTable(pc),a1		; Table of pdtlib functions
	lea	PdtlibOffsetTable(pc),a2		; Table of trampolines offsets in the stack frame
	movea.l	fp,a3					; Stack frame base
	
	;------------------------------------------------------------------------------------------
	;	Args of kernel::LibsExec
	;------------------------------------------------------------------------------------------
	move.b	#PDTLIB_VERSION,-(sp)			; Lib version
	move.w	#PDTLIB_INSTALL_TRAMPOLINES,-(sp)	; Function
	pea	PdtlibFilename(pc)			; Lib name
	
	;------------------------------------------------------------------------------------------
	;	Call and check
	;------------------------------------------------------------------------------------------
	RAMC	kernel_LibsExec				; Reloc and opens Pdtlib
	tst.l	(sp)					; Test success
	bne.s	\PdtlibOk
		moveq.l	#ERROR_PDTLIB,d0		; Failed to load Pdtlib
		RAMC	kernel_exit			; So exit with an error code
\PdtlibOk:
	move.l	a0,PDTLIB_DESCRIPTOR(fp)		; Save descriptor

;==================================================================================================
;	Load the PedroM's libc
;==================================================================================================

	moveq.l	#LIBC_VERSION,d1			; Version
	lea	LibcFilename(pc),a0			; Libc name
	lea	LibcFunctionTable(pc),a1		; Table of the libc functions
	lea	LibcOffsetTable(pc),a2			; Table of trampolines offsets in the stack frame
	;movea.l	fp,a3				; The stack frame base is already set
	jsr	INSTALL_TRAMPOLINES(fp)			; pdtlib::InstallTrampolines
	move.l	a0,LIBC_DESCRIPTOR(fp)			; Test and save descriptor
	bne.s	\LibcOk
	
	;------------------------------------------------------------------------------------------
	;	Loading failed. We need to close Pdtlib before exiting
	;------------------------------------------------------------------------------------------
		movea.l	PDTLIB_DESCRIPTOR(fp),a0
		RAMC	kernel_LibsEnd
		moveq.l	#ERROR_LIBC,d0			; Error code
		RAMC	kernel_exit
\LibcOk:

;==================================================================================================
;	The address put in STDERR(fp) is the one of the PedroM's RAM Data Table
;	Wen want the one of stderr
;==================================================================================================
	
	movea.l	2+STDERR(fp),a0				; +2: skip jmp opcode
	move.l	PEDROM_stderr(a0),STDERR(fp)

;==================================================================================================
;	Set the variables in the stack frame
;==================================================================================================

	lea	GLOBAL_FLAGS(fp),a0			; At the beginning, we are interested in the global flags
	move.l	CompilationFlags(pc),(a0)		; They are initialized with the user-defined compilation flags
	move.l	a0,FLAGS_PTR(fp)			; The flags pointer points to these global flags
	clr.l	CUSTOM_CONFIG_FILENAME_PTR(fp)		; Default: no custom config file

;==================================================================================================
;	Execution process and command line parsing
;
;	1. Parse the CLI, looking for commands, ignoring compilation flags nd source files
;	2. Read the config file, if there is one to parse
;	3. Parse the global compilation files
;	4. Get the first source file, read its flags, then assemble it
;	5. Loop while a source file remains
;==================================================================================================
	
	;------------------------------------------------------------------------------------------
	;	First pass
	;------------------------------------------------------------------------------------------
	lea	CMDLINE(fp),a0
	move.w	ARGC(fp),d0
	movea.l	ARGV(fp),a1
	jsr	INIT_CMDLINE(fp)
	bsr	cli::ParseCommands
	
	;------------------------------------------------------------------------------------------
	;	Parse the config file
	;------------------------------------------------------------------------------------------
	bsr	config::ParseConfigFile

;==================================================================================================
;	Exit procedure
;	The return code is set in d3 by the error handlers
;==================================================================================================

	moveq.l	#ERROR_NO_ERROR,d3

ExitError:
	;------------------------------------------------------------------------------------------
	;	Display an exit message indicating the error code
	;	The error code must be in d3.w
	;------------------------------------------------------------------------------------------	
	move.w	d3,-(sp)
	pea	StrExit(pc)
	bsr	print::PrintToStdout
	
	;------------------------------------------------------------------------------------------
	;	Unload the libc and Pdtlib
	;------------------------------------------------------------------------------------------
	movea.l	PDTLIB_DESCRIPTOR(fp),a0
	RAMC	kernel_LibsEnd
	movea.l	LIBC_DESCRIPTOR(fp),a0
	RAMC	kernel_LibsEnd
	
	;------------------------------------------------------------------------------------------
	;	Exit point
	;------------------------------------------------------------------------------------------
	move.w	d3,d0					; Return code for the kernel
	RAMC	kernel_exit
	

;==================================================================================================
;	Exit procedures (in case of error)
;	d3 will contain the error code
;==================================================================================================

	;------------------------------------------------------------------------------------------
	;	Print the error message before the exit procedure
	;------------------------------------------------------------------------------------------
PrintError:
	bsr	print::PrintToStderr
	bra.s	ExitError
	
	;------------------------------------------------------------------------------------------
	;	Invalid switch found in the command line
	;------------------------------------------------------------------------------------------
ErrorInvalidSwitch:
	moveq.l	#ERROR_INVALID_SWITCH,d3
	pea	StrErrorInvalidSwitch(pc)
	bra.s	PrintError

	;------------------------------------------------------------------------------------------
	;	Switch not found in the tables
	;------------------------------------------------------------------------------------------
ErrorSwitchNotFound:	
	moveq.l	#ERROR_SWITCH_NOT_FOUND,d3
	pea	StrErrorSwitchNotFound(pc)
	bra.s	PrintError

	;------------------------------------------------------------------------------------------
	;	Invalid return value from a CLI callback (should never happen)
	;------------------------------------------------------------------------------------------
ErrorInvalidReturnValue:	
	moveq.l	#ERROR_INVALID_RETURN_VALUE,d3
	move.w	d1,-(sp)				; Return value
	pea	StrErrorInvalidReturnValue(pc)
	bra.s	PrintError
	
	;------------------------------------------------------------------------------------------
	;	A callback stopped CLI parsing (should never happen)
	;------------------------------------------------------------------------------------------
ErrorStoppedByCallback:
	moveq.l	#ERROR_STOPPED_BY_CALLBACK,d3
	pea	StrErrorStoppedByCallback(pc)
	bra.s	PrintError

	;------------------------------------------------------------------------------------------
	;	Catchall for any other CLI parsing error
	;------------------------------------------------------------------------------------------
ErrorUnhandledPdtlibReturnValue:
	moveq.l	#ERROR_UNHANDLED_PDTLIB_RETURN_VALUE,d3
	pea	StrErrorUnhandledPdtlibReturnValue(pc)
	bra.s	PrintError

	;------------------------------------------------------------------------------------------
	;	The --config switch needs a filename as argument
	;------------------------------------------------------------------------------------------
ErrorNoArgForConfig:
	moveq.l	#ERROR_NO_ARG_FOR_CONFIG,d3
	pea	StrErrorNoArgForConfig(pc)
	bra.s	PrintError
	
	;------------------------------------------------------------------------------------------
	;	The configuration file specified with --config was not found
	;------------------------------------------------------------------------------------------
ErrorConfigFileNotFound:
	moveq.l	#ERROR_CONFIG_FILE_NOT_FOUND,d3
	move.l	CUSTOM_CONFIG_FILENAME_PTR(fp),-(sp)
	pea	StrErrorConfigFilenameNotFound(pc)
	bra.s	PrintError
	

;==================================================================================================
;	Sources inclusion
;==================================================================================================

	include "flags.asm"				; CLI/config flags
	include "cli.asm"				; Command line input
	include "print.asm"				; Stdout/stderr handling
	include "config.asm"				; Default/custom config file parsing
	include "libs.asm"				; May be far from the executable code
	include "strings.asm"				; Size may be odd
