	include "tios.h"
	include "romcalls.h"
	include "as.h"
	include "asmhd.h"
	include "config.h"
	include "error.h"
	include "flags.h"
	include "krnlramc.h"
	include "opcodes.h"
	include "pdtlib.h"
	include "pdrmramc.h"
	include "stckfrm.h"

	xdef	_ti89
	xdef	_ti89ti
	xdef	_ti92plus
	xdef	_v200

	DEFINE	_main		; Program entry point
	DEFINE	_flag_2		; Don't redraw screen
	DEFINE	_flag_3		; Binary is read-only


;==================================================================================================
;
;	Check the OS and its version
;
;==================================================================================================

	cmpi.w	#PEDROM_SIGNATURE,OS_SIGNATURE		; We can't run on AMS (too many restrictions)
	beq.s	\OSok
\WrongOS:	pea	StrErrorWrongOS(pc)
		ROMC	ST_helpMsg			; The libc is not loaded yet, we can't throw to stderr
		moveq	#ERROR_BOOT,d0
		RAMC	kernel_exit

\OSok:	cmpi.w	#PEDROM_MINIMUM_VERSION,OS_VERSION	; We need at least PedroM 0.83 with a patched kernel::LibsExec
	bcs.s	\WrongOS

;==================================================================================================
;
;	Create the stack frame, and begin to populate it (full initialization is below)
;	Only argc/argv are initialized, because we don't pop the stack, so they will become hard to access
;
;==================================================================================================

	lea	-STACK_FRAME_SIZE(sp),sp		; Create the stack frame
	movea.l	sp,fp					; a6 is used as a global pointer in the whole program
	move.w	4+STACK_FRAME_SIZE(sp),ARGC(fp)		; argc
	move.l	6+STACK_FRAME_SIZE(sp),ARGV(fp)		; argv

;==================================================================================================
;
;	Load Pdtlib
;
;==================================================================================================

	;------------------------------------------------------------------------------------------
	;	Args of pdtlib::InstallTrampolines
	;------------------------------------------------------------------------------------------

	moveq	#PDTLIB_VERSION,d1			; Version
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

	RAMC	kernel_LibsExec				; Reloc and open Pdtlib (twice, because pdtlib::InstallTrampolines will do the same)
	tst.l	(sp)					; Test success
	bne.s	\PdtlibOk
		moveq	#ERROR_PDTLIB,d0		; Failed to load Pdtlib
		RAMC	kernel_exit			; So exit with an error code
\PdtlibOk:
	move.l	a0,PDTLIB_DESCRIPTOR(fp)		; Save descriptor

;==================================================================================================
;
;	Load the PedroM's libc
;
;==================================================================================================

	moveq	#LIBC_VERSION,d1			; Version
	lea	LibcFilename(pc),a0			; Libc name
	lea	LibcFunctionTable(pc),a1		; Table of the libc functions
	lea	LibcOffsetTable(pc),a2			; Table of trampolines offsets in the stack frame
	;movea.l	fp,a3				; Stack frame base already set
	jsr	INSTALL_TRAMPOLINES(fp)			; pdtlib::InstallTrampolines
	move.l	a0,LIBC_DESCRIPTOR(fp)			; Test and save descriptor
	bne.s	\LibcOk

	;------------------------------------------------------------------------------------------
	;	Loading failed. We need to close Pdtlib before exiting
	;------------------------------------------------------------------------------------------

		movea.l	PDTLIB_DESCRIPTOR(fp),a0
		RAMC	kernel_LibsEnd
		moveq	#ERROR_LIBC,d0			; Error code
		RAMC	kernel_exit
\LibcOk:

;==================================================================================================
;
;	The address put in STDERR(fp) is the one of the PedroM's RAM Data Table
;	We want the one of stderr
;
;==================================================================================================

	movea.l	2+STDERR(fp),a0				; +2: skip jmp opcode
	move.l	PEDROM_stderr(a0),STDERR(fp)

;==================================================================================================
;
;	Set the variables in the stack frame
;
;==================================================================================================

	lea	GLOBAL_FLAGS(fp),a0			; At the beginning, we are interested in the global flags
	move.l	CompilationFlags(pc),(a0)		; They are initialized with the user-defined compilation flags
	move.l	a0,FLAGS_PTR(fp)			; The flags pointer points to these global flags
	clr.l	CUSTOM_CONFIG_FILENAME_PTR(fp)		; Default: no custom config file
	clr.l	CURRENT_SRC_FILENAME_PTR(fp)		; Default: no source to assemble
	clr.w	FILE_LIST_HD(fp)			; Handle containing the list of the currently assembled files
	RAMC	kernel_ROM_base				; Read ROM base ptr
	move.l	a0,ROM_BASE(fp)				; Save it
	clr.w	SWAPPABLE_FILE_HD(fp)			; Handle containing the handles of the source files which can be swapped in
	clr.w	SYMBOL_LIST_HD(fp)			; Handle containing the table of symbols found in the current source
	clr.w	BINARY_HD(fp)				; Handle containing the binary code

;==================================================================================================
;
;	Execution process and command line parsing.
;
;	CLI parsing is done in two passes.
;	PASS 1: parse and execute commands, ignoring compilation flags and source files. Commands are disabled when executed
;	PASS 2: parse global flags, then source files and their local flags. Commands are disabled so they are ignored
;
;	Between the two passes, the config file is opened, parsed and close (if one exists)
;
;==================================================================================================

	;------------------------------------------------------------------------------------------
	;	First pass
	;------------------------------------------------------------------------------------------

	lea	CLI_CMDLINE(fp),a0
	move.l	a0,CURRENT_CMDLINE(fp)
	move.w	ARGC(fp),d0
	movea.l	ARGV(fp),a1
	jsr	INIT_CMDLINE(fp)
	jsr	DISABLE_CURRENT_ARG(fp)			; Don't parse *argv[0] (program name)
	bsr	cli::ParseCommands

	;------------------------------------------------------------------------------------------
	;	Parse the config file
	;------------------------------------------------------------------------------------------

	bsr	config::ParseConfigFile

	;------------------------------------------------------------------------------------------
	;	Second pass
	;------------------------------------------------------------------------------------------

	lea	CLI_CMDLINE(fp),a0
	move.l	a0,CURRENT_CMDLINE(fp)
	jsr	REWIND_CMDLINE_PARSER(fp)
	bsr	cli::ParseFiles

;==================================================================================================
;
;	Exit procedure
;	The return code is set in d3 by the error handlers
;
;==================================================================================================

	moveq	#ERROR_NO_ERROR,d3			; Default: no error occured

ExitError:

	bsr	asmhd::FreeAssemblyHandles		; Clean handles used to assemble files
	; TODO: SWAPPABLE_FILE_HD should be freed? But how??

	;------------------------------------------------------------------------------------------
	;	Display an exit message indicating the error code contained by d3.w
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
;
;	Exit procedures (in case of error)
;	d3 will contain the error code
;
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
	moveq	#ERROR_INVALID_SWITCH,d3
	pea	StrErrorInvalidSwitch(pc)
	bra.s	PrintError

	;------------------------------------------------------------------------------------------
	;	Switch not found in the tables
	;------------------------------------------------------------------------------------------

ErrorSwitchNotFound:
	moveq	#ERROR_SWITCH_NOT_FOUND,d3
	pea	StrErrorSwitchNotFound(pc)
	bra.s	PrintError

	;------------------------------------------------------------------------------------------
	;	Invalid return value from a CLI callback (should never happen)
	;------------------------------------------------------------------------------------------

ErrorInvalidReturnValue:
	moveq	#ERROR_INVALID_RETURN_VALUE,d3
	move.w	d1,-(sp)				; Return value
	pea	StrErrorInvalidReturnValue(pc)
	bra.s	PrintError

	;------------------------------------------------------------------------------------------
	;	A callback stopped CLI parsing (should never happen)
	;------------------------------------------------------------------------------------------

ErrorStoppedByCallback:
	moveq	#ERROR_STOPPED_BY_CALLBACK,d3
	pea	StrErrorStoppedByCallback(pc)
	bra.s	PrintError

	;------------------------------------------------------------------------------------------
	;	Catchall for any other CLI parsing error
	;------------------------------------------------------------------------------------------

ErrorUnhandledPdtlibReturnValue:
	moveq	#ERROR_UNHANDLED_PDTLIB_RETURN_VALUE,d3
	pea	StrErrorUnhandledPdtlibReturnValue(pc)
	bra.s	PrintError

	;------------------------------------------------------------------------------------------
	;	The --config switch needs a filename as argument
	;------------------------------------------------------------------------------------------

ErrorNoArgForConfig:
	moveq	#ERROR_NO_ARG_FOR_CONFIG,d3
	pea	StrErrorNoArgForConfig(pc)
	bra.s	PrintError

	;------------------------------------------------------------------------------------------
	;	The configuration file specified with --config was not found
	;------------------------------------------------------------------------------------------

ErrorConfigFileNotFound:
	moveq	#ERROR_CONFIG_FILE_NOT_FOUND,d3
	move.l	CUSTOM_CONFIG_FILENAME_PTR(fp),-(sp)
	pea	StrErrorConfigFilenameNotFound(pc)
	bra.s	PrintError

	;------------------------------------------------------------------------------------------
	;	Not enough memory to (re)allocate
	;------------------------------------------------------------------------------------------

ErrorMemory:
	moveq	#ERROR_MEMORY,d3
	pea	StrErrorMemory(pc)
	bra.s	PrintError

	;------------------------------------------------------------------------------------------
	;	Something without +/- found in the config file
	;------------------------------------------------------------------------------------------

ErrorInvalidInConfigFile:
	moveq	#ERROR_INVALID_ARG_IN_CONFIG_FILE,d3
	lea	CFG_CMDLINE(fp),a0
	jsr	GET_CURRENT_ARG(fp)
	pea	(a0)
	pea	StrErrorInvalidInConfigFile(pc)
	bra.s	PrintError

	;------------------------------------------------------------------------------------------
	;	File not found (base file or included file)
	;	filename is in a0
	;------------------------------------------------------------------------------------------

ErrorFileNotFound:
	moveq	#ERROR_FILE_NOT_FOUND,d3
	pea	(a0)					; Filename
	pea	StrErrorFileNotFound(pc)
	bra.s	PrintError

	;------------------------------------------------------------------------------------------
	;	Invalid character in a symbol
	;------------------------------------------------------------------------------------------

ErrorInvalidSymbolName:
	bsr	assembly::SaveFileData
	bsr	print::PrintSourceContext

	moveq	#ERROR_INVALID_SYMBOL,d3
	pea	StrErrorInvalidSymbolName(pc)
	bra.s	PrintError


;==================================================================================================
;
;	Sources inclusion
;
;==================================================================================================

	include "flags.asm"				; Config flags
	include "cli.asm"				; Parsing and callbacks of command line parsing
	include "print.asm"				; Stdout/stderr printing
	include "config.asm"				; Default/custom config file parsing
	include "mem.asm"				; Heap and virtual memory management
	include "asmhd.asm"				; Allocation/reallocation of handles used by the assembler parser
	include "assembly.asm"				; Source parser and assembler engine
	include "libs.asm"				; Contain only data for the PedroM's libc and Pdtlib, may be far from the executable code
	include "opcodes.asm"				; Contain instruction table + opcode description
	include "strings.asm"				; All strings. WARNING: size may be odd
