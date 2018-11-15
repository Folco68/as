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

config::ParseConfigFile

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
	;	The name has been created
	;------------------------------------------------------------------------------------------
\CustomConfigFile:
	movea.l	d0,a0
	jsr	GET_FILE_PTR(fp)			; Get a pointer to the file content
	move.l	a0,d1
	bne.s	\FileFound

	;------------------------------------------------------------------------------------------
	;	No file found
	;------------------------------------------------------------------------------------------
	tst.l	CUSTOM_CONFIG_FILENAME_PTR(fp)		; If a file was specified, we must have found one
	bne	ErrorConfigFileNotFound			; Else it's a fatal error

	move.l	d0,-(sp)				; Default file name ptr
	pea	StrNoDefaultConfigFile(pc)		; Warning message
	bsr	print::PrintToStdout
	addq.l	#8,sp
	rts

	;------------------------------------------------------------------------------------------
	;	A file was found, let's parse it
	;------------------------------------------------------------------------------------------
\FileFound:
\End:	rts
