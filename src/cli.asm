; kate: indent-width 8; replace-tabs false; syntax Motorola 68k (VASM/Devpac); tab-width 8;

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

	cmpi.w	#PDTLIB_STOPPED_BY_CALLBACK,d1	; A callback stopped the parsing. It must never happen
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
;		a0	(void*)
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

	pea	(fp)				; Save frame pointer
	movea.l	a0,fp				; Set the new one
	pea	StrVersion(pc)			; Version text
	bsr	print::PrintToStdout		; Print it
	addq.l	#4,sp				; Pop text
	bsr	RemoveCurrentArg		; Remove this command from the command line
	movea.l	(sp)+,fp			; Restore frame pointer
	moveq.l	#PDTLIB_CONTINUE_PARSING,d0	; Return value
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
	bsr	RemoveCurrentArg		; Remove this command from the command line

	;------------------------------------------------------------------------------------------
	;	Get the next argument if one exists
	;------------------------------------------------------------------------------------------

	lea	CMDLINE(fp),a0			; CMDLINE*
	jsr	GET_NEXT_ARG(fp)
	move.l	a0,d0				; Is an arg available?
	beq	ErrorNoArgForConfig		; No...

	;------------------------------------------------------------------------------------------
	;	Save the pointer of the filename, without additional check
	;------------------------------------------------------------------------------------------
	
	bsr	RemoveCurrentArg		; Remove this command from the command line
	move.l	a0,CUSTOM_CONFIG_FILENAME_PTR(fp)
	moveq.l	#PDTLIB_CONTINUE_PARSING,d0	; Return value
\Error:	movea.l	(sp)+,fp			; Restore org frame pointer
	rts


;==================================================================================================
;
;	Enable/Disable the swap
;
;==================================================================================================

EnableSwap:

	;------------------------------------------------------------------------------------------
	;	Save the current frame pointer to set up the one given by Pdtlib
	;------------------------------------------------------------------------------------------

	pea	(fp)
	movea.l	a0,fp

	;------------------------------------------------------------------------------------------
	;	Set the flag according to the sign
	;------------------------------------------------------------------------------------------

	moveq.l	#BIT_SWAP,d1			; Flag rank
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
	;	Restore a6, set the return value and quit
	;------------------------------------------------------------------------------------------

	bsr	RemoveCurrentArg		; Remove this command from the command line
	movea.l	(sp)+,fp
	moveq.l	#PDTLIB_CONTINUE_PARSING,d0	; Return value
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
	bsr	RemoveCurrentArg		; Remove this command from the command line
	moveq.l	#PDTLIB_CONTINUE_PARSING,d0	; Return value
	rts


;==================================================================================================
;
;	Display the default compilation flags of as
;
;==================================================================================================

DisplayFlags:

	bsr	RemoveCurrentArg		; Remove this command from the command line
	moveq.l	#PDTLIB_CONTINUE_PARSING,d0	; Return value
	rts


;==================================================================================================
;
;	RemoveCurrentArg
;
;	Remove the current argument from the argv structure. Adjust argc
;
;	input	fp	frame pointer
;
;	output	d0 = 0 if there is no arg to remove (end of command line reached)
;
;	destroy	d0/a
;
;==================================================================================================

RemoveCurrentArg:

	lea	CMDLINE(fp),a0
	jsr	REMOVE_CURRENT_ARG(fp)
	subq.w	#1,ARGC(fp)
	rts
