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
	bne	DoLoop

	move.l	SelectedGadget(pc),a0
	moveq	#0,d0
	move.w	gg_GadgetID(a0),d0

	cmp.w	#GD_QuitIcon,d0
	beq.s	exit_UFO_Cheat

	cmp.w	#GD_LoadIcon,d0
	beq.s	DoLoad

	cmp.w	#GD_SaveIcon,d0
	beq.s	DoSave

	move.l	d0,hello.arg
	lea	hello(pc),a0		;format string
	lea	hello.arg(pc),a1	;arguments string
	bsr	printf

DoLoop
	bra.s	MainLoop


DoLoad
	moveq	#FREQ_LOAD,d7
	bsr	request.dir.name
	bra	MainLoop

DoSave
	moveq	#FREQ_SAVE,d7
	bsr	request.dir.name
	bra	MainLoop


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


ComputeX
	move.l  d1,-(sp)
	move.w  FontX,d1
	bra.s   ComputeItX
ComputeY
	move.l  d1,-(sp)
	move.w  FontY,d1
	mulu    d1,d0
	addq.w  #4,d0
	divu    #8,d0
	move.l  (sp)+,d1
	rts

ComputeItX
	mulu    d1,d0
	addq.w  #4,d0
	divu    #8,d0
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
	bsr     ComputeX
	add.w   OffX,d0
	add.b   sc_WBorRight(a0),d0
	cmp.w   sc_Width(a0),d0
	bhi.s   UseTopaz
	move.w  d3,d0
	bsr     ComputeY
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

SetupScreen
	movem.l d1-d3/a0-a2/a6,-(sp)
	move.l  PubScreenName,a0
	CALLINT	LockPubScreen
	move.l  d0,Scr

	tst.l   d0
	beq     SError

	moveq   #0,d2
	moveq   #0,d3
	bsr     ComputeFont
	move.l  Scr,a0
	lea.l   TD,a1
	CALLGAD	GetVisualInfoA
	move.l  d0,VisualInfo
	tst.l   d0
	beq     VError
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
	cmpa.l  #0,a0
	beq.s   NoVis
	CALLGAD	FreeVisualInfo
	move.l  #0,VisualInfo
NoVis
	suba.l  a0,a0
	move.l  Scr,a1
	cmpa.l  #0,a1
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
	bsr     ComputeFont
	move.l  Scr,a0
	move.l  d2,d0
	bsr     ComputeX
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
	bsr     ComputeY
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
	beq     UFO_EditorCError
	movem.w d2-d3,-(sp)
	moveq   #0,d3
	lea.l   UFO_EditorGTags,a4

UFO_EditorGL
	lea.l   UFO_EditorNGads,a0
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
	bne.s    UFO_EditorCOK
	movem.w (sp)+,d2-d3
	bra     UFO_EditorCError

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
	bmi     UFO_EditorGL
	movem.w (sp)+,d2-d3
	move.l  UFO_EditorGList,UFO_EditorWG+4
	move.l  Scr,UFO_EditorSC+4
	ext.l   d2
	ext.l   d3
	move.l  d2,UFO_EditorL+4
	move.l  d3,UFO_EditorT+4
	move.l  Scr,a0
	move.w  UFO_EditorWidth,d0
	bsr     ComputeX
	add.w   OffX,d0
	add.b   sc_WBorRight(a0),d0
	move.l  d0,UFO_EditorW+4
	move.w  UFO_EditorHeight,d0
	bsr     ComputeY
	add.w   OffY,d0
	add.b   sc_WBorBottom(a0),d0
	move.l  d0,UFO_EditorH+4
	suba.l  a0,a0
	lea.l   UFO_EditorWindowTags,a1
	CALLINT	OpenWindowTagList

	move.l  d0,UFO_EditorWnd
	tst.l   d0
	beq     UFO_EditorWError
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
	beq     UFO_EditorNWnd
	CALLINT	CloseWindow
	move.l  #0,UFO_EditorWnd

UFO_EditorNWnd
	move.l  UFO_EditorGList,a0
	cmpa.l  #0,a0
	beq     UFO_EditorNGad
	CALLGAD	FreeGadgets
	move.l  #0,UFO_EditorGList

UFO_EditorNGad
	movem.l (sp)+,d0-d1/a0-a2/a6
	rts


	include	ufo.DirRequester.s
	include	Printf.s
	


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


*---------------------------------------------------------------------------*

GD_BaseIcon                            EQU    0
GD_StoresIcon                          EQU    1
GD_ConstructionIcon                    EQU    2
GD_LoadIcon                            EQU    3
GD_SaveIcon                            EQU    4
GD_QuitIcon                            EQU    5
GD_FacilityIcon                        EQU    6
GD_UFOPediaIcon                        EQU    7
GD_ResearchIcon                        EQU    8
GD_ProductIcon                         EQU    9

UFO_Editor_CNT	equ	10

Scr
	dc.l    0
VisualInfo
	dc.l    0
PubScreenName
	dc.l    0
UFO_EditorWnd
	dc.l    0
UFO_EditorGList
	dc.l    0
UFO_EditorGadgets
	DCB.L    10,0
BufNewGad
	dc.w    0,0,0,0
	dc.l    0,0
	dc.w    0
	dc.l    0,0,0
TD
	dc.l    TAG_DONE
UFO_EditorLeft
	dc.w    110
UFO_EditorTop
	dc.w    31
UFO_EditorWidth
	dc.w    374
UFO_EditorHeight
	dc.w    109
Font
	dc.l    0
FontX
	dc.w    0
FontY
	dc.w    0
OffX
	dc.w    0
OffY
	dc.w    0
Attr
	dc.l    0
	dc.w    0
	dc.b    0,0
TopazName
	dc.b    'topaz.font',0
	even

UFO_EditorGTypes
	dc.w    BUTTON_KIND
	dc.w    BUTTON_KIND
	dc.w    BUTTON_KIND
	dc.w    BUTTON_KIND
	dc.w    BUTTON_KIND
	dc.w    BUTTON_KIND
	dc.w    BUTTON_KIND
	dc.w    BUTTON_KIND
	dc.w    BUTTON_KIND
	dc.w    BUTTON_KIND

UFO_EditorNGads
	dc.w    14,6,170,15
	dc.l    BaseIconText,0
	dc.w    GD_BaseIcon
	dc.l    PLACETEXT_IN,0,0

	dc.w    14,25,173,15
	dc.l    StoresIconText,0
	dc.w    GD_StoresIcon
	dc.l    PLACETEXT_IN,0,0

	dc.w    14,44,173,15
	dc.l    ConstructionIconText,0
	dc.w    GD_ConstructionIcon
	dc.l    PLACETEXT_IN,0,0

	dc.w    45,88,63,15
	dc.l    LoadIconText,0
	dc.w    GD_LoadIcon
	dc.l    PLACETEXT_IN,0,0

	dc.w    158,88,63,15
	dc.l    SaveIconText,0
	dc.w    GD_SaveIcon
	dc.l    PLACETEXT_IN,0,0

	dc.w    271,88,63,15
	dc.l    QuitIconText,0
	dc.w    GD_QuitIcon
	dc.l    PLACETEXT_IN,0,0

	dc.w    104,63,173,15
	dc.l    FacilityIconText,0
	dc.w    GD_FacilityIcon
	dc.l    PLACETEXT_IN,0,0

	dc.w    194,6,173,15
	dc.l    UFOPediaIconText,0
	dc.w    GD_UFOPediaIcon
	dc.l    PLACETEXT_IN,0,0

	dc.w    194,25,173,15
	dc.l    ResearchIconText,0
	dc.w    GD_ResearchIcon
	dc.l    PLACETEXT_IN,0,0

	dc.w    194,44,173,15
	dc.l    ProductIconText,0
	dc.w    GD_ProductIcon
	dc.l    PLACETEXT_IN,0,0

UFO_EditorGTags
	dc.l    TAG_DONE
	dc.l    TAG_DONE
	dc.l    TAG_DONE
	dc.l    TAG_DONE
	dc.l    TAG_DONE
	dc.l    TAG_DONE
	dc.l    TAG_DONE
	dc.l    TAG_DONE
	dc.l    TAG_DONE
	dc.l    TAG_DONE


BaseIconText
	dc.b    'Edit Base',0

StoresIconText
	dc.b    'Edit Stores',0

ConstructionIconText
	dc.b    'Construction Time',0

LoadIconText
	dc.b    'Load',0

SaveIconText
	dc.b    'Save',0

QuitIconText
	dc.b    'Quit',0

FacilityIconText
	dc.b    'Available Facilities',0

UFOPediaIconText
	dc.b    'All UFOPedia',0

ResearchIconText
	dc.b    'All Research',0

ProductIconText
	dc.b    'All Products',0
	even

UFO_EditorWindowTags
UFO_EditorL
	dc.l    WA_Left,0
UFO_EditorT
	dc.l    WA_Top,0
UFO_EditorW
	dc.l    WA_Width,0
UFO_EditorH
	dc.l    WA_Height,0
	dc.l    WA_IDCMP,BUTTONIDCMP!IDCMP_CLOSEWINDOW!IDCMP_REFRESHWINDOW
	dc.l    WA_Flags,WFLG_DRAGBAR!WFLG_DEPTHGADGET!WFLG_SMART_REFRESH
UFO_EditorWG
	dc.l    WA_Gadgets,0
	dc.l    WA_Title,UFO_EditorWTitle
	dc.l    WA_ScreenTitle,UFO_EditorSTitle
UFO_EditorSC
	dc.l    WA_PubScreen,0
	dc.l    TAG_DONE

UFO_EditorWTitle
	dc.b    'UFO Save Game Editor',0
	even

UFO_EditorSTitle
	dc.b    'GadToolsBox v2.0 © 1991-1993',0
	even
