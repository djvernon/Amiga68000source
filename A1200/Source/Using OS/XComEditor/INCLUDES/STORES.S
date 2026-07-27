

GD_CraftWeapon		equ	0
GD_Value1		equ	1
GD_Value2		equ	2
GD_HWPCycle		equ	3
GD_Value3		equ	4
GD_XcomArmCycle		equ	5
GD_Value4		equ	6
GD_XcomMiscCycle	equ	7
GD_AlienWeaponsCycle	equ	8
GD_Value5		equ	9
GD_AliensCycle		equ	10
GD_Value6		equ	11
GD_AlienMiscCycle	equ	12
GD_Value7		equ	13
GD_MoneyValue		equ	14
GD_ExitStores		equ	15

EditStores_CNT		equ	16

ValueGadget1	dc.l	EditStoresGadgets+4
ValueGadget2	dc.l	EditStoresGadgets+8
ValueGadget3	dc.l	EditStoresGadgets+16
ValueGadget4	dc.l	EditStoresGadgets+24
ValueGadget5	dc.l	EditStoresGadgets+36
ValueGadget6	dc.l	EditStoresGadgets+44
ValueGadget7	dc.l	EditStoresGadgets+52

EditStoresWnd
	dc.l	0
EditStoresGList
	dc.l	0
EditStoresGadgets
	dcb.l	16,0
EditStoresLeft
	dc.w	0
EditStoresTop
	dc.w    19
EditStoresWidth
	dc.w	632
EditStoresHeight
	dc.w	135

EditStoresGTypes
	dc.w	CYCLE_KIND
	dc.w	INTEGER_KIND
	dc.w	INTEGER_KIND
	dc.w	CYCLE_KIND
	dc.w	INTEGER_KIND
	dc.w	CYCLE_KIND
	dc.w	INTEGER_KIND
	dc.w	CYCLE_KIND
	dc.w	CYCLE_KIND
	dc.w	INTEGER_KIND
	dc.w	CYCLE_KIND
	dc.w	INTEGER_KIND
	dc.w	CYCLE_KIND
	dc.w	INTEGER_KIND
	dc.w	INTEGER_KIND
	dc.w	BUTTON_KIND

EditStoresNGads
	dc.w	16,17,176,13
	dc.l	CraftWeaponText,0
	dc.w	GD_CraftWeapon
	dc.l	PLACETEXT_ABOVE,0,0

	dc.w	218,17,58,13
	dc.l	Value1Text,0
	dc.w	GD_Value1
	dc.l	PLACETEXT_ABOVE,0,0

	dc.w	218,48,58,13
	dc.l	Value2Text,0
	dc.w	GD_Value2
	dc.l	PLACETEXT_ABOVE,0,0

	dc.w	16,48,176,13
	dc.l	HWPCycleText,0
	dc.w	GD_HWPCycle
	dc.l	PLACETEXT_ABOVE,0,0

	dc.w	218,79,58,13
	dc.l	Value3Text,0
	dc.w	GD_Value3
	dc.l	PLACETEXT_ABOVE,0,0

	dc.w	16,79,176,13
	dc.l	XcomArmCycleText,0
	dc.w	GD_XcomArmCycle
	dc.l	PLACETEXT_ABOVE,0,0

	dc.w	218,110,58,13
	dc.l	Value4Text,0
	dc.w	GD_Value4
	dc.l	PLACETEXT_ABOVE,0,0

	dc.w	16,110,176,13
	dc.l	XcomMiscCycleText,0
	dc.w	GD_XcomMiscCycle
	dc.l	PLACETEXT_ABOVE,0,0

	dc.w	320,17,176,13
	dc.l	AlienWeaponsCycleText,0
	dc.w	GD_AlienWeaponsCycle
	dc.l	PLACETEXT_ABOVE,0,0

	dc.w	522,17,58,13
	dc.l	Value5Text,0
	dc.w	GD_Value5
	dc.l	PLACETEXT_ABOVE,0,0

	dc.w	320,48,176,13
	dc.l	AliensCycleText,0
	dc.w	GD_AliensCycle
	dc.l	PLACETEXT_ABOVE,0,0

	dc.w	522,48,58,13
	dc.l	Value6Text,0
	dc.w	GD_Value6
	dc.l	PLACETEXT_ABOVE,0,0

	dc.w	320,79,176,13
	dc.l	AlienMiscCycleText,0
	dc.w	GD_AlienMiscCycle
	dc.l	PLACETEXT_ABOVE,0,0

	dc.w	522,79,58,13
	dc.l	Value7Text,0
	dc.w	GD_Value7
	dc.l	PLACETEXT_ABOVE,0,0

	dc.w	313,110,145,13
	dc.l	MoneyValueText,0
	dc.w	GD_MoneyValue
	dc.l	PLACETEXT_ABOVE,0,0

	dc.w	482,110,100,13
	dc.l	ExitStoresText,0
	dc.w	GD_ExitStores
	dc.l	PLACETEXT_IN,0,0

EditStoresGTags
	dc.l	GTCY_Labels,CraftWeaponLabels
	dc.l	TAG_DONE

Val1Attr
	dc.l	GTIN_Number
Val1	dc.l	0
	dc.l	GTIN_MaxChars,4
	dc.l	STRINGA_Justification,GACT_STRINGCENTER
	dc.l	TAG_DONE

Val2Attr
	dc.l	GTIN_Number
Val2	dc.l	0
	dc.l	GTIN_MaxChars,4
	dc.l	STRINGA_Justification,GACT_STRINGCENTER
	dc.l	TAG_DONE

	dc.l	GTCY_Labels,HWPCycleLabels
	dc.l	TAG_DONE

Val3Attr
	dc.l	GTIN_Number
Val3	dc.l	0
	dc.l	GTIN_MaxChars,4
	dc.l	STRINGA_Justification,GACT_STRINGCENTER
	dc.l	TAG_DONE

	dc.l	GTCY_Labels,XcomArmCycleLabels
	dc.l	TAG_DONE

Val4Attr
	dc.l	GTIN_Number
Val4	dc.l	0
	dc.l	GTIN_MaxChars,4
	dc.l	STRINGA_Justification,GACT_STRINGCENTER
	dc.l	TAG_DONE

	dc.l	GTCY_Labels,XcomMiscCycleLabels
	dc.l	TAG_DONE

	dc.l	GTCY_Labels,AlienWeaponsCycleLabels
	dc.l	TAG_DONE

Val5Attr
	dc.l	GTIN_Number
Val5	dc.l	0
	dc.l	GTIN_MaxChars,4
	dc.l	STRINGA_Justification,GACT_STRINGCENTER
	dc.l	TAG_DONE

	dc.l	GTCY_Labels,AliensCycleLabels
	dc.l	TAG_DONE

Val6Attr
	dc.l	GTIN_Number
Val6	dc.l	0
	dc.l	GTIN_MaxChars,4
	dc.l	STRINGA_Justification,GACT_STRINGCENTER
	dc.l	TAG_DONE

	dc.l	GTCY_Labels,AlienMiscCycleLabels
	dc.l	TAG_DONE

Val7Attr
	dc.l	GTIN_Number
Val7	dc.l	0
	dc.l	GTIN_MaxChars,4
	dc.l	STRINGA_Justification,GACT_STRINGCENTER
	dc.l	TAG_DONE

	dc.l	GTIN_Number
Money	dc.l	0
	dc.l	GTIN_MaxChars,8
	dc.l	STRINGA_Justification,GACT_STRINGCENTER
	dc.l	TAG_DONE

	dc.l	TAG_DONE


CraftWeaponText
	DC.B    'Craft Weaponary',0

Value1Text
	DC.B    '0-9999',0

Value2Text
	DC.B    '0-9999',0

HWPCycleText
	DC.B    'Heavy Weapon Platforms',0

Value3Text
	DC.B    '0-9999',0

XcomArmCycleText
	DC.B    'Xcom Armament',0

Value4Text
	DC.B    '0-9999',0

XcomMiscCycleText
	DC.B    'Xcom Miscellaneous',0

AlienWeaponsCycleText
	DC.B    'Alien Equipment',0

Value5Text
	DC.B    '0-9999',0

AliensCycleText
	DC.B    '  Aliens',0

Value6Text
	DC.B    '0-9999',0

AlienMiscCycleText
	DC.B    'Alien Miscellaneous',0

Value7Text
	DC.B    '0-9999',0

MoneyValueText
	DC.B    'Current Money',0

ExitStoresText
	DC.B    'EXIT STORES',0

	CNOP    0,2

CraftWeaponLabels
	dc.l	CraftWeaponLab0
	dc.l	CraftWeaponLab1
	dc.l	CraftWeaponLab2
	dc.l	CraftWeaponLab3
	dc.l	CraftWeaponLab4
	dc.l	CraftWeaponLab5
	dc.l	CraftWeaponLab6
	dc.l	CraftWeaponLab7
	dc.l	CraftWeaponLab8
	dc.l	CraftWeaponLab9
	dc.l	0

HWPCycleLabels
	dc.l	HWPCycleLab0
	dc.l	HWPCycleLab1
	dc.l	HWPCycleLab2
	dc.l	HWPCycleLab3
	dc.l	HWPCycleLab4
	dc.l	HWPCycleLab5
	dc.l	HWPCycleLab6
	dc.l	HWPCycleLab7
	dc.l	0

XcomArmCycleLabels
	dc.l	XcomArmCycleLab0
	dc.l	XcomArmCycleLab1
	dc.l	XcomArmCycleLab2
	dc.l	XcomArmCycleLab3
	dc.l	XcomArmCycleLab4
	dc.l	XcomArmCycleLab5
	dc.l	XcomArmCycleLab6
	dc.l	XcomArmCycleLab7
	dc.l	XcomArmCycleLab8
	dc.l	XcomArmCycleLab9
	dc.l	XcomArmCycleLab10
	dc.l	XcomArmCycleLab11
	dc.l	XcomArmCycleLab12
	dc.l	XcomArmCycleLab13
	dc.l	XcomArmCycleLab14
	dc.l	XcomArmCycleLab15
	dc.l	XcomArmCycleLab16
	dc.l	XcomArmCycleLab17
	dc.l	XcomArmCycleLab18
	dc.l	0

XcomMiscCycleLabels
	dc.l	XcomMiscCycleLab0
	dc.l	XcomMiscCycleLab1
	dc.l	XcomMiscCycleLab2
	dc.l	XcomMiscCycleLab3
	dc.l	XcomMiscCycleLab4
	dc.l	XcomMiscCycleLab5
	dc.l	XcomMiscCycleLab6
	dc.l	XcomMiscCycleLab7
	dc.l	XcomMiscCycleLab8
	dc.l	XcomMiscCycleLab9
	dc.l	XcomMiscCycleLab10
	dc.l	XcomMiscCycleLab11
	dc.l	0

AlienWeaponsCycleLabels
	dc.l	AlienWeaponsCycleLab0
	dc.l	AlienWeaponsCycleLab1
	dc.l	AlienWeaponsCycleLab2
	dc.l	AlienWeaponsCycleLab3
	dc.l	AlienWeaponsCycleLab4
	dc.l	AlienWeaponsCycleLab5
	dc.l	AlienWeaponsCycleLab6
	dc.l	AlienWeaponsCycleLab7
	dc.l	AlienWeaponsCycleLab8
	dc.l	AlienWeaponsCycleLab9
	dc.l	AlienWeaponsCycleLab10
	dc.l	AlienWeaponsCycleLab11
	dc.l	AlienWeaponsCycleLab12
	dc.l	0

AliensCycleLabels
	dc.l	AliensCycleLab0
	dc.l	AliensCycleLab1
	dc.l	AliensCycleLab2
	dc.l	AliensCycleLab3
	dc.l	AliensCycleLab4
	dc.l	AliensCycleLab5
	dc.l	AliensCycleLab6
	dc.l	AliensCycleLab7
	dc.l	AliensCycleLab8
	dc.l	AliensCycleLab9
	dc.l	AliensCycleLab10
	dc.l	AliensCycleLab11
	dc.l	AliensCycleLab12
	dc.l	AliensCycleLab13
	dc.l	AliensCycleLab14
	dc.l	AliensCycleLab15
	dc.l	AliensCycleLab16
	dc.l	AliensCycleLab17
	dc.l	0

AlienMiscCycleLabels
	dc.l	AlienMiscCycleLab0
	dc.l	AlienMiscCycleLab1
	dc.l	AlienMiscCycleLab2
	dc.l	AlienMiscCycleLab3
	dc.l	AlienMiscCycleLab4
	dc.l	AlienMiscCycleLab5
	dc.l	AlienMiscCycleLab6
	dc.l	AlienMiscCycleLab7
	dc.l	AlienMiscCycleLab8
	dc.l	AlienMiscCycleLab9
	dc.l	0

CraftWeaponLab0		DC.B	'Stingray Launcher',0
CraftWeaponLab1		DC.B	'Avalanche Launcher',0
CraftWeaponLab2		DC.B	'Cannon',0
CraftWeaponLab3		DC.B	'Fusion Launcher',0
CraftWeaponLab4		DC.B	'Laser Cannon',0
CraftWeaponLab5		DC.B	'Plasma Beam',0
CraftWeaponLab6		DC.B	'Stingray Missile',0
CraftWeaponLab7		DC.B	'Avalanche Missile',0
CraftWeaponLab8		DC.B	'Cannon Rounds x50',0
CraftWeaponLab9		DC.B	'Fusion Ball',0

	CNOP    0,2

HWPCycleLab0	DC.B	'Tank Cannon',0
HWPCycleLab1	DC.B	'Tank Rocket',0
HWPCycleLab2	DC.B	'Tank Laser',0
HWPCycleLab3	DC.B	'Hovertank Plasma',0
HWPCycleLab4	DC.B	'Hovertank Launcher',0
HWPCycleLab5	DC.B	'HWP Cannon Shells',0
HWPCycleLab6	DC.B	'HWP Rockets',0
HWPCycleLab7	DC.B	'HWP Fusion Bombs',0

    CNOP    0,2

XcomArmCycleLab0	DC.B	'Pistol',0
XcomArmCycleLab1	DC.B	'Pistol Clip',0
XcomArmCycleLab2	DC.B	'Rifle',0
XcomArmCycleLab3	DC.B	'Rifle Clip',0
XcomArmCycleLab4	DC.B	'Heavy Cannon',0
XcomArmCycleLab5	DC.B	'HC-AP',0
XcomArmCycleLab6	DC.B	'HC-HE',0
XcomArmCycleLab7	DC.B	'HC-I',0
XcomArmCycleLab8	DC.B	'Auto Cannon',0
XcomArmCycleLab9	DC.B	'AC-AP',0
XcomArmCycleLab10	DC.B	'AC-HE',0
XcomArmCycleLab11	DC.B	'AC-I',0
XcomArmCycleLab12	DC.B	'Rocket Launcher',0
XcomArmCycleLab13	DC.B	'Small Rocket',0
XcomArmCycleLab14	DC.B	'Large Rocket',0
XcomArmCycleLab15	DC.B	'Incendiary Rocket',0
XcomArmCycleLab16	DC.B	'Laser Pistol',0
XcomArmCycleLab17	DC.B	'Laser Rifle',0
XcomArmCycleLab18	DC.B	'Heavy Laser',0

    CNOP    0,2

XcomMiscCycleLab0	DC.B	'Grenade',0
XcomMiscCycleLab1	DC.B	'Smoke Grenade',0
XcomMiscCycleLab2	DC.B	'Proximity Grenade',0
XcomMiscCycleLab3	DC.B	'High Explosive',0
XcomMiscCycleLab4	DC.B	'Motion Scanner',0
XcomMiscCycleLab5	DC.B	'Medi Kit',0
XcomMiscCycleLab6	DC.B	'Psi-Amp',0
XcomMiscCycleLab7	DC.B	'Stun Rod',0
XcomMiscCycleLab8	DC.B	'Electro Flare',0
XcomMiscCycleLab9	DC.B	'Personal Armour',0
XcomMiscCycleLab10	DC.B	'Power Suit',0
XcomMiscCycleLab11	DC.B	'Flying Suit',0

    CNOP    0,2

AlienWeaponsCycleLab0	DC.B	'Heavy Plasma',0
AlienWeaponsCycleLab1	DC.B	'Heavy Plasma Clip',0
AlienWeaponsCycleLab2	DC.B	'Plasma Rifle',0
AlienWeaponsCycleLab3	DC.B	'Plasma Rifle Clip',0
AlienWeaponsCycleLab4	DC.B	'Plasma Pistol',0
AlienWeaponsCycleLab5	DC.B	'Plasma Pistol Clip',0
AlienWeaponsCycleLab6	DC.B	'Blaster Launcher',0
AlienWeaponsCycleLab7	DC.B	'Blaster Bomb',0
AlienWeaponsCycleLab8	DC.B	'Small Launcher',0
AlienWeaponsCycleLab9	DC.B	'Stun Bomb',0
AlienWeaponsCycleLab10	DC.B	'Alien Grenade',0
AlienWeaponsCycleLab11	DC.B	'Elerium-115',0
AlienWeaponsCycleLab12	DC.B	'Mind Probe',0

    CNOP    0,2

AliensCycleLab0		DC.B	'Sectoid',0
AliensCycleLab1		DC.B	'Snakeman',0
AliensCycleLab2		DC.B	'Ethereal',0
AliensCycleLab3		DC.B	'Sectoid Corpse',0
AliensCycleLab4		DC.B	'Snakeman Corpse',0
AliensCycleLab5		DC.B	'Ethereal Corpse',0
AliensCycleLab6		DC.B	'Muton Corpse',0
AliensCycleLab7		DC.B	'Floater Corpse',0
AliensCycleLab8		DC.B	'Celatid Corpse',0
AliensCycleLab9		DC.B	'Silatoid Corpse',0
AliensCycleLab10	DC.B	'Chryssalid Corpse',0
AliensCycleLab11	DC.B	'Reaper Corpse',0
AliensCycleLab12	DC.B	'Sectopod Corpse',0
AliensCycleLab13	DC.B	'Cyberdisc Corpse',0
AliensCycleLab14	DC.B	'Medic',0
AliensCycleLab15	DC.B	'Navigator',0
AliensCycleLab16	DC.B	'Soldier',0
AliensCycleLab17	DC.B	'Terrorist',0

    CNOP    0,2

AlienMiscCycleLab0	DC.B	'UFO Power Source',0
AlienMiscCycleLab1	DC.B	'UFO Navigation',0
AlienMiscCycleLab2	DC.B	'UFO Construction',0
AlienMiscCycleLab3	DC.B	'Alien Food',0
AlienMiscCycleLab4	DC.B	'Alien Reproduction',0
AlienMiscCycleLab5	DC.B	'Alien Entertainment',0
AlienMiscCycleLab6	DC.B	'Alien Surgery',0
AlienMiscCycleLab7	DC.B	'Examination Room',0
AlienMiscCycleLab8	DC.B	'Alien Alloys',0
AlienMiscCycleLab9	DC.B	'Alien Habitat',0

    CNOP    0,2

EditStoresWindowTags
EditStoresL
	dc.l    WA_Left,0
EditStoresT
	dc.l    WA_Top,0
EditStoresW
	dc.l    WA_Width,0
EditStoresH
	dc.l    WA_Height,0
	dc.l    WA_IDCMP,CYCLEIDCMP!INTEGERIDCMP!BUTTONIDCMP!IDCMP_CLOSEWINDOW!IDCMP_REFRESHWINDOW
	dc.l    WA_Flags,WFLG_SMART_REFRESH!ACTIVATE
EditStoresWG
	dc.l    WA_Gadgets,0
	dc.l    WA_Title,EditStoresWTitle
	dc.l    WA_ScreenTitle,EditStoresSTitle
EditStoresSC
	dc.l    WA_PubScreen,0
	dc.l    WA_MinWidth,67
	dc.l    WA_MinHeight,21
	dc.l    WA_MaxWidth,640
	dc.l    WA_MaxHeight,256
	dc.l    TAG_DONE

EditStoresWTitle
	DC.B    'Change Store Values',0
	CNOP    0,2

EditStoresSTitle
	DC.B    'GadToolsBox v2.0 © 1991-1993',0
	CNOP    0,2

*-------------------------------------------*

OpenEditStoresWindow
	movem.l d1-d4/a0-a4/a6,-(sp)
	move.l  Scr,a0
	moveq   #0,d3
	moveq   #0,d2
	move.w  EditStoresWidth,d2
	move.w  EditStoresHeight,d3
	bsr     ComputeFont
	move.l  Scr,a0
	move.l  d2,d0
	bsr     ComputeX
	move.l  d0,d4
	move.w  EditStoresLeft,d2
	add.w   d2,d0
	add.w   OffX,d0
	add.b   sc_WBorRight(a0),d0
	cmp.w   sc_Width(a0),d0
	bls.s   EditStoresWOk
	move.w  sc_Width(a0),d0
	sub.w   d4,d0
	move.w  d0,d2
EditStoresWOk
	move.l  d3,d0
	bsr     ComputeY
	move.l  d0,d4
	move.w  EditStoresTop,d3
	add.w   d3,d0
	add.w   OffY,d0
	add.b   sc_WBorBottom(a0),d0
	cmp.w   sc_Height(a0),d0
	bls.s   EditStoresHOk
	move.w  sc_Height(a0),d0
	sub.w   d4,d0
	move.w  d0,d3
EditStoresHOk
	lea.l   EditStoresGList,a0
	CALLGAD	CreateContext

	move.l  d0,a3
	tst.l   d0
	beq     EditStoresCError
	movem.w d2-d3,-(sp)
	moveq   #0,d3
	lea.l   EditStoresGTags,a4
EditStoresGL
	lea.l   EditStoresNGads,a0
	move.l  d3,d0
	mulu    #gng_SIZEOF,d0
	add.l   d0,a0
	lea.l   BufNewGad,a1
	moveq   #gng_SIZEOF,d0
	CALLEXEC CopyMem

	lea.l   BufNewGad,a0
	move.l  VisualInfo,gng_VisualInfo(a0)
	move.l  Font,gng_TextAttr(a0)
	move.w  gng_LeftEdge(a0),d0
	bsr     ComputeX
	add.w   OffX,d0
	move.w  d0,gng_LeftEdge(a0)
	move.w  gng_TopEdge(a0),d0
	bsr     ComputeY
	add.w   OffY,d0
	move.w  d0,gng_TopEdge(a0)
	move.w  gng_Width(a0),d0
	bsr     ComputeX
	move.w  d0,gng_Width(a0)
	move.w  gng_Height(a0),d0
	bsr     ComputeY
	move.w  d0,gng_Height(a0)
	lea.l   EditStoresGTypes,a0
	moveq   #0,d0
	move.l  d3,d1
	asl.l   #1,d1
	add.l   d1,a0
	move.w  (a0),d0
	move.l  a3,a0
	lea.l   BufNewGad,a1
	move.l  a4,a2
	CALLGAD	CreateGadgetA
	tst.l   d0
	bne.s    EditStoresCOK
	movem.w (sp)+,d2-d3
	bra     EditStoresCError
EditStoresCOK
	move.l  d0,a3
	move.l  d3,d0
	asl.l   #2,d0
	lea.l   EditStoresGadgets,a0
	add.l   d0,a0
	move.l  a3,(a0)
EditStoresTL
	tst.l   (a4)
	beq.s   EditStoresDN
	addq.w  #8,a4
	bra.s   EditStoresTL
EditStoresDN
	addq.w  #4,a4
	addq.w  #1,d3
	cmp.w   #EditStores_CNT,d3
	bmi     EditStoresGL
	movem.w (sp)+,d2-d3
	move.l  EditStoresGList,EditStoresWG+4
	move.l  Scr,EditStoresSC+4
	ext.l   d2
	ext.l   d3
	move.l  d2,EditStoresL+4
	move.l  d3,EditStoresT+4
	move.l  Scr,a0
	move.w  EditStoresWidth,d0
	bsr     ComputeX
	add.w   OffX,d0
	add.b   sc_WBorRight(a0),d0
	move.l  d0,EditStoresW+4
	move.w  EditStoresHeight,d0
	bsr     ComputeY
	add.w   OffY,d0
	add.b   sc_WBorBottom(a0),d0
	move.l  d0,EditStoresH+4
	suba.l  a0,a0
	lea.l   EditStoresWindowTags,a1
	CALLINT	OpenWindowTagList
	move.l  d0,EditStoresWnd
	tst.l   d0
	beq     EditStoresWError
	move.l  EditStoresWnd,a0
	suba.l  a1,a1
	CALLGAD	RefreshWindow
	moveq   #0,d0
EditStoresDone
	movem.l (sp)+,d1-d4/a0-a4/a6
	rts
	
EditStoresCError
	moveq   #1,d0
	bra.s   EditStoresDone
EditStoresGError
	moveq   #2,d0
	bra.s   EditStoresDone
EditStoresWError
	moveq   #4,d0
	bra.s   EditStoresDone

*-------------------------------------------*

CloseEditStoresWindow
	movem.l d0-d1/a0-a2/a6,-(sp)
	move.l  EditStoresWnd,a0
	cmpa.l  #0,a0
	beq     EditStoresNWnd
	CALLINT	CloseWindow
	move.l  #0,EditStoresWnd
EditStoresNWnd
	move.l  EditStoresGList,a0
	cmpa.l  #0,a0
	beq     EditStoresNGad
	CALLGAD	FreeGadgets
	move.l  #0,EditStoresGList
EditStoresNGad
	movem.l (sp)+,d0-d1/a0-a2/a6
	rts

*-------------------------------------------*

CraftWeaponTable	ds.w	10
HWPTableA		ds.w	5
HWPTableB		ds.w	3
XcomArmTable		ds.w	19
XcomMiscTableA		ds.w	9
XcomMiscTableB		ds.w	3
AlienWeaponsTable	ds.w	13
AliensTable		ds.w	18
AlienMiscTable		ds.w	10

*-------------------------------------------*



