; kate: replace-tabs false;  syntax M68k for Folco;  tab-width 8;

;==================================================================================================
;
;	Instruction table
;
;	The instruction are 0 terminated and padded to 8 bytes.
;	The two next bytes are the offset of the opcode in the opcode table
;
;==================================================================================================

InstructionTable:

	INSTRUCTION	"abcd",4,OpcodeAbcd-OpcodeTable
	INSTRUCTION	"add",5,OpcodeAdd-OpcodeTable
	INSTRUCTION	"adda",4,OpcodeAdda-OpcodeTable
	INSTRUCTION	"addi",4,OpcodeAddi-OpcodeTable
	INSTRUCTION	"addq",4,OpcodeAddq-OpcodeTable
	INSTRUCTION	"addx",4,OpcodeAddx-OpcodeTable
	INSTRUCTION	"and",5,OpcodeAnd-OpcodeTable
	INSTRUCTION	"andi",4,OpcodeAndi-OpcodeTable
	INSTRUCTION	"asl",5,OpcodeAsl-OpcodeTable
	INSTRUCTION	"asr",5,OpcodeAsr-OpcodeTable
	INSTRUCTION	"bcc",5,OpcodeBcc-OpcodeTable
	INSTRUCTION	"bchg",4,OpcodeBchg-OpcodeTable
	INSTRUCTION	"bclr",4,OpcodeBclr-OpcodeTable
	INSTRUCTION	"bcs",5,OpcodeBcs-OpcodeTable
	INSTRUCTION	"beq",5,OpcodeBeq-OpcodeTable
	INSTRUCTION	"bge",5,OpcodeBge-OpcodeTable
	INSTRUCTION	"bgt",5,OpcodeBgt-OpcodeTable
	INSTRUCTION	"bhi",5,OpcodeBhi-OpcodeTable
	INSTRUCTION	"ble",5,OpcodeBle-OpcodeTable
	INSTRUCTION	"bls",5,OpcodeBls-OpcodeTable
	INSTRUCTION	"blt",5,OpcodeBlt-OpcodeTable
	INSTRUCTION	"bmi",5,OpcodeBmi-OpcodeTable
	INSTRUCTION	"bne",5,OpcodeBne-OpcodeTable
	INSTRUCTION	"bpl",5,OpcodeBpl-OpcodeTable
	INSTRUCTION	"bset",4,OpcodeBset-OpcodeTable
	INSTRUCTION	"bsr",5,OpcodeBsr-OpcodeTable
	INSTRUCTION	"bra",5,OpcodeBra-OpcodeTable
	INSTRUCTION	"btst",4,OpcodeBtst-OpcodeTable
	INSTRUCTION	"bvc",5,OpcodeBvc-OpcodeTable
	INSTRUCTION	"bvs",5,OpcodeBvs-OpcodeTable
	INSTRUCTION	"chk",5,OpcodeChk-OpcodeTable
	INSTRUCTION	"clr",5,OpcodeClr-OpcodeTable
	INSTRUCTION	"cmp",5,OpcodeCmp-OpcodeTable
	INSTRUCTION	"cmpa",4,OpcodeCmpa-OpcodeTable
	INSTRUCTION	"cmpi",4,OpcodeCmpi-OpcodeTable
	INSTRUCTION	"cmpm",4,OpcodeCmpm-OpcodeTable
	INSTRUCTION	"dbcc",4,OpcodeDbcc-OpcodeTable
	INSTRUCTION	"dbcs",4,OpcodeDbcs-OpcodeTable
	INSTRUCTION	"dbeq",4,OpcodeDbeq-OpcodeTable
	INSTRUCTION	"dbf",5,OpcodeDbf-OpcodeTable
	INSTRUCTION	"dbge",4,OpcodeDbge-OpcodeTable
	INSTRUCTION	"dbgt",4,OpcodeDbgt-OpcodeTable
	INSTRUCTION	"dbhi",4,OpcodeDbhi-OpcodeTable
	INSTRUCTION	"dble",4,OpcodeDble-OpcodeTable
	INSTRUCTION	"dbls",4,OpcodeDbls-OpcodeTable
	INSTRUCTION	"dblt",4,OpcodeDblt-OpcodeTable
	INSTRUCTION	"dbmi",4,OpcodeDbmi-OpcodeTable
	INSTRUCTION	"dbne",4,OpcodeDbne-OpcodeTable
	INSTRUCTION	"dbpl",4,OpcodeDbpl-OpcodeTable
	INSTRUCTION	"dbra",4,OpcodeDbf-OpcodeTable	; Aliased to dbf
	INSTRUCTION	"dbvc",4,OpcodeDbvc-OpcodeTable
	INSTRUCTION	"dbvs",4,OpcodeDbvs-OpcodeTable
	INSTRUCTION	"divs",4,OpcodeDivs-OpcodeTable
	INSTRUCTION	"divu",4,OpcodeDivu-OpcodeTable
	INSTRUCTION	"eor",5,OpcodeEor-OpcodeTable
	INSTRUCTION	"eori",4,OpcodeEori-OpcodeTable
	INSTRUCTION	"exg",5,OpcodeExg-OpcodeTable
	INSTRUCTION	"ext",5,OpcodeExt-OpcodeTable
	INSTRUCTION	"illegal",1,OpcodeIllegal-OpcodeTable
	INSTRUCTION	"jsr",5,OpcodeJsr-OpcodeTable
	INSTRUCTION	"jmp",5,OpcodeJmp-OpcodeTable
	INSTRUCTION	"lea",5,OpcodeLea-OpcodeTable
	INSTRUCTION	"link",4,OpcodeLink-OpcodeTable
	INSTRUCTION	"lsl",5,OpcodeLsl-OpcodeTable
	INSTRUCTION	"lsr",5,OpcodeLsr-OpcodeTable
	INSTRUCTION	"move",4,OpcodeMove-OpcodeTable
	INSTRUCTION	"movea",3,OpcodeMovea-OpcodeTable
	INSTRUCTION	"movem",3,OpcodeMovem-OpcodeTable
	INSTRUCTION	"movep",3,OpcodeMovep-OpcodeTable
	INSTRUCTION	"moveq",3,OpcodeMoveq-OpcodeTable
	INSTRUCTION	"muls",4,OpcodeMuls-OpcodeTable
	INSTRUCTION	"mulu",4,OpcodeMulu-OpcodeTable
	INSTRUCTION	"nbcd",4,OpcodeNbcd-OpcodeTable
	INSTRUCTION	"neg",5,OpcodeNeg-OpcodeTable
	INSTRUCTION	"negx",4,OpcodeNegx-OpcodeTable
	INSTRUCTION	"nop",5,OpcodeNop-OpcodeTable
	INSTRUCTION	"not",5,OpcodeNot-OpcodeTable
	INSTRUCTION	"or",6,OpcodeOr-OpcodeTable
	INSTRUCTION	"ori",5,OpcodeOri-OpcodeTable
	INSTRUCTION	"pea",5,OpcodePea-OpcodeTable
	INSTRUCTION	"reset",3,OpcodeReset-OpcodeTable
	INSTRUCTION	"rol",5,OpcodeRol-OpcodeTable
	INSTRUCTION	"ror",5,OpcodeRor-OpcodeTable
	INSTRUCTION	"roxl",4,OpcodeRoxl-OpcodeTable
	INSTRUCTION	"roxr",4,OpcodeRoxr-OpcodeTable
	INSTRUCTION	"rte",5,OpcodeRte-OpcodeTable
	INSTRUCTION	"rtr",5,OpcodeRtr-OpcodeTable
	INSTRUCTION	"rts",5,OpcodeRts-OpcodeTable
	INSTRUCTION	"sbcd",4,OpcodeSbcd-OpcodeTable
	INSTRUCTION	"scc",5,OpcodeScc-OpcodeTable
	INSTRUCTION	"scs",5,OpcodeScs-OpcodeTable
	INSTRUCTION	"seq",5,OpcodeSeq-OpcodeTable
	INSTRUCTION	"sf",6,OpcodeSf-OpcodeTable
	INSTRUCTION	"sge",5,OpcodeSge-OpcodeTable
	INSTRUCTION	"sgt",5,OpcodeSgt-OpcodeTable
	INSTRUCTION	"shi",5,OpcodeShi-OpcodeTable
	INSTRUCTION	"sle",5,OpcodeSle-OpcodeTable
	INSTRUCTION	"sls",5,OpcodeSls-OpcodeTable
	INSTRUCTION	"slt",5,OpcodeSlt-OpcodeTable
	INSTRUCTION	"smi",5,OpcodeSmi-OpcodeTable
	INSTRUCTION	"sne",5,OpcodeSne-OpcodeTable
	INSTRUCTION	"spl",5,OpcodeSpl-OpcodeTable
	INSTRUCTION	"st",6,OpcodeSt-OpcodeTable
	INSTRUCTION	"stop",4,OpcodeStop-OpcodeTable
	INSTRUCTION	"sub",5,OpcodeSub-OpcodeTable
	INSTRUCTION	"suba",4,OpcodeSuba-OpcodeTable
	INSTRUCTION	"subi",4,OpcodeSubi-OpcodeTable
	INSTRUCTION	"subq",4,OpcodeSubq-OpcodeTable
	INSTRUCTION	"subx",4,OpcodeSubx-OpcodeTable
	INSTRUCTION	"svc",5,OpcodeSvc-OpcodeTable
	INSTRUCTION	"svs",5,OpcodeSvs-OpcodeTable
	INSTRUCTION	"swap",4,OpcodeSwap-OpcodeTable
	INSTRUCTION	"tas",5,OpcodeTas-OpcodeTable
	INSTRUCTION	"trap",4,OpcodeTrap-OpcodeTable
	INSTRUCTION	"trapv",3,OpcodeTrapv-OpcodeTable
	INSTRUCTION	"tst",5,OpcodeTst-OpcodeTable
	INSTRUCTION	"unlk",4,OpcodeUnlk-OpcodeTable
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

	OPCODE		OpcodeCmpm,$B108,SRC_AN_INC+DEST_AN_INC+SIZE_BWL67				; cmpm.blw	(ax)+,(ay)+
	
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
