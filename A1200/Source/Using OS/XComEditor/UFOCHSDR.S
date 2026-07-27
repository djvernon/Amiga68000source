*
*	im_code - this equals the number 0-? of the 
*	item shown in the cycle gadget
*
*	UFO Cheat program written by J.Lucas 24/11/95
*

	include	ram:system2.gs
	incdir	dh0:assem/include/
	include	libraries/gadtools.i
	include	libraries/gadtools_lib.i

CALLRT	MACRO
	move.l	_ReqBase(pc),a6
	jsr	_LVOrt\1(a6)
	ENDM

CALLGAD	MACRO
	move.l	_GadToolsBase(pc),a6
	jsr	_LVOGT_\1(a6)
	ENDM

_LVORawIOInit	equ	-$1F8

start
	move.l	4.w,_SysBase
	bsr	_PrintInit		;initialise printf
	beq	exit_now

* Open the Intuition library

	moveq	#0,d0
	lea	IntuitionName(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_IntuitionBase
	beq	exit_now

* Open the Graphics library

	moveq	#0,d0
	lea	GfxName(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_GfxBase
	beq	exit_closeint

* Open the Gadtools library

	moveq	#0,d0
	lea	GadName(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_GadToolsBase
	beq	exit_closegraf

* Open the REQTools library

	lea	ReqName(pc),a1
	moveq	#REQTOOLSVERSION,d0
	CALLEXEC OpenLibrary
	move.l	d0,_ReqBase
	beq	exit_closegad

	bsr	SetupScreen
	bsr	OpenUFO_EditorWindow

*---------------------------------------------------------------------------*

MainLoop
	moveq	#1,d1
	CALLDOS	Delay

	move.l	UFO_EditorWnd(pc),a0
	move.l	wd_UserPort(a0),a0
	CALLGAD	GetIMsg
	tst.l	d0
	beq	DoLoop

	move.l	d0,a1
	move.l	im_Class(a1),d2
	move.w	im_Code(a1),d3
	move.w	im_Qualifier(a1),d4
	move.l	im_IAddress(a1),SelectedGadget
	CALLGAD	ReplyIMsg

DoReadGadgets
	cmp.l	#GADGETUP,d2
	bne.s	DoLoop

	move.l	SelectedGadget(pc),a0
	moveq	#0,d0
	move.w	gg_GadgetID(a0),d0

	cmp.w	#GD_BaseIcon,d0
	beq	DoEditFacility

	cmp.w	#GD_StoresIcon,d0
	beq	DoEditStores

	cmp.w	#GD_ConstructionIcon,d0
	beq	DoConstructionTime

	cmp.w	#GD_LoadIcon,d0
	beq.s	DoLoad

	cmp.w	#GD_SaveIcon,d0
	beq.s	DoSave

	cmp.w	#GD_QuitIcon,d0
	beq	exit_UFO_Cheat

	cmp.w	#GD_FacilityIcon,d0
	beq	DoAvailFacility

	cmp.w	#GD_UFOPediaIcon,d0
	beq	DoUFOPedia

	cmp.w	#GD_ResearchIcon,d0
	beq	DoResearch

	cmp.w	#GD_ProductIcon,d0
	beq	DoProducts

	cmp.w	#GD_BaseSelect,d0
	beq	DoSelectBase

DoLoop
	bra	MainLoop

*---------------------------------------------------*

DoLoad
	moveq	#FREQ_LOAD,d7
	bsr	request.dir.name
	bne.s	LoadCanceledFailed
	bsr	Load.Files.And.Process
	bsr	ChangeSliderMax
LoadCanceledFailed
	bra	MainLoop

DoSave
	bsr	Process.Files.And.Save
	bsr	ResetEditor
	bra	MainLoop

DoAvailFacility
	st	SaveFacility
	lea	UFO_EditorGadgets,a0
	move.l	4*6(a0),a0
	move.l	UFO_EditorWnd,a1
	sub.l	a2,a2
	CALLINT	OffGadget
	bra	MainLoop

DoUFOPedia
	st	SaveUfoPedia
	lea	UFO_EditorGadgets,a0
	move.l	4*7(a0),a0
	move.l	UFO_EditorWnd,a1
	sub.l	a2,a2
	CALLINT	OffGadget
	bra	MainLoop

DoResearch
	st	SaveResearch
	bsr	UpdateResearchFile
	lea	UFO_EditorGadgets,a0
	move.l	4*8(a0),a0
	move.l	UFO_EditorWnd,a1
	sub.l	a2,a2
	CALLINT	OffGadget
	bra	MainLoop

DoProducts
	st	SaveProducts
	lea	UFO_EditorGadgets,a0
	move.l	4*9(a0),a0
	move.l	UFO_EditorWnd,a1
	sub.l	a2,a2
	CALLINT	OffGadget
	bra	MainLoop

DoConstructionTime
	bsr	SetConstructionTime
	bra	MainLoop

DoSelectBase
	subq.w	#1,d3
	move.w	d3,BaseToEdit
	bra	MainLoop


*---------------------------------------------------*

ChangeSliderMax
	moveq	#0,d0
	move.w	BaseCount,d0
	move.l	d0,MaxBase
	lea	UFO_EditorGadgets+4*10,a0
	move.l	(a0),a0
	move.l	UFO_EditorWnd,a1
	sub.l	a2,a2
	lea	SliderAttr,a3

	CALLGAD	SetGadgetAttrsA

	lea	UFO_EditorGadgets+4*10,a0
	move.l	(a0),a0
	move.l	UFO_EditorWnd,a1
	sub.l	a2,a2
	CALLINT	RefreshGadgets

	rts

*---------------------------------------------------*

UpdateResearchFile
	lea	Research.Dat,a0

	move.b	#$80,9(a0)
	move.w	#$8000,$3e(a0)
	move.w	#$8000,$13e(a0)

	lea	$1ae(a0),a1
	moveq	#16-1,d7

.SetLop1
	move.w	#$8000,(a1)
	add.l	#16,a1
	dbra	d7,.SetLop1

	lea	$38e(a0),a1
	moveq	#6-1,d7

.SetLop2
	move.w	#$8000,(a1)
	add.l	#16,a1
	dbra	d7,.SetLop2

	rts


*---------------------------------------------------*

DoEditStores
	tst.w	BaseToEdit
	bne	MainLoop

	bsr	InitiliseStoresValues
	bsr	OpenEditStoresWindow

StoresLoop
	moveq	#1,d1
	CALLDOS	Delay

	move.l	EditStoresWnd(pc),a0
	move.l	wd_UserPort(a0),a0
	CALLGAD	GetIMsg
	tst.l	d0
	beq	DoStoreLoop

	move.l	d0,a1
	move.l	im_Class(a1),d2
	move.w	im_Code(a1),d3
	move.w	im_Qualifier(a1),d4
	move.l	im_IAddress(a1),SelectedGadget
	CALLGAD	ReplyIMsg

	cmp.l	#GADGETUP,d2
	bne	DoStoreLoop

	move.l	SelectedGadget(pc),a0
	moveq	#0,d0
	move.w	gg_GadgetID(a0),d0

	cmp.w	#GD_ExitStores,d0
	beq.s	ExitStoresGotoMainLoop

	cmp.w	#GD_CraftWeapon,d0
	beq.s	UpdateCraftCycle

	cmp.w	#GD_HWPCycle,d0
	beq	UpdateHWPCycle

	cmp.w	#GD_XcomArmCycle,d0
	beq	UpdateXCOMArmCycle

	cmp.w	#GD_XcomMiscCycle,d0
	beq	UpdateXcomMiscCycle

	cmp.w	#GD_AlienWeaponsCycle,d0
	beq	UpdateAlienWeaponCycle

	cmp.w	#GD_AliensCycle,d0
	beq	UpdateAliensCycle

	cmp.w	#GD_AlienMiscCycle,d0
	beq	UpdateAlienMiscCycle

	cmp.w	#GD_Value1,d0
	beq	ChangeVal1

	cmp.w	#GD_Value2,d0
	beq	ChangeVal2

	cmp.w	#GD_Value3,d0
	beq	ChangeVal3

	cmp.w	#GD_Value4,d0
	beq	ChangeVal4

	cmp.w	#GD_Value5,d0
	beq	ChangeVal5

	cmp.w	#GD_Value6,d0
	beq	ChangeVal6

	cmp.w	#GD_Value7,d0
	beq	ChangeVal7

	cmp.w	#GD_MoneyValue,d0
	beq	ChangeMoney

DoStoreLoop
	bra	StoresLoop

ExitStoresGotoMainLoop
	bsr	CloseEditStoresWindow
	bra	MainLoop

UpdateCraftCycle
	move.w	d3,CraftWeaponCount

	lea	CraftWeaponTable,a1
	move.l	ValueGadget1,a2
	lea	Val1Attr,a3
	bsr	ChangeWindowValue

	bra	StoresLoop

UpdateHWPCycle
	move.w	d3,HWPCount

	lea	HWPTableA,a1
	move.l	ValueGadget2,a2
	lea	Val2Attr,a3
	bsr	ChangeWindowValue

	bra	StoresLoop

UpdateXCOMArmCycle
	move.w	d3,XCOMWeaponCount

	lea	XcomArmTable,a1
	move.l	ValueGadget3,a2
	lea	Val3Attr,a3
	bsr	ChangeWindowValue

	bra	StoresLoop

UpdateXcomMiscCycle
	move.w	d3,XCOMMiscCount

	lea	XcomMiscTableA,a1
	move.l	ValueGadget4,a2
	lea	Val4Attr,a3
	bsr	ChangeWindowValue

	bra	StoresLoop

UpdateAlienWeaponCycle
	move.w	d3,AlienWeaponCount

	lea	AlienWeaponsTable,a1
	move.l	ValueGadget5,a2
	lea	Val5Attr,a3
	bsr	ChangeWindowValue

	bra	StoresLoop

UpdateAliensCycle
	move.w	d3,AlienCount

	lea	AliensTable,a1
	move.l	ValueGadget6,a2
	lea	Val6Attr,a3
	bsr	ChangeWindowValue

	bra	StoresLoop

UpdateAlienMiscCycle
	move.w	d3,AlienMiscCount

	lea	AlienMiscTable,a1
	move.l	ValueGadget7,a2
	lea	Val7Attr,a3
	bsr	ChangeWindowValue

	bra	StoresLoop
	
ChangeMoney
	move.l	gg_SpecialInfo(a0),a0
	move.l	si_LongInt(a0),Money
	bra	StoresLoop

ChangeVal1
	move.l	gg_SpecialInfo(a0),a0
	move.l	si_LongInt(a0),d0
	lea	CraftWeaponTable(pc),a1
	move.w	CraftWeaponCount(pc),d1
	add.w	d1,d1
	move.w	d0,(a1,d1.w)
	bra	StoresLoop

ChangeVal2
	move.l	gg_SpecialInfo(a0),a0
	move.l	si_LongInt(a0),d0
	lea	HWPTableA(pc),a1
	move.w	HWPCount(pc),d1
	add.w	d1,d1
	move.w	d0,(a1,d1.w)
	bra	StoresLoop

ChangeVal3
	move.l	gg_SpecialInfo(a0),a0
	move.l	si_LongInt(a0),d0
	lea	XcomArmTable(pc),a1
	move.w	XCOMWeaponCount(pc),d1
	add.w	d1,d1
	move.w	d0,(a1,d1.w)
	bra	StoresLoop

ChangeVal4
	move.l	gg_SpecialInfo(a0),a0
	move.l	si_LongInt(a0),d0
	lea	XcomMiscTableA(pc),a1
	move.w	XCOMMiscCount(pc),d1
	add.w	d1,d1
	move.w	d0,(a1,d1.w)
	bra	StoresLoop

ChangeVal5
	move.l	gg_SpecialInfo(a0),a0
	move.l	si_LongInt(a0),d0
	lea	AlienWeaponsTable(pc),a1
	move.w	AlienWeaponCount(pc),d1
	add.w	d1,d1
	move.w	d0,(a1,d1.w)
	bra	StoresLoop

ChangeVal6
	move.l	gg_SpecialInfo(a0),a0
	move.l	si_LongInt(a0),d0
	lea	AliensTable(pc),a1
	move.w	AlienCount(pc),d1
	add.w	d1,d1
	move.w	d0,(a1,d1.w)
	bra	StoresLoop

ChangeVal7
	move.l	gg_SpecialInfo(a0),a0
	move.l	si_LongInt(a0),d0
	lea	AlienMiscTable(pc),a1
	move.w	AlienMiscCount(pc),d1
	add.w	d1,d1
	move.w	d0,(a1,d1.w)
	bra	StoresLoop

ChangeWindowValue
	add.w	d3,d3
	moveq	#0,d0
	move.w	(a1,d3.w),d0
	move.l	d0,4(a3)

	move.l	(a2),a0
	move.l	EditStoresWnd,a1
	sub.l	a2,a2

	CALLGAD	SetGadgetAttrsA
	rts

*---------------------------------------------------------------------------*

DoEditFacility
	bsr	SetBaseEditGadgets
	bsr	OpenEditFacilityWindow
	clr.w	CurrentFacility


FacilityLoop
	moveq	#1,d1
	CALLDOS	Delay

	move.l	EditFacilityWnd(pc),a0
	move.l	wd_UserPort(a0),a0
	CALLGAD	GetIMsg
	tst.l	d0
	beq.s	DoFacilityLoop

	move.l	d0,a1
	move.l	im_Class(a1),d2
	move.w	im_Code(a1),d3
	move.w	im_Qualifier(a1),d4
	move.l	im_IAddress(a1),SelectedGadget
	CALLGAD	ReplyIMsg

	cmp.l	#GADGETUP,d2
	bne	DoStoreLoop

	move.l	SelectedGadget(pc),a0
	moveq	#0,d0
	move.w	gg_GadgetID(a0),d0

	cmp.w	#GD_Map36,d0
	bgt.s	CheckOtherFacilityGadgets

	cmp.w	#GD_Map1,d0
	bge.s	DoEditBase

CheckOtherFacilityGadgets
	cmp.w	#GD_FacilityCycle,d0
	beq.s	UpdateSelectedFacility

	cmp.w	#GD_FacilityExit,d0
	beq.s	ExitFacilityGotoMainLoop

DoFacilityLoop
	bra.s	FacilityLoop

ExitFacilityGotoMainLoop
	bsr	CloseEditFacilityWindow
	bra	MainLoop

UpdateSelectedFacility
	move.w	d3,CurrentFacility
	bra	FacilityLoop

DoEditBase
	bsr	EditBase
	bra	FacilityLoop

*---------------------------------------------------------------------------*

exit_UFO_Cheat
	bsr	CloseUFO_EditorWindow
	bsr	CloseDownScreen

exit_closereq
	move.l	_ReqBase(pc),a1
	CALLEXEC CloseLibrary

exit_closegad
	move.l	_GadToolsBase(pc),a1
	CALLEXEC CloseLibrary

exit_closegraf
	move.l	_GfxBase(pc),a1
	CALLEXEC CloseLibrary

exit_closeint
	move.l	_IntuitionBase(pc),a1
	CALLEXEC CloseLibrary

	bsr	_PrintClose		;free printf memory

exit_now
	moveq	#0,d0
	rts

hello		dc.b	"You Pressed gadget %ld !",10,0
		even
hello.arg	dc.l	911
		even


SetupScreen
	movem.l d1-d3/a0-a2/a6,-(sp)
	move.l  PubScreenName,a0
	CALLINT	LockPubScreen
	move.l  d0,Scr

	tst.l   d0
	beq.s	SError

	moveq   #0,d2
	moveq   #0,d3
	bsr	 ComputeFont
	move.l  Scr,a0
	lea.l   TD,a1
	CALLGAD	GetVisualInfoA
	move.l  d0,VisualInfo
	tst.l   d0
	beq.s	VError
	moveq   #0,d0
SDone
	movem.l (sp)+,d1-d3/a0-a2/a6
	rts
SError
	moveq   #1,d0
	bra.s   SDone
VError
	moveq   #2,d0
	bra.s   SDone

CloseDownScreen
	movem.l d0-d1/a0-a1/a6,-(sp)
	move.l  VisualInfo,a0
	cmp.l	#0,a0
	beq.s   NoVis
	CALLGAD	FreeVisualInfo
	move.l  #0,VisualInfo
NoVis
	suba.l  a0,a0
	move.l  Scr,a1
	cmp.l	#0,a1
	beq.s   NoScr
	CALLINT	UnlockPubScreen
	move.l  #0,Scr
NoScr
	movem.l (sp)+,d0-d1/a0-a1/a6
	rts

OpenUFO_EditorWindow
	movem.l d1-d4/a0-a4/a6,-(sp)
	move.l  Scr,a0
	moveq   #0,d3
	moveq   #0,d2
	move.w  UFO_EditorWidth,d2
	move.w  UFO_EditorHeight,d3
	bsr	 ComputeFont
	move.l  Scr,a0
	move.l  d2,d0
	bsr	 ComputeX
	move.l  d0,d4
	move.w  UFO_EditorLeft,d2
	add.w   d2,d0
	add.w   OffX,d0
	add.b   sc_WBorRight(a0),d0
	cmp.w   sc_Width(a0),d0
	bls.s   UFO_EditorWOk
	move.w  sc_Width(a0),d0
	sub.w   d4,d0
	move.w  d0,d2

UFO_EditorWOk
	move.l  d3,d0
	bsr	 ComputeY
	move.l  d0,d4
	move.w  UFO_EditorTop,d3
	add.w   d3,d0
	add.w   OffY,d0
	add.b   sc_WBorBottom(a0),d0
	cmp.w   sc_Height(a0),d0
	bls.s   UFO_EditorHOk
	move.w  sc_Height(a0),d0
	sub.w   d4,d0
	move.w  d0,d3

UFO_EditorHOk
	lea.l   UFO_EditorGList,a0
	CALLGAD	CreateContext
	move.l  d0,a3
	tst.l   d0
	beq	 UFO_EditorCError
	movem.w d2-d3,-(sp)
	moveq   #0,d3
	lea.l   UFO_EditorGTags,a4

UFO_EditorGL
	lea.l   UFO_EditorNGads,a0
	move.l  d3,d0
	mulu	#gng_SIZEOF,d0
	add.l   d0,a0
	lea.l   BufNewGad,a1
	moveq   #gng_SIZEOF,d0
	CALLEXEC CopyMem

	lea.l   BufNewGad,a0
	move.l  VisualInfo,gng_VisualInfo(a0)
	move.l  Font,gng_TextAttr(a0)
	move.w  gng_LeftEdge(a0),d0
	bsr	 ComputeX
	add.w   OffX,d0
	move.w  d0,gng_LeftEdge(a0)
	move.w  gng_TopEdge(a0),d0
	bsr	 ComputeY
	add.w   OffY,d0
	move.w  d0,gng_TopEdge(a0)
	move.w  gng_Width(a0),d0
	bsr	 ComputeX
	move.w  d0,gng_Width(a0)
	move.w  gng_Height(a0),d0
	bsr	 ComputeY
	move.w  d0,gng_Height(a0)
	lea.l   UFO_EditorGTypes,a0
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
	bne.s	UFO_EditorCOK
	movem.w (sp)+,d2-d3
	bra	 UFO_EditorCError

UFO_EditorCOK
	move.l  d0,a3
	move.l  d3,d0
	asl.l   #2,d0
	lea.l   UFO_EditorGadgets,a0
	add.l   d0,a0
	move.l  a3,(a0)

UFO_EditorTL
	tst.l   (a4)
	beq.s   UFO_EditorDN
	addq.w  #8,a4
	bra.s   UFO_EditorTL

UFO_EditorDN
	addq.w  #4,a4
	addq.w  #1,d3
	cmp.w   #UFO_Editor_CNT,d3
	bmi	UFO_EditorGL
	movem.w	(sp)+,d2-d3
	move.l	UFO_EditorGList,UFO_EditorWG+4
	move.l	Scr,UFO_EditorSC+4
	ext.l	d2
	ext.l	d3
	move.l	d2,UFO_EditorL+4
	move.l	d3,UFO_EditorT+4
	move.l	Scr,a0
	move.w	UFO_EditorWidth,d0
	bsr	ComputeX
	add.w   OffX,d0
	add.b   sc_WBorRight(a0),d0
	move.l  d0,UFO_EditorW+4
	move.w  UFO_EditorHeight,d0
	bsr	ComputeY
	add.w   OffY,d0
	add.b   sc_WBorBottom(a0),d0
	move.l  d0,UFO_EditorH+4
	suba.l  a0,a0
	lea.l   UFO_EditorWindowTags,a1
	CALLINT	OpenWindowTagList

	move.l  d0,UFO_EditorWnd
	tst.l   d0
	beq.s	UFO_EditorWError
	move.l  UFO_EditorWnd,a0
	suba.l  a1,a1
	CALLGAD	RefreshWindow
	moveq   #0,d0

UFO_EditorDone
	movem.l (sp)+,d1-d4/a0-a4/a6
	rts

UFO_EditorCError
	moveq   #1,d0
	bra.s   UFO_EditorDone

UFO_EditorGError
	moveq   #2,d0
	bra.s   UFO_EditorDone

UFO_EditorWError
	moveq   #4,d0
	bra.s   UFO_EditorDone

CloseUFO_EditorWindow
	movem.l d0-d1/a0-a2/a6,-(sp)
	move.l  UFO_EditorWnd,a0
	cmpa.l  #0,a0
	beq.s	UFO_EditorNWnd
	CALLINT	CloseWindow
	move.l  #0,UFO_EditorWnd

UFO_EditorNWnd
	move.l  UFO_EditorGList,a0
	cmpa.l  #0,a0
	beq.s	UFO_EditorNGad
	CALLGAD	FreeGadgets
	move.l  #0,UFO_EditorGList

UFO_EditorNGad
	movem.l (sp)+,d0-d1/a0-a2/a6
	rts

ComputeX
	move.l  d1,-(sp)
	move.w  FontX,d1
	bra.s   ComputeItX
ComputeY
	move.l  d1,-(sp)
	move.w  FontY,d1
	mulu	d1,d0
	addq.w  #4,d0
	divu	#8,d0
	move.l  (sp)+,d1
	rts

ComputeItX
	mulu	d1,d0
	addq.w  #4,d0
	divu	#8,d0
	move.l  (sp)+,d1
	rts

ComputeFont
	lea.l   Attr,a0
	move.l  a0,Font
	move.l  Scr,a1
	lea.l   sc_RastPort(a1),a1
	move.l  rp_Font(a1),a1
	move.l  LN_NAME(a1),ta_Name(a0)
	move.w  tf_YSize(a1),ta_YSize(a0)
	move.w  tf_XSize(a1),FontX
	move.w  tf_YSize(a1),FontY
	move.l  Scr,a0
	move.b  sc_WBorLeft(a0),d0
	ext.w   d0
	move.w  d0,OffX
	move.l  sc_Font(a0),a1
	move.w  ta_YSize(a1),d0
	addq.w  #1,d0
	add.b   sc_WBorTop(a0),d0
	move.w  d0,OffY
	tst.w   d2
	beq.s   CompDone
	tst.w   d3
	beq.s   CompDone
	move.w  d2,d0
	bsr	 ComputeX
	add.w   OffX,d0
	add.b   sc_WBorRight(a0),d0
	cmp.w   sc_Width(a0),d0
	bhi.s   UseTopaz
	move.w  d3,d0
	bsr	 ComputeY
	add.w   OffY,d0
	add.b   sc_WBorBottom(a0),d0
	cmp.w   sc_Height(a0),d0
	bhi.s   UseTopaz
CompDone
	rts
UseTopaz
	move.l  Font,a0
	move.l  #TopazName,ta_Name(a0)
	move.w  #8,FontY
	move.w  #8,FontX
	move.w  #8,ta_YSize(a0)
	rts

	incdir		includes/
	include		File.Handling.s
	include		Printf.s
	include		Stores.s
	include		Facility.s
	


*****************************************************************************
*
*	Variables and Constants
*
********

IntuitionName	INTNAME
GfxName		GRAFNAME
ReqName		REQTOOLSNAME
GadName		dc.b	'gadtools.library',0
	even
DosName		DOSNAME
		even

_MemPtr1:	dc.l	0
_DosOutput:	dc.l	0

_DOSBase	dc.l	0
_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_GadToolsBase	dc.l	0
_SysBase	dc.l	0
_ReqBase	dc.l	0

SelectedGadget	dc.l	0
BaseToEdit	dc.w	0

CraftWeaponCount	dc.w	0
HWPCount		dc.w	0
XCOMWeaponCount		dc.w	0
XCOMMiscCount		dc.w	0
AlienWeaponCount	dc.w	0
AlienCount		dc.w	0
AlienMiscCount		dc.w	0

SaveFacility	dc.b	0
SaveUfoPedia	dc.b	0
SaveResearch	dc.b	0
SaveProducts	dc.b	0

*---------------------------------------------------------------------------*

GD_BaseIcon		equ	0
GD_StoresIcon		equ	1
GD_ConstructionIcon	equ	2
GD_LoadIcon		equ	3
GD_SaveIcon		equ	4
GD_QuitIcon		equ	5
GD_FacilityIcon		equ	6
GD_UFOPediaIcon		equ	7
GD_ResearchIcon		equ	8
GD_ProductIcon		equ	9
GD_BaseSelect		equ	10

UFO_Editor_CNT		equ	11

Scr
	dc.l	0
VisualInfo
	dc.l	0
PubScreenName
	dc.l	0
UFO_EditorWnd
	dc.l	0
UFO_EditorGList
	dc.l	0
UFO_EditorGadgets
	dcb.l	11,0
BufNewGad
	dc.w	0,0,0,0
	dc.l	0,0
	dc.w	0
	dc.l	0,0,0
TD
	dc.l	TAG_DONE
UFO_EditorLeft
	dc.w	110
UFO_EditorTop
	dc.w	31
UFO_EditorWidth
	dc.w	374
UFO_EditorHeight
	dc.w	120
Font
	dc.l	0
FontX
	dc.w	0
FontY
	dc.w	0
OffX
	dc.w	0
OffY
	dc.w	0
Attr
	dc.l	0
	dc.w	0
	dc.b	0,0
TopazName
	dc.b	'topaz.font',0
	even

UFO_EditorGTypes
	dc.w	BUTTON_KIND
	dc.w	BUTTON_KIND
	dc.w	BUTTON_KIND
	dc.w	BUTTON_KIND
	dc.w	BUTTON_KIND
	dc.w	BUTTON_KIND
	dc.w	BUTTON_KIND
	dc.w	BUTTON_KIND
	dc.w	BUTTON_KIND
	dc.w	BUTTON_KIND
	dc.w	SLIDER_KIND


UFO_EditorNGads
	dc.w	14,6,173,15
	dc.l	BaseIconText,0
	dc.w	GD_BaseIcon
	dc.l	PLACETEXT_IN,0,0

	dc.w	14,25,173,15
	dc.l	StoresIconText,0
	dc.w	GD_StoresIcon
	dc.l	PLACETEXT_IN,0,0

	dc.w	14,44,173,15
	dc.l	ConstructionIconText,0
	dc.w	GD_ConstructionIcon
	dc.l	PLACETEXT_IN,0,0

	dc.w	45,100,63,15
	dc.l	LoadIconText,0
	dc.w	GD_LoadIcon
	dc.l	PLACETEXT_IN,0,0

	dc.w	158,100,63,15
	dc.l	SaveIconText,0
	dc.w	GD_SaveIcon
	dc.l	PLACETEXT_IN,0,0

	dc.w	271,100,63,15
	dc.l	QuitIconText,0
	dc.w	GD_QuitIcon
	dc.l	PLACETEXT_IN,0,0

	dc.w	104,63,173,15
	dc.l	FacilityIconText,0
	dc.w	GD_FacilityIcon
	dc.l	PLACETEXT_IN,0,0

	dc.w	194,6,173,15
	dc.l	UFOPediaIconText,0
	dc.w	GD_UFOPediaIcon
	dc.l	PLACETEXT_IN,0,0

	dc.w	194,25,173,15
	dc.l	ResearchIconText,0
	dc.w	GD_ResearchIcon
	dc.l	PLACETEXT_IN,0,0

	dc.w	194,44,173,15
	dc.l	ProductIconText,0
	dc.w	GD_ProductIcon
	dc.l	PLACETEXT_IN,0,0

	DC.W	190,83,120,11
	DC.l	BaseSelectText,0
	DC.W	GD_BaseSelect
	DC.L	PLACETEXT_LEFT,0,0


UFO_EditorGTags
	dc.l	GA_Disabled,1
	dc.l	TAG_DONE

	dc.l	GA_Disabled,1
	dc.l	TAG_DONE

	dc.l	GA_Disabled,1
	dc.l	TAG_DONE

	dc.l	TAG_DONE

	dc.l	GA_Disabled,1
	dc.l	TAG_DONE

	dc.l	TAG_DONE

	dc.l	GA_Disabled,1
	dc.l	TAG_DONE

	dc.l	GA_Disabled,1
	dc.l	TAG_DONE

	dc.l	GA_Disabled,1
	dc.l	TAG_DONE

	dc.l	GA_Disabled,1
	dc.l	TAG_DONE

SliderAttr
	dc.l	GTSL_Min,1
	dc.l	GTSL_Max
MaxBase	dc.l	1
	dc.l	GTSL_MaxLevelLen,3
	dc.l	GTSL_LevelFormat,BaseSelectFormat
	dc.l	GTSL_LevelPlace,PLACETEXT_RIGHT
	dc.l	PGA_Freedom,LORIENT_HORIZ
	dc.l	GA_RelVerify,1
	dc.l	GA_Disabled
SliderOn
	dc.l	1
	dc.l	TAG_DONE

BaseSelectFormat:
	dc.b	'%ld',0
	even

BaseSelectText:
	dc.b	'Select Base To Edit',0
	even

BaseIconText
	dc.b	'Edit Base',0

StoresIconText
	dc.b	'Edit Stores',0

ConstructionIconText
	dc.b	'Construction Time',0

LoadIconText
	dc.b	'Load',0

SaveIconText
	dc.b	'Save',0

QuitIconText
	dc.b	'Quit',0

FacilityIconText
	dc.b	'All Facilities',0

UFOPediaIconText
	dc.b	'All UFOPedia',0

ResearchIconText
	dc.b	'All Research',0

ProductIconText
	dc.b	'All Products',0
	even

UFO_EditorWindowTags
UFO_EditorL
	dc.l	WA_Left,0
UFO_EditorT
	dc.l	WA_Top,0
UFO_EditorW
	dc.l	WA_Width,0
UFO_EditorH
	dc.l	WA_Height,0
	dc.l	WA_IDCMP,BUTTONIDCMP!IDCMP_CLOSEWINDOW!IDCMP_REFRESHWINDOW
	dc.l	WA_Flags,WFLG_DRAGBAR!WFLG_DEPTHGADGET!WFLG_SMART_REFRESH!ACTIVATE
UFO_EditorWG
	dc.l	WA_Gadgets,0
	dc.l	WA_Title,UFO_EditorWTitle
	dc.l	WA_ScreenTitle,UFO_EditorSTitle
UFO_EditorSC
	dc.l	WA_PubScreen,0
	dc.l	TAG_DONE

UFO_EditorWTitle
	dc.b	'UFO EDITOR ',$a9,' 1995 J.Lucas V1.0',0
	even

UFO_EditorSTitle
	dc.b	'Ufo Mega Editor',0
	even

Facil.Dat	incbin	ufodatafiles/allfacil.dat
FACILLENGTH	equ	*-Facil.Dat
Product.Dat	incbin	ufodatafiles/allproduct.dat
PRODUCTLENGTH	equ	*-Product.Dat
UfoPedia.Dat	incbin	ufodatafiles/allupedia.dat
UFOPEDIALENGTH	equ	*-UfoPedia.Dat

	section	Base,bss
Base.Dat	ds.b	2320

	section	Money,bss
Money.Dat	ds.b	148

	section	Research,bss
Research.Dat	ds.b	1536
RESEARCHLENGTH	equ	*-Research.Dat

