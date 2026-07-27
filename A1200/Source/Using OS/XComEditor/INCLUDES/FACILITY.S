GD_Map1			equ	0
GD_Map2			equ	1
GD_Map3			equ	2
GD_Map4			equ	3
GD_Map5			equ	4
GD_Map6			equ	5
GD_Map7			equ	6
GD_Map8			equ	7
GD_Map9			equ	8
GD_Map10		equ	9
GD_Map11		equ	10
GD_Map12		equ	11
GD_Map13		equ	12
GD_Map14		equ	13
GD_Map15		equ	14
GD_Map16		equ	15
GD_Map17		equ	16
GD_Map18		equ	17
GD_Map19		equ	18
GD_Map20		equ	19
GD_Map21		equ	20
GD_Map22		equ	21
GD_Map23		equ	22
GD_Map24		equ	23
GD_Map25		equ	24
GD_Map26		equ	25
GD_Map27		equ	26
GD_Map28		equ	27
GD_Map29		equ	28
GD_Map30		equ	29
GD_Map31		equ	30
GD_Map32		equ	31
GD_Map33		equ	32
GD_Map34		equ	33
GD_Map35		equ	34
GD_Map36		equ	35
GD_FacilityMX		equ	36
GD_FacilityExit		equ	37
GD_FacilityDefault	equ	38

EditFacility_CNT	equ	39

EditFacilityWnd:
	dc.l	0
EditFacilityGList:
	dc.l	0
EditFacilityGadgets:
	dcb.l	39,0
EditFacilityLeft:
	dc.w	103
EditFacilityTop:
	dc.w	19
EditFacilityWidth:
	dc.w	470
EditFacilityHeight:
	dc.w	159

EditFacilityGTypes:
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
	dc.w	BUTTON_KIND
	dc.w	BUTTON_KIND
	dc.w	BUTTON_KIND
	dc.w	BUTTON_KIND
	dc.w	BUTTON_KIND
	dc.w	BUTTON_KIND
	dc.w	MX_KIND
	dc.w	BUTTON_KIND
	dc.w	BUTTON_KIND

EditFacilityNGads:
MapGadAttr1
	dc.w	15,4,41,21
	dc.l	Map1Text,0
	dc.w	GD_Map1
	dc.l	PLACETEXT_IN,0,0

MapGadAttr2
	dc.w	56,4,41,21
	dc.l	Map2Text,0
	dc.w	GD_Map2
	dc.l	PLACETEXT_IN,0,0

MapGadAttr3
	dc.w	97,4,41,21
	dc.l	Map3Text,0
	dc.w	GD_Map3
	dc.l	PLACETEXT_IN,0,0

MapGadAttr4
	dc.w	138,4,41,21
	dc.l	Map4Text,0
	dc.w	GD_Map4
	dc.l	PLACETEXT_IN,0,0

MapGadAttr5
	dc.w	179,4,41,21
	dc.l	Map5Text,0
	dc.w	GD_Map5
	dc.l	PLACETEXT_IN,0,0

MapGadAttr6
	dc.w	220,4,41,21
	dc.l	Map6Text,0
	dc.w	GD_Map6
	dc.l	PLACETEXT_IN,0,0

MapGadAttr7
	dc.w	15,25,41,21
	dc.l	Map7Text,0
	dc.w	GD_Map7
	dc.l	PLACETEXT_IN,0,0

MapGadAttr8
	dc.w	56,25,41,21
	dc.l	Map8Text,0
	dc.w	GD_Map8
	dc.l	PLACETEXT_IN,0,0

MapGadAttr9
	dc.w	97,25,41,21
	dc.l	Map9Text,0
	dc.w	GD_Map9
	dc.l	PLACETEXT_IN,0,0

MapGadAttr10
	dc.w	138,25,41,21
	dc.l	Map10Text,0
	dc.w	GD_Map10
	dc.l	PLACETEXT_IN,0,0

MapGadAttr11
	dc.w	179,25,41,21
	dc.l	Map11Text,0
	dc.w	GD_Map11
	dc.l	PLACETEXT_IN,0,0

MapGadAttr12
	dc.w	220,25,41,21
	dc.l	Map12Text,0
	dc.w	GD_Map12
	dc.l	PLACETEXT_IN,0,0

MapGadAttr13
	dc.w	15,46,41,21
	dc.l	Map13Text,0
	dc.w	GD_Map13
	dc.l	PLACETEXT_IN,0,0

MapGadAttr14
	dc.w	56,46,41,21
	dc.l	Map14Text,0
	dc.w	GD_Map14
	dc.l	PLACETEXT_IN,0,0

MapGadAttr15
	dc.w	97,46,41,21
	dc.l	Map15Text,0
	dc.w	GD_Map15
	dc.l	PLACETEXT_IN,0,0

MapGadAttr16
	dc.w	138,46,41,21
	dc.l	Map16Text,0
	dc.w	GD_Map16
	dc.l	PLACETEXT_IN,0,0

MapGadAttr17
	dc.w	179,46,41,21
	dc.l	Map17Text,0
	dc.w	GD_Map17
	dc.l	PLACETEXT_IN,0,0

MapGadAttr18
	dc.w	220,46,41,21
	dc.l	Map18Text,0
	dc.w	GD_Map18
	dc.l	PLACETEXT_IN,0,0

MapGadAttr19
	dc.w	15,67,41,21
	dc.l	Map19Text,0
	dc.w	GD_Map19
	dc.l	PLACETEXT_IN,0,0

MapGadAttr20
	dc.w	56,67,41,21
	dc.l	Map20Text,0
	dc.w	GD_Map20
	dc.l	PLACETEXT_IN,0,0

MapGadAttr21
	dc.w	97,67,41,21
	dc.l	Map21Text,0
	dc.w	GD_Map21
	dc.l	PLACETEXT_IN,0,0

MapGadAttr22
	dc.w	138,67,41,21
	dc.l	Map22Text,0
	dc.w	GD_Map22
	dc.l	PLACETEXT_IN,0,0

MapGadAttr23
	dc.w	179,67,41,21
	dc.l	Map23Text,0
	dc.w	GD_Map23
	dc.l	PLACETEXT_IN,0,0

MapGadAttr24
	dc.w	220,67,41,21
	dc.l	Map24Text,0
	dc.w	GD_Map24
	dc.l	PLACETEXT_IN,0,0

MapGadAttr25
	dc.w	15,88,41,21
	dc.l	Map25Text,0
	dc.w	GD_Map25
	dc.l	PLACETEXT_IN,0,0

MapGadAttr26
	dc.w	56,88,41,21
	dc.l	Map26Text,0
	dc.w	GD_Map26
	dc.l	PLACETEXT_IN,0,0

MapGadAttr27
	dc.w	97,88,41,21
	dc.l	Map27Text,0
	dc.w	GD_Map27
	dc.l	PLACETEXT_IN,0,0

MapGadAttr28
	dc.w	138,88,41,21
	dc.l	Map28Text,0
	dc.w	GD_Map28
	dc.l	PLACETEXT_IN,0,0

MapGadAttr29
	dc.w	179,88,41,21
	dc.l	Map29Text,0
	dc.w	GD_Map29
	dc.l	PLACETEXT_IN,0,0

MapGadAttr30
	dc.w	220,88,41,21
	dc.l	Map30Text,0
	dc.w	GD_Map30
	dc.l	PLACETEXT_IN,0,0

MapGadAttr31
	dc.w	15,109,41,21
	dc.l	Map31Text,0
	dc.w	GD_Map31
	dc.l	PLACETEXT_IN,0,0

MapGadAttr32
	dc.w	56,109,41,21
	dc.l	Map32Text,0
	dc.w	GD_Map32
	dc.l	PLACETEXT_IN,0,0

MapGadAttr33
	dc.w	97,109,41,21
	dc.l	Map33Text,0
	dc.w	GD_Map33
	dc.l	PLACETEXT_IN,0,0

MapGadAttr34
	dc.w	138,109,41,21
	dc.l	Map34Text,0
	dc.w	GD_Map34
	dc.l	PLACETEXT_IN,0,0

MapGadAttr35
	dc.w	179,109,41,21
	dc.l	Map35Text,0
	dc.w	GD_Map35
	dc.l	PLACETEXT_IN,0,0

MapGadAttr36
	dc.w	220,109,41,21
	dc.l	Map36Text,0
	dc.w	GD_Map36
	dc.l	PLACETEXT_IN,0,0

	dc.w	425,1,16,8
	dc.l	FacilityMXText,0
	dc.w	GD_FacilityMX
	dc.l	PLACETEXT_LEFT,0,0

	dc.w	47,140,81,13
	dc.l	FacilityExitText,0
	dc.w	GD_FacilityExit
	dc.l	PLACETEXT_IN,0,0

	dc.w	148,140,80,13
	dc.l	FacilityDefaultText,0
	dc.w	GD_FacilityDefault
	dc.l	PLACETEXT_IN,0,0


EditFacilityGTags:
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	GTMX_Labels,FacilityMXLabels
	dc.l	TAG_DONE
	dc.l	TAG_DONE
	dc.l	TAG_DONE


Map1Text:
	dc.b	'  ',0

Map2Text:
	dc.b	'  ',0

Map3Text:
	dc.b	'  ',0

Map4Text:
	dc.b	'  ',0

Map5Text:
	dc.b	'  ',0

Map6Text:
	dc.b	'  ',0

Map7Text:
	dc.b	'  ',0

Map8Text:
	dc.b	'  ',0

Map9Text:
	dc.b	'  ',0

Map10Text:
	dc.b	'  ',0

Map11Text:
	dc.b	'  ',0

Map12Text:
	dc.b	'  ',0

Map13Text:
	dc.b	'  ',0

Map14Text:
	dc.b	'  ',0

Map15Text:
	dc.b	'  ',0

Map16Text:
	dc.b	'  ',0

Map17Text:
	dc.b	'  ',0

Map18Text:
	dc.b	'  ',0

Map19Text:
	dc.b	'  ',0

Map20Text:
	dc.b	'  ',0

Map21Text:
	dc.b	'  ',0

Map22Text:
	dc.b	'  ',0

Map23Text:
	dc.b	'  ',0

Map24Text:
	dc.b	'  ',0

Map25Text:
	dc.b	'  ',0

Map26Text:
	dc.b	'  ',0

Map27Text:
	dc.b	'  ',0

Map28Text:
	dc.b	'  ',0

Map29Text:
	dc.b	'  ',0

Map30Text:
	dc.b	'  ',0

Map31Text:
	dc.b	'  ',0

Map32Text:
	dc.b	'  ',0

Map33Text:
	dc.b	'  ',0

Map34Text:
	dc.b	'  ',0

Map35Text:
	dc.b	'  ',0

Map36Text:
	dc.b	'  ',0

FacilityMXText:
	dc.b	'Select Facility',0

FacilityExitText:
	dc.b	'EXIT',0

FacilityDefaultText:
	dc.b	'Default',0

	CNOP	0,2

FacilityMXLabels:
	dc.l	FacilityMXLab0
	dc.l	FacilityMXLab1
	dc.l	FacilityMXLab2
	dc.l	FacilityMXLab3
	dc.l	FacilityMXLab4
	dc.l	FacilityMXLab5
	dc.l	FacilityMXLab6
	dc.l	FacilityMXLab7
	dc.l	FacilityMXLab8
	dc.l	FacilityMXLab9
	dc.l	FacilityMXLab10
	dc.l	FacilityMXLab11
	dc.l	FacilityMXLab12
	dc.l	FacilityMXLab13
	dc.l	FacilityMXLab14
	dc.l	FacilityMXLab15
	dc.l	FacilityMXLab16
	dc.l	0

FacilityMXLab0		dc.b	'Access Lift',0
FacilityMXLab1		dc.b	'Living Quarters',0
FacilityMXLab2		dc.b	'Laboratory',0
FacilityMXLab3		dc.b	'Workshop',0
FacilityMXLab4		dc.b	'Small Radar',0
FacilityMXLab5		dc.b	'Large Radar',0
FacilityMXLab6		dc.b	'Missile Defence',0
FacilityMXLab7		dc.b	'General Stores',0
FacilityMXLab8		dc.b	'Alien Containment',0
FacilityMXLab9		dc.b	'Laser Defence',0
FacilityMXLab10		dc.b	'Plasma Defence',0
FacilityMXLab11		dc.b	'Fusion Defence',0
FacilityMXLab12		dc.b	'Grav Shield',0
FacilityMXLab13		dc.b	'Mind Shield',0
FacilityMXLab14		dc.b	'Psi-Lab',0
FacilityMXLab15		dc.b	'Hyper Wave Decoder',0
FacilityMXLab16		dc.b	'Hangar',0

	CNOP	0,2

EditFacilityWindowTags
EditFacilityL
	dc.l	WA_Left,0
EditFacilityT
	dc.l	WA_Top,0
EditFacilityW
	dc.l	WA_Width,0
EditFacilityH
	dc.l	WA_Height,0
	dc.l	WA_IDCMP,BUTTONIDCMP!MXIDCMP!IDCMP_CLOSEWINDOW!IDCMP_REFRESHWINDOW
	dc.l	WA_Flags,WFLG_SMART_REFRESH!WFLG_ACTIVATE
EditFacilityWG
	dc.l	WA_Gadgets,0
	dc.l	WA_Title,EditFacilityWTitle
	dc.l	WA_ScreenTitle,EditFacilitySTitle
EditFacilitySC
	dc.l	WA_PubScreen,0
	dc.l	TAG_DONE

EditFacilityWTitle
	dc.b	'Facility Editor : Editing Base - '
FacilityTitle
	ds.b	40
	CNOP	0,2

EditFacilitySTitle
	dc.b	'UFO-Project',0
	CNOP	0,2


OpenEditFacilityWindow
	movem.l d1-d4/a0-a4/a6,-(sp)
	move.l  Scr,a0
	moveq   #0,d3
	moveq   #0,d2
	move.w  EditFacilityWidth,d2
	move.w  EditFacilityHeight,d3
	bsr	ComputeFont
	move.l  Scr,a0
	move.l  d2,d0
	bsr	ComputeX
	move.l  d0,d4
	move.w  EditFacilityLeft,d2
	add.w   d2,d0
	add.w   OffX,d0
	add.b   sc_WBorRight(a0),d0
	cmp.w   sc_Width(a0),d0
	bls.s   EditFacilityWOk
	move.w  sc_Width(a0),d0
	sub.w   d4,d0
	move.w  d0,d2
EditFacilityWOk
	move.l  d3,d0
	bsr	ComputeY
	move.l  d0,d4
	move.w  EditFacilityTop,d3
	add.w   d3,d0
	add.w   OffY,d0
	add.b   sc_WBorBottom(a0),d0
	cmp.w   sc_Height(a0),d0
	bls.s   EditFacilityHOk
	move.w  sc_Height(a0),d0
	sub.w   d4,d0
	move.w  d0,d3
EditFacilityHOk
	lea.l   EditFacilityGList,a0
	CALLGAD	CreateContext
	move.l  d0,a3
	tst.l   d0
	beq	EditFacilityCError
	movem.w d2-d3,-(sp)
	moveq   #0,d3
	lea.l   EditFacilityGTags,a4
EditFacilityGL
	lea.l   EditFacilityNGads,a0
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
	bsr	ComputeX
	add.w   OffX,d0
	move.w  d0,gng_LeftEdge(a0)
	move.w  gng_TopEdge(a0),d0
	bsr	ComputeY
	add.w   OffY,d0
	move.w  d0,gng_TopEdge(a0)
	move.w  gng_Width(a0),d0
	bsr	ComputeX
	move.w  d0,gng_Width(a0)
	move.w  gng_Height(a0),d0
	bsr	ComputeY
	move.w  d0,gng_Height(a0)
	lea.l   EditFacilityGTypes,a0
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
	bne.s	EditFacilityCOK
	movem.w (sp)+,d2-d3
	bra	EditFacilityCError
EditFacilityCOK
	move.l  d0,a3
	move.l  d3,d0
	asl.l   #2,d0
	lea.l   EditFacilityGadgets,a0
	add.l   d0,a0
	move.l  a3,(a0)
EditFacilityTL
	tst.l   (a4)
	beq.s   EditFacilityDN
	addq.w  #8,a4
	bra.s   EditFacilityTL
EditFacilityDN
	addq.w  #4,a4
	addq.w  #1,d3
	cmp.w   #EditFacility_CNT,d3
	bmi	EditFacilityGL
	movem.w (sp)+,d2-d3
	move.l  EditFacilityGList,EditFacilityWG+4
	move.l  Scr,EditFacilitySC+4
	ext.l   d2
	ext.l   d3
	move.l  d2,EditFacilityL+4
	move.l  d3,EditFacilityT+4
	move.l  Scr,a0
	move.w  EditFacilityWidth,d0
	bsr	ComputeX
	add.w   OffX,d0
	add.b   sc_WBorRight(a0),d0
	move.l  d0,EditFacilityW+4
	move.w  EditFacilityHeight,d0
	bsr	ComputeY
	add.w   OffY,d0
	add.b   sc_WBorBottom(a0),d0
	move.l  d0,EditFacilityH+4
	suba.l  a0,a0
	lea.l   EditFacilityWindowTags,a1
	CALLINT	OpenWindowTagList
	move.l  d0,EditFacilityWnd
	tst.l   d0
	beq	EditFacilityWError
	move.l  EditFacilityWnd,a0
	suba.l  a1,a1
	CALLGAD	RefreshWindow
	moveq   #0,d0
EditFacilityDone
	movem.l (sp)+,d1-d4/a0-a4/a6
	rts
EditFacilityCError
	moveq   #1,d0
	bra.s   EditFacilityDone
EditFacilityGError
	moveq   #2,d0
	bra.s   EditFacilityDone
EditFacilityWError
	moveq   #4,d0
	bra.s   EditFacilityDone

CloseEditFacilityWindow
	movem.l d0-d1/a0-a2/a6,-(sp)
	move.l  EditFacilityWnd,a0
	cmpa.l  #0,a0
	beq	EditFacilityNWnd
	CALLINT	CloseWindow
	move.l  #0,EditFacilityWnd
EditFacilityNWnd
	move.l  EditFacilityGList,a0
	cmpa.l  #0,a0
	beq	EditFacilityNGad
	CALLGAD	FreeGadgets
	move.l  #0,EditFacilityGList
EditFacilityNGad
	movem.l (sp)+,d0-d1/a0-a2/a6
	rts


*---------------------------------------------------------*

CurrentFacility		dc.w	0

FacilityTextPointers
	dc.l	Map1Text,Map2Text,Map3Text,Map4Text
	dc.l	Map5Text,Map6Text,Map7Text,Map8Text
	dc.l	Map9Text,Map10Text,Map11Text,Map12Text
	dc.l	Map13Text,Map14Text,Map15Text,Map16Text
	dc.l	Map17Text,Map18Text,Map19Text,Map20Text
	dc.l	Map21Text,Map22Text,Map23Text,Map24Text
	dc.l	Map25Text,Map26Text,Map27Text,Map28Text
	dc.l	Map29Text,Map30Text,Map31Text,Map32Text
	dc.l	Map33Text,Map34Text,Map35Text,Map36Text

MapAttributes
	dc.l	MapGadAttr1,MapGadAttr2,MapGadAttr3,MapGadAttr4
	dc.l	MapGadAttr5,MapGadAttr6,MapGadAttr7,MapGadAttr8
	dc.l	MapGadAttr9,MapGadAttr10,MapGadAttr11,MapGadAttr12
	dc.l	MapGadAttr13,MapGadAttr14,MapGadAttr15,MapGadAttr16
	dc.l	MapGadAttr17,MapGadAttr18,MapGadAttr19,MapGadAttr20
	dc.l	MapGadAttr21,MapGadAttr22,MapGadAttr23,MapGadAttr24
	dc.l	MapGadAttr25,MapGadAttr26,MapGadAttr27,MapGadAttr28
	dc.l	MapGadAttr29,MapGadAttr30,MapGadAttr31,MapGadAttr32
	dc.l	MapGadAttr33,MapGadAttr34,MapGadAttr35,MapGadAttr36

Base.Text
	dc.b	'AC','LQ','LB','WS','SR','LR','MD','GS','AL','LD'
	dc.b	'PD','FD','GR','MS','PL','HW','HA','HA','HA','HA'

EditBase
	move.w	CurrentFacility,d1
	cmp.w	#16,d1
	beq.s	EditHangar

	move.w	BaseToEdit,d2
	mulu	#290,d2			290 = each base size

	lea	Base.Dat,a0
	lea	CONSTTIME(a0,d2.w),a1
	lea	BASESTART(a0,d2.w),a0

	cmp.b	#16,(a0,d0.w)	d0 set on entry to sub routine from 0 >
	bge	ExitEditBase

	move.b	d1,(a0,d0.w)
	move.b	#1,(a1,d0.w)

	add.w	d0,d0
	add.w	d0,d0

	add.w	d1,d1

	lea	FacilityTextPointers(pc),a2
	move.l	(a2,d0.w),a2			get icon text address

	lea	Base.Text(pc),a3
	move.w	(a3,d1.w),(a2)			write new icon description

	lea	MapAttributes(pc),a3
	move.l	(a3,d0.w),a3			a3 = taglist

	lea	EditFacilityGadgets(pc),a0
	move.l	(a0,d0.w),a0			a0 = gadget
	move.l	a0,-(sp)

	move.l	EditFacilityWnd(pc),a1		a1 = window
	sub.l	a2,a2				a2 = req

	CALLGAD	SetGadgetAttrsA

	move.l	(sp)+,a0

	move.l	EditFacilityWnd(pc),a1
	sub.l	a2,a2

	CALLINT	RefreshGadgets
	rts


EditHangar
	cmp.w	#GD_Map30,d0
	bge	ExitEditBase

	cmp.w	#GD_Map6,d0
	beq	ExitEditBase

	cmp.w	#GD_Map12,d0
	beq	ExitEditBase

	cmp.w	#GD_Map18,d0
	beq	ExitEditBase

	cmp.w	#GD_Map24,d0
	beq	ExitEditBase

	move.w	BaseToEdit,d2
	mulu	#290,d2

	lea	Base.Dat,a0
	lea	CONSTTIME(a0,d2.w),a1
	lea	BASESTART(a0,d2.w),a0

	cmp.b	#16,(a0,d0.w)
	bge	ExitEditBase

	cmp.b	#16,1(a0,d0.w)
	bge	ExitEditBase

	cmp.b	#16,6(a0,d0.w)
	bge	ExitEditBase

	cmp.b	#16,7(a0,d0.w)
	bge	ExitEditBase

	move.b	#16,(a0,d0.w)
	move.b	#1,(a1,d0.w)

	move.b	#17,1(a0,d0.w)
	move.b	#1,1(a1,d0.w)

	move.b	#18,6(a0,d0.w)
	move.b	#1,6(a1,d0.w)

	move.b	#19,7(a0,d0.w)
	move.b	#1,7(a1,d0.w)

	add.w	d0,d0
	add.w	d0,d0

	lea	FacilityTextPointers(pc),a2
	move.l	7*4(a2,d0.w),a5
	move.l	6*4(a2,d0.w),a4
	move.l	1*4(a2,d0.w),a3
	move.l	(a2,d0.w),a2

	move.w	#'HA',(a2)
	move.w	#'HA',(a3)
	move.w	#'HA',(a4)
	move.w	#'HA',(a5)

	lea	MapAttributes(pc),a3
	move.l	(a3,d0.w),HangarAttrib
	move.l	1*4(a3,d0.w),HangarAttrib+4
	move.l	6*4(a3,d0.w),HangarAttrib+8
	move.l	7*4(a3,d0.w),HangarAttrib+12

	lea	EditFacilityGadgets(pc),a0
	move.l	(a0,d0.w),HangarGadgets
	move.l	1*4(a0,d0.w),HangarGadgets+4
	move.l	6*4(a0,d0.w),HangarGadgets+8
	move.l	7*4(a0,d0.w),HangarGadgets+12

	lea	HangarGadgets,a5
	lea	HangarAttrib,a4

	moveq	#4-1,d7

UpdateHangar
	move.l	(a5)+,a0
	move.l	(a4)+,a3

	move.l	EditFacilityWnd(pc),a1
	sub.l	a2,a2
	CALLGAD	SetGadgetAttrsA

	dbra	d7,UpdateHangar

	move.l	HangarGadgets,a0
	move.l	EditFacilityWnd(pc),a1
	sub.l	a2,a2
	CALLINT	RefreshGadgets

ExitEditBase
	rts

HangarGadgets	dc.l	0,0,0,0
HangarAttrib	dc.l	0,0,0,0

*---------------------------------------------------------*

SetDefaultBase
	move.w	BaseToEdit,d2
	mulu	#290,d2

	lea	Base.Dat,a2
	lea	BASESTART(a2,d2.w),a0
	lea	CONSTTIME(a2,d2.w),a1

	lea	DefaultBase.data(pc),a2
	lea	DefaultBase.time(pc),a3

	moveq	#36-1,d7

.CopyLoop1
	move.b	(a2)+,(a0)+
	move.b	(a3)+,(a1)+

	dbra	d7,.CopyLoop1

	lea	FacilityTextPointers(pc),a4	icon current text pointers
	lea	DefaultBase.text(pc),a5		new icon text list

	moveq	#36-1,d7
	moveq	#0,d0

.CopyLoop2
	move.l	(a4)+,a3			get icon to change
	move.w	(a5)+,(a3)			write new text

	lea	MapAttributes(pc),a3
	move.l	(a3,d0.w),a3			a3 = taglist

	lea	EditFacilityGadgets(pc),a0
	move.l	(a0,d0.w),a0			a0 = gadget

	move.l	EditFacilityWnd(pc),a1		a1 = window
	sub.l	a2,a2				a2 = req

	movem.l	a4/a5/d0/d7,-(sp)

	CALLGAD	SetGadgetAttrsA

	movem.l	(sp)+,a4/a5/d0/d7

	addq.w	#4,d0

	dbra	d7,.CopyLoop2

	lea	EditFacilityGadgets(pc),a0
	move.l	(a0),a0				a0 = gadget

	move.l	EditFacilityWnd(pc),a1
	sub.l	a2,a2

	CALLINT	RefreshGadgets
	
	rts

*----------------------------*

DefaultBase.data
	dc.b	$ff,$ff,$10,$11,$ff,$ff
	dc.b	$ff,$ff,$12,$13,$ff,$ff
	dc.b	$ff,$ff,$00,$01,$ff,$ff
	dc.b	$ff,$04,$07,$02,$03,$ff
	dc.b	$10,$11,$ff,$ff,$10,$11
	dc.b	$12,$13,$ff,$ff,$12,$13

DefaultBase.time
	dc.b	$ff,$ff,$00,$00,$ff,$ff
	dc.b	$ff,$ff,$00,$00,$ff,$ff
	dc.b	$ff,$ff,$00,$00,$ff,$ff
	dc.b	$ff,$00,$00,$00,$00,$ff
	dc.b	$00,$00,$ff,$ff,$00,$00
	dc.b	$00,$00,$ff,$ff,$00,$00

DefaultBase.text
	dc.w	'  ','  ','HA','HA','  ','  '
	dc.w	'  ','  ','HA','HA','  ','  '
	dc.w	'  ','  ','AC','LQ','  ','  '
	dc.w	'  ','SR','GS','LB','WS','  '
	dc.w	'HA','HA','  ','  ','HA','HA'
	dc.w	'HA','HA','  ','  ','HA','HA'

*---------------------------------------------------------*

SetConstructionTime
	move.w	BaseToEdit,d2
	mulu	#290,d2

	lea	Base.Dat,a0
	lea	CONSTTIME(a0,d2.w),a0

	moveq	#36-1,d7
	moveq	#0,d6

.TimeLoop
	cmp.b	#$ff,(a0,d6.w)		$ff = not built on
	beq.s	.NextTime		00 = building complete

	tst.b	(a0,d6.w)
	beq.s	.NextTime

	move.b	#1,(a0,d6.w)

.NextTime
	addq.w	#1,d6
	dbra	d7,.TimeLoop

	rts


