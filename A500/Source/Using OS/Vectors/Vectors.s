	section	Vectors,code
	opt	o+,ow-

CLOSEWINDOW	equ	$200
MOUSEBUTTONS	equ	$8
WINDOWCLOSE	equ	$8
ACTIVATE	equ	$1000
MENUPICK	equ	$100
GADGETUP	equ	$40
GADGETDOWN	equ	$20
SMART_REFRESH	equ	$0
REPORTMOUSE	equ	$200
SCREEN_VP	equ	$2c
CLASS		equ	$14
CODE		equ	$18
QUALIFIER	equ	$1a
MOUSEX		equ	$20
MOUSEY		equ	$22
WD_USERPORT	equ	$56
WD_RASTPORT	equ	$32
WD_MOUSEX	equ	$e
WD_MOUSEY	equ	$c
MENUENABLED	equ	$1
ITEMTEXT	equ	$2
COMMSEQ		equ	$4
CHECKIT		equ	$1
CHECKED		equ	$100
ITEMENABLED	equ	$10
HIGHCOMP	equ	$40
JAM1		equ	$0
GADGHCOMP	equ	$0
GADGHNONE	equ	$3
GADGIMAGE	equ	$4
GADGHIMAGE	equ	$2
GADG_FLAGS	equ	$c
RELVERIFY	equ	$1
GADGIMMEDIATE	equ	$2
TOGGLESELECT	equ	$100
PROPGADGET	equ	$3
BOOLGADGET	equ	$1
SPECIALINFO	equ	$22
AUTOKNOB	equ	$1
FREEHORIZ	equ	$2
FREEVERT	equ	$4
HORIZPOT	equ	$2


* Open the intuition library

	moveq	#0,d0
	lea	int_name,a1
	move.l	4.w,a6
	jsr	-552(a6)	OpenLibrary
	tst.l	d0
	beq	exit_false
	move.l	d0,_IntuitionBase


* Open the graphics library

	moveq	#0,d0
	lea	grafname,a1
	move.l	4.w,a6
	jsr	-552(a6)	OpenLibrary
	tst.l	d0
	beq	exit_closeint
	move.l	d0,_GfxBase


* Open the DOS library

	moveq	#0,d0
	lea	dosname,a1
	move.l	4.w,a6
	jsr	-552(a6)	OpenLibrary
	tst.l	d0
	beq	exit_closegraf
	move.l	d0,_DOSBase


* Allocate Screen memory

	move.l	#40960,d0
	move.l	#$10002,d1
	move.l	4.w,a6
	jsr	-198(a6)	AllocMem
	tst.l	d0
	beq	exit_closedos
	move.l	d0,ScreenMem


* Allocate Workspace

	move.l	#10240,d0
	move.l	#$10002,d1
	move.l	4.w,a6
	jsr	-198(a6)	AllocMem
	tst.l	d0
	beq	exit_freemem
	move.l	d0,WorkSpace


* Initialize Bitmap

	move.l	_GfxBase,a6
	lea	BitMap,a0
	moveq	#4,d0		4 bitplanes
	move.l	#320,d1		width
	move.l	#256,d2		height
	jsr	-390(a6)	InitBitMap


* Fill Bitmap structure

	move.l	ScreenMem,a0
	lea	BmPlanes,a1
	move.l	a0,(a1)+
	add.l	#10240,a0
	move.l	a0,(a1)+
	add.l	#10240,a0
	move.l	a0,(a1)+
	add.l	#10240,a0
	move.l	a0,(a1)


* Open the screen

	lea	NewScreen,a0
	move.l	_IntuitionBase,a6
	jsr	-198(a6)	OpenScreen
	tst.l	d0
	beq	exit_freemem2
	move.l	d0,Screen


* Change colours

	move.l	Screen,a0
	lea	SCREEN_VP(a0),a0
	lea	colours,a1
	moveq	#16,d0
	move.l	_GfxBase,a6
	jsr	-192(a6)	LoadRGB4


* Open the window

	move.l	Screen,scrnptr
	lea	NewWindow,a0
	move.l	_IntuitionBase,a6
	jsr	-204(a6)	OpenWindow
	tst.l	d0
	beq	exit_closescreen
	move.l	d0,Window
	move.l	d0,a0
	move.l	WD_RASTPORT(a0),RP


* Turn the menu on

	move.l	Window,a0
	move.l	#Menu1,a1
	move.l	_IntuitionBase,a6
	jsr	-264(a6)	SetMenuStrip


* Turn the gadgets on

	move.l	Window,a0
	move.l	#Bool1,a1
	moveq	#-1,d0
	move.l	_IntuitionBase,a6
	jsr	-42(a6)		AddGadget

	move.l	Window,a0
	move.l	#Bool2,a1
	moveq	#-1,d0
	move.l	_IntuitionBase,a6
	jsr	-42(a6)		AddGadget

	move.l	Window,a0
	move.l	#Bool3,a1
	moveq	#-1,d0
	move.l	_IntuitionBase,a6
	jsr	-42(a6)		AddGadget

	move.l	Window,a0
	move.l	#Bool4,a1
	moveq	#-1,d0
	move.l	_IntuitionBase,a6
	jsr	-42(a6)		AddGadget

	move.l	Window,a0
	move.l	#Bool5,a1
	moveq	#-1,d0
	move.l	_IntuitionBase,a6
	jsr	-42(a6)		AddGadget

	move.l	Window,a0
	move.l	#Bool6,a1
	moveq	#-1,d0
	move.l	_IntuitionBase,a6
	jsr	-42(a6)		AddGadget

	move.l	Window,a0
	move.l	#Prop,a1
	moveq	#-1,d0
	move.l	_IntuitionBase,a6
	jsr	-42(a6)		AddGadget

	move.l	#Bool1,a0
	move.l	Window,a1
	move.l	_IntuitionBase,a6
	jsr	-222(a6)	RefreshGadgets


* Print text

	lea	LineItext,a1
	move.w	#0,d0		left
	move.w	#0,d1		top
	bsr	text

* Draw colour boxes

	bsr	colboxes


* Main loop

loop	move.l	Window,a0
	move.l	#$ffff,d0
	move.l	_IntuitionBase,a6
	jsr	-192(a6)	OnMenu
	move.l	Window,a0
	move.l	WD_USERPORT(a0),a0
	move.l	4.w,a6
	jsr	-384(a6)	Waitport
	move.l	Window,a0
	move.l	WD_USERPORT(a0),a0
	move.l	4.w,a6
	jsr	-372(a6)	GetMsg
	tst.l	d0
	beq.s	loop
	move.l	d0,a1
	move.l	CLASS(a1),d2
	move.w	CODE(a1),d3
	move.w	QUALIFIER(a1),d4
	move.l	4.w,a6
	jsr	-378(a6)	ReplyMsg

	cmp.l	#CLOSEWINDOW,d2
	beq.s	end

	cmp.l	#MENUPICK,d2
	bne.s	loop
	moveq	#0,d0
	move.w	d3,d0
	lsr.w	#5,d0
	andi.w	#63,d0		menuitem

domenu	cmpi.w	#0,d0
	bne.s	chkload
	bsr	animate
	bra.s	loop

chkload	cmpi.w	#1,d0
	bne.s	chksave
	bsr	load
	bra	loop

chksave	cmpi.w	#2,d0
	bne.s	chksaveas
	bsr	save
	bra	loop

chksaveas
	cmpi.w	#3,d0
	bne.s	chknew
	bsr	saveas
	bra	loop

chknew	cmpi.w	#4,d0
	bne.s	chkquit
	bsr	new
	bra	loop

chkquit	cmpi.w	#5,d0
	beq.s	end
	bra	loop


* various exit routines that do tidying up

end	move.l	Window,a0
	move.l	#Bool1,a1
	move.l	_IntuitionBase,a6
	jsr	-228(a6)	RemoveGadget

	move.l	Window,a0
	move.l	#Bool2,a1
	move.l	_IntuitionBase,a6
	jsr	-228(a6)	RemoveGadget

	move.l	Window,a0
	move.l	#Bool3,a1
	move.l	_IntuitionBase,a6
	jsr	-228(a6)	RemoveGadget

	move.l	Window,a0
	move.l	#Bool4,a1
	move.l	_IntuitionBase,a6
	jsr	-228(a6)	RemoveGadget

	move.l	Window,a0
	move.l	#Bool5,a1
	move.l	_IntuitionBase,a6
	jsr	-228(a6)	RemoveGadget

	move.l	Window,a0
	move.l	#Bool6,a1
	move.l	_IntuitionBase,a6
	jsr	-228(a6)	RemoveGadget

	move.l	Window,a0
	move.l	#Prop,a1
	move.l	_IntuitionBase,a6
	jsr	-228(a6)	RemoveGadget

	move.l	Window,a0
	move.l	_IntuitionBase,a6
	jsr	-54(a6)		ClearMenuStrip

exit_closewindow
	move.l	Window,a0
	move.l	_IntuitionBase,a6
	jsr	-72(a6)		CloseWindow

exit_closescreen
	move.l	Screen,a0
	move.l	_IntuitionBase,a6
	jsr	-66(a6)		CloseScreen

exit_freemem2
	move.l	WorkSpace,a1
	move.l	#10240,d0
	move.l	4.w,a6
	jsr	-210(a6)	FreeMem

exit_freemem
	move.l	ScreenMem,a1
	move.l	#40960,d0
	move.l	4.w,a6
	jsr	-210(a6)	FreeMem

exit_closedos
	move.l	_DOSBase,a1
	move.l	4.w,a6
	jsr	-414(a6)	CloseLibrary

exit_closegraf
	move.l	_GfxBase,a1
	move.l	4.w,a6
	jsr	-414(a6)	CloseLibrary

exit_closeint
	move.l	_IntuitionBase,a1
	move.l	4.w,a6
	jsr	-414(a6)	CloseLibrary

exit_false
	rts


;""""""""""""""""""""
;" MENU SUBROUTINES "
;"		    "
;""""""""""""""""""""

animate	rts

load	rts

save	rts

saveas	rts

new	rts


;""""""""""""""""""""""""
;" GRAPHICS SUBROUTINES "
;"			"
;""""""""""""""""""""""""

colboxes
	move.w	boxcolour,d0
	bsr	pen
	move.w	#232,d4		x1
	moveq	#3,d5		count-1
colboxloop
	bsr.s	boxcolumn
	add.w	#21,d4		update x1
	dbra	d5,colboxloop
	rts

boxcolumn
	move.w	d4,d0		x1
	move.w	d0,d2
	add.w	#20,d2		x2
	move.w	#163,d1		y1
	move.w	#182,d3		y2
	moveq	#3,d6		count-1
boxcloop
	movem.w	d0-d3,-(sp)
	bsr	filled_rect
	addq.w	#1,boxcolour
	move.w	boxcolour,d0
	bsr.s	pen
	movem.w	(sp)+,d0-d3
	add.w	#20,d1		update y1
	add.w	#20,d3		update y2
	dbra	d6,boxcloop
	rts

boxcolour
	dc.w	0


move	move.l	RP,a0
	move.l	_GfxBase,a6
	jsr	-240(a6)	Move
	rts

line	move.l	RP,a0
	move.l	_GfxBase,a6
	jsr	-246(a6)	Draw
	rts

fill	move.l	RP,a1
	move.l	_GfxBase,a6
	jsr	-306(a6)	RectFill
	rts

text	move.l	RP,a0
	move.l	_IntuitionBase,a6
	jsr	-216(a6)	PrintItext
	rts

plot	move.l	RP,a1
	move.l	_GfxBase,a6
	jsr	-324(a6)	WritePixel
	rts

pen	move.l	RP,a1
	move.l	_GfxBase,a6
	jsr	-342(a6)	SetAPen
	rts


filled_rect
	move.l	RP,a1
	move.l	_GfxBase,a6
	jsr	-306(a6)	RectFill
	rts

outline_rect
	move.l	RP,a1
	move.l	_GfxBase,a6
	lea	rectlist,a2
	move.w	d0,(a2)+	store corner points in turn
	move.w	d1,(a2)+
	move.w	d0,(a2)+
	move.w	d3,(a2)+
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	move.w	d2,(a2)+
	move.w	d1,(a2)+
	move.w	d0,(a2)+
	move.w	d1,(a2)+
	jsr	-240(a6)	Move
	move.w	#5,d0		number of pairs of co-ordinates
	lea	rectlist,a0
	jsr	-336(a6)	PolyDraw
	rts

rectlist	ds.w	10


* Variables

_IntuitionBase	dc.l	0	
_DOSBase	dc.l	0
_GfxBase	dc.l	0
ScreenMem	dc.l	0
WorkSpace	dc.l	0
Screen		dc.l	0
Window		dc.l	0
RP		dc.l	0


* Constants

int_name	dc.b	'intuition.library',0
	even
dosname		dc.b	'dos.library',0
	even
grafname	dc.b	'graphics.library',0
	even
screen_title	dc.b	" VECTORS by D.Vernon 1990",0
	even

Menu1Name	dc.b	'Project',0
	even
Menu1Text1	dc.b	'Animate',0
	even
Menu1Text2	dc.b	'Load',0
	even
Menu1Text3	dc.b	'Save',0
	even
Menu1Text4	dc.b	'Save As',0
	even
Menu1Text5	dc.b	'New',0
	even
Menu1Text6	dc.b	'Quit',0
	even

Bool1Text1	dc.b	'Add Lines',0
	even
Bool1Text2	dc.b	'Move Lines',0
	even

Bool2Text	dc.b	'Store',0
	even

Bool3Text	dc.b	'Delete',0
	even

Bool4Text	dc.b	'Cancel',0
	even

Bool5Text1a	dc.b	'Front &',0
	even
Bool5Text1b	dc.b	'Side',0
	even
Bool5Text2a	dc.b	'Front &',0
	even
Bool5Text2b	dc.b	'Top',0
	even
Bool5Text3a	dc.b	'Side &',0
	even
Bool5Text3b	dc.b	'Top',0
	even
Bool5Text4a	dc.b	'Rear &',0
	even
Bool5Text4b	dc.b	'Side',0
	even
Bool5Text5a	dc.b	'Rear &',0
	even
Bool5Text5b	dc.b	'Bottom',0
	even
Bool5Text6a	dc.b	'Side &',0
	even
Bool5Text6b	dc.b	'Bottom',0
	even

Bool6Texta	dc.b	'Reverse',0
	even
Bool6Textb	dc.b	'views',0
	even

LineText	dc.b	'Line :',0
	even

ModeText	dc.b	'Mode',0
	even

ViewText	dc.b	'View',0
	even


colours	dc.w	$000,$a88,$ecc,$005,$006,$007,$008,$009
	dc.w	$00a,$00b,$00c,$00d,$00e,$000,$311,$cbb


		****************************************
		*				       *
		*   Here are all the screen, window,   *
		*   menu and gadget structures.	       *
		*				       *
		****************************************

* Screen structure

NewScreen	dc.w	0,0		left,top
		dc.w	320,256		width,height
		dc.w	4		depth
		dc.b	0,1		pens
		dc.w	0		viewmodes
		dc.w	$4f		CUSTOMBITMAP & CUSTOMSCREEN
		dc.l	0		font
		dc.l	screen_title	title
		dc.l	0		gadgets
		dc.l	BitMap		bitmap

BitMap		ds.w	1	BytesPerRow
		ds.w	1	Rows
		ds.b	1	Flags
		ds.b	1	Depth
		ds.w	1	Pad
BmPlanes	ds.l	8	Plane pointers


* Window structure

NewWindow	dc.w	0,12	left,top
		dc.w	320,244	width,height
		dc.b	0,1	pens
		dc.l	MOUSEBUTTONS!MENUPICK!GADGETUP!GADGETDOWN	IDCMP
		dc.l	ACTIVATE!SMART_REFRESH	flags
		dc.l	0	firstgadget
		dc.l	0	checkmark
		dc.l	0	title
scrnptr		dc.l	0	screen
		dc.l	0	bitmap
		dc.w	0	minwidth
		dc.w	0	minheight
		dc.w	0	maxwidth
		dc.w	0	maxheight
		dc.w	$f	CUSTOMSCREEN


* 'Project' menu structure

Menu1		dc.l	0	next menu
		dc.w	5	left
		dc.w	0	top
		dc.w	60	width
		dc.w	9	height
		dc.w	MENUENABLED	flags
		dc.l	Menu1Name	menu name
		dc.l	Menu1Item1	first menu item
		dc.w	0	jazzx
		dc.w	0	jazzy
		dc.w	0	beatx
		dc.w	0	beaty


Menu1Item1	dc.l	Menu1Item2	next menu item
		dc.w	2	left
		dc.w	0	top
		dc.w	100	width
		dc.w	11	height
		dc.w	ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	0	mutual exclude
		dc.l	Menu1Itext1	intuitext
		dc.l	0	select fill
		dc.b	'A'	alternate command key
		dc.b	0	align to next word
		dc.l	0	subitem
		dc.w	0	next select

Menu1Itext1	dc.b	0	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	2	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	Menu1Text1	text
		dc.l	0	next text


Menu1Item2	dc.l	Menu1Item3	next menu item
		dc.w	2	left
		dc.w	12	top
		dc.w	100	width
		dc.w	11	height
		dc.w	ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	0	mutual exclude
		dc.l	Menu1Itext2	intuitext
		dc.l	0	select fill
		dc.b	'L'	alternate command key
		dc.b	0	align to next word
		dc.l	0	subitem
		dc.w	0	next select

Menu1Itext2	dc.b	0	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	2	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	Menu1Text2	text
		dc.l	0	next text


Menu1Item3	dc.l	Menu1Item4	next menu item
		dc.w	2	left
		dc.w	24	top
		dc.w	100	width
		dc.w	11	height
		dc.w	ITEMTEXT!ITEMENABLED!HIGHCOMP	flags
		dc.l	0	mutual exclude
		dc.l	Menu1Itext3	intuitext
		dc.l	0	select fill
		dc.b	0	alternate command key
		dc.b	0	align to next word
		dc.l	0	subitem
		dc.w	0	next select

Menu1Itext3	dc.b	0	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	2	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	Menu1Text3	text
		dc.l	0	next text


Menu1Item4	dc.l	Menu1Item5	next menu item
		dc.w	2	left
		dc.w	36	top
		dc.w	100	width
		dc.w	11	height
		dc.w	ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	0	mutual exclude
		dc.l	Menu1Itext4	intuitext
		dc.l	0	select fill
		dc.b	'S'	alternate command key
		dc.b	0	align to next word
		dc.l	0	subitem
		dc.w	0	next select

Menu1Itext4	dc.b	0	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	2	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	Menu1Text4	text
		dc.l	0	next text


Menu1Item5	dc.l	Menu1Item6	next menu item
		dc.w	2	left
		dc.w	48	top
		dc.w	100	width
		dc.w	11	height
		dc.w	ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	0	mutual exclude
		dc.l	Menu1Itext5	intuitext
		dc.l	0	select fill
		dc.b	'N'	alternate command key
		dc.b	0	align to next word
		dc.l	0	subitem
		dc.w	0	next select

Menu1Itext5	dc.b	0	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	2	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	Menu1Text5	text
		dc.l	0	next text


Menu1Item6	dc.l	0	next menu item
		dc.w	2	left
		dc.w	60	top
		dc.w	100	width
		dc.w	11	height
		dc.w	ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	0	mutual exclude
		dc.l	Menu1Itext6	intuitext
		dc.l	0	select fill
		dc.b	'Q'	alternate command key
		dc.b	0	align to next word
		dc.l	0	subitem
		dc.w	0	next select

Menu1Itext6	dc.b	0	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	2	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	Menu1Text6	text
		dc.l	0	next text

* Gadget structures

Bool1		dc.l	0	next gadget
		dc.w	231	left
		dc.w	31	top
		dc.w	86	width
		dc.w	15	height
		dc.w	GADGHCOMP	flags
		dc.w	RELVERIFY!GADGIMMEDIATE	activation flags
		dc.w	BOOLGADGET	type
		dc.l	Bool1Border	render
		dc.l	0	select render
		dc.l	Bool1Itext1	text
		dc.l	0	mutual exclude
		dc.l	0	special info
		dc.w	0	gadget ID
		dc.l	0	userdata

Bool1Border	dc.w	0	left
		dc.w	0	top
		dc.b	1	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	5	count
		dc.l	Bool1xy	coordinates
		dc.l	0	nextborder

Bool1xy		dc.w	0,0	x1,y1
		dc.w	85,0	x2,y2
		dc.w	85,14	x3,y3
		dc.w	0,14	x4,y4
		dc.w	0,0	x5,y5

Bool1Itext1	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	7	leftedge
		dc.w	4	topedge
		dc.l	0	font
		dc.l	Bool1Text1	text
		dc.l	0	next text

Bool1Itext2	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	4	leftedge
		dc.w	4	topedge
		dc.l	0	font
		dc.l	Bool1Text2	text
		dc.l	0	next text


Bool2		dc.l	0	next gadget
		dc.w	231	left
		dc.w	48	top
		dc.w	86	width
		dc.w	15	height
		dc.w	GADGHCOMP	flags
		dc.w	RELVERIFY!GADGIMMEDIATE	activation flags
		dc.w	BOOLGADGET	type
		dc.l	Bool2Border	render
		dc.l	0	select render
		dc.l	Bool2Itext	text
		dc.l	0	mutual exclude
		dc.l	0	special info
		dc.w	0	gadget ID
		dc.l	0	userdata

Bool2Border	dc.w	0	left
		dc.w	0	top
		dc.b	1	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	5	count
		dc.l	Bool2xy	coordinates
		dc.l	0	nextborder

Bool2xy		dc.w	0,0	x1,y1
		dc.w	85,0	x2,y2
		dc.w	85,14	x3,y3
		dc.w	0,14	x4,y4
		dc.w	0,0	x5,y5

Bool2Itext	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	23	leftedge
		dc.w	4	topedge
		dc.l	0	font
		dc.l	Bool2Text	text
		dc.l	0	next text


Bool3		dc.l	0	next gadget
		dc.w	231	left
		dc.w	65	top
		dc.w	86	width
		dc.w	15	height
		dc.w	GADGHCOMP	flags
		dc.w	RELVERIFY!GADGIMMEDIATE	activation flags
		dc.w	BOOLGADGET	type
		dc.l	Bool3Border	render
		dc.l	0	select render
		dc.l	Bool3Itext	text
		dc.l	0	mutual exclude
		dc.l	0	special info
		dc.w	0	gadget ID
		dc.l	0	userdata

Bool3Border	dc.w	0	left
		dc.w	0	top
		dc.b	1	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	5	count
		dc.l	Bool3xy	coordinates
		dc.l	0	nextborder

Bool3xy		dc.w	0,0	x1,y1
		dc.w	85,0	x2,y2
		dc.w	85,14	x3,y3
		dc.w	0,14	x4,y4
		dc.w	0,0	x5,y5

Bool3Itext	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	19	leftedge
		dc.w	4	topedge
		dc.l	0	font
		dc.l	Bool3Text	text
		dc.l	0	next text


Bool4		dc.l	0	next gadget
		dc.w	231	left
		dc.w	82	top
		dc.w	86	width
		dc.w	15	height
		dc.w	GADGHCOMP	flags
		dc.w	RELVERIFY!GADGIMMEDIATE	activation flags
		dc.w	BOOLGADGET	type
		dc.l	Bool4Border	render
		dc.l	0	select render
		dc.l	Bool4Itext	text
		dc.l	0	mutual exclude
		dc.l	0	special info
		dc.w	0	gadget ID
		dc.l	0	userdata

Bool4Border	dc.w	0	left
		dc.w	0	top
		dc.b	1	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	5	count
		dc.l	Bool4xy	coordinates
		dc.l	0	nextborder

Bool4xy		dc.w	0,0	x1,y1
		dc.w	85,0	x2,y2
		dc.w	85,14	x3,y3
		dc.w	0,14	x4,y4
		dc.w	0,0	x5,y5

Bool4Itext	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	19	leftedge
		dc.w	4	topedge
		dc.l	0	font
		dc.l	Bool4Text	text
		dc.l	0	next text


Bool5		dc.l	0	next gadget
		dc.w	231	left
		dc.w	112	top
		dc.w	86	width
		dc.w	24	height
		dc.w	GADGHCOMP	flags
		dc.w	RELVERIFY!GADGIMMEDIATE	activation flags
		dc.w	BOOLGADGET	type
		dc.l	Bool5Border	render
		dc.l	0	select render
		dc.l	Bool5Itext1a	text
		dc.l	0	mutual exclude
		dc.l	0	special info
		dc.w	0	gadget ID
		dc.l	0	userdata

Bool5Border	dc.w	0	left
		dc.w	0	top
		dc.b	1	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	5	count
		dc.l	Bool5xy	coordinates
		dc.l	0	nextborder

Bool5xy		dc.w	0,0	x1,y1
		dc.w	85,0	x2,y2
		dc.w	85,23	x3,y3
		dc.w	0,23	x4,y4
		dc.w	0,0	x5,y5

Bool5Itext1a	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	15	leftedge
		dc.w	4	topedge
		dc.l	0	font
		dc.l	Bool5Text1a	text
		dc.l	Bool5Itext1b	next text

Bool5Itext1b	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	27	leftedge
		dc.w	13	topedge
		dc.l	0	font
		dc.l	Bool5Text1b	text
		dc.l	0	next text

Bool5Itext2a	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	15	leftedge
		dc.w	4	topedge
		dc.l	0	font
		dc.l	Bool5Text2a	text
		dc.l	Bool5Itext2b	next text

Bool5Itext2b	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	31	leftedge
		dc.w	13	topedge
		dc.l	0	font
		dc.l	Bool5Text2b	text
		dc.l	0	next text

Bool5Itext3a	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	19	leftedge
		dc.w	4	topedge
		dc.l	0	font
		dc.l	Bool5Text3a	text
		dc.l	Bool5Itext3b	next text

Bool5Itext3b	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	31	leftedge
		dc.w	13	topedge
		dc.l	0	font
		dc.l	Bool5Text3b	text
		dc.l	0	next text

Bool5Itext4a	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	19	leftedge
		dc.w	4	topedge
		dc.l	0	font
		dc.l	Bool5Text4a	text
		dc.l	Bool5Itext4b	next text

Bool5Itext4b	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	27	leftedge
		dc.w	13	topedge
		dc.l	0	font
		dc.l	Bool5Text4b	text
		dc.l	0	next text

Bool5Itext5a	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	19	leftedge
		dc.w	4	topedge
		dc.l	0	font
		dc.l	Bool5Text5a	text
		dc.l	Bool5Itext5b	next text

Bool5Itext5b	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	19	leftedge
		dc.w	13	topedge
		dc.l	0	font
		dc.l	Bool5Text5b	text
		dc.l	0	next text

Bool5Itext6a	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	19	leftedge
		dc.w	4	topedge
		dc.l	0	font
		dc.l	Bool5Text6a	text
		dc.l	Bool5Itext6b	next text

Bool5Itext6b	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	19	leftedge
		dc.w	13	topedge
		dc.l	0	font
		dc.l	Bool5Text6b	text
		dc.l	0	next text


Bool6		dc.l	0	next gadget
		dc.w	231	left
		dc.w	138	top
		dc.w	86	width
		dc.w	24	height
		dc.w	GADGHCOMP	flags
		dc.w	RELVERIFY!GADGIMMEDIATE	activation flags
		dc.w	BOOLGADGET	type
		dc.l	Bool6Border	render
		dc.l	0	select render
		dc.l	Bool6Itexta	text
		dc.l	0	mutual exclude
		dc.l	0	special info
		dc.w	0	gadget ID
		dc.l	0	userdata

Bool6Border	dc.w	0	left
		dc.w	0	top
		dc.b	1	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	5	count
		dc.l	Bool6xy	coordinates
		dc.l	0	nextborder

Bool6xy		dc.w	0,0	x1,y1
		dc.w	85,0	x2,y2
		dc.w	85,23	x3,y3
		dc.w	0,23	x4,y4
		dc.w	0,0	x5,y5

Bool6Itexta	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	15	leftedge
		dc.w	4	topedge
		dc.l	0	font
		dc.l	Bool6Texta	text
		dc.l	Bool6Itextb	next text

Bool6Itextb	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	23	leftedge
		dc.w	13	topedge
		dc.l	0	font
		dc.l	Bool6Textb	text
		dc.l	0	next text


Prop		dc.l	0	next gadget
		dc.w	231	left
		dc.w	14	top
		dc.w	86	width
		dc.w	15	height
		dc.w	GADGHCOMP	flags
		dc.w	RELVERIFY!GADGIMMEDIATE	activation flags
		dc.w	PROPGADGET	type
		dc.l	PropImage	render
		dc.l	0	select render
		dc.l	0	text
		dc.l	0	mutual exclude
		dc.l	PropInfo	special info
		dc.w	0	gadget ID
		dc.l	0	userdata

PropImage	dcb.b	20,0

PropInfo	dc.w	AUTOKNOB!FREEHORIZ	flags
		dc.w	0	horizpot
		dc.w	0	vertpot
		dc.w	$3ff	horizbody	($ffff/64)
		dc.w	0	vertbody
		dc.w	0	cwidth
		dc.w	0	cheight
		dc.w	0	hpotres
		dc.w	0	vpotres
		dc.w	0	leftborder
		dc.w	0	topborder


* 'Line :' intuitext structure

LineItext	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	238	leftedge
		dc.w	4	topedge
		dc.l	0	font
		dc.l	LineText	text
		dc.l	ViewItext	next text


* 'View' intuitext structure

ViewItext	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	258	leftedge
		dc.w	102	topedge
		dc.l	0	font
		dc.l	ViewText	text
		dc.l	0	next text
