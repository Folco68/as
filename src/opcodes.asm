;==================================================================================================
;
;	Instruction table
;
;	The instruction are 0 terminated and padded to 8 bytes.
;	The two next bytes are the offset of the opcode in the opcode table
;
;==================================================================================================

InstructionTable:

	INSTRUCTION	"abcd",4,OpcodeAbcd
	INSTRUCTION	"add",5,OpcodeAdd
	INSTRUCTION	"adda",4,OpcodeAdda
	INSTRUCTION	"addi",4,OpcodeAddi
	INSTRUCTION	"addq",4,OpcodeAddq
	INSTRUCTION	"addx",4,OpcodeAddx
	INSTRUCTION	"and",5,OpcodeAnd
	INSTRUCTION	"andi",4,OpcodeAndi
	INSTRUCTION	"asl",5,OpcodeAsl
	INSTRUCTION	"asr",5,OpcodeAsr
	INSTRUCTION	"bcc",5,OpcodeBcc
	INSTRUCTION	"bchg",4,OpcodeBchg
	INSTRUCTION	"bclr",4,OpcodeBclr
	INSTRUCTION	"bcs",5,OpcodeBcs
	INSTRUCTION	"beq",5,OpcodeBeq
	INSTRUCTION	"bge",5,OpcodeBge
	INSTRUCTION	"bgt",5,OpcodeBgt
	INSTRUCTION	"bhi",5,OpcodeBhi
	INSTRUCTION	"ble",5,OpcodeBle
	INSTRUCTION	"bls",5,OpcodeBls
	INSTRUCTION	"blt",5,OpcodeBlt
	INSTRUCTION	"bmi",5,OpcodeBmi
	INSTRUCTION	"bne",5,OpcodeBne
	INSTRUCTION	"bpl",5,OpcodeBpl
	INSTRUCTION	"bset",4,OpcodeBset
	INSTRUCTION	"bsr",5,OpcodeBsr
	INSTRUCTION	"bra",5,OpcodeBra
	INSTRUCTION	"btst",4,OpcodeBtst
	INSTRUCTION	"bvc",5,OpcodeBvc
	INSTRUCTION	"bvs",5,OpcodeBvs
	INSTRUCTION	"chk",5,OpcodeChk
	INSTRUCTION	"clr",5,OpcodeClr
	INSTRUCTION	"cmp",5,OpcodeCmp
	INSTRUCTION	"cmpa",4,OpcodeCmpa
	INSTRUCTION	"cmpi",4,OpcodeCmpi
	INSTRUCTION	"cmpm",4,OpcodeCmpm
	INSTRUCTION	"dbcc",4,OpcodeDbcc
	INSTRUCTION	"dbcs",4,OpcodeDbcs
	INSTRUCTION	"dbeq",4,OpcodeDbeq
	INSTRUCTION	"dbf",5,OpcodeDbf
	INSTRUCTION	"dbge",4,OpcodeDbge
	INSTRUCTION	"dbgt",4,OpcodeDbgt
	INSTRUCTION	"dbhi",4,OpcodeDbhi
	INSTRUCTION	"dble",4,OpcodeDble
	INSTRUCTION	"dbls",4,OpcodeDbls
	INSTRUCTION	"dblt",4,OpcodeDblt
	INSTRUCTION	"dbmi",4,OpcodeDbmi
	INSTRUCTION	"dbne",4,OpcodeDbne
	INSTRUCTION	"dbpl",4,OpcodeDbpl
	INSTRUCTION	"dbra",4,OpcodeDbf	; Aliased to dbf
	INSTRUCTION	"dbvc",4,OpcodeDbvc
	INSTRUCTION	"dbvs",4,OpcodeDbvs
	INSTRUCTION	"divs",4,OpcodeDivs
	INSTRUCTION	"divu",4,OpcodeDivu
	INSTRUCTION	"eor",5,OpcodeEor
	INSTRUCTION	"eori",4,OpcodeEori
	INSTRUCTION	"exg",5,OpcodeExg
	INSTRUCTION	"ext",5,OpcodeExt
	INSTRUCTION	"illegal",1,OpcodeIllegal
	INSTRUCTION	"jsr",5,OpcodeJsr
	INSTRUCTION	"jmp",5,OpcodeJmp
	INSTRUCTION	"lea",5,OpcodeLea
	INSTRUCTION	"link",4,OpcodeLink
	INSTRUCTION	"lsl",5,OpcodeLsl
	INSTRUCTION	"lsr",5,OpcodeLsr
	INSTRUCTION	"move",4,OpcodeMove
	INSTRUCTION	"movea",3,OpcodeMovea
	INSTRUCTION	"movem",3,OpcodeMovem
	INSTRUCTION	"movep",3,OpcodeMovep
	INSTRUCTION	"moveq",3,OpcodeMoveq
	INSTRUCTION	"muls",4,OpcodeMuls
	INSTRUCTION	"mulu",4,OpcodeMulu
	INSTRUCTION	"nbcd",4,OpcodeNbcd
	INSTRUCTION	"neg",5,OpcodeNeg
	INSTRUCTION	"negx",4,OpcodeNegx
	INSTRUCTION	"nop",5,OpcodeNop
	INSTRUCTION	"not",5,OpcodeNot
	INSTRUCTION	"or",6,OpcodeOr
	INSTRUCTION	"ori",5,OpcodeOri
	INSTRUCTION	"pea",5,OpcodePea
	INSTRUCTION	"reset",3,OpcodeReset
	INSTRUCTION	"rol",5,OpcodeRol
	INSTRUCTION	"ror",5,OpcodeRor
	INSTRUCTION	"roxl",4,OpcodeRoxl
	INSTRUCTION	"roxr",4,OpcodeRoxr
	INSTRUCTION	"rte",5,OpcodeRte
	INSTRUCTION	"rtr",5,OpcodeRtr
	INSTRUCTION	"rts",5,OpcodeRts
	INSTRUCTION	"sbcd",4,OpcodeSbcd
	INSTRUCTION	"scc",5,OpcodeScc
	INSTRUCTION	"scs",5,OpcodeScs
	INSTRUCTION	"seq",5,OpcodeSeq
	INSTRUCTION	"sf",6,OpcodeSf
	INSTRUCTION	"sge",5,OpcodeSge
	INSTRUCTION	"sgt",5,OpcodeSgt
	INSTRUCTION	"shi",5,OpcodeShi
	INSTRUCTION	"sle",5,OpcodeSle
	INSTRUCTION	"sls",5,OpcodeSls
	INSTRUCTION	"slt",5,OpcodeSlt
	INSTRUCTION	"smi",5,OpcodeSmi
	INSTRUCTION	"sne",5,OpcodeSne
	INSTRUCTION	"spl",5,OpcodeSpl
	INSTRUCTION	"st",6,OpcodeSt
	INSTRUCTION	"stop",4,OpcodeStop
	INSTRUCTION	"sub",5,OpcodeSub
	INSTRUCTION	"suba",4,OpcodeSuba
	INSTRUCTION	"subi",4,OpcodeSubi
	INSTRUCTION	"subq",4,OpcodeSubq
	INSTRUCTION	"subx",4,OpcodeSubx
	INSTRUCTION	"svc",5,OpcodeSvc
	INSTRUCTION	"svs",5,OpcodeSvs
	INSTRUCTION	"swap",4,OpcodeSwap
	INSTRUCTION	"tas",5,OpcodeTas
	INSTRUCTION	"trap",4,OpcodeTrap
	INSTRUCTION	"trapv",3,OpcodeTrapv
	INSTRUCTION	"tst",5,OpcodeTst
	INSTRUCTION	"unlk",4,OpcodeUnlk
InstructionTableEnd:

;==================================================================================================
;
;	Opcode table
;
;	The opcode describe each instruction. One instruction may have several opcodes depending
;	on the addressing methods allowed by Motorola
;
;==================================================================================================

OpcodeTable:

	OPCODE		OpcodeAbcd,$C100,SRC_DN+DEST_DN+SIZE_B+STRICT_FALLBACK				; abcd(.b)	dx,dy
	FALLBACK	$C108,SRC_AN_DEC+DEST_AN_DEC+SIZE_B						; abcd(.b)	-(ax),-(ay)

	OPCODE		OpcodeAdd,$D000,SRC_ALL-SRC_AN+SIZE_B67+STRICT_FALLBACK				; add.b		<ea>,dn (with <ea> != an)
	FALLBACK	$D000,SRC_ALL+DEST_DN+SIZE_WL67+STRICT_FALLBACK					; add.wl	<ea>,dn
	FALLBACK	$D100,SRC_DN+DEST_MEM+SIZE_BWL67+PERMISSIVE_FALLBACK				; add.bwl	dn,<ea>

	OPCODE		OpcodeAdda,$D0C0,SRC_ALL+DEST_AN+SIZE_WL+SIZE_8+PERMISSIVE_FALLBACK		; adda.wl	<ea>,an
	
	OPCODE		OpcodeAddi,$0600,SRC_IMM+DEST_DN+DEST_MEM+SIZE_BWL67				; addi.bwl	#imm,<ea>
	
	OPCODE		OpcodeAddq,$5000,SRC_1_8+DEST_DN+DEST_AN+DEST_MEM+SIZE_BWL67			; addq.bwl	#1-8,<ea>
	
	OPCODE		OpcodeAddx,$D100,SRC_DN+DEST_DN+SIZE_BWL+SIZE_67+STRICT_FALLBACK		; addx.bwl	dx,dy
	FALLBACK	$D108,SRC_AN_DEC+DEST_AN_DEC+SIZE_BWL67						; addx.bwl	-(ax),-(ay)
	
	OPCODE		OpcodeAnd,$C000,SRC_ALL-SRC_AN+SIZE_BWL67+STRICT_FALLBACK			; and.bwl	<ea>,dn
	FALLBACK	$C100,SRC_DN+DEST_MEM+SIZE_BWL67+PERMISSIVE_FALLBACK				; and.bwl	dn,<ea>
	
	OPCODE		OpcodeAndi,$0200,SRC_IMM+DEST_DN+DEST_MEM+SIZE_BWL67+STRICT_FALLBACK		; andi.bwl	#imm,<ea>
	FALLBACK	$023C,SRC_IMM+DEST_CCR+SIZE_B+STRICT_FALLBACK					; andi(.b)	#imm,CCR
	FALLBACK	$027C,SRC_IMM+DEST_SR+SIZE_W							; andi(.w)	#imm,SR

	OPCODE		OpcodeAsl,$E120,SRC_DN+DEST_DN+SRC_911+SIZE_BWL67+STRICT_FALLBACK		; asl.bwl	dx,dy
	FALLBACK	$E100,SRC_1_8+DEST_DN+SIZE_BWL67+STRICT_FALLBACK				; asl.bwl	#1-8,dn
	FALLBACK	$E1C0,DEST_MEM+SIZE_W								; asl(.w)	<ea>
	
	OPCODE		OpcodeAsr,$E020,SRC_DN+DEST_DN+SRC_911+SIZE_BWL67+STRICT_FALLBACK		; asr.bwl	dx,dy
	FALLBACK	$E000,SRC_1_8+DEST_DN+SIZE_BWL67+STRICT_FALLBACK				; asr.bwl	#1-8,dn
	FALLBACK	$E0C0,DEST_MEM+SIZE_W								; asr(.w)	<ea>
	
	OPCODE		OpcodeBcc,$6400,DEST_DISP_BW+SIZE_BW+SIZE_OPTIONAL				; bcc(.bw)	<label>
	
	OPCODE		OpcodeBchg,$0140,SRC_DN+DEST_DN+SRC_911+SIZE_L+STRICT_FALLBACK			; bchg(.l)	dx,dy
	FALLBACK	$0140,SRC_DN,DEST_MEM+SIZE_B+STRICT_FALLBACK					; bchg(.b)	dn,<ea> (with <ea> != dn)
	FALLBACK	$0840,SRC_IMM,DEST_DN+SIZE_L+STRICT_FALLBACK					; bchg(.l)	#imm,dn
	FALLBACK	$0840,SRC_IMM,DEST_MEM+SIZE_B							; bchg(.b)	#imm,<ea> (with <ea> != dn)

	OPCODE		OpcodeBclr,$0180,SRC_DN+DEST_DN+SRC_911+SIZE_L+STRICT_FALLBACK			; bclr(.l)	dx,dy
	FALLBACK	$0180,SRC_DN,DEST_MEM+SIZE_B+STRICT_FALLBACK					; bclr(.b)	dn,<ea> (with <ea> != dn)
	FALLBACK	$0880,SRC_IMM,DEST_DN+SIZE_L+STRICT_FALLBACK					; bclr(.l)	#imm,dn
	FALLBACK	$0880,SRC_IMM,DEST_MEM+SIZE_B							; bclr(.b)	#imm,<ea> (with <ea> != dn)

	OPCODE		OpcodeBcs,$6500,DEST_DISP_BW+SIZE_BW+SIZE_OPTIONAL				; bcs(.bw)	<label>

	OPCODE		OpcodeBeq,$6700,DEST_DISP_BW+SIZE_BW+SIZE_OPTIONAL				; beq(.bw)	<label>

	OPCODE		OpcodeBge,$6C00,DEST_DISP_BW+SIZE_BW+SIZE_OPTIONAL				; bge(.bw)	<label>

	OPCODE		OpcodeBgt,$6E00,DEST_DISP_BW+SIZE_BW+SIZE_OPTIONAL				; bgt(.bw)	<label>

	OPCODE		OpcodeBhi,$6200,DEST_DISP_BW+SIZE_BW+SIZE_OPTIONAL				; bhi(.bw)	<label>

	OPCODE		OpcodeBle,$6F00,DEST_DISP_BW+SIZE_BW+SIZE_OPTIONAL				; ble(.bw)	<label>

	OPCODE		OpcodeBls,$6300,DEST_DISP_BW+SIZE_BW+SIZE_OPTIONAL				; bls(.bw)	<label>

	OPCODE		OpcodeBlt,$6D00,DEST_DISP_BW+SIZE_BW+SIZE_OPTIONAL				; blt(.bw)	<label>

	OPCODE		OpcodeBmi,$6B00,DEST_DISP_BW+SIZE_BW+SIZE_OPTIONAL				; bmi(.bw)	<label>

	OPCODE		OpcodeBne,$6600,DEST_DISP_BW+SIZE_BW+SIZE_OPTIONAL				; bne(.bw)	<label>

	OPCODE		OpcodeBpl,$6A00,DEST_DISP_BW+SIZE_BW+SIZE_OPTIONAL				; bpl(.bw)	<label>
	
	OPCODE		OpcodeBra,$6000,DEST_DISP_BW+SIZE_BW+SIZE_OPTIONAL				; bra(.bw)	<label>

	OPCODE		OpcodeBset,$01C0,SRC_DN+DEST_DN+SRC_911+SIZE_L+STRICT_FALLBACK			; bset.l	dx,dy
	FALLBACK	$01C0,SRC_DN,DEST_MEM+SIZE_B+STRICT_FALLBACK					; bset.b	dn,<ea> (with <ea> != dn)
	FALLBACK	$08C0,SRC_IMM,DEST_DN+SIZE_L+STRICT_FALLBACK					; bset.l	#imm,dn
	FALLBACK	$08C0,SRC_IMM,DEST_MEM+SIZE_B							; bset.b	#imm,<ea> (with <ea> != dn)
	
	OPCODE		OpcodeBsr,$6100,DEST_DISP_BW+SIZE_BW+SIZE_OPTIONAL				; bsr(.bw)	<label>

	OPCODE		OpcodeBtst,$0100,SRC_DN+DEST_DN+SRC_911+SIZE_L+STRICT_FALLBACK			; btst.l	dx,dy
	FALLBACK	$0100,SRC_DN,DEST_MEM+SIZE_B+STRICT_FALLBACK					; btst.b	dn,<ea> (with <ea> != dn)
	FALLBACK	$0800,SRC_IMM,DEST_DN+SIZE_L+STRICT_FALLBACK					; btst.l	#imm,dn
	FALLBACK	$0800,SRC_IMM,DEST_MEM+SIZE_B							; btst.b	#imm,<ea> (with <ea> != dn)

	OPCODE		OpcodeBvc,$6800,DEST_DISP_BW+SIZE_BW+SIZE_OPTIONAL				; bvc(.bw)	<label>
	
	OPCODE		OpcodeBvs,$6900,DEST_DISP_BW+SIZE_BW+SIZE_OPTIONAL				; bvs(.bw)	<label>

	OPCODE		OpcodeChk,$4180,SRC_ALL-SRC_AN+DEST_DN+SIZE_W					; chk(.w)	<ea>,dn
	
	OPCODE		OpcodeClr,$4200,DEST_DN+DEST_MEM+SIZE_BWL67					; clr.bwl	<ea>
	
	OPCODE		OpcodeCmp,$B000,SRC_ALL+DEST_DN+SIZE_WL67+STRICT_FALLBACK			; cmp.wl	<ea>,dn
	FALLBACK	$B000,SRC_ALL-SRC_AN+DEST_DN+SIZE_B67+PERMISSIVE_FALLBACK			; cmb.b		<ea>,dn (with <ea> != an)
	
	OPCODE		OpcodeCmpa,$B0C0,SRC_ALL+DEST_AN+SIZE_BW+SIZE_8+PERMISSIVE_FALLBACK		; cmpa.wl	<ea>,an
	
	OPCODE		OpcodeCmpi,$0C00,SRC_IMM+DEST_DN+DEST_MEM+SIZE_BWL67+PERMISSIVE_FALLBACK	; cmpi.bwl	#imm,<ea>

	OPCODE		OpcodeCmpm,$B108,SRC_AN_INC+DEST_AN_INC+SIZE_BWL67				; cmpm.bwl	(ax)+,(ay)+
	
	OPCODE		OpcodeDbcc,$54C8,SRC_DN+DEST_DISP_W+SIZE_W					; dbcc(.w)	dn,<label>
	
	OPCODE		OpcodeDbcs,$55C8,SRC_DN+DEST_DISP_W+SIZE_W					; dbcs(.w)	dn,<label>

	OPCODE		OpcodeDbeq,$57C8,SRC_DN+DEST_DISP_W+SIZE_W					; dbeq(.w)	dn,<label>

	OPCODE		OpcodeDbf,$51C8,SRC_DN+DEST_DISP_W+SIZE_W					; dbf(.w)	dn,<label>

	OPCODE		OpcodeDbge,$5CC8,SRC_DN+DEST_DISP_W+SIZE_W					; dbge(.w)	dn,<label>

	OPCODE		OpcodeDbgt,$5EC8,SRC_DN+DEST_DISP_W+SIZE_W					; dbgt(.w)	dn,<label>

	OPCODE		OpcodeDbhi,$52C8,SRC_DN+DEST_DISP_W+SIZE_W					; dbhi(.w)	dn,<label>

	OPCODE		OpcodeDble,$5FC8,SRC_DN+DEST_DISP_W+SIZE_W					; dble(.w)	dn,<label>

	OPCODE		OpcodeDbls,$53C8,SRC_DN+DEST_DISP_W+SIZE_W					; dbls(.w)	dn,<label>

	OPCODE		OpcodeDblt,$5DC8,SRC_DN+DEST_DISP_W+SIZE_W					; dblt(.w)	dn,<label>

	OPCODE		OpcodeDbmi,$5BC8,SRC_DN+DEST_DISP_W+SIZE_W					; dbmi(.w)	dn,<label>

	OPCODE		OpcodeDbne,$56C8,SRC_DN+DEST_DISP_W+SIZE_W					; dbne(.w)	dn,<label>

	OPCODE		OpcodeDbpl,$5AC8,SRC_DN+DEST_DISP_W+SIZE_W					; dbpl(.w)	dn,<label>

	OPCODE		OpcodeDbvc,$58C8,SRC_DN+DEST_DISP_W+SIZE_W					; dbvc(.w)	dn,<label>

	OPCODE		OpcodeDbvs,$59C8,SRC_DN+DEST_DISP_W+SIZE_W					; dbvs(.w)	dn,<label>

	OPCODE		OpcodeDivs,$81C0,SRC_ALL-SRC_AN+DEST_DN+SIZE_W					; divs(.w)	<ea>,dn
	
	OPCODE		OpcodeDivu,$80C0,SRC_ALL-SRC_AN+DEST_DN+SIZE_W					; divu(.w)	<ea>,dn
	
	OPCODE		OpcodeEor,$B100,SRC_DN+DEST_DN+DEST_MEM+SIZE_BWL67+PERMISSIVE_FALLBACK		; eor.bwl	dn,<ea>
	
	OPCODE		OpcodeEori,$0A00,SRC_IMM+DEST_DN+DEST_MEM+SIZE_BWL67+STRICT_FALLBACK		; eori.bwl	#imm,<ea>
	FALLBACK	$0A3C,SRC_IMM+DEST_CCR+SIZE_B+STRICT_FALLBACK					; eori(.b)	#imm,CCR
	FALLBACK	$0A7C,SRC_IMM+DEST_SR+SIZE_W							; eori(.w)	#imm,SR
	
	OPCODE		OpcodeExg,$C140,SRC_DN+DEST_DN+SIZE_L+STRICT_FALLBACK				; exg(.l)	dx,dy
	FALLBACK	$4148,SRC_AN+DEST_AN+SIZE_L+STRICT_FALLBACK					; exg(.l)	ax,ay
	FALLBACK	$4188,SRC_DN+DEST_AN+SRC_911+SIZE_L						; exg(.l)	ax,dx
	
	OPCODE		OpcodeExt,$4880,SRC_DN+SIZE_WL+SIZE_6						; ext.wl	dn

	OPCODE		OpcodeIllegal,$4AFC,0								; illegal

	OPCODE		OpcodeJmp,$4EC0,SRC_IND_X_PC							; jmp		<ea>
	
	OPCODE		OpcodeJsr,$4E80,SRC_IND_X_PC							; jsr		<ea>
	
	OPCODE		OpcodeLea,$41C0,SRC_IND_X_PC+DEST_AN+SIZE_L					; lea(.l)	<ea>,an
	
	OPCODE		OpcodeLink,$4E50,SRC_AN+DEST_DISP_IMM+SIZE_W					; link(.w)	an,disp

	OPCODE		OpcodeLsl,$E128,SRC_DN+DEST_DN+SRC_911+SIZE_BWL67+STRICT_FALLBACK		; lsl.bwl	dx,dy
	FALLBACK	$E108,SRC_1_8+DEST_DN+SIZE_BWL67+STRICT_FALLBACK				; lsl.bwl	#1-8,dn
	FALLBACK	$E3C0,DEST_MEM+SIZE_W								; lsl(.w)	<ea>

	OPCODE		OpcodeLsr,$E028,SRC_DN+DEST_DN+SRC_911+SIZE_BWL67+STRICT_FALLBACK		; lsr.bwl	dx,dy
	FALLBACK	$E008,SRC_1_8+DEST_DN+SIZE_BWL67+STRICT_FALLBACK				; lsr.bwl	#1-8,dn
	FALLBACK	$E2C0,DEST_MEM+SIZE_W								; lsr(.w)	<ea>

	OPCODE		OpcodeMove,$0000,SRC_ALL+DEST_DN+DEST_MEM+SIZE_WL+SIZE_1213+STRICT_FALLBACK	; move.wl	<ea1>,<ea2>
	FALLBACK	$0000,SRC_ALL-SRC_AN+DEST_DN+DEST_MEM+SIZE_B+SIZE_1213+STRICT_FALLBACK		; move.b	<ea1>,<ea2> (with <ea1> != an)
	FALLBACK	$42C0,SRC_CCR+DEST_DN+DEST_MEM+SIZE_W+STRICT_FALLBACK				; move(.w)	CCR,<ea>
	FALLBACK	$44C0,SRC_ALL-SRC_AN+DEST_CCR+SIZE_W+STRICT_FALLBACK				; move(.w)	<ea>,CCR
	FALLBACK	$40C0,SRC_SR+DEST_DN+DEST_MEM+SIZE_W+STRICT_FALLBACK				; move(.w)	SR,<ea>
	FALLBACK	$46C0,SRC_ALL-SRC_AN+DEST_SR+SIZE_W+STRICT_FALLBACK				; move(.w)	<ea>,SR
	FALLBACK	$4E68,SRC_USP+DEST_AN+SIZE_L+STRICT_FALLBACK					; move(.l)	USP,an
	FALLBACK	$4E60,SRC_AN+DEST_USP+SIZE_L							; move(.l)	an,USP
	
	OPCODE		OpcodeMovea,$0040,SRC_ALL+DEST_AN+SIZE_WL+SIZE_1213				; movea.wl	<ea>,an

	OPCODE		OpcodeMovem,$4880,SRC_REG_LIST+DEST_AN_DEC+DEST_IND_X+SIZE_WL6+STRICT_FALLBACK	; movem.wl	list,<ea>
	FALLBACK	$4C80,SRC_AN_INC+SRC_IND_X_PC+DEST_REG_LIST+SIZE_WL6				; movem.wl	<ea>,list
	
	OPCODE		OpcodeMovep,$0108,SRC_XAN+DEST_DN+SIZE_WL6+STRICT_FALLBACK			; movep.wl	x(ax),dy
	FALLBACK	$0188,SRC_DN+DEST_XAN+SIZE_WL6							; movep.wl	dx,x(ay)
	
	OPCODE		OpcodeMoveq,$7000,SRC_128_127+DEST_DN+SIZE_L					; moveq(.l)	#-128+127,dn

	OPCODE		OpcodeMuls,$C1C0,SRC_ALL-SRC_AN+DEST_DN+SIZE_W					; muls(.w)	<ea>,dn

	OPCODE		OpcodeMulu,$C0C0,SRC_ALL-SRC_AN+DEST_DN+SIZE_W					; mulu(.w)	<ea>,dn
	
	OPCODE		OpcodeNbcd,$4800,DEST_DN+DEST_MEM+SIZE_B					; nbcd(.b)	<ea>
	
	OPCODE		OpcodeNeg,$4400,DEST_DN+DEST_MEM+SIZE_BWL67					; neg.bwl	<ea>
	
	OPCODE		OpcodeNegx,$4000,DEST_DN+DEST_MEM+SIZE_BWL67					; negx.bwl	<ea>

	OPCODE		OpcodeNop,$4E71,0								; nop

	OPCODE		OpcodeNot,$4600,DEST_DN+DEST_MEM+SIZE_BWL67					; not.bwl	<ea>
	
	OPCODE		OpcodeOr,$8000,SRC_ALL-SRC_AN+DEST_DN+SIZE_BWL67+STRICT_FALLBACK		; eor.bwl	<ea>,dn
	FALLBACK	$8100,SRC_DN+DEST_MEM+SIZE_BWL67+PERMISSIVE_FALLBACK				; eor.bwl	dn,<ea>
	
	OPCODE		OpcodeOri,$0000,SRC_IMM+DEST_DN+DEST_MEM+SIZE_BWL67+STRICT_FALLBACK		; ori.bwl	#imm,<ea>
	FALLBACK	$003C,SRC_IMM+DEST_CCR+SIZE_B+STRICT_FALLBACK					; ori(.b)	#imm,CCR
	FALLBACK	$007C,SRC_IMM,DEST_SR+SIZE_W							; ori(.w)	#imm,SR
	
	OPCODE		OpcodePea,$4840,SRC_IND_X_PC+SIZE_L						; pea(.l)	<ea>
	
	OPCODE		OpcodeReset,$4E70,0								; reset
	
	OPCODE		OpcodeRol,$E138,SRC_DN+DEST_DN+SRC_911+SIZE_BWL67+STRICT_FALLBACK		; rol.bwl	dx,dy
	FALLBACK	$E118,SRC_1_8+DEST_DN+SIZE_BWL67+STRICT_FALLBACK				; rol.bwl	#1-8,dn
	FALLBACK	$E7C0,DEST_MEM+SIZE_W								; rol(.w)	<ea>
	
	OPCODE		OpcodeRor,$E038,SRC_DN+DEST_DN+SRC_911+SIZE_BWL67+STRICT_FALLBACK		; ror.bwl	dx,dy
	FALLBACK	$E018,SRC_1_8+DEST_DN+SIZE_BWL67+STRICT_FALLBACK				; ror.bwl	#1-8,dn
	FALLBACK	$E6C0,DEST_MEM+SIZE_W								; ror(.w)	<ea>
	
	OPCODE		OpcodeRoxl,$E130,SRC_DN+DEST_DN+SRC_911+SIZE_BWL67+STRICT_FALLBACK		; roxl.bwl	dx,dy
	FALLBACK	$E110,SRC_1_8+DEST_DN+SIZE_BWL67+STRICT_FALLBACK				; roxl.bwl	#1-8,dn
	FALLBACK	$E5C0,DEST_MEM+SIZE_W								; roxl(.w)	<ea>

	OPCODE		OpcodeRoxr,$E030,SRC_DN+DEST_DN+SRC_911+SIZE_BWL67+STRICT_FALLBACK		; roxr.bwl	dx,dy
	FALLBACK	$E010,SRC_1_8+DEST_DN+SIZE_BWL67+STRICT_FALLBACK				; roxr.bwl	#1-8,dn
	FALLBACK	$E4C0,DEST_MEM+SIZE_W								; roxr(.w)	<ea>
	
	OPCODE		OpcodeRte,$4E73,0								; rte

	OPCODE		OpcodeRtr,$4E77,0								; rtr

	OPCODE		OpcodeRts,$4E75,0								; rts

	OPCODE		OpcodeSbcd,$8100,SRC_DN+DEST_DN+SIZE_B+STRICT_FALLBACK				; sbcd(.b)	dx,dy
	FALLBACK	$8100,SRC_AN_DEC+DEST_AN_DEC+SIZE_B						; sbcd(.b)	-(ax),-(ay)
	
	OPCODE		OpcodeScc,$54C0,DEST_DN+DEST_MEM+SIZE_B						; scc(.b)	<ea>
	
	OPCODE		OpcodeScs,$55C0,DEST_DN+DEST_MEM+SIZE_B						; scs(.b)	<ea>

	OPCODE		OpcodeSeq,$57C0,DEST_DN+DEST_MEM+SIZE_B						; seq(.b)	<ea>

	OPCODE		OpcodeSf,$51C0,DEST_DN+DEST_MEM+SIZE_B						; sf(.b)	<ea>

	OPCODE		OpcodeSge,$5CC0,DEST_DN+DEST_MEM+SIZE_B						; sge(.b)	<ea>

	OPCODE		OpcodeSgt,$5EC0,DEST_DN+DEST_MEM+SIZE_B						; sgt(.b)	<ea>

	OPCODE		OpcodeShi,$52C0,DEST_DN+DEST_MEM+SIZE_B						; shi(.b)	<ea>

	OPCODE		OpcodeSle,$5FC0,DEST_DN+DEST_MEM+SIZE_B						; sle(.b)	<ea>

	OPCODE		OpcodeSls,$53C0,DEST_DN+DEST_MEM+SIZE_B						; sls(.b)	<ea>

	OPCODE		OpcodeSlt,$5DC0,DEST_DN+DEST_MEM+SIZE_B						; slt(.b)	<ea>

	OPCODE		OpcodeSmi,$5BC0,DEST_DN+DEST_MEM+SIZE_B						; smi(.b)	<ea>

	OPCODE		OpcodeSne,$56C0,DEST_DN+DEST_MEM+SIZE_B						; sne(.b)	<ea>

	OPCODE		OpcodeSpl,$5AC0,DEST_DN+DEST_MEM+SIZE_B						; spl(.b)	<ea>

	OPCODE		OpcodeSt,$50C0,DEST_DN+DEST_MEM+SIZE_B						; st(.b)	<ea>

	OPCODE		OpcodeStop,$4E72,0								; stop
	
	OPCODE		OpcodeSub,$9100,SRC_ALL+DEST_DN+SIZE_BWL67+STRICT_FALLBACK			; sub.bwl	<ea>,dn
	FALLBACK	$9000,SRC_DN+DEST_MEM+PERMISSIVE_FALLBACK					; sub.bwl	dn,<ea>
	
	OPCODE		OpcodeSuba,$90C0,SRC_ALL+DEST_AN+SIZE_WL+SIZE_8+PERMISSIVE_FALLBACK		; suba.wl	<ea>,an
	
	OPCODE		OpcodeSubi,$0400,SRC_IMM+DEST_DN+DEST_MEM+SIZE_BWL67				; subi.bwl	#imm,<ea>
	
	OPCODE		OpcodeSubq,$5100,SRC_1_8+DEST_DN+DEST_AN+DEST_MEM+SIZE_BWL67			; subq.bwl	#1-8,<ea>
	
	OPCODE		OpcodeSubx,$9100,SRC_DN+DEST_DN+SIZE_BWL67+STRICT_FALLBACK			; subx.bwl	dx,dy
	FALLBACK	$9108,SRC_AN_DEC+DEST_AN_DEC+SIZE_BWL						; subx.bwl	-(ax),-(ay)

	OPCODE		OpcodeSvc,$58C0,DEST_DN+DEST_MEM+SIZE_B						; svc(.b)	<ea>

	OPCODE		OpcodeSvs,$59C0,DEST_DN+DEST_MEM+SIZE_B						; svs(.b)	<ea>

	OPCODE		OpcodeSwap,$4840,SRC_DN+SIZE_W							; swap(.w)	dn
	
	OPCODE		OpcodeTas,$4AC0,DEST_DN+DEST_MEM+SIZE_B						; tas(.b)	<ea>
	
	OPCODE		OpcodeTrap,$4E40,SRC_0_15							; trap		#0-15
	
	OPCODE		OpcodeTrapv,$4E76,0								; trapv
	
	OPCODE		OpcodeTst,$4A00,DEST_DN+DEST_MEM+SIZE_BWL67					; tst.bwl	<ea>
	
	OPCODE		OpcodeUnlk,$4E58,SRC_AN								; unlk		an
