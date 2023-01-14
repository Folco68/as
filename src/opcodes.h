; kate: replace-tabs false; syntax M68k for Folco; tab-width 8;

; Observations
;
; reg src,reg dest	
;	src = 0-2, dest = 9-11	=> SOMETIMES INVERTED IF ONLY 1 ADDRESS METHOD! Use SRC_911 in such a case
;
; <ea>,reg or reg,<ea>
;	<ea> reg	bits 0-2
;	<ea> opmode	bits 3-5
;	reg		bits 9-11
;
; #imm
;	.b	lower byte of next word
;	.w	next word
;	.l	next longword

;==================================================================================================
;
;	INSTRUCTION
;
;	Macro describing the name of an instruction, and the opcode position related to
;
;==================================================================================================

INSTRUCTION	macro
	dc.b	\1	; Name (up to 7 bytes)
	ds.b	\2	; Padding to 8 bytes
	dc.w	\3	; Offset of the first possible opcode in the opcode table
	endm


;==================================================================================================
;
;	Property field of the OPCODE macro
;
;	This is a 32 bits value describing the address methods, sizes and other properties
;	of each opcode
;
;==================================================================================================

	;------------------------------------------------------------------------------------------
	;	Source address method
	;------------------------------------------------------------------------------------------

SRC_DN			equ	1<<0	; dn
SRC_AN			equ	1<<1	; an
SRC_XAN			equ	1<<2	; x(an)
SRC_AN_INC		equ	1<<3	; (an)+
SRC_AN_DEC		equ	1<<4	; -(an)
SRC_IMM			equ	1<<5	; #imm
SRC_IND_X_PC		equ	1<<6	; (an),x(an),x(an,yn),x(pc),x(pc,yn),x16,x32
SRC_SR			equ	1<<7	; SR			|
SRC_CCR			equ	2<<7	; CCR			|
SRC_USP			equ	3<<7	; move USP,an		|
SRC_REG_LIST		equ	4<<7	; dx-dx'/ay-ay'		| All these address methods are exclusive, so they can be compacted in 3 bits
SRC_0_15		equ	5<<7	; trap			|
SRC_1_8			equ	6<<7	; addq/asx/rox/roxx	|
SRC_128_127		equ	7<<7	; moveq			|

SRC_MEM			equ	SRC_AN_INC+SRC_AN_DEC+SRC_IND_X_PC
SRC_ALL			equ	SRC_DN+SRC_AN+SRC_MEM+SRC_IMM

	;------------------------------------------------------------------------------------------
	;	Destination address method
	;------------------------------------------------------------------------------------------

DEST_DN			equ	1<<10	; dn
DEST_AN			equ	1<<11	; an
DEST_XAN		equ	1<<12	; x(an)
DEST_AN_INC		equ	1<<13	; (an)+
DEST_AN_DEC		equ	1<<14	; -(an)
DEST_IND_X		equ	1<<15	; (an),x(an),x(an,yn),x16,x32
DEST_PC			equ	1<<16	; x(pc),x(pc,yn)
DEST_SR			equ	1<<17	; SR		|			
DEST_CCR		equ	2<<17	; CCR		|
DEST_USP		equ	3<<17	; move	an,USP	|
DEST_REG_LIST		equ	4<<17	; dx-dx'/ay-ay'	| All these address methods are exclusive, so they can be compacted in 3 bits
DEST_DISP_BW		equ	5<<17	; bcc/bsr/bra	|
DEST_DISP_W		equ	6<<17	; dbcc		|
DEST_DISP_IMM		equ	7<<17	; link		|

DEST_MEM		equ	DEST_AN_INC+DEST_AN_DEC+DEST_IND_X

	;------------------------------------------------------------------------------------------
	;	Operand size
	;
	;	Some instructions support only one size, so they don't need a size specification
	;	in the opcode. In such a case, a size specification in the source code is toletared,
	;	even if it is useless
	;
	;	Sometimes, the instruction supports several sizes, but the assembler chose the right
	;	one by itself (Bcc family). These opcodes are flagged with SIZE_OPTIONAL.
	;------------------------------------------------------------------------------------------

SIZE_B			equ	1<<20
SIZE_W			equ	1<<21
SIZE_L			equ	1<<22
SIZE_OPTIONAL		equ	1<<23	; Size specification is allowed, but not mandatory (bcc/bsr/bra)
SIZE_67			equ	1<<24	; Size in bits 6 & 7	|
SIZE_6			equ	1<<25	; Size in bit 6		|	
SIZE_8			equ	1<<26	; Size in bit 8		| Can be compacted if needed
SIZE_1213		equ	1<<27	; Size in bits 12 & 13	|

SIZE_BW			equ	SIZE_B+SIZE_W
SIZE_WL			equ	SIZE_W+SIZE_L
SIZE_BWL		equ	SIZE_B+SIZE_W+SIZE_L

SIZE_B67		equ	SIZE_B+SIZE_67
SIZE_WL6		equ	SIZE_WL+SIZE_6
SIZE_WL67		equ	SIZE_WL+SIZE_67
SIZE_BWL67		equ	SIZE_BWL+SIZE_67

	;------------------------------------------------------------------------------------------
	;	Fallback
	;------------------------------------------------------------------------------------------

PERMISSIVE_FALLBACK	equ	1<<28	; Fallback allowed if --strict not specified (move -> movea, etc)
STRICT_FALLBACK		equ	1<<29	; Fallback always allowed (several address methods for the same instruction

	;------------------------------------------------------------------------------------------
	;	Operand position
	;------------------------------------------------------------------------------------------

SRC_911			equ	1<<30	; Source coded on bits 9-11 instead of usual 0-2


;==================================================================================================
;
;	OPCODE and FALLBACK
;
;	These macros define an opcode.
;	An opcode is defined with a word, and completed by a 32 bits field contaning its properties
;
;==================================================================================================


OPCODE		macro
\1	dc.w	\2	; Opcode
	dc.l	\3	; Properties
	endm

FALLBACK	macro
	dc.w	\1	; Opcode
	dc.l	\2	; Properties
	endm
