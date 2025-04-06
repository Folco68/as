;==================================================================================================
;
;	External libraries names
;
;==================================================================================================

PdtlibFilename:		dc.b	"pdtlib",0	; Used to load pdtlib
LibcFilename:		dc.b	"pedrom",0	; Used to load the PedroM's libc


;==================================================================================================
;
;	Commands parsed in CLI
;
;==================================================================================================

CLICommands:	dc.b	"f","flags",0		; Display the flags with which as was compiled
		dc.b	"h","help",0		; Display a short help
		dc.b	"w","swap",0		; Allow swapping into flash
		dc.b	"v","version",0		; Disply version
		dc.b	0,"config",0		; Specify a config file to use
		dc.b	0,0			; End of table


;==================================================================================================
;
;	Flags parsed in CLI or in a config file
;
;==================================================================================================

CLIFlags:	dc.b	"s","strict",0		; Don't fix automatically wrong instructions
		dc.b	"x","xan",0		; Optimize x(an) into (an) if x = 0
		dc.b	0,0			; End of table


;==================================================================================================
;
;	Error messages
;
;==================================================================================================

StrErrorWrongOS:			dc.b	"as needs PedroM 0.83 or higher",0			; Boot failed
StrErrorInvalidSwitch:			dc.b	"Invalid switch: %s",EOL,0				; Invalid switch found un the CLI
StrErrorSwitchNotFound:			dc.b	"Switch not found: %s",EOL,0				; Switch not found in the CLI
StrErrorInvalidReturnValue:		dc.b	"Invalid return value: %d",EOL,0			; A CLI callback returned an invalid value
StrErrorStoppedByCallback:		dc.b	"The callback of %s stopped CLI parsing",EOL,0		; A callback switch requested CLI parsing to stop
StrErrorUnhandledPdtlibReturnValue:	dc.b	"Unhandled value returned by Pdtlib: %i",EOL,0		; Pdtlib returned an unknown value
StrErrorNoArgForConfig:			dc.b	"Switch 'config' needs a filename",EOL,0		; No argument for the --config switch
StrErrorConfigFilenameNotFound:		dc.b	"Config file '%s' not found",EOL,0			; The specified config file couldn't be found
StrErrorMemory:				dc.b	"Not enough memory",EOL,0				; Not enough memory to (re)alloc
StrErrorInvalidInConfigFile:		dc.b	"Invalid in config file: %s",EOL,0			; Something without +/- found in the config file
StrErrorFileNotFound:			dc.b	"File not found: %s",EOL,0				; A source file was not found (CLI or inclusion)
StrErrorInvalidSymbolName:		dc.b	"Invalid symbol name",EOL,0				; Invalid character found in a symbol


;==================================================================================================
;
;	Verbosity
;
;==================================================================================================

StrExit:		dc.b	"as exiting with code %i",EOL,0
StrVersion:		dc.b	"as v"
			include "version.h"
			dc.b	" by Martial Demolins AKA Folco",EOL
			dc.b	"License: GPL3",EOL
			dc.b	"Build: "
			include "info.h"
			dc.b	EOL,EOL,0
StrSwapWarning:		dc.b	"WARNING: using the swap intensively may damage your calculator",EOL,0
StrHelp:		dc.b	"Usage: as [commands/global opts] src1 [src1 opts] src2...",EOL
			dc.b	"Use commands/opts with -, --, + or ++",EOL
			dc.b	"v, version: print as version",EOL
			dc.b	"s, swap: use flash if RAM is exhausted",EOL
			dc.b	"f, flags: print default flags of as",EOL
			dc.b	"h, help: print this help",EOL
			dc.b	"config <file>: specify a custom config file",EOL,0
StrNoDefaultConfigFile:	dc.b	"Config file not found: %s",EOL,0
StrParsingConfigFile:	dc.b	"Parsing config file: %s",EOL,0
StrAssemblingFile:	dc.b	"Assembling file: %s",EOL,0
StrPrintBasefile:	dc.b	"In file %s (line %i)",EOL,0
StrPrintIncludedFile:	dc.b	"in included file %s (line %i)",EOL,0
StrPrintMacroFile:	dc.b	"in macro from file %s (line %i)",EOL,0
StrPrintMacroParamFile:	dc.b	"in macro parameter from file %s (line %i)",EOL,0


;==================================================================================================
;
;	String parsing
;
;==================================================================================================

StrConfigFileSeparator:	dc.b	SPACE,HTAB,CONFIG_FILE_COMMENT,EOL,0					; Separators after a switch in the config file
StrSymbolFirstChar:	dc.b	"AZ",0,"az",0,'_',0,':',0,'\',0,'@',0,0					; Symbol in asm source: ^[A-Za-z_:\@][A-Za-z0-9_:\@]
StrSymbolOtherChars:	dc.b	"AZ",0,"az",0,'_',0,':',0,'\',0,'@',0,"09",0,0				; Symbol in asm source: ^[A-Za-z_:\@][A-Za-z0-9_:\@]
