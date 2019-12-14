; kate: indent-width 8; replace-tabs false; syntax Motorola 68k (VASM/Devpac); tab-width 8;

;==================================================================================================
;
;	ParseConfigFile
;
;	Parse a configuration file
;	- if one is specified in the command line, finding it is mandatory
;	- if non is specified, try to read the default one if it exists, but finding one is not mandatory
;
;	The default name is <kernel_SystemDir>\<program name>
;
;	input	a6	frame pointer
;
;	output	nothing
;
;	destroy	std
;
;==================================================================================================

config::ParseConfigFile:

	;------------------------------------------------------------------------------------------
	;	Copy the custom filename in the buffer if one is specified
	;------------------------------------------------------------------------------------------
	move.l	CUSTOM_CONFIG_FILENAME_PTR(fp),d0		; Check if we have to use the default filename
	bne.s	\CustomConfigFile

	;------------------------------------------------------------------------------------------
	;	No custom filename specified, create the default one
	;------------------------------------------------------------------------------------------

	RAMC	kernel_SystemDir			; Get a pointer to the system directory name
	lea	DEFAULT_CONFIG_FILENAME_BUFFER(fp),a1	; Buffer of the default filename
\SysDir:
	move.b	(a0)+,(a1)+				; Copy the system directory in the buffer
	bne.s	\SysDir
	move.b	#'\',-1(a1)				; Override the terminal 0 with the path separator
	movea.l	ARGV(fp),a0				; **Program name
	movea.l	(a0),a0					; *Program name
\ProgName:
	move.b	(a0)+,(a1)+				; Copy the program name
	bne.s	\ProgName
	lea	DEFAULT_CONFIG_FILENAME_BUFFER(fp),a0	; Retrieve the beginning of the buffer
	move.l	a0,d0

	;------------------------------------------------------------------------------------------
	;	The name has been created, check if a text file exists
	;------------------------------------------------------------------------------------------

\CustomConfigFile:
	pea	(a3)					; Save regs
	pea	(a2)
	movea.l	d0,a2					; a2 = filename ptr
	movea.l	sp,a3					; Save sp to restore it after file parsing
	
	movea.l	d0,a0					; Arg of pdtlib::CheckFileType
	moveq.l	#$FFFFFFE0,d2				; We look for a text
	jsr	CHECK_FILE_TYPE(fp)
	tst.w	d0
	beq.s	\FileFound

		;------------------------------------------------------------------------------------------
		;	No file found or wrong file type
		;	Fatal error if --config switch specified, else we just display a warning
		;------------------------------------------------------------------------------------------

		tst.l	CUSTOM_CONFIG_FILENAME_PTR(fp)	; If a file was specified, we must have found one
		bne	ErrorConfigFileNotFound		; Else it's a fatal error
		pea	DEFAULT_CONFIG_FILENAME_BUFFER(fp)
		pea	StrNoDefaultConfigFile(pc)	; Warning message
		bsr	print::PrintToStdout
		bra	\End

	;==========================================================================================
	;
	;	Prepare the file for parsing. We will use pdtlib::ParseCmdline to proceed.
	;	- copy file content in a frame buffer
	;	- put a null byte after each entry to emulate command line data format
	;	- create the argv table, below the previous frame buffer
	;	- create a CMDLINE structure below the argv table
	;	- finally, call pdtlib::ParseCmdline
	;
	;==========================================================================================

\FileFound:

	;------------------------------------------------------------------------------------------
	;	Print a message saying that the config file is going to be parsed
	;------------------------------------------------------------------------------------------

	pea	(a2)
	pea	StrParsingConfigFile(pc)
	bsr	print::PrintToStdout

	;------------------------------------------------------------------------------------------
	;	Initialize the reader of the file
	;------------------------------------------------------------------------------------------

	movea.l	a2,a0					; Filename
	jsr	GET_FILE_PTR(fp)			; Get a ptr to data file
	moveq.l	#0,d0					; Clear d0 (for config files > 32767 bytes! :D)
	move.w	(a0),d0					; Read file size
	suba.l	d0,sp					; Create a buffer to put the args parsed in the file
	movea.l	sp,a2					; First byte of the buffer
	addq.l	#4,a0					; Skip size + TIOS header
	moveq.l	#1,d1					; argc. Initialized with 1 to emulate program name entry

	;------------------------------------------------------------------------------------------
	;	File parsing and copying
	;------------------------------------------------------------------------------------------

\NextLine:
	addq.l	#1,a0					; Start a line

	;------------------------------------------------------------------------------------------
	;	Discard blank spaces, empty lines and comments
	;------------------------------------------------------------------------------------------
	
\NextCharNoArg:
	moveq.l	#1,d2					; Increment of argc when an arg is found
\NextChar:	
	move.b	(a0)+,d0				; Read a char
	beq.s	\EndOfParsing				; EOF
	cmpi.b	#CONFIG_FILE_COMMENT,d0			; Comment
	bne.s	\NoComment
	
\Comment:	move.b	(a0)+,d0			; Skip comment
		beq.s	\EndOfParsing
		cmpi.b	#EOL,d0
		bne.s	\Comment
		bra.s	\NextLine
		
\NoComment:
	cmpi.b	#EOL,d0					; EOL
	beq.s	\NextLine
	cmpi.b	#SPACE,d0				; Space
	beq.s	\NextCharNoArg
	cmpi.b	#HTAB,d0				; Horizontal tab
	beq.s	\NextCharNoArg

	;------------------------------------------------------------------------------------------
	;	Something that should be an arg found, copy it in the buffer
	;------------------------------------------------------------------------------------------
	
	add.l	d2,d1					; Update argc
	adda.l	d2,a2					; Update a2 to avoid overwriting the terminating byte of the previous arg
							; !!! WARNING !!! This makes that the first byte of the buffer contains garbage, and musn't be used
	moveq.l	#0,d2					; Won't update argc and a2 when parsing next char
	move.b	d0,(a2)+				; Copy current char in the buffer
	clr.b	(a2)					; Terminating null byte if there is no more char to copy
	bra.s	\NextChar

	;------------------------------------------------------------------------------------------
	;	Parsing terminated
	;	Prepare the frame buffer of the argv table
	;------------------------------------------------------------------------------------------

\EndOfParsing:
	lea	1(sp),a2				; a2 = first significant byte of the buffer. One is skipped due to the above warning
	move.w	d1,d2					; d2 = argc
	add.w	d1,d1					; d1 = argc * 4 = size of argv table
	add.w	d1,d1
	suba.l	d1,sp
	movea.l	sp,a4					; a4 = argv**
	lea	4(a4),a0				; argv[1]*: first arg

	move.w	d2,d0					; argc
	subq.l	#2,d0					; Counter to build the argv table: remove 1 for program name + 1 for counter
	bmi.s	\NoArg					; Don't try to loop with counter < 0...
	
	;------------------------------------------------------------------------------------------
	;	Write the argv table
	;------------------------------------------------------------------------------------------

\ArgvLoop:
	move.l	a2,(a0)+				; Write argv[x]
\SkipArg:
	tst.b	(a2)+					; Skip current arg
	bne.s	\SkipArg
	dbf.w	d0,\ArgvLoop				; Until the end of the table
\NoArg:

	;------------------------------------------------------------------------------------------
	;	Prepare the "command line" parsing
	;------------------------------------------------------------------------------------------

	lea	CMDLINE(fp),a0
	movea.l	a4,a1					; argv**
	move.w	d2,d0					; argc
	jsr	INIT_CMDLINE(fp)
		
	;------------------------------------------------------------------------------------------
	;	Parse it and check return value
	;------------------------------------------------------------------------------------------

	pea	flags::FlagXan(pc)
	pea	flags::FlagStrict(pc)
	pea	ErrorInvalidInConfigFile(pc)		; Error handler if an arg without +/- is found
	pea	CLIFlags(pc)				; Switch table
	pea	(fp)					; data*
	pea	CMDLINE(fp)				; CMDLINE*
	jsr	PARSE_CMDLINE(fp)	
	bsr	cli::CheckParsingReturnValue

	;------------------------------------------------------------------------------------------
	;	Restore stack and registers
	;------------------------------------------------------------------------------------------

\End:	movea.l	a3,sp					; Restore stack pointer
	movea.l	(sp)+,a3				; Restore registers
	movea.l	(sp)+,a2
	rts
