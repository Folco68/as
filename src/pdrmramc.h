; kate: replace-tabs false; syntax M68k for Folco; tab-width 8;

;==================================================================================================
;
;	PedroM's custom header, allowing libc calls through LibsCall/LibsExec;
;	See Library.asm of PedroM for more details
;
;==================================================================================================

PEDROM_RAMDATATABLE	equ	$00
PEDROM_RUNMAINFUNCTION	equ	$01
PEDROM_HEAPREALLOC	equ	$02
PEDROM_HEAPMAX		equ	$03
PEDROM_PRINTF		equ	$04
PEDROM_VCBPRINTF	equ	$05
PEDROM_CLRSCR		equ	$06
PEDROM_FCLOSE		equ	$07
PEDROM_FREOPEN		equ	$08
PEDROM_FOPEN		equ	$09
PEDROM_FSEEK		equ	$0A
PEDROM_FTELL		equ	$0B
PEDROM_FEOF		equ	$0C
PEDROM_FPUTC		equ	$0D
PEDROM_FPUTS		equ	$0E
PEDROM_FWRITE		equ	$0F
PEDROM_FGETC		equ	$10
PEDROM_FREAD		equ	$11
PEDROM_FGETS		equ	$12
PEDROM_UNGETC		equ	$13
PEDROM_FFLUSH		equ	$14
PEDROM_CLEARERR		equ	$15
PEDROM_FERROR		equ	$16
PEDROM_REWIND		equ	$17
PEDROM_FPRINTF		equ	$18
PEDROM_TMPNAM		equ	$19
PEDROM_DIALOG.DO	equ	$1A
PEDROM_QSORT		equ	$1B
PEDROM_PID_SWITCH	equ	$1C
PEDROM__TT_DECOMPRESS	equ	$1D
PEDROM_BSEARCH		equ	$1E
PEDROM_UNLINK		equ	$1F
PEDROM_RENAME		equ	$20
PEDROM_ATOI		equ	$21
PEDROM_KBD_QUEUE	equ	$22
PEDROM_RAND		equ	$23
PEDROM_SRAND		equ	$24
PEDROM_CALLOC		equ	$25
PEDROM_REALLOC		equ	$26
PEDROM_ATOF		equ	$27
PEDROM__SPUTC		equ	$28
PEDROM_PERROR		equ	$29
PEDROM_GETENV		equ	$2A
PEDROM_SYSTEM		equ	$2B
PEDROM_SETVBUF		equ	$2C
PEDROM_KERNEL__EXIT	equ	$2D
PEDROM_KERNEL__ATEXIT	equ	$2E

;==================================================================================================
;
;	RAM data table
;
;==================================================================================================

PEDROM_stdin		equ	0
PEDROM_stdout		equ	4
PEDROM_stderr		equ	8
PEDROM_ARGC		equ	12
PEDROM_ARGV		equ	16
PEDROM_errno		equ	20
PEDROM_TextFont46	equ	24
