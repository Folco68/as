; kate: replace-tabs false; syntax M68k for Folco; tab-width 8;

;==================================================================================================
;
;	ParseCommands
;
;	Parse the CLI, looking only for commands
;	Unknows entries are ignored, without reporting an error
;
;	input	nothing
;
;	output	nothing
;
;	destroy	std
;
;==================================================================================================

cli::ParseCommands:

	;------------------------------------------------------------------------------------------
	;	Prepare the args
	;------------------------------------------------------------------------------------------

	pea	SetConfigFile(pc)		; Callbacks
	pea	DisplayVersion(pc)
	pea	EnableSwap(pc)
	pea	DisplayHelp(pc)
	pea	DisplayFlags(pc)
	clr.l	-(sp)				; No callback called if an arg haven't a +/- sign
	pea	CLICommands(pc)			; String table of commands
	pea	(fp)				; (void*)data thrown to the callbacks
	pea	CMDLINE(fp)			; CMDLINE*
	jsr	PARSE_CMDLINE(fp)
	lea	9*4(sp),sp			; Pop args

	;------------------------------------------------------------------------------------------
	;	Special handling of this error for the first pass:
	;	we just ignore the unknown switches, they will be parsed during the second pass
	;------------------------------------------------------------------------------------------

	cmpi.w	#PDTLIB_SWITCH_NOT_FOUND,d0
	beq.s	cli::ParseCommands

	;------------------------------------------------------------------------------------------
	;
	;	!!! WARNING !!!
	;	This code is used to handle the return value of config file parsing,
	;	and the return value of the second pass
	;
	;------------------------------------------------------------------------------------------

cli::CheckParsingReturnValue:

	;------------------------------------------------------------------------------------------
	;	Return if all was fine
	;------------------------------------------------------------------------------------------

	cmpi.w	#PDTLIB_END_OF_PARSING,d0
	bne.s	\Error
		rts
\Error:

	;------------------------------------------------------------------------------------------
	;	Prepare the guilty switch for fprintf
	;------------------------------------------------------------------------------------------

	move.w	d0,d1				; Save the pdtlib::ParseCmdline return value
	lea	CMDLINE(fp),a0
	jsr	GET_CURRENT_ARG(fp)
	pea	(a0)

	;------------------------------------------------------------------------------------------
	;	Check the return value to call the right error handler
	;------------------------------------------------------------------------------------------

	cmpi.w	#PDTLIB_INVALID_SWITCH,d1	; Invalid switch
	beq	ErrorInvalidSwitch

	cmpi.w	#PDTLIB_SWITCH_NOT_FOUND,d1	; Switch not found
	beq	ErrorSwitchNotFound

	cmpi.w	#PDTLIB_INVALID_RETURN_VALUE,d1	; Invalid return value. If it happens, a callback is buggy
	beq	ErrorInvalidReturnValue

	cmpi.w	#PDTLIB_STOPPED_BY_CALLBACK,d1	; A callback stopped the parsing. It should never happen
	beq	ErrorStoppedByCallback

	bra	ErrorUnhandledPdtlibReturnValue	; Catchall: any other value is unknown


;==================================================================================================
;
;	ParseFiles
;
;	Parse the CLI, looking for global flags, then source files and local flags
;
;	input	nothing
;
;	output	nothing
;
;	destroy	std
;
;==================================================================================================

cli::ParseFiles:

	pea	flags::FlagStrict(pc)
	pea	flags::FlagXan(pc)
	pea	assembly::AssembleFileFromCLI(pc)
	pea	CLIFlags(pc)
	pea	(fp)
	pea	CMDLINE(fp)
	jsr	PARSE_CMDLINE(fp)
	lea	6*4(sp),sp

	;------------------------------------------------------------------------------------------
	;	Return value check
	;------------------------------------------------------------------------------------------

	bsr.s	cli::CheckParsingReturnValue

	;------------------------------------------------------------------------------------------
	;	Assemble the last source, on hold but not assembled yet
	;------------------------------------------------------------------------------------------

	move.l	CURRENT_SRC_FILENAME_PTR(fp),d0
	bne	assembly::AssembleBaseFile
	rts


;==================================================================================================
;
;	Command callbacks
;
;	These callbaks are called by Pdtlib while parsing the command line
;
;	input	d0.b	sign. May be #'+' or #'-'
;		a0	void*	 			Frame pointer
;
;	output	d0.w	PDTLIB_CONTINUE_PARSING		Pdtlib must continue the parsing of the CLI
;			PDTLIB_STOP_PARSING		Pdtlib must stop the parsing of the CLI
;
;	destroy	std
;
;==================================================================================================

;==================================================================================================
;
;	Display the version/about of as
;
;==================================================================================================

DisplayVersion:

	;------------------------------------------------------------------------------------------
	;	Print the help text
	;------------------------------------------------------------------------------------------

	pea	StrVersion(pc)			; Version text
	bsr	print::PrintToStdout		; Print it
	addq.l	#4,sp				; Pop text

	;------------------------------------------------------------------------------------------
	;	Remove command from cmdline and return
	;------------------------------------------------------------------------------------------

	bsr.s	RemoveCurrentArg		; Remove this command from the command line
	moveq	#PDTLIB_CONTINUE_PARSING,d0	; Return value
	rts


;==================================================================================================
;
;	Specify a config file
;
;==================================================================================================

SetConfigFile:

	;------------------------------------------------------------------------------------------
	;	Save the current frame pointer to set up the one given by Pdtlib
	;------------------------------------------------------------------------------------------

	pea	(fp)
	movea.l	a0,fp

	;------------------------------------------------------------------------------------------
	;	Get the next argument if one exists
	;------------------------------------------------------------------------------------------

	lea	CMDLINE(fp),a0			; CMDLINE*
	jsr	GET_NEXT_ARG(fp)
	move.l	a0,d0				; Is an arg available?
	beq	ErrorNoArgForConfig		; No...
		move.l	a0,CUSTOM_CONFIG_FILENAME_PTR(fp)
		movea.l	(sp)+,fp		; Restore fp
		movea.l	fp,a0			; RemoveCurrentArg needs fp in a0 too

	;------------------------------------------------------------------------------------------
	;	Remove command + filename from cmdline and return
	;------------------------------------------------------------------------------------------

	bsr.s	RemoveCurrentArg		; Remove filename
	movea.l	fp,a0				; Need fp in a0 once again
	bsr.s	RemoveCurrentArg		; Remove command
	moveq	#PDTLIB_CONTINUE_PARSING,d0	; Return value
	rts


;==================================================================================================
;
;	Enable/Disable the swap
;
;==================================================================================================

EnableSwap:

	;------------------------------------------------------------------------------------------
	;	Set the flag according to the sign
	;------------------------------------------------------------------------------------------

	moveq	#BIT_SWAP,d1			; Flag rank
	bsr	flags::SetFlag			; The sign is already in d0

	;------------------------------------------------------------------------------------------
	;	Print a warning message if the command enables the swap
	;------------------------------------------------------------------------------------------

	cmpi.b	#'+',d0
	bne.s	\NoWarning
		pea	StrSwapWarning(pc)
		bsr	print::PrintToStdout
		addq.l	#4,sp
\NoWarning:

	;------------------------------------------------------------------------------------------
	;	Remove command from cmdline and return
	;------------------------------------------------------------------------------------------

	bsr.s	RemoveCurrentArg		; Remove this command from the command line
	moveq	#PDTLIB_CONTINUE_PARSING,d0	; Return value
	rts


;==================================================================================================
;
;	Print a short help
;
;==================================================================================================

DisplayHelp:

	pea	StrHelp(pc)
	bsr	print::PrintToStdout
	addq.l	#4,sp

	;------------------------------------------------------------------------------------------
	;	Remove command from cmdline and return
	;------------------------------------------------------------------------------------------

	bsr.s	RemoveCurrentArg		; Remove this command from the command line
	moveq	#PDTLIB_CONTINUE_PARSING,d0	; Return value
	rts


;==================================================================================================
;
;	Display the default compilation flags of as
;
;==================================================================================================

DisplayFlags:

	nop

	;------------------------------------------------------------------------------------------
	;	Remove command from cmdline and return
	;------------------------------------------------------------------------------------------

	bsr.s	RemoveCurrentArg		; Remove this command from the command line
	moveq	#PDTLIB_CONTINUE_PARSING,d0	; Return value
	rts


;==================================================================================================
;
;	RemoveCurrentArg
;
;	Remove the current argument from the argv structure. Adjust argc
;
;	input	a0	frame pointer
;
;	output	d0 = 0 if there is no arg to remove (end of command line reached)
;
;	destroy	d0/a0
;
;==================================================================================================

RemoveCurrentArg:

	pea	(fp)
	movea.l	a0,fp
	lea	CMDLINE(fp),a0
	jsr	REMOVE_CURRENT_ARG(fp)
	movea.l	(sp)+,fp
	rts
