; kate: indent-width 8; replace-tabs false; syntax Motorola 68k (VASM/Devpac); tab-width 8;

;==================================================================================================
;	RAM call macro. Call a ramcall through the F-Line handler
;==================================================================================================

RAMC	macro
	dc.w	$F000+\1
	endm

;==================================================================================================
;	RAM calls
;==================================================================================================

kernel_CALCULATOR		equ	$0000
kernel_LCD_WIDTH		equ	$0001
kernel_LCD_HEIGHT		equ	$0002
kernel_ROM_base			equ	$0003
kernel_LCD_LINE_BYTES		equ	$0004
kernel_KEY_LEFT			equ	$0005
kernel_KEY_RIGHT		equ	$0006
kernel_KEY_UP			equ	$0007
kernel_KEY_DOWN			equ	$0008
kernel_KEY_UPRIGHT		equ	$0009
kernel_KEY_DOWNLEFT		equ	$000A
kernel_KEY_DIAMOND		equ	$000B
kernel_LCD_SIZE			equ	$000C
kernel_KEY_SHIFT		equ	$000D
kernel_font_medium		equ	$000E
kernel_ReturnValue		equ	$000F
kernel_kb_globals		equ	$0010
kernel_Heap			equ	$0011
kernel_FolderListHandle		equ	$0012
kernel_MainHandle		equ	$0013
kernel_ROM_VERSION		equ	$0014
kernel_Idle			equ	$0015
kernel_Exec			equ	$0016
kernel_Ptr2Hd			equ	$0017
kernel_Hd2Sym			equ	$0018
kernel_LibsBegin		equ	$0019
kernel_LibsEnd			equ	$001A
kernel_LibsCall			equ	$001B
kernel_LibsPtr			equ	$001C
kernel_LibsExec			equ	$001D
kernel_HdKeep			equ	$001E
kernel_ExtractFromPack		equ	$001F
kernel_ExtractFile		equ	$0020
kernel_LCD_MEM 			equ 	$0021
kernel_font_small		equ	$0022
kernel_font_large		equ	$0023
kernel_SYM_ENTRY.name		equ	$0024
kernel_SYM_ENTRY.compat		equ	$0025
kernel_SYM_ENTRY.flags		equ	$0026
kernel_SYM_ENTRY.hVal		equ	$0027
kernel_SYM_ENTRY.sizeof		equ	$0028
kernel_ExtractFileFromPack	equ	$0029
kernel_exit			equ	$002A
kernel_atexit			equ	$002B
kernel_RegisterVector		equ	$002C
kernel_GHOST_SPACE		equ	$002D
kernel_KERNEL_SPACE		equ	$002E
kernel_SystemDir		equ	$002F
