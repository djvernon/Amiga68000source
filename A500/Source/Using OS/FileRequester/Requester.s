	Section	Requester,code
	opt	o+




* Rastport equates

JAM1	equ	0
JAM2	equ	1
COMPLEMENT	equ	2
INVERSVID	equ	4

* IDCMP equates

CLOSEWINDOW	equ	$200

* IDCMP message equates

IM_CLASS	equ	20
IM_CODE	equ	24
IM_QUALIFIER	equ	26

* Window flags

WINDOWDRAG	equ	2
WINDOWCLOSE	equ	8
ACTIVATE	equ	$1000
RMBTRAP		equ	$10000

* Window equates

WD_USERPORT	equ	86

* Screen type

WBENCHSCREEN	equ	1

* Gadget activation flags

RELVERIFY	equ	1
GADGIMMEDIATE	equ	2

* Gadget types

BOOLGADGET	equ	1
PROPGADGET	equ	3
STRGADGET	equ	4

* Proportional gadget flags

AUTOKNOB	equ	1
FREEVERT	equ	4




* Open the Intuition library

	moveq	#0,d0
	lea	intname(pc),a1
	move.l	4.w,a6
	jsr	-552(a6)		OpenLibrary
	move.l	d0,INTBase
	beq	exit_now




* Open the window

	lea	NewWindow(pc),a0
	move.l	INTBase(pc),a6
	jsr	-204(a6)		OpenWindow
	move.l	d0,Window
	beq	exit_closeint




* Initialise all gadgets

	moveq	#-1,d0			add to end of list
	move.l	Window(pc),a0
	lea	String1(pc),a1
	move.l	INTBase(pc),a6
	jsr	-42(a6)			AddGadget

	moveq	#-1,d0
	move.l	Window(pc),a0
	lea	String2(pc),a1
	move.l	INTBase(pc),a6
	jsr	-42(a6)			AddGadget

	moveq	#-1,d0
	move.l	Window(pc),a0
	lea	Prop1(pc),a1
	move.l	INTBase(pc),a6
	jsr	-42(a6)			AddGadget

	moveq	#-1,d0
	move.l	Window(pc),a0
	lea	Bool1(pc),a1
	move.l	INTBase(pc),a6
	jsr	-42(a6)			AddGadget

	moveq	#-1,d0
	move.l	Window(pc),a0
	lea	Bool2(pc),a1
	move.l	INTBase(pc),a6
	jsr	-42(a6)			AddGadget

	moveq	#-1,d0
	move.l	Window(pc),a0
	lea	Bool3(pc),a1
	move.l	INTBase(pc),a6
	jsr	-42(a6)			AddGadget

	moveq	#-1,d0
	move.l	Window(pc),a0
	lea	Bool4(pc),a1
	move.l	INTBase(pc),a6
	jsr	-42(a6)			AddGadget

	lea	String1(pc),a0
	move.l	Window(pc),a1
	move.l	INTBase(pc),a6
	jsr	-222(a6)		RefreshGadgets




* Main loop

message.loop
	move.l	Window(pc),a0
	move.l	WD_USERPORT(a0),a0
	move.l	4.w,a6
	jsr	-384(a6)	WaitPort

	move.l	Window(pc),a0
	move.l	WD_USERPORT(a0),a0
	move.l	4.w,a6
	jsr	-372(a6)	GetMsg
	tst.l	d0
	beq.s	message.loop

	move.l	d0,a1
	move.l	IM_CLASS(a1),d2
	move.w	IM_CODE(a1),d3
	move.w	IM_QUALIFIER(a1),d4

	move.l	4.w,a6
	jsr	-378(a6)	ReplyMsg

	cmp.l	#CLOSEWINDOW,d2
	bne.s	message.loop




* Remove all gadgets

	move.l	Window(pc),a0
	lea	Bool4(pc),a1
	move.l	INTBase(pc),a6
	jsr	-228(a6)		RemoveGadget

	move.l	Window(pc),a0
	lea	Bool3(pc),a1
	move.l	INTBase(pc),a6
	jsr	-228(a6)		RemoveGadget

	move.l	Window(pc),a0
	lea	Bool2(pc),a1
	move.l	INTBase(pc),a6
	jsr	-228(a6)		RemoveGadget

	move.l	Window(pc),a0
	lea	Bool1(pc),a1
	move.l	INTBase(pc),a6
	jsr	-228(a6)		RemoveGadget

	move.l	Window(pc),a0
	lea	Prop1(pc),a1
	move.l	INTBase(pc),a6
	jsr	-228(a6)		RemoveGadget

	move.l	Window(pc),a0
	lea	String2(pc),a1
	move.l	INTBase(pc),a6
	jsr	-228(a6)		RemoveGadget

	move.l	Window(pc),a0
	lea	String1(pc),a1
	move.l	INTBase(pc),a6
	jsr	-228(a6)		RemoveGadget




exit_closewindow
	move.l	Window,a0
	move.l	INTBase(pc),a6
	jsr	-72(a6)			CloseWindow




exit_closeint
	move.l	INTBase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary




exit_now
	moveq	#0,d0
	rts




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

INTBase	dc.l	0
Window	dc.l	0

FileNameBuffer	ds.b	80
DirNameBuffer	ds.b	80
UndoBuffer	ds.b	80




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

intname	dc.b	'intuition.library',0

window_title	dc.b	'Load File',0

Bool1Text	dc.b	'  OK  ',0

Bool2Text	dc.b	'CANCEL',0

Bool3Text	dc.b	'Drives',0

Bool4Text	dc.b	'Parent',0
	even


NewWindow
	dc.w	25,20			left, top
	dc.w	300,136			width, height
	dc.b	0,1			pens
	dc.l	CLOSEWINDOW		IDCMP
	dc.l	WINDOWDRAG!WINDOWCLOSE!ACTIVATE!RMBTRAP	flags
	dc.l	0			first gadget
	dc.l	0			checkmark
	dc.l	window_title		title
	dc.l	0			screen
	dc.l	0			bitmap
	dc.w	0			min. width
	dc.w	0			min. height
	dc.w	0			max. width
	dc.w	0			max. height
	dc.w	WBENCHSCREEN		screen type


String1	dc.l	0			next gadget
	dc.w	60,103			left, top
	dc.w	234,10			width, height
	dc.w	0			flags
	dc.w	RELVERIFY		activation flags
	dc.w	STRGADGET		type
	dc.l	String1Border		render
	dc.l	0			select render
	dc.l	0			text
	dc.l	0			mutual excludes
	dc.l	String1Info		special info
	dc.w	$7680			gadget ID
	dc.l	0			user data

String1Border
	dc.w	0,0			left, top
	dc.b	1,0			pens
	dc.b	JAM1			draw mode
	dc.b	5			number of xy pairs
	dc.l	String1xy		xy pairs
	dc.l	0			next border

String1xy
	dc.w	-1,-1			x1, y1
	dc.w	232,-1			x2, y2
	dc.w	232,8			x3, y3
	dc.w	-1,8			x4, y4
	dc.w	-1,-1			x5, y5

String1Info
	dc.l	FileNameBuffer		buffer
	dc.l	UndoBuffer		undo buffer
	dc.w	1			char. position in buffer
	dc.w	80			max. chars. in buffer
	dc.w	0			disp. pos.
	dc.w	0			undo. pos.
	dc.w	0			number of chars. in buffer
	dc.w	0			number of chars. visible
	dc.w	0			pixels from left edge
	dc.w	0			pixels from top edge
	dc.l	0			layer ptr.
	dc.l	0			long integer value
	dc.l	0			alternate keymap


String2	dc.l	0			next gadget
	dc.w	60,90			left, top
	dc.w	234,10			width, height
	dc.w	0			flags
	dc.w	RELVERIFY		activation flags
	dc.w	STRGADGET		type
	dc.l	String2Border		render
	dc.l	0			select render
	dc.l	0			text
	dc.l	0			mutual excludes
	dc.l	String2Info		special info
	dc.w	$7681			gadget ID
	dc.l	0			user data

String2Border
	dc.w	0,0			left, top
	dc.b	1,0			pens
	dc.b	JAM1			draw mode
	dc.b	5			number of xy pairs
	dc.l	String2xy		xy pairs
	dc.l	0			next border

String2xy
	dc.w	-1,-1			x1, y1
	dc.w	232,-1			x2, y2
	dc.w	232,8			x3, y3
	dc.w	-1,8			x4, y4
	dc.w	-1,-1			x5, y5

String2Info
	dc.l	DirNameBuffer		buffer
	dc.l	UndoBuffer		undo buffer
	dc.w	1			char. position in buffer
	dc.w	80			max. chars. in buffer
	dc.w	0			disp. pos.
	dc.w	0			undo. pos.
	dc.w	0			number of chars. in buffer
	dc.w	0			number of chars. visible
	dc.w	0			pixels from left edge
	dc.w	0			pixels from top edge
	dc.l	0			layer ptr.
	dc.l	0			long integer value
	dc.l	0			alternate keymap


Prop1	dc.l	0			next gadget
	dc.w	283,15			left, top
	dc.w	11,49			width, height
	dc.w	0			flags
	dc.w	RELVERIFY!GADGIMMEDIATE	activation flags
	dc.w	PROPGADGET		type
	dc.l	Prop1Image		render
	dc.l	0			select render
	dc.l	0			text
	dc.l	0			mutual excludes
	dc.l	Prop1Info		special info
	dc.w	$7682			gadget ID
	dc.l	0			user data

Prop1Image
	ds.w	10

Prop1Info
	dc.w	AUTOKNOB!FREEVERT	flags
	dc.w	0			horizpot
	dc.w	0			vertpot
	dc.w	0			horizbody
	dc.w	65535/5			vertbody
	dc.w	0			cwidth
	dc.w	0			cheight
	dc.w	0			hpotres
	dc.w	0			vpotres
	dc.w	0			leftborder
	dc.w	0			topborder


Bool1	dc.l	0			next gadget
	dc.w	15,116			left, top
	dc.w	56,13			width, height
	dc.w	0			flags
	dc.w	RELVERIFY		activation flags
	dc.w	BOOLGADGET		type
	dc.l	Bool1Border		render
	dc.l	0			select render
	dc.l	Bool1Itext		text
	dc.l	0			mutual excludes
	dc.l	0			special info
	dc.w	$7683			gadget ID
	dc.l	0			user data

Bool1Border
	dc.w	0,0			left, top
	dc.b	1,0			pens
	dc.b	JAM1			draw mode
	dc.b	5			number of xy pairs
	dc.l	Bool1xy			xy pairs
	dc.l	0			next border

Bool1xy	dc.w	0,0			x1, y1
	dc.w	55,0			x2, y2
	dc.w	55,12			x3, y3
	dc.w	0,12			x4, y4
	dc.w	0,0			x5, y5

Bool1Itext
	dc.b	1,0			pens
	dc.b	JAM1			draw mode
	dc.b	0			align to next word
	dc.w	4,3			left, top
	dc.l	0			font
	dc.l	Bool1Text		text
	dc.l	0			next text


Bool2	dc.l	0			next gadget
	dc.w	225,116			left, top
	dc.w	56,13			width, height
	dc.w	0			flags
	dc.w	RELVERIFY		activation flags
	dc.w	BOOLGADGET		type
	dc.l	Bool2Border		render
	dc.l	0			select render
	dc.l	Bool2Itext		text
	dc.l	0			mutual excludes
	dc.l	0			special info
	dc.w	$7684			gadget ID
	dc.l	0			user data

Bool2Border
	dc.w	0,0			left, top
	dc.b	1,0			pens
	dc.b	JAM1			draw mode
	dc.b	5			number of xy pairs
	dc.l	Bool2xy			xy pairs
	dc.l	0			next border

Bool2xy	dc.w	0,0			x1, y1
	dc.w	55,0			x2, y2
	dc.w	55,12			x3, y3
	dc.w	0,12			x4, y4
	dc.w	0,0			x5, y5

Bool2Itext
	dc.b	1,0			pens
	dc.b	JAM1			draw mode
	dc.b	0			align to next word
	dc.w	4,3			left, top
	dc.l	0			font
	dc.l	Bool2Text		text
	dc.l	0			next text

Bool3	dc.l	0			next gadget
	dc.w	85,116			left, top
	dc.w	56,13			width, height
	dc.w	0			flags
	dc.w	RELVERIFY		activation flags
	dc.w	BOOLGADGET		type
	dc.l	Bool3Border		render
	dc.l	0			select render
	dc.l	Bool3Itext		text
	dc.l	0			mutual excludes
	dc.l	0			special info
	dc.w	$7685			gadget ID
	dc.l	0			user data

Bool3Border
	dc.w	0,0			left, top
	dc.b	1,0			pens
	dc.b	JAM1			draw mode
	dc.b	5			number of xy pairs
	dc.l	Bool3xy			xy pairs
	dc.l	0			next border

Bool3xy	dc.w	0,0			x1, y1
	dc.w	55,0			x2, y2
	dc.w	55,12			x3, y3
	dc.w	0,12			x4, y4
	dc.w	0,0			x5, y5

Bool3Itext
	dc.b	1,0			pens
	dc.b	JAM1			draw mode
	dc.b	0			align to next word
	dc.w	4,3			left, top
	dc.l	0			font
	dc.l	Bool3Text		text
	dc.l	0			next text

Bool4	dc.l	0			next gadget
	dc.w	155,116			left, top
	dc.w	56,13			width, height
	dc.w	0			flags
	dc.w	RELVERIFY		activation flags
	dc.w	BOOLGADGET		type
	dc.l	Bool4Border		render
	dc.l	0			select render
	dc.l	Bool4Itext		text
	dc.l	0			mutual excludes
	dc.l	0			special info
	dc.w	$7686			gadget ID
	dc.l	0			user data

Bool4Border
	dc.w	0,0			left, top
	dc.b	1,0			pens
	dc.b	JAM1			draw mode
	dc.b	5			number of xy pairs
	dc.l	Bool4xy			xy pairs
	dc.l	0			next border

Bool4xy	dc.w	0,0			x1, y1
	dc.w	55,0			x2, y2
	dc.w	55,12			x3, y3
	dc.w	0,12			x4, y4
	dc.w	0,0			x5, y5

Bool4Itext
	dc.b	1,0			pens
	dc.b	JAM1			draw mode
	dc.b	0			align to next word
	dc.w	4,3			left, top
	dc.l	0			font
	dc.l	Bool4Text		text
	dc.l	0			next text
