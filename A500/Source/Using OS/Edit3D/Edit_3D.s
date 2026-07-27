	section	Edit_3D,code_c
	opt	a+

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

* Open the ARP library

	moveq	#0,d0
	lea	arpname,a1
	move.l	4.w,a6
	jsr	-552(a6)	OpenLibrary
	tst.l	d0
	beq	exit_closedos
	move.l	d0,_ARPBase

* Allocate Screen memory

	move.l	#40960,d0
	move.l	#$10002,d1
	move.l	4.w,a6
	jsr	-198(a6)	AllocMem
	tst.l	d0
	beq	exit_closearp
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
	lea	10240(a0),a0
	move.l	a0,(a1)+
	lea	10240(a0),a0
	move.l	a0,(a1)+
	lea	10240(a0),a0
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

* Turn the menu on

	move.l	Window,a0
	move.l	#Menu1,a1
	move.l	_IntuitionBase,a6
	jsr	-264(a6)	SetMenuStrip

* Turn the gadgets on

	move.l	Window,a0
	move.l	#Prop1,a1
	moveq	#0,d0
	moveq	#-1,d0
	move.l	_IntuitionBase,a6
	jsr	-42(a6)		AddGadget

	move.l	Window,a0
	move.l	#Prop2,a1
	moveq	#0,d0
	moveq	#-1,d0
	move.l	_IntuitionBase,a6
	jsr	-42(a6)		AddGadget

	move.l	Window,a0
	move.l	#Prop3,a1
	moveq	#0,d0
	moveq	#-1,d0
	move.l	_IntuitionBase,a6
	jsr	-42(a6)		AddGadget

	move.l	#Prop1,a0
	move.l	Window,a1
	move.l	_IntuitionBase,a6
	jsr	-222(a6)	RefreshGadgets

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
	beq	end
	cmp.l	#MENUPICK,d2
	bne	gadgtest
	moveq	#0,d0
	move.w	d3,d0	separate menu and menuitem
	move.l	d0,d1
	andi.w	#31,d0	menu
	lsr.w	#5,d1
	andi.w	#63,d1	menuitem
	tst.w	d0
	bne.s	domenu2
domenu1
	cmpi.w	#4,d1
	beq	end
chkclear
	cmpi.w	#0,d1
	bne.s	chkload
	bsr	clear
	bra	loop
chkload
	cmpi.w	#1,d1
	bne.s	chksave
	bsr	load
	bra	loop
chksave
	cmpi.w	#2,d1
	bne.s	chksaveas
	bsr	save
	bra	loop
chksaveas
	cmpi.w	#3,d1
	bne	loop
	bsr	saveas
	bra	loop

domenu2
chknew
	cmpi.w	#0,d1
	bne.s	chkedit
	bsr	new
	bra	loop
chkedit
	cmpi.w	#1,d1
	bne.s	chkanim
	bsr	edit
	bra	loop
chkanim
	cmpi.w	#2,d1
	bne	loop
	bsr	animate
	bra	loop

gadgtest
	moveq	#0,d0
	cmp.l	#GADGETUP,d2
	bne	loop
	move.l	#Prop1,a0
	move.l	SPECIALINFO(a0),a0
	move.w	HORIZPOT(a0),d0
	divu	#$b6,d0		(ffff/360)
	move.w	d0,XANGLE

	moveq	#0,d0
	move.l	#Prop2,a0
	move.l	SPECIALINFO(a0),a0
	move.w	HORIZPOT(a0),d0
	divu	#$b6,d0		(ffff/360)
	move.w	d0,YANGLE

	moveq	#0,d0
	move.l	#Prop3,a0
	move.l	SPECIALINFO(a0),a0
	move.w	HORIZPOT(a0),d0
	divu	#$b6,d0		(ffff/360)
	move.w	d0,ZANGLE

	bsr	rot
	bsr	pers
	bsr	draw
	bra	loop


* menu subroutines

clear	move.l	_GfxBase,a6
	jsr	-456(a6)	OwnBlitter
	move.l	ScreenMem,a0
	lea	400(a0),a0	allow for menu bar
wait	cmp.b	#$ff,$dff006	wait for bottom of frame
	bne.s	wait
bltfin	btst	#6,$dff002.l	wait until blitter finished
	bne.s	bltfin
	move.l	a0,$dff054	destination D
	move.w	#$100,$dff040	enable channel D only
	moveq	#0,d0
	move.w	d0,$dff042	bltcon1
	move.w	d0,$dff066	no modulo
	move.w	#%11000010010100,$dff058	go
bltfin2	btst	#6,$dff002.l	wait until blitter finished
	bne.s	bltfin2
	move.l	_GfxBase,a6
	jsr	-462(a6)	DisownBlitter
	rts

load	move.l	Window,FReqWin
	lea	FReq,a0
	move.l	_ARPBase,a6
	jsr	-294(a6)	FileRequest
	rts

save	rts

saveas	rts

new	rts

edit	move.w	#$100,$dff096		bitplane DMA off
	bsr	edwindow
	tst.l	d0
	beq	failed
	bsr	clear2
	move.w	#$8100,$dff096		bitplane DMA on
	bsr	gadgetson
	bsr	linenumber
	bsr	setview
edloop	bsr	getcoords
	move.l	Window2,a0
	move.l	WD_USERPORT(a0),a0
	move.l	4.w,a6
	jsr	-372(a6)	GetMsg
	tst.l	d0
	beq.s	edloop
	move.l	d0,a1
	move.l	CLASS(a1),d2
	move.w	CODE(a1),d3
	move.w	QUALIFIER(a1),d4
	move.l	4.w,a6
	jsr	-378(a6)	ReplyMsg

	cmp.l	#CLOSEWINDOW,d2
	beq	editend
	cmp.l	#MENUPICK,d2
	bne.s	gadgtest2
	moveq	#0,d0
	move.w	d3,d0	separate menu and menuitem
	move.l	d0,d1
	andi.w	#31,d0	menu
	lsr.w	#5,d1
	andi.w	#63,d1	menuitem
chkfront
	cmpi.w	#0,d1
	bne.s	chkside
	bsr	front
	bra.s	edloop
chkside
	cmpi.w	#1,d1
	bne.s	chktop
	bsr	side
	bra.s	edloop
chktop
	cmpi.w	#2,d1
	bne.s	edloop
	bsr	top
	bra.s	edloop
gadgtest2
	cmp.l	#GADGETUP,d2
	bne.s	mousetest
	move.l	Window2,a0
	move.w	WD_MOUSEX(a0),d5
	move.w	WD_MOUSEY(a0),d6
	cmp.w	#199,d6
	ble.s	linechange
chkbool1
	cmp.w	#132,d5
	bge.s	chkbool2
	bsr	dobool1
	bra	edloop
chkbool2
	cmp.w	#239,d5
	bge.s	chkbool3
	bsr	dobool2
	bra	edloop
chkbool3
	cmp.w	#292,d5
	bgt	edloop
	bra.s	editend
linechange
	bsr	linenumber
	bra	edloop

mousetest
	btst	#6,$bfe001.l	left mouse button
	bne.s	notline
	cmp.w	#127,numlines
	beq.s	notline
	bsr	lineloop
	bsr	setcoords
	addq.w	#1,numlines
notline	bra	edloop


editend	bsr	gadgetsoff
	move.l	Window2,a0
	move.l	_IntuitionBase,a6
	jsr	-54(a6)		ClearMenuStrip
	move.l	Window2,a0
	move.l	_IntuitionBase,a6
	jsr	-72(a6)		CloseWindow
failed	rts


;""""""""""""""""""""""""""""""""""""""""
;" Maths routines - rotate point about	"
;" X, Y, Z axes by XANGLE, YANGLE and	"
;" ZANGLE respectively.  Rotations are	"
;" anti-clockwise.			"
;"					"
;" The formulae used are:-		"
;"					"
;" X rotation:	X = X			"
;"		Y2 = Ycos - Zsin	"
;"		Z2 = Ysin + Zcos	"
;"					"
;" Y rotation:	X2 = Xcos + Z2sin	"
;"		Y2 = Y2			"
;"		Z3 = Z2cos - Xsin	"
;"					"
;" Z rotation:	X3 = X2cos - Y2sin	"
;"		Y3 = X2sin + Y2cos	"
;"		Z3 = Z3			"
;"					"
;""""""""""""""""""""""""""""""""""""""""

rot	moveq	#0,d0
	lea	table,a0
	move.w	XANGLE,d0	get sine and cosine of XANGLE
	lsl.w	#1,d0
	move.w	(a0,d0.w),XSIN	sine
	cmp.w	#540,d0
	blt.s	cos1
	sub.w	#540,d0
	bra.s	getcos1
cos1	add.w	#180,d0
getcos1	move.w	(a0,d0.w),XCOS	cosine

	move.w	YANGLE,d0	get sine and cosine of YANGLE
	lsl.w	#1,d0
	move.w	(a0,d0.w),YSIN	sine
	cmp.w	#540,d0
	blt.s	cos2
	sub.w	#540,d0
	bra.s	getcos2
cos2	add.w	#180,d0
getcos2	move.w	(a0,d0.w),YCOS	cosine

	move.w	ZANGLE,d0	get sine and cosine of ZANGLE
	lsl.w	#1,d0
	move.w	(a0,d0.w),ZSIN	sine
	cmp.w	#540,d0
	blt.s	cos3
	sub.w	#540,d0
	bra.s	getcos3
cos3	add.w	#180,d0
getcos3	move.w	(a0,d0.w),ZCOS	cosine

	lea	worldX,a0
	lea	worldY,a1
	lea	worldZ,a2
	lea	newX,a3
	lea	newY,a4
	lea	newZ,a5
	move.w	numpoints,d0
	cmp.w	#-$1,d0		-1 indicates no points
	beq	endrot
	moveq	#14,d4

rotloop	move.w	XSIN,d1		x rotation
	move.w	XCOS,d2
	move.w	(a1),d3	y
	muls	d3,d2	y cos
	move.w	(a2),d3 z
	muls	d3,d1	z sin
	sub.l	d1,d2	y cos-z sin
	lsr.l	d4,d2
	move.w	d2,d6	y2

	move.w	XSIN,d1
	move.w	XCOS,d2
	move.w	(a1)+,d3 y
	muls	d3,d1	y sin
	move.w	(a2)+,d3 z
	muls	d3,d2	z cos
	add.l	d1,d2	y sin+z cos
	lsr.l	d4,d2
	move.w	d2,d7	z2

	move.w	YSIN,d1		y rotation
	move.w	YCOS,d2
	move.w	(a0),d3	x
	muls	d3,d2	x cos
	muls	d7,d1	z2 sin
	add.l	d1,d2	x cos+z2 sin
	lsr.l	d4,d2
	move.w	d2,d5	x2

	move.w	YSIN,d1
	move.w	YCOS,d2
	move.w	(a0)+,d3 x
	muls	d3,d1	x sin
	muls	d7,d2	z2 cos
	sub.l	d1,d2	z2 cos-x sin
	lsr.l	d4,d2
	move.w	d2,(a5)+	z3

	move.w	ZSIN,d1		z rotation
	move.w	ZCOS,d2
	muls	d6,d1	y2 sin
	muls	d5,d2	x2 cos
	sub.l	d1,d2	x2 cos-y2 sin
	lsr.l	d4,d2
	move.w	d2,(a3)+	x3

	move.w	ZSIN,d1
	move.w	ZCOS,d2
	muls	d5,d1	x2 sin
	muls	d6,d2	y2 cos
	add.l	d1,d2	x2 sin+y2 cos
	lsr.l	d4,d2
	move.w	d2,(a4)+	y3

	dbra	d0,rotloop
endrot	rts


;"""""""""""""""""""""""""""""""""
;" Calculate perspective - from  "
;" X, Y, Z world co-ords to X, Y "
;" screen co-ords.		 "
;"				 "
;"""""""""""""""""""""""""""""""""

pers	lea 	newX,a1
	lea 	newY,a2
	lea 	newZ,a3
	lea 	scrX,a4
	lea 	scrY,a5
	move.w 	numpoints,d0
	cmp.w	#-$1,d0		-1 indicates no points
	beq.s	endpers
	ext.l 	d0	
ploop	move.w 	(a3)+,d2	z
	move.w	d2,d3

	move.w 	(a1)+,d1	x
	muls.w 	d1,d2		xz
	lsr.l	#8,d2		xz/256
	add.w 	d2,d1		x + xz/256
	move.w 	d1,(a4)+	x value

	move.w	(a2)+,d1	y
	muls.w	d1,d3		yz
	lsr.l	#8,d3		yz/256
	add.w	d3,d1		y + yz/256
	move.w	d1,(a5)+	y value
	dbra 	d0,ploop
endpers	rts


;"""""""""""""""""""""""""
;" Clear screen and draw "
;" the new image.	 "
;"			 "
;"""""""""""""""""""""""""

draw	move.l	_GfxBase,a6
	jsr	-456(a6)	OwnBlitter
	move.l	ScreenMem,a0
	lea	400(a0),a0	allow for menu bar
wait2	cmp.b	#$ff,$dff006	wait for bottom of frame
	bne.s	wait2
bltfin3	btst	#6,$dff002.l	wait until blitter finished
	bne.s	bltfin3

	move.l	a0,$dff054	destination D
	move.w	#$100,$dff040	enable channel D only
	moveq	#0,d0
	move.w	d0,$dff042	bltcon1
	move.w	d0,$dff066	no modulo
	move.w	#%11000010010100,$dff058	go
		
	lea	lines,a3
	move.w	numlines,d7
	cmp.w	#-$1,d7		-1 indicates no lines
	beq	enddraw
	move.w	#40,a1		width of screen in bytes
	move.w	#$ffff,a2	mask => no pattern
	move.l	#scrX,a4	list of screen x co-ords
	move.l	#scrY,a5	list of screen y co-ords

drawloop
	moveq	#0,d4
	move.b	(a3)+,d4	next point
	lsl.w	#1,d4		multiply by 2

	move.w	(a4,d4.w),d0
	add.w	Xorg,d0		x start
	cmp.w	#319,d0		check it is on screen
	bgt.s	nextline
	cmp.w	#0,d0		check it is on screen
	blt.s	nextline
	move.w	(a5,d4.w),d4		
	move.w	Yorg,d1
	sub.w	d4,d1	Yorg-y start  (quicker than:- 194-(y start+97)
	cmp.w	#164,d1		check it is on screen
	bgt.s	nextline
	cmp.w	#0,d1		check it is on screen
	blt.s	nextline

	moveq	#0,d5
	move.b	(a3)+,d5	next point
	lsl.w	#1,d5		multiply by 2

	move.w	(a4,d5.w),d2
	add.w	Xorg,d2		x end
	cmp.w	#319,d0		check it is on screen
	bgt.s	drawcount
	cmp.w	#0,d0		check it is on screen
	blt.s	drawcount
	move.w	(a5,d5.w),d4
	move.w	Yorg,d3
	sub.w	d4,d3	Yorg-y end  (quicker than:- 194-(y end+97)
	cmp.w	#164,d1		check it is on screen
	bgt.s	drawcount
	cmp.w	#0,d1		check it is on screen
	blt.s	drawcount

	bsr.s	drawline
	bra.s	drawcount
nextline
	move.b	(a3)+,d0	update for next line (value in d0 not needed)
drawcount
	dbra	d7,drawloop
enddraw
bltfin4	btst	#6,$dff002.l	wait until blitter finished
	bne.s	bltfin4
	move.l	_GfxBase,a6
	jsr	-462(a6)	DisownBlitter
	rts


* Drawline routine *

drawline
	moveq	#0,d6	clear this for later
	move.l	a1,d4
	mulu	d1,d4
	moveq	#-16,d5
	and.w	d0,d5
	lsr.w	#3,d5
	add.w	d5,d4
	add.l	a0,d4

	clr.l	d5
	sub.w	d1,d3
	bne.s	netz1	Addition to check for dx & dy both being
;			equal to zero.  If this is not done then
;			a line 1024 pixels high will be produced
;			instead of a single pixel.
	moveq	#1,d6
netz1	roxl.b	#1,d5
	tst.w	d3
	bge.s	y2gy1
	neg.w	d3
y2gy1
	sub.w	d0,d2
	bne.s	netz2	Check for dx being equal to zero.
	cmpi.b	#1,d6	equal to zero also?
	bne.s	netz2
	moveq	#1,d2	if both equal to zero then set dx to 1
netz2	roxl.b	#1,d5
	tst.w	d2
	bge.s	x2gx1
	neg.w	d2
x2gx1
	move.w	d3,d1
	sub.w	d2,d1
	bge.s	dygdx
	exg	d2,d3
dygdx	roxl.b	#1,d5
	move.b	octant_table(pc,d5),d5
	add.w	d2,d2

wblit	btst	#6,$dff002.l
	bne.s	wblit

	move.w	d2,$dff062
	sub.w	d3,d2
	bge.s	signal

	or.b	#$40,d5
signal	move.w	d2,$dff052

	sub.w	d3,d2
	move.w	d2,$dff064

	move.w	#$8000,$dff074
	move.w	a2,$dff072
	move.w	#$ffff,$dff044
	and.w	#$000f,d0
	ror.w	#4,d0
	or.w	#$0bca,d0
	move.w	d0,$dff040
	move.w	d5,$dff042
	move.l	d4,$dff048
	move.l	d4,$dff054
	move.w	a1,$dff060
	move.w	a1,$dff066

	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d3,$dff058
	rts

octant_table
	dc.b	0*4+1
	dc.b	4*4+1
	dc.b	2*4+1
	dc.b	5*4+1
	dc.b	1*4+1
	dc.b	6*4+1
	dc.b	3*4+1
	dc.b	7*4+1

;""""""""""""""""""""""""""""
;" Simple Animation Routine "
;"			    "
;""""""""""""""""""""""""""""

animate	moveq	#0,d0
	move.l	#Prop1,a0
	move.l	SPECIALINFO(a0),a0
	move.w	HORIZPOT(a0),d0
	divu	#$b6,d0		(ffff/360)
	move.w	d0,XINC

	moveq	#0,d0
	move.l	#Prop2,a0
	move.l	SPECIALINFO(a0),a0
	move.w	HORIZPOT(a0),d0
	divu	#$b6,d0		(ffff/360)
	move.w	d0,YINC

	moveq	#0,d0
	move.l	#Prop3,a0
	move.l	SPECIALINFO(a0),a0
	move.w	HORIZPOT(a0),d0
	divu	#$b6,d0		(ffff/360)
	move.w	d0,ZINC

	move.l	Window,a0
	move.l	_IntuitionBase,a6
	jsr	-54(a6)		ClearMenuStrip
animloop
	cmp.w	#360,XANGLE
	ble.s	xok
	sub.w	#360,XANGLE
xok	cmp.w	#360,YANGLE
	ble.s	yok
	sub.w	#360,YANGLE
yok	cmp.w	#360,ZANGLE
	ble.s	zok
	sub.w	#360,ZANGLE
zok	bsr	rot
	bsr	pers
	bsr	draw
	move.w	XINC,d1
	add.w	d1,XANGLE
	move.w	YINC,d1
	add.w	d1,YANGLE
	move.w	ZINC,d1
	add.w	d1,ZANGLE
	btst	#6,$bfe001.l
	bne.s	animloop
	move.l	Window,a0
	move.l	#Menu1,a1
	move.l	_IntuitionBase,a6
	jsr	-264(a6)	SetMenuStrip
	rts


;"""""""""""""""""""""""""""""""
;" The Object Editor routines. "
;"			       "
;"""""""""""""""""""""""""""""""

edwindow
	move.l	Screen,scrnptr2
	lea	NewWindow2,a0
	move.l	_IntuitionBase,a6
	jsr	-204(a6)	OpenWindow
	move.l	d0,Window2
	move.l	d0,a0
	move.l	WD_RASTPORT(a0),RP

	move.l	Window2,a0
	lea	Menu3,a1
	move.l	_IntuitionBase,a6
	jsr	-264(a6)	SetMenuStrip

	move.l	Window2,a0
	lea	Pointer,a1
	moveq	#15,d0		width
	moveq	#15,d1		height
	moveq	#-8,d2		Xoffset
	moveq	#-7,d3		Yoffset
	move.l	_IntuitionBase,a6
	jsr	-270(a6)	SetPointer

	lea	SLineItext,a1
	move.w	#0,d0		left
	move.w	#0,d1		top
	bsr	text

	moveq	#1,d0
	bsr	pen
	move.w	#1,d0
	move.w	#27,d1
	bsr.s	move
	move.w	#318,d0
	move.w	#27,d1
	bsr	line
	move.w	#1,d0
	move.w	#209,d1
	bsr.s	move
	move.w	#318,d0
	move.w	#209,d1
	bsr.s	line
	move.w	#1,d0
	move.w	#225,d1
	bsr.s	move
	move.w	#318,d0
	move.w	#225,d1
	bsr.s	line
	move.w	#2,d0
	move.w	#226,d1
	move.w	#24,d2
	move.w	#242,d3
	bsr.s	fill
	move.w	#82,d0
	move.w	#226,d1
	move.w	#129,d2
	move.w	#242,d3
	bsr.s	fill
	move.w	#189,d0
	move.w	#226,d1
	move.w	#236,d2
	move.w	#242,d3
	bsr.s	fill
	move.w	#295,d0
	move.w	#226,d1
	move.w	#317,d2
	move.w	#242,d3
	bsr.s	fill
	rts

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

gadgetson
	move.l	Window2,a0
	move.l	#Bool1,a1
	moveq	#0,d0
	moveq	#-1,d0
	move.l	_IntuitionBase,a6
	jsr	-42(a6)		AddGadget

	move.l	Window2,a0
	move.l	#Bool2,a1
	moveq	#0,d0
	moveq	#-1,d0
	move.l	_IntuitionBase,a6
	jsr	-42(a6)		AddGadget

	move.l	Window2,a0
	move.l	#Bool3,a1
	moveq	#0,d0
	moveq	#-1,d0
	move.l	_IntuitionBase,a6
	jsr	-42(a6)		AddGadget

	move.l	Window2,a0
	move.l	#Prop4,a1
	moveq	#0,d0
	moveq	#-1,d0
	move.l	_IntuitionBase,a6
	jsr	-42(a6)		AddGadget

	move.l	#Bool1,a0
	move.l	Window2,a1
	move.l	_IntuitionBase,a6
	jsr	-222(a6)	RefreshGadgets
	rts

gadgetsoff
	move.l	Window2,a0
	move.l	#Bool1,a1
	move.l	_IntuitionBase,a6
	jsr	-228(a6)	RemoveGadget

	move.l	Window2,a0
	move.l	#Bool2,a1
	move.l	_IntuitionBase,a6
	jsr	-228(a6)	RemoveGadget

	move.l	Window2,a0
	move.l	#Bool3,a1
	move.l	_IntuitionBase,a6
	jsr	-228(a6)	RemoveGadget

	move.l	Window2,a0
	move.l	#Prop4,a1
	move.l	_IntuitionBase,a6
	jsr	-228(a6)	RemoveGadget
	rts

front	move.b	#1,THISVIEW
	move.w	#0,d0
	bsr	pen
	move.w	#256,d0
	move.w	#214,d1
	move.w	#294,d2
	move.w	#221,d3
	bsr	fill
	lea	FrontItext,a1
	move.w	#256,d0
	move.w	#212,d1
	bsr	text
	move.w	#1,d0
	bsr	pen
	move.w	#0,XANGLE
	move.w	#0,YANGLE
	move.w	#0,ZANGLE
	bsr	rot	get co-ords without perspective
	lea	newX,a4
	lea	newY,a5
	bsr	initobject
	rts

side	move.b	#2,THISVIEW
	move.w	#0,d0
	bsr	pen
	move.w	#256,d0
	move.w	#214,d1
	move.w	#294,d2
	move.w	#221,d3
	bsr	fill
	lea	SideItext,a1
	move.w	#256,d0
	move.w	#212,d1
	bsr	text
	move.w	#1,d0
	bsr	pen
	move.w	#0,XANGLE
	move.w	#0,YANGLE
	move.w	#0,ZANGLE
	bsr	rot	get co-ords without perspective
	lea	newZ,a4
	lea	newY,a5
	bsr	initobject
	rts

top	move.b	#4,THISVIEW
	move.w	#0,d0
	bsr	pen
	move.w	#256,d0
	move.w	#214,d1
	move.w	#294,d2
	move.w	#221,d3
	bsr	fill
	lea	TopItext,a1
	move.w	#256,d0
	move.w	#212,d1
	bsr	text
	move.w	#1,d0
	bsr	pen
	move.w	#0,XANGLE
	move.w	#0,YANGLE
	move.w	#0,ZANGLE
	bsr	rot	get co-ords without perspective
	lea	newX,a4
	lea	newZ,a5
	bsr	initobject2
	rts

linenumber		;get line number from prop gadget
	moveq	#0,d0
	move.l	#Prop4,a0
	move.l	SPECIALINFO(a0),a0
	move.w	HORIZPOT(a0),d0
	divu	#$204,d0		(ffff/128)
	move.w	d0,CURRENTLINE
	lea	LineNumText,a1
	bsr	decconvert
	move.w	#0,d0
	bsr	pen
	move.w	#127,d0
	move.w	#214,d1
	move.w	#148,d2
	move.w	#220,d3
	bsr	fill
	lea	LineNumItext,a1
	move.w	#126,d0
	move.w	#212,d1
	bsr	text
	move.w	#1,d0
	bsr	pen
	rts

setview	btst	#0,THISVIEW	set the current view
	beq.s	nofront
	bsr	front
	rts
nofront	btst	#1,THISVIEW
	beq.s	noside
	bsr	side
	rts
noside	bsr	top
	rts


initobject
	bsr	clear2
	lea	lines,a3
	move.w	numlines,d7
	cmp.w	#-$1,d7		-1 indicates no lines
	beq.s	endinit
	move.w	#1,d0
	bsr	pen
initloop
	moveq	#0,d4
	move.b	(a3)+,d4	next point
	lsl.w	#1,d4		multiply by 2

	move.w	(a4,d4.w),d0
	add.w	Xorg,d0		x start
	move.w	(a5,d4.w),d4
	move.w	Yorg2,d1
	sub.w	d4,d1		Yorg-y start
	bsr	move

	moveq	#0,d5
	move.b	(a3)+,d5	next point
	lsl.w	#1,d5		multiply by 2

	move.w	(a4,d5.w),d0
	add.w	Xorg,d0		x end
	move.w	(a5,d5.w),d4
	move.w	Yorg2,d1
	sub.w	d4,d1		Yorg-y start
	bsr	line

	dbra	d7,initloop
endinit	rts


initobject2
	bsr	clear2
	lea	lines,a3
	move.w	numlines,d7
	cmp.w	#-$1,d7		-1 indicates no lines
	beq.s	endinit2
	move.w	#1,d0
	bsr	pen
initloop2
	moveq	#0,d4
	move.b	(a3)+,d4	next point
	lsl.w	#1,d4		multiply by 2

	move.w	(a4,d4.w),d0
	add.w	Xorg,d0		x start
	move.w	(a5,d4.w),d1
	add.w	Yorg2,d1
	bsr	move

	moveq	#0,d5
	move.b	(a3)+,d5	next point
	lsl.w	#1,d5		multiply by 2

	move.w	(a4,d5.w),d0
	add.w	Xorg,d0		x end
	move.w	(a5,d5.w),d1
	add.w	Yorg2,d1
	bsr	line

	dbra	d7,initloop2
endinit2
	rts


lineloop
	move.l	Window2,a0
	move.w	WD_MOUSEX(a0),d0
	move.w	WD_MOUSEY(a0),d1
	cmp.w	#208,d1
	bgt	noline
	cmp.w	#28,d1
	blt	noline
	bsr	blitsave
	move.w	d0,STARTX
	move.w	d1,STARTY
	move.w	d0,ENDX
	move.w	d1,ENDY
	bsr	plot
lineloop2
	bsr	getcoords
	move.l	Window2,a0
	move.w	WD_MOUSEX(a0),d0
	move.w	WD_MOUSEY(a0),d1
	cmp.w	#209,d1
	blt.s	yendok
	move.w	#208,d1
yendok	cmp.w	#27,d1
	bgt.s	yendok2
	move.w	#28,d1
yendok2	cmp.w	ENDX,d0
	bne.s	xnotequal
	bset	#0,d2		set flag
	bra.s	xendok
xnotequal
	bclr	#0,d2		clear flag
xendok	move.w	d0,ENDX
	cmp.w	ENDY,d1
	bne.s	ynotequal
	btst	#0,d2		test flag
	bne.s	samexy
ynotequal
	move.w	d1,ENDY
	bsr	blitback	restore screen
	move.w	#1,d0		draw new line
	bsr	pen
	move.w	STARTX,d0
	move.w	STARTY,d1
	bsr	move
	move.w	ENDX,d0
	move.w	ENDY,d1
	bsr	line
samexy	btst	#6,$bfe001.l
	beq.s	lineloop2
noline	rts


setcoords
	btst	#0,THISVIEW
	beq.s	addside
	move.w	STARTX,d1
	sub.w	Xorg,d1		d1 = world x co-ord
	move.w	STARTY,d0
	move.w	Yorg2,d2
	sub.w	d0,d2		d2 = world y co-ord
	moveq	#0,d3		d3 = world z co-ord = 0
	bsr.s	exist
	move.w	ENDX,d1
	sub.w	Xorg,d1		d1 = world x co-ord
	move.w	ENDY,d0
	move.w	Yorg2,d2
	sub.w	d0,d2		d2 = world y co-ord
	moveq	#0,d3		d3 = world z co-ord = 0
	bsr.s	exist
	rts
addside	btst	#1,THISVIEW
	beq.s	addtop
	moveq	#0,d1		d1 = world x co-ord = 0
	move.w	STARTY,d0
	move.w	Yorg2,d2
	sub.w	d0,d2		d2 = world y co-ord
	move.w	STARTX,d3
	sub.w	Xorg,d3		d3 = world z co-ord
	bsr.s	exist
	moveq	#0,d1		d1 = world x co-ord = 0
	move.w	ENDY,d0
	move.w	Yorg2,d2
	sub.w	d0,d2		d2 = world y co-ord
	move.w	ENDX,d3
	sub.w	Xorg,d3		d3 = world z co-ord
	bsr.s	exist
	rts
addtop	move.w	STARTX,d1
	sub.w	Xorg,d1		d1 = world x co-ord
	moveq	#0,d2		d2 = world y co-ord = 0
	move.w	STARTY,d0
	move.w	Yorg2,d3
	sub.w	d0,d3		d3 = world y co-ord
	bsr.s	exist
	move.w	ENDX,d1
	sub.w	Xorg,d1		d1 = world x co-ord
	moveq	#0,d2		d2 = world y co-ord = 0
	move.w	ENDY,d0
	move.w	Yorg2,d3
	sub.w	d0,d3		d3 = world y co-ord
	bsr.s	exist
	rts

exist	lea	worldX,a0	see if co-ords are already in table
	lea	worldY,a1
	lea	worldZ,a2
	moveq	#0,d0		offset starts at zero
testx	cmp.w	(a0,d0.w),d1	does x already exist ?
	beq.s	testy		yes
	addq.w	#2,d0		no, try next set of co-ords
	cmp.w	#512,d0		maximum of 512/2 = 256 co-ords
	bne.s	testx
	bsr.s	newcoords
	rts
testy	cmp.w	(a1,d0.w),d2	does y already exist ?
	beq.s	testz		yes
	addq.w	#2,d0		no, try next set of co-ords
	cmp.w	#512,d0		maximum of 512/2 = 256 co-ords
	bne.s	testx
	bsr.s	newcoords
	rts
testz	cmp.w	(a2,d0.w),d3	does z already exist ?
	beq.s	oldcoords	yes
	addq.w	#2,d0		no, try next set of co-ords
	cmp.w	#512,d0		maximum of 512/2 = 256 co-ords
	bne.s	testx
	bsr.s	newcoords
	rts

newcoords
	addq.w	#1,numpoints	one more set of co-ords
	move.l	Xptr,a0		current pointers
	move.l	a0,d0
	move.l	Yptr,a1
	move.l	Zptr,a2
	move.w	d1,(a0)+	move co-ords into next location
	move.w	d2,(a1)+
	move.w	d3,(a2)+
	move.l	a0,Xptr		update pointers
	move.l	a1,Yptr
	move.l	a2,Zptr
	lea	worldX,a0	position of line (start or end) into table
	sub.l	a0,d0		get offset
	lsr.w	#1,d0
	move.l	lineptr,a0
	move.b	d0,(a0)+
	move.l	a0,lineptr	update line pointer
	rts

oldcoords
	lsr.w	#1,d0		get number of line's start or end point
	move.l	lineptr,a0
	move.b	d0,(a0)+
	move.l	a0,lineptr	update line pointer
	rts


dobool1	rts		;'OK' boolean gadget

dobool2	rts		;'DELETE' boolean gadget

getcoords
	move.l	Window2,a0
	move.w	WD_MOUSEX(a0),d0
	cmp.w	CURRENTX,d0
	beq.s	checky
	move.w	d0,CURRENTX
	lea	HCoordText,a1
	bsr.s	decconvert
	move.w	#237,d0
	move.w	#2,d1
	move.w	#258,d2
	move.w	#8,d3
	bsr	fill
	lea	HCoordItext,a1
	move.w	#236,d0
	move.w	#0,d1
	bsr	text
checky	move.l	Window2,a0
	move.w	WD_MOUSEY(a0),d0
	sub.w	#28,d0
	bge.s	itsok
	moveq	#0,d0
itsok	cmpi.w	#180,d0
	ble.s	itsok2
	move.w	#180,d0
itsok2	cmp.w	CURRENTY,d0
	beq.s	endcoords
	move.w	d0,CURRENTY
	lea	VCoordText,a1
	bsr.s	decconvert
	move.w	#293,d0
	move.w	#2,d1
	move.w	#314,d2
	move.w	#8,d3
	bsr	fill
	lea	VCoordItext,a1
	move.w	#292,d0
	move.w	#0,d1
	bsr	text
endcoords
	rts

decconvert
	movem.l	d0-d1/a0-a1,-(sp)
	lea.l	decdigits,a0
	moveq	#0,d1
	move.w	d0,d1
	divs	#100,d1		hundreds
	andi.l	#$ffff,d1	get rid of remainder
	move.b	(a0,d1.w),(a1)+	save hundreds
	mulu	#100,d1
	sub.w	d1,d0		take off hundreds
	move.w	d0,d1
	divs	#10,d1		tens
	andi.l	#$ffff,d1	get rid of remainder
	move.b	(a0,d1.w),(a1)+	save tens
	mulu	#10,d1
	sub.w	d1,d0		take off tens
	move.b	(a0,d0.w),(a1)+	save units
	movem.l	(sp)+,d0-d1/a0-a1
	rts

decdigits	dc.b	'0123456789'


;"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
;" Blitter subroutines for saving and restoring editor screen. "
;"							       "
;"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

blitsave
	move.l	_GfxBase,a6
	jsr	-456(a6)	OwnBlitter
	move.l	ScreenMem,a0
	move.l	WorkSpace,a1
	lea	1600(a0),a0	allow for top (40*40)
wait3	cmp.b	#$ff,$dff006	wait for bottom of frame
	bne.s	wait3
bltfin5	btst	#6,$dff002.l	wait until blitter finished
	bne.s	bltfin5
	move.l	a0,$dff050	source A
	move.l	a1,$dff054	destination D
	move.l	#-1,$dff044	no first/last word mask
	clr.l	$dff064		no modulo
	move.w	#%100111110000,$dff040	A=D; Use A,D
	clr.w	$dff042		bltcon1
	move.w	#%10110101010100,$dff058	go
bltfin6	btst	#6,$dff002.l	wait until blitter finished
	bne.s	bltfin6
	move.l	_GfxBase,a6
	jsr	-462(a6)	DisownBlitter
	rts

blitback
	move.l	_GfxBase,a6
	jsr	-456(a6)	OwnBlitter
	move.l	WorkSpace,a0
	move.l	ScreenMem,a1
	lea	1600(a1),a1	allow for top (40*40)
wait4	cmp.b	#$ff,$dff006	wait for bottom of frame
	bne.s	wait4
bltfin7	btst	#6,$dff002.l	wait until blitter finished
	bne.s	bltfin7
	move.l	a0,$dff050	source A
	move.l	a1,$dff054	destination D
	move.l	#-1,$dff044	no first/last word mask
	clr.l	$dff064		no modulo
	move.w	#%100111110000,$dff040	A=D; Use A,D
	clr.w	$dff042		bltcon1
	move.w	#%10110101010100,$dff058	go
bltfin8	btst	#6,$dff002.l	wait until blitter finished
	bne.s	bltfin8
	move.l	_GfxBase,a6
	jsr	-462(a6)	DisownBlitter
	rts

clear2	move.l	_GfxBase,a6
	jsr	-456(a6)	OwnBlitter
	move.l	ScreenMem,a0
	lea	1600(a0),a0	allow for top
wait5	cmp.b	#$ff,$dff006	wait for bottom of frame
	bne.s	wait5
bltfin9	btst	#6,$dff002.l	wait until blitter finished
	bne.s	bltfin9
	move.l	a0,$dff054	destination D
	move.w	#$100,$dff040	enable channel D only
	moveq	#0,d0
	move.w	d0,$dff042	bltcon1
	move.w	d0,$dff066	no modulo
	move.w	#%10110101010100,$dff058	go
bltfinA	btst	#6,$dff002.l	wait until blitter finished
	bne.s	bltfinA
	move.l	_GfxBase,a6
	jsr	-462(a6)	DisownBlitter
	rts


* various exit routines that do tidying up

end	move.l	Window,a0
	move.l	#Prop1,a1
	move.l	_IntuitionBase,a6
	jsr	-228(a6)	RemoveGadget

	move.l	Window,a0
	move.l	#Prop2,a1
	move.l	_IntuitionBase,a6
	jsr	-228(a6)	RemoveGadget

	move.l	Window,a0
	move.l	#Prop3,a1
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

exit_closearp
	move.l	_ARPBase,a1
	move.l	4.w,a6
	jsr	-414(a6)	CloseLibrary

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


* Variables

_IntuitionBase	dc.l	0	
_DOSBase	dc.l	0
_GfxBase	dc.l	0
_ARPBase	dc.l	0
ScreenMem	dc.l	0
Screen		dc.l	0
WorkSpace	dc.l	0
Window		dc.l	0
Window2		dc.l	0
RP		dc.l	0
XPROP		dc.l	0
YPROP		dc.l	0
ZPROP		dc.l	0
XANGLE		dc.w	0
YANGLE		dc.w	0
ZANGLE		dc.w	0
XINC		dc.w	0
YINC		dc.w	0
ZINC		dc.w	0
XSIN		dc.w	0
XCOS		dc.w	0
YSIN		dc.w	0
YCOS		dc.w	0
ZSIN		dc.w	0
ZCOS		dc.w	0
CURRENTX	dc.w	0
CURRENTY	dc.w	0
CURRENTLINE	dc.w	0
THISVIEW	dc.b	1
	even
STARTX		dc.w	0
STARTY		dc.w	0
ENDX		dc.w	0
ENDY		dc.w	0


* Constants

int_name	dc.b	'intuition.library',0
	even
dosname		dc.b	'dos.library',0
	even
grafname	dc.b	'graphics.library',0
	even
arpname		dc.b	'arp.library',0
	even
screen_title	dc.b	"Edit-3D by D.Vernon 1990",0
	even
window_title	dc.b	'Angle',0
	even
window2_title	dc.b	'Object Editor',0
	even

SLineText	dc.b	'Select Line',0
	even
LineText	dc.b	'Line Number:',0
	even
LineNumText	dc.b	0,0,0,0
	even
ViewText	dc.b	'View:',0
	even
FrontText	dc.b	'Front',0
	even
SideText	dc.b	'Side',0
	even
TopText		dc.b	'Top',0
	even
HVText		dc.b	'H:     V:000',0
	even
HCoordText	dc.b	0,0,0,0
	even
VCoordText	dc.b	0,0,0,0
	even

Menu1Name	dc.b	'Project',0
	even
Menu1Text1	dc.b	'Clear',0
	even
Menu1Text2	dc.b	'Load',0
	even
Menu1Text3	dc.b	'Save',0
	even
Menu1Text4	dc.b	'Save As',0
	even
Menu1Text5	dc.b	'Quit',0
	even

Menu2Name	dc.b	'Object',0
	even
Menu2Text1	dc.b	'New',0
	even
Menu2Text2	dc.b	'Edit',0
	even
Menu2Text3	dc.b	'Animate',0
	even

Menu3Name	dc.b	'View',0
	even
Menu3Text1	dc.b	'  Front',0
	even
Menu3Text2	dc.b	'  Side',0
	even
Menu3Text3	dc.b	'  Top',0
	even

Bool1Text	dc.b	'  Ok',0
	even
Bool2Text	dc.b	'Delete',0
	even
Bool3Text	dc.b	'Cancel',0
	even

LoadText	dc.b	'Load Object',0
	even

colours	dc.w	$000,$840,$d70,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$400,$d70

table	dc.w 0,286,572,857,1143,1428,1713,1997,2280
	dc.w 2563,2845,3126,3406,3686,3964,4240,4516
	dc.w 4790,5063,5334,5604,5872,6138,6402,6664
	dc.w 6924,7182,7438,7692,7943,8192,8438,8682	
	dc.w 8923,9162,9397,9630,9860,10087,10311,10531
	dc.w 10749,10963,11174,11381,11585,11786,11982,12176
	dc.w 12365,12551,12733,12911,13085,13255,13421,13583
	dc.w 13741,13894,14044,14189,14330,14466,14598,14726
	dc.w 14849,14968,15082,15191,15296,15396,15491,15582
	dc.w 15668,15749,15826,15897,15964,16026,16083,16135
	dc.w 16182,16225,16262,16294,16322,16344,16362,16374
	dc.w 16382,16384
	dc.w 16382
	dc.w 16374,16362,16344,16322,16294,16262,16225,16182
	dc.w 16135,16083,16026,15964,15897,15826,15749,15668	
	dc.w 15582,15491,15396,15296,15191,15082,14967,14849
	dc.w 14726,14598,14466,14330,14189,14044,13894,13741	
	dc.w 13583,13421,13255,13085,12911,12733,12551,12365
	dc.w 12176,11982,11786,11585,11381,11174,10963,10749
	dc.w 10531,10311,10087,9860,9630,9397,9162,8923
	dc.w 8682,8438,8192,7943,7692,7438,7182,6924
	dc.w 6664,6402,6138,5872,5604,5334,5063,4790
	dc.w 4516,4240,3964,3686,3406,3126,2845,2563
	dc.w 2280,1997,1713,1428,1143,857,572,286,0
	dc.w -286,-572,-857,-1143,-1428,-1713,-1997,-2280
	dc.w -2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
	dc.w -4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
	dc.w -6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682	
	dc.w -8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
	dc.w -10749,-10963,-11174,-11381,-11585,-11786,-11982,-12176
	dc.w -12365,-12551,-12733,-12911,-13085,-13255,-13421,-13583
	dc.w -13741,-13894,-14044,-14189,-14330,-14466,-14598,-14726
	dc.w -14849,-14968,-15082,-15191,-15296,-15396,-15491,-15582
	dc.w -15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
	dc.w -16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374
	dc.w -16382,-16384
	dc.w -16382
	dc.w -16374,-16362,-16344,-16322,-16294,-16262,-16225,-16182
	dc.w -16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668	
	dc.w -15582,-15491,-15396,-15296,-15191,-15082,-14967,-14849
	dc.w -14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741	
	dc.w -13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
	dc.w -12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
	dc.w -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
	dc.w -8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
	dc.w -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
	dc.w -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
	dc.w -2280,-1997,-1713,-1428,-1143,-857,-572,-286,0
	dc.w 286

;"""""""""""""""""""
;" Data for object "
;"		   "
;"""""""""""""""""""

worldX	ds.w	256

worldY	ds.w	256

worldZ	ds.w	256

Xptr	dc.l	worldX
Yptr	dc.l	worldY
Zptr	dc.l	worldZ

lines	ds.b	256
lineptr	dc.l	lines

Xorg	dc.w	160
Yorg	dc.w	97	(256-(window height+10))/2
Yorg2	dc.w	118	(244-36)-(180/2)
numpoints	dc.w	-$1
numlines	dc.w	-$1
newX	ds.w	256
newY	ds.w	256
newZ	ds.w	256
scrX	ds.w	256
scrY	ds.w	256

		****************************************
		*				       *
		*   Here are all the screen, window,   *
		*   menu and gadget structures.	       *
		*				       *
		****************************************

* ARP file requester structure

FReq		dc.l	LoadText	hailing text
		dc.l	Fname		filename array ptr
		dc.l	Dname		directory array ptr
FReqWin		dc.l	0		window ptr
		dc.b	%00001000	flags
		dc.b	0
		dc.l	alter.window	function to call for wildcards
		dc.l	0		intuimessages

Fname		ds.b	33
	even
Dname		ds.b	34
	even

alter.window
	move.w	#10,(a0)		left
	move.w	#39,2(a0)		top
	rts

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

NewWindow	dc.w	0,204	left,top
		dc.w	320,52	width,height
		dc.b	0,1	pens
		dc.l	CLOSEWINDOW!MENUPICK!GADGETUP!GADGETDOWN	IDCMP (menus,gadgets etc.)
		dc.l	WINDOWCLOSE!ACTIVATE!SMART_REFRESH	flags (mouse movements)
		dc.l	0	firstgadget
		dc.l	0	checkmark
		dc.l	window_title	title
scrnptr		dc.l	0	screen
		dc.l	0	bitmap
		dc.w	0	minwidth
		dc.w	0	minheight
		dc.w	0	maxwidth
		dc.w	0	maxheight
		dc.w	$f	CUSTOMSCREEN


* Edit Window structure

NewWindow2	dc.w	0,12	left,top
		dc.w	320,244	width,height
		dc.b	0,1	pens
		dc.l	MOUSEBUTTONS!CLOSEWINDOW!MENUPICK!GADGETUP!GADGETDOWN	IDCMP
		dc.l	WINDOWCLOSE!ACTIVATE!SMART_REFRESH	flags
		dc.l	0	firstgadget
		dc.l	0	checkmark
		dc.l	window2_title	title
scrnptr2	dc.l	0	screen
		dc.l	0	bitmap
		dc.w	0	minwidth
		dc.w	0	minheight
		dc.w	0	maxwidth
		dc.w	0	maxheight
		dc.w	$f	CUSTOMSCREEN


* 'Select Line' intuitext structure

SLineItext	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	6	leftedge
		dc.w	15	topedge
		dc.l	0	font
		dc.l	SLineText	text
		dc.l	LineItext	next text


* 'Line Number:' intuitext structure

LineItext	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	22	leftedge
		dc.w	214	topedge
		dc.l	0	font
		dc.l	LineText	text
		dc.l	ViewItext	next text


* 'View:' intuitext structure

ViewItext	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	208	leftedge
		dc.w	214	topedge
		dc.l	0	font
		dc.l	ViewText	text
		dc.l	HVItext	next text


* 'H' and 'V' intuitext structure

HVItext		dc.b	0	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	220	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	HVText	text
		dc.l	0	next text


* Horizontal co-ordinate intuitext structure

HCoordItext	dc.b	0	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	0	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	HCoordText	text
		dc.l	0	next text


* Vertictal co-ordinate intuitext structure

VCoordItext	dc.b	0	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	0	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	VCoordText	text
		dc.l	0	next text


* Current line intuitext structure

LineNumItext	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	0	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	LineNumText	text
		dc.l	0	next text


* 'Front' view intuitext structure

FrontItext	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	0	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	FrontText	text
		dc.l	0	next text


* 'Side' view intuitext structure

SideItext	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	0	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	SideText	text
		dc.l	0	next text


* 'Top' view intuitext structure

TopItext	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	0	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	TopText	text
		dc.l	0	next text


* 'Project' menu structure

Menu1		dc.l	Menu2	next menu
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
		dc.l	30	mutual exclude
		dc.l	Menu1Itext1	intuitext
		dc.l	0	select fill
		dc.b	'C'	alternate command key
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
		dc.l	29	mutual exclude
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
		dc.l	27	mutual exclude
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
		dc.l	23	mutual exclude
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


Menu1Item5	dc.l	0	next menu item
		dc.w	2	left
		dc.w	48	top
		dc.w	100	width
		dc.w	11	height
		dc.w	ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	15	mutual exclude
		dc.l	Menu1Itext5	intuitext
		dc.l	0	select fill
		dc.b	'Q'	alternate command key
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


* 'Object' menu structure

Menu2		dc.l	0	next menu
		dc.w	70	left
		dc.w	0	top
		dc.w	52	width
		dc.w	9	height
		dc.w	MENUENABLED	flags
		dc.l	Menu2Name	menu name
		dc.l	Menu2Item1	first menu item
		dc.w	0	jazzx
		dc.w	0	jazzy
		dc.w	0	beatx
		dc.w	0	beaty

Menu2Item1	dc.l	Menu2Item2	next menu item
		dc.w	2	left
		dc.w	0	top
		dc.w	100	width
		dc.w	11	height
		dc.w	ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	6	mutual exclude
		dc.l	Menu2Itext1	intuitext
		dc.l	0	select fill
		dc.b	'N'	alternate command key
		dc.b	0	align to next word
		dc.l	0	subitem
		dc.w	0	next select

Menu2Itext1	dc.b	0	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	2	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	Menu2Text1	text
		dc.l	0	next text


Menu2Item2	dc.l	Menu2Item3	next menu item
		dc.w	2	left
		dc.w	12	top
		dc.w	100	width
		dc.w	11	height
		dc.w	ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	5	mutual exclude
		dc.l	Menu2Itext2	intuitext
		dc.l	0	select fill
		dc.b	'E'	alternate command key
		dc.b	0	align to next word
		dc.l	0	subitem
		dc.w	0	next select

Menu2Itext2	dc.b	0	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	2	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	Menu2Text2	text
		dc.l	0	next text


Menu2Item3	dc.l	0	next menu item
		dc.w	2	left
		dc.w	24	top
		dc.w	100	width
		dc.w	11	height
		dc.w	ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	3	mutual exclude
		dc.l	Menu2Itext3	intuitext
		dc.l	0	select fill
		dc.b	'A'	alternate command key
		dc.b	0	align to next word
		dc.l	0	subitem
		dc.w	0	next select

Menu2Itext3	dc.b	0	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	2	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	Menu2Text3	text
		dc.l	0	next text


* 'View' menu structure

Menu3		dc.l	0	next menu
		dc.w	5	left
		dc.w	0	top
		dc.w	38	width
		dc.w	9	height
		dc.w	MENUENABLED	flags
		dc.l	Menu3Name	menu name
		dc.l	Menu3Item1	first menu item
		dc.w	0	jazzx
		dc.w	0	jazzy
		dc.w	0	beatx
		dc.w	0	beaty

Menu3Item1	dc.l	Menu3Item2	next menu item
		dc.w	2	left
		dc.w	0	top
		dc.w	100	width
		dc.w	11	height
		dc.w	CHECKED!CHECKIT!ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	6	mutual exclude
		dc.l	Menu3Itext1	intuitext
		dc.l	0	select fill
		dc.b	'F'	alternate command key
		dc.b	0	align to next word
		dc.l	0	subitem
		dc.w	0	next select

Menu3Itext1	dc.b	0	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	2	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	Menu3Text1	text
		dc.l	0	next text


Menu3Item2	dc.l	Menu3Item3	next menu item
		dc.w	2	left
		dc.w	12	top
		dc.w	100	width
		dc.w	11	height
		dc.w	CHECKIT!ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	5	mutual exclude
		dc.l	Menu3Itext2	intuitext
		dc.l	0	select fill
		dc.b	'S'	alternate command key
		dc.b	0	align to next word
		dc.l	0	subitem
		dc.w	0	next select

Menu3Itext2	dc.b	0	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	2	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	Menu3Text2	text
		dc.l	0	next text


Menu3Item3	dc.l	0	next menu item
		dc.w	2	left
		dc.w	24	top
		dc.w	100	width
		dc.w	11	height
		dc.w	CHECKIT!ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	3	mutual exclude
		dc.l	Menu3Itext3	intuitext
		dc.l	0	select fill
		dc.b	'T'	alternate command key
		dc.b	0	align to next word
		dc.l	0	subitem
		dc.w	0	next select

Menu3Itext3	dc.b	0	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	2	leftedge
		dc.w	2	topedge
		dc.l	0	font
		dc.l	Menu3Text3	text
		dc.l	0	next text


* Gadget structures

Prop1		dc.l	0	next gadget
		dc.w	4	left
		dc.w	12	top
		dc.w	312	width
		dc.w	11	height
		dc.w	GADGIMAGE!GADGHNONE	flags
		dc.w	RELVERIFY!GADGIMMEDIATE	activation flags
		dc.w	PROPGADGET	type
		dc.l	Prop1Image	render
		dc.l	0	select render
		dc.l	0	text
		dc.l	0	mutual exclude
		dc.l	Prop1Info	special info
		dc.w	0	gadget ID
		dc.l	0	userdata

Prop1Image	dc.w	0	left
		dc.w	0	top
		dc.w	7	width
		dc.w	7	height
		dc.w	1	depth
		dc.l	Prop1Data	image data
		dc.b	2	plane pick
		dc.b	0	plane on off
		dc.l	0	next image

Prop1Info	dc.w	FREEHORIZ	flags
		dc.w	0	horizpot
		dc.w	0	vertpot
		dc.w	$b6	horizbody	(ffff/360)
		dc.w	0	vertbody
		dc.w	0	cwidth
		dc.w	0	cheight
		dc.w	0	hpotres
		dc.w	0	vpotres
		dc.w	0	leftborder
		dc.w	0	topborder


Prop2		dc.l	0	next gadget
		dc.w	4	left
		dc.w	25	top
		dc.w	312	width
		dc.w	11	height
		dc.w	GADGIMAGE!GADGHNONE	flags
		dc.w	RELVERIFY!GADGIMMEDIATE	activation flags
		dc.w	PROPGADGET	type
		dc.l	Prop2Image	render
		dc.l	0	select render
		dc.l	0	text
		dc.l	0	mutual exclude
		dc.l	Prop2Info	special info
		dc.w	0	gadget ID
		dc.l	0	userdata

Prop2Image	dc.w	0	left
		dc.w	0	top
		dc.w	7	width
		dc.w	7	height
		dc.w	1	depth
		dc.l	Prop2Data	image data
		dc.b	2	plane pick
		dc.b	0	plane on off
		dc.l	0	next image

Prop2Info	dc.w	FREEHORIZ	flags
		dc.w	0	horizpot
		dc.w	0	vertpot
		dc.w	$b6	horizbody	(ffff/360)
		dc.w	0	vertbody
		dc.w	0	cwidth
		dc.w	0	cheight
		dc.w	0	hpotres
		dc.w	0	vpotres
		dc.w	0	leftborder
		dc.w	0	topborder


Prop3		dc.l	0	next gadget
		dc.w	4	left
		dc.w	38	top
		dc.w	312	width
		dc.w	11	height
		dc.w	GADGIMAGE!GADGHNONE	flags
		dc.w	RELVERIFY!GADGIMMEDIATE	activation flags
		dc.w	PROPGADGET	type
		dc.l	Prop3Image	render
		dc.l	0	select render
		dc.l	0	text
		dc.l	0	mutual exclude
		dc.l	Prop3Info	special info
		dc.w	0	gadget ID
		dc.l	0	userdata

Prop3Image	dc.w	0	left
		dc.w	0	top
		dc.w	7	width
		dc.w	7	height
		dc.w	1	depth
		dc.l	Prop3Data	image data
		dc.b	2	plane pick
		dc.b	0	plane on off
		dc.l	0	next image

Prop3Info	dc.w	FREEHORIZ	flags
		dc.w	0	horizpot
		dc.w	0	vertpot
		dc.w	$b6	horizbody	(ffff/360)
		dc.w	0	vertbody
		dc.w	0	cwidth
		dc.w	0	cheight
		dc.w	0	hpotres
		dc.w	0	vpotres
		dc.w	0	leftborder
		dc.w	0	topborder


Prop4		dc.l	0	next gadget
		dc.w	99	left
		dc.w	12	top
		dc.w	217	width
		dc.w	13	height
		dc.w	GADGHCOMP	flags
		dc.w	RELVERIFY!GADGIMMEDIATE	activation flags
		dc.w	PROPGADGET	type
		dc.l	Prop4Image	render
		dc.l	0	select render
		dc.l	0	text
		dc.l	0	mutual exclude
		dc.l	Prop4Info	special info
		dc.w	0	gadget ID
		dc.l	0	userdata

Prop4Image	dcb.b	20,0

Prop4Info	dc.w	AUTOKNOB!FREEHORIZ	flags
		dc.w	0	horizpot
		dc.w	0	vertpot
		dc.w	$204	horizbody	(ffff/128)
		dc.w	0	vertbody
		dc.w	0	cwidth
		dc.w	0	cheight
		dc.w	0	hpotres
		dc.w	0	vpotres
		dc.w	0	leftborder
		dc.w	0	topborder


Bool1		dc.l	0	next gadget
		dc.w	27	left
		dc.w	228	top
		dc.w	53	width
		dc.w	13	height
		dc.w	GADGHCOMP	flags
		dc.w	RELVERIFY!GADGIMMEDIATE	activation flags
		dc.w	BOOLGADGET	type
		dc.l	Bool1Border	render
		dc.l	0	select render
		dc.l	Bool1Itext	text
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
		dc.w	52,0	x2,y2
		dc.w	52,12	x3,y3
		dc.w	0,12	x4,y4
		dc.w	0,0	x5,y5

Bool1Itext	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	3	leftedge
		dc.w	3	topedge
		dc.l	0	font
		dc.l	Bool1Text	text
		dc.l	0	next text


Bool2		dc.l	0	next gadget
		dc.w	132	left
		dc.w	228	top
		dc.w	55	width
		dc.w	13	height
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
		dc.w	54,0	x2,y2
		dc.w	54,12	x3,y3
		dc.w	0,12	x4,y4
		dc.w	0,0	x5,y5

Bool2Itext	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	4	leftedge
		dc.w	3	topedge
		dc.l	0	font
		dc.l	Bool2Text	text
		dc.l	0	next text


Bool3		dc.l	0	next gadget
		dc.w	239	left
		dc.w	228	top
		dc.w	54	width
		dc.w	13	height
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
		dc.w	53,0	x2,y2
		dc.w	53,12	x3,y3
		dc.w	0,12	x4,y4
		dc.w	0,0	x5,y5

Bool3Itext	dc.b	2	frontpen
		dc.b	0	backpen
		dc.b	JAM1	drawmode
		dc.b	0	align to next word
		dc.w	4	leftedge
		dc.w	3	topedge
		dc.l	0	font
		dc.l	Bool3Text	text
		dc.l	0	next text


Prop1Data	dc.w	%1000001000000000
		dc.w	%0100010000000000
		dc.w	%0010100000000000
		dc.w	%0001000000000000
		dc.w	%0010100000000000
		dc.w	%0100010000000000
		dc.w	%1000001000000000

Prop2Data	dc.w	%1000001000000000
		dc.w	%0100010000000000
		dc.w	%0010100000000000
		dc.w	%0001000000000000
		dc.w	%0001000000000000
		dc.w	%0001000000000000
		dc.w	%0001000000000000

Prop3Data	dc.w	%1010101000000000
		dc.w	%0000010000000000
		dc.w	%0000100000000000
		dc.w	%0001000000000000
		dc.w	%0010000000000000
		dc.w	%0100000000000000
		dc.w	%1010101000000000

Pointer		dc.w	%0000000000000000,%0000000000000000
		dc.w	%0000000100000000,%0000000000000000
		dc.w	%0000000100000000,%0000000000000000
		dc.w	%0000000100000000,%0000000000000000
		dc.w	%0000000100000000,%0000000000000000
		dc.w	%0000000100000000,%0000000000000000
		dc.w	%0000000100000000,%0000000000000000
		dc.w	%0000000000000000,%0000000000000000
		dc.w	%1111110001111110,%0000000000000000
		dc.w	%0000000000000000,%0000000000000000
		dc.w	%0000000100000000,%0000000000000000
		dc.w	%0000000100000000,%0000000000000000
		dc.w	%0000000100000000,%0000000000000000
		dc.w	%0000000100000000,%0000000000000000
		dc.w	%0000000100000000,%0000000000000000
		dc.w	%0000000100000000,%0000000000000000
