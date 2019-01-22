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
	;	The name has been created, check if a file exists
	;------------------------------------------------------------------------------------------

\CustomConfigFile:
	movea.l	d0,a0
	jsr	GET_FILE_PTR(fp)			; Get a pointer to the file content
	move.l	a0,d1
	bne.s	\FileFound

		;------------------------------------------------------------------------------------------
		;	No file found. Fatal error if --config switch specified, else we just display a warning
		;------------------------------------------------------------------------------------------

		tst.l	CUSTOM_CONFIG_FILENAME_PTR(fp)	; If a file was specified, we must have found one
		bne	ErrorConfigFileNotFound		; Else it's a fatal error
		move.l	d0,-(sp)			; Default file name ptr
		pea	StrNoDefaultConfigFile(pc)	; Warning message
		bsr	print::PrintToStdout
		addq.l	#8,sp
		rts

	;------------------------------------------------------------------------------------------
	;	A file was found, let's parse it:
	;	- create a buffer and copy inside the strings correponding to the switches in the config files (removing spaces, empty lines, comments etc)
	;	- create a buffer with the argv* table
	;------------------------------------------------------------------------------------------

\FileFound:
	pea	(a2)					; a2 = file reader
	movea.l	d1,a2					; very first byte of the config file
	addq.l	#4,a2					; skip size + TIOS header

	lea	\ConfigBufferData(pc),a0		; Container header data
	lea	CONFIG_BUFFER_HD(fp),a1			; handle*
	bsr	container::Create			; Create the container

	lea	\ArgvBufferData(pc),a0
	lea	ARGV_BUFFER_HD(fp),a1
	bsr	container::Create

	;==========================================================================================
	;
	;	Parse the config file
	;
	;==========================================================================================

\LineLoop:
	addq.l	#1,a2					; Skip TIOS reserved char
\NextChar:
	move.b	(a2)+,d0				; Read a char

	;------------------------------------------------------------------------------------------
	;	Skip chars which must be ignored
	;------------------------------------------------------------------------------------------

	beq.s	\EndOfFileParsing			; EOF
	cmpi.b	#CONFIG_FILE_COMMENT,d0			; Comment
	beq.s	\SkipLine
	cmpi.b	#SPACE,d0				; Space
	beq.s	\NextChar
	cmpi.b	#HTAB,d0				; Horizontal tab
	beq.s	\NextChar
	cmpi.b	#EOL,d0					; EOL
	beq.s	\LineLoop

	;------------------------------------------------------------------------------------------
	;	Something found, add it to the buffer
	;------------------------------------------------------------------------------------------

	move.w	CONFIG_BUFFER_HD(fp),d0			; Handle
	movea.l	a2,a0					; String to add
	lea	StrConfigFileSeparator(pc),a1		; Separators which terminate a switch
	bsr	container::AddString
	adda.l	d0,a2					; Add the string size to a2
	addq.l	#1,a2					; Skip terminal 0
	bra.s	\NextChar				; And look for another switch

\EndOfFileParsing:

	;==========================================================================================
	;
	;	Parsing done, create the argv table
	;
	;==========================================================================================


	;------------------------------------------------------------------------------------------
	;	Add a first dummy entry to simulate the pointer to the program name in the argv table
	;------------------------------------------------------------------------------------------

	move.w	ARGV_BUFFER_HD(fp),d0			; Container handle
	suba.l	a1,a1					; Just to be sure that the pointer is valid
	bsr	container::AddEntry			; Add it

	;------------------------------------------------------------------------------------------
	;	Add a first dummy entry to simulate the pointer to the program name in the argv table
	;------------------------------------------------------------------------------------------

\AddArgvEntry:
	moveq.l	#0,d1					; Rank of the string we want in the config buffer
	move.w	CONFIG_BUFFER_HD(fp),d0			; Config buffer handle
	bsr	container::GetEntryPtr			; Get a pointer to the entry
	move.l	a0,d0					; The entry exists ?
	beq.s	\ArgvTableFilled			; No, nothing more to add
	pea	(a0)					; Else push data
	lea	(sp),a0					; Get a pointer to it
	move.w	ARGV_BUFFER_HD(fp),d0			; Get argv buffer handle
	bsr	container::AddEntry			; And add the pointer of the string
	addq.l	#4,sp					; Pop pointer
	bra.s	\AddArgvEntry				; And loop

\ArgvTableFilled:



					; At this moment, a2 points to a random character


	; browse the config buffer
	;	for (0; CfgBuffer.count() - 1;) {
	;		ArgvBuffer.addEntry(getEntryPtr(CfgBuffer));
	;	}


	;------------------------------------------------------------------------------------------
	;	To save memory, we don't wait program exit to free the buffers
	;------------------------------------------------------------------------------------------

	move.w	CONFIG_BUFFER_HD(fp),d0
	bsr	mem::Free				; Delete argv buffer
	clr.w	CONFIG_BUFFER_HD(fp)			; Prevent the buffer to be deleted on exit

	move.w	ARGV_BUFFER_HD(fp),d0
	bsr	mem::Free				; Delete config buffer
	clr.w	ARGV_BUFFER_HD(fp)			; Prevent the buffer to be deleted on exit

	movem.l	(sp)+,a2
\End:	rts

	;------------------------------------------------------------------------------------------
	;	Skip a line in the config file. a2 points just after the comment char
	;------------------------------------------------------------------------------------------

\SkipLine:
	move.b	(a2)+,d0				; Read next char
	beq.s	\EndOfFileParsing			; EOL => no next line
	cmpi.b	#EOL,d0					; EOL found?
	bne.s	\SkipLine				; No, parse next char
	bra	\LineLoop				; Else parse a new line


;==================================================================================================
;
;	Config buffer containers data
;
;==================================================================================================

\ConfigBufferData:
	dc.w	50		; 50 entries
	dc.w	1		; Of 1 byte (data are string)

\ArgvBufferData:
	dc.w	10		; 10 entries
	dc.w	4		; table of pointer
