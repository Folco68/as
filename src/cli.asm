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
	pea	StopParsing(pc)			; Commands are located before the first filename, stop parsing when finding one
	pea	CLICommands(pc)			; String table of commands
	pea	(fp)				; (void*)data passed to the callbacks
	pea	CLI_CMDLINE(fp)			; CMDLINE*
\ParseCommands:
	jsr	PARSE_CMDLINE(fp)

	;------------------------------------------------------------------------------------------
	;	Special handling of the SwitchNotFound error during the first pass:
	;	we just ignore unknown switches, they will be parsed during the second pass
	;------------------------------------------------------------------------------------------

	cmpi.w	#PDTLIB_SWITCH_NOT_FOUND,d0
	bne.s	\NoSNF
		lea	CLI_CMDLINE(fp),a0
		jsr	GET_NEXT_ARG(fp)
		bra.s	\ParseCommands
\NoSNF:	lea	9*4(sp),sp			; Pop args of pdtlib::ParseCmdline

	;------------------------------------------------------------------------------------------
	;
	;	!!! WARNING !!!
	;
	;	This code is used to handle the return value of the first pass,
	;	of the config file parsing, and of the second pass
	;
	;------------------------------------------------------------------------------------------

cli::CheckParsingReturnValue:

	;------------------------------------------------------------------------------------------
	;	Return if all was fine
	;------------------------------------------------------------------------------------------

	cmpi.w	#PDTLIB_END_OF_PARSING,d0
	beq.s	Rts
	cmpi.w	#PDTLIB_STOPPED_BY_CALLBACK,d0
	beq.s	Rts

	;------------------------------------------------------------------------------------------
	;	Prepare the guilty switch for fprintf
	;------------------------------------------------------------------------------------------

	move.w	d0,d1				; Save the pdtlib::ParseCmdline return value
	movea.l	CURRENT_CMDLINE(fp),a0
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

	bra	ErrorUnhandledPdtlibReturnValue	; Catchall: any other value is unknown (Pdtlib internal bug)


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
	pea	CLI_CMDLINE(fp)
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
Rts:	rts


;==================================================================================================
;
;	Command callbacks
;
;	These callbaks are called by Pdtlib while parsing the command line
;
;	input	d0.b	sign	May be #'+' or #'-'
;		a0	void*	Frame pointer
;
;	output	d0.w	PDTLIB_CONTINUE_PARSING		Pdtlib must continue the parsing of the CLI
;			PDTLIB_STOP_PARSING		Pdtlib must stop the parsing of the CLI
;
;	destroy	std
;
;==================================================================================================

;==================================================================================================
;
;	Stop parsing
;
;	While commands are located before the first filename, we stop the parsing when finding one
;
;==================================================================================================

StopParsing:
	moveq	#PDTLIB_STOP_PARSING,d0
	rts


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
	bra.s	DisableCurrentArg		; Remove command from cmdline and return


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
	;	Disable the command and check that another argument exists 
	;------------------------------------------------------------------------------------------

	bsr	DisableCurrentArg
	lea	CLI_CMDLINE(fp),a0
	jsr	GET_NEXT_ARG(fp)
	move.l	a0,d0					; Is an arg available?
	beq	ErrorNoArgForConfig			; No...
		move.l	a0,CUSTOM_CONFIG_FILENAME_PTR(fp)
		movea.l	fp,a0				; DisableCurrentArg needs fp in a0 too
		movea.l	(sp)+,fp			; Restore fp
		bra.s	DisableCurrentArg		; Remove command from cmdline and return


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
	bra.s	DisableCurrentArg		; Remove command from cmdline and return


;==================================================================================================
;
;	Print a short help
;
;==================================================================================================

DisplayHelp:

	pea	StrHelp(pc)
	bsr	print::PrintToStdout
	addq.l	#4,sp
	bra.s	DisableCurrentArg		; Remove command from cmdline and return


;==================================================================================================
;
;	Display the default compilation flags of as
;
;==================================================================================================

DisplayFlags:

	nop
;	bra.s	DisableCurrentArg		; Remove command from cmdline and return


;==================================================================================================
;
;	DisableCurrentArg
;
;	Disable the current argument from the argv structure and return to pdtlib::ParseCmdline
;
;	input	a0	frame pointer
;
;	output	d0 = PDTLIB_CONTINUE_PARSING
;
;	destroy	d0/a0-a1
;
;==================================================================================================

DisableCurrentArg:

	lea	DISABLE_CURRENT_ARG(a0),a1
	lea	CLI_CMDLINE(a0),a0		
	jsr	(a1)
	moveq	#PDTLIB_CONTINUE_PARSING,d0	; Commands return value
	rts
