*****************************************
*					*
*  Digital Communication Assignment.	*
*					*
*  Program to Plot Time Waveforms.	*
*					*
*  Written in 68000 Assembly Language	*
*					*
*  on the Commodore Amiga.		*
*					*
*  D. Vernon, J. Simpson, S. Powell	*
*					*
*  		BSc IT II		*
*					*
*****************************************

	opt	o+,a+



* Open the Intuition Library

	moveq	#0,d0			any version
	lea	IntName,a1
	move.l	4.w,a6			ExecBase
	jsr	-552(a6)		OpenLibrary
	move.l	d0,IntBase
	beq	exit_now		exit if library could not be opened


* Open the Graphics Library

	moveq	#0,d0
	lea	GrafName,a1
	move.l	4.w,a6
	jsr	-552(a6)
	move.l	d0,GrafBase
	beq	exit_closeint


* Open the Floating Point Maths Library

	moveq	#0,d0
	lea	MathName,a1
	move.l	4.w,a6
	jsr	-552(a6)
	move.l	d0,MathBase
	beq.s	exit_closegraf


* Open the Floating Point Transcendental Maths Library

	moveq	#0,d0
	lea	MathTransName,a1
	move.l	4.w,a6
	jsr	-552(a6)
	move.l	d0,MathTransBase
	beq.s	exit_closemath


* Open the Screen

	lea	ScreenDefinition,a0
	move.l	IntBase,a6
	jsr	-198(a6)		OpenScreen
	move.l	d0,ScreenPointer
	beq.s	exit_closemathtrans	exit if screen could not be opened

	move.l	d0,a1
	lea	84(a1),a1
	move.l	a1,ScreenRastPort


* Calculate Floating Point Value of 2*Pi

	bsr.s	calculate.two.pi


* Draw Horizontal and Vertical Axes

	bsr.s	draw.axes


* Plot Required Graph

	bsr	plot.stageA


* Wait for Right Mouse Button to be Pressed

wait	btst	#2,$dff016.l
	bne.s	wait


* Close All Libraries and Exit


exit_closescreen
	move.l	ScreenPointer,a0
	move.l	IntBase,a6
	jsr	-66(a6)			CloseScreen


exit_closemathtrans
	move.l	MathTransBase,a1
	move.l	4.w,a6			ExecBase
	jsr	-414(a6)		CloseLibrary

exit_closemath
	move.l	MathBase,a1
	move.l	4.w,a6
	jsr	-414(a6)

exit_closegraf
	move.l	GrafBase,a1
	move.l	4.w,a6
	jsr	-414(a6)

exit_closeint
	move.l	IntBase,a1
	move.l	4.w,a6
	jsr	-414(a6)

exit_now
	moveq	#0,d0
	rts				Return to OS



;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

calculate.two.pi
	move.l	#10000000,d0
	move.l	MathBase,a6
	jsr	-36(a6)			Integer to Floating Point
	move.l	d0,d7

	move.l	#31415927*2,d0
	jsr	-36(a6)

	move.l	d7,d1
	jsr	-84(a6)			Floating Point Division
	move.l	d0,TwoPi
	rts



draw.axes
	move.w	#10,d0
	move.w	#133,d1
	move.l	ScreenRastPort,a1
	move.l	GrafBase,a6
	jsr	-240(a6)		Move Pen

	move.w	#315,d0
	move.w	#133,d1
	move.l	ScreenRastPort,a1
	jsr	-246(a6)		Draw Line

	move.w	#15,d0
	move.w	#13,d1
	move.l	ScreenRastPort,a1
	jsr	-240(a6)		Move Pen

	move.w	#15,d0
	move.w	#253,d1
	move.l	ScreenRastPort,a1
	jsr	-246(a6)		Draw Line

	move.w	#10,d0
	move.w	#13,d1
	move.l	ScreenRastPort,a1
	jsr	-240(a6)		Move Pen

	move.w	#15,d0
	move.w	#13,d1
	move.l	ScreenRastPort,a1
	jsr	-246(a6)		Draw Line

	move.w	#10,d0
	move.w	#253,d1
	move.l	ScreenRastPort,a1
	jsr	-240(a6)		Move Pen

	move.w	#15,d0
	move.w	#253,d1
	move.l	ScreenRastPort,a1
	jsr	-246(a6)		Draw Line

	move.w	#315,d0
	move.w	#133,d1
	move.l	ScreenRastPort,a1
	jsr	-240(a6)		Move Pen

	move.w	#315,d0
	move.w	#138,d1
	move.l	ScreenRastPort,a1
	jsr	-246(a6)		Draw Line
	rts



plot.stageA
	move.l	#0,t.times.10000000

	move.l	#10000,d0
	move.l	MathBase,a6
	jsr	-36(a6)			Integer to Floating Point
	move.l	d0,FP10000

	move.l	#10000000,d0
	jsr	-36(a6)			Integer to Floating Point
	move.l	d0,FP10000000

	moveq	#120,d0
	jsr	-36(a6)			Integer to Floating Point
	move.l	d0,FP120

next.A.plot
	move.l	t.times.10000000,d0
	move.l	MathBase,a6
	jsr	-36(a6)			Integer to Floating Point

	move.l	TwoPi,d1
	jsr	-78(a6)			2*Pi*t*10000000

	move.l	FP10000,d1
	jsr	-78(a6)			2*Pi*t*10000000*10000

	move.l	FP10000000,d1
	jsr	-84(a6)			2*Pi*t*10000

	move.l	MathTransBase,a6
	jsr	-42(a6)			Cos(2*Pi*t*10000)

	move.l	FP120,d1
	move.l	MathBase,a6
	jsr	-78(a6)			120*Cos(2*Pi*10000*t)

	jsr	-30(a6)			Floating Point to Integer

	move.l	d0,d1
	neg.l	d1			Convert to Screen Co-Ordinates
	add.l	#240/2+13,d1		Centre Around Horizontal Axis
	move.l	t.times.10000000,d0
	mulu	#300,d0
	divu	#1000,d0
	add.w	#15,d0
	move.l	ScreenRastPort,a1
	move.l	GrafBase,a6
	jsr	-324(a6)		Plot Pixel

	addq.l	#1,t.times.10000000
	cmp.l	#1000,t.times.10000000
	bne.s	next.A.plot		Do 1000 Plots
	rts



plot.stageB
	move.l	#0,t.times.50000000

	move.l	#10000,d0
	move.l	MathBase,a6
	jsr	-36(a6)			Integer to Floating Point
	move.l	d0,FP10000

	move.l	#1000000,d0
	jsr	-36(a6)			Integer to Floating Point
	move.l	d0,FP1000000

	move.l	#50000000,d0
	jsr	-36(a6)			Integer to Floating Point
	move.l	d0,FP50000000

	moveq	#12,d0
	jsr	-36(a6)			Integer to Floating Point
	move.l	d0,FP12

	moveq	#10,d0
	jsr	-36(a6)			Integer to Floating Point
	move.l	d0,d7

	moveq	#25,d0
	jsr	-36(a6)			Integer to Floating Point

	move.l	d7,d1
	jsr	-84(a6)			Floating Point Division
	move.l	d0,FP2.5

	moveq	#6,d0
	jsr	-36(a6)			Integer to Floating Point
	move.l	d0,FP6

next.B.plot
	move.l	t.times.50000000,d0
	move.l	MathBase,a6
	jsr	-36(a6)			Integer to Floating Point

	move.l	TwoPi,d1
	jsr	-78(a6)			2*Pi*t*50000000

	move.l	FP1000000,d1
	jsr	-78(a6)			2*Pi*t*50000000*1000000

	move.l	FP50000000,d1
	jsr	-84(a6)			2*Pi*t*1000000
	move.l	d0,d6

	move.l	MathTransBase,a6
	jsr	-42(a6)			Cos(2*Pi*t*1000000)
	move.l	d0,d7

	moveq	#3,d5			Initial n
	moveq	#0,d4

add.harmonics
	not.b	d4			Next Component Has Opposite Sign

	move.l	d5,d0
	move.l	MathBase,a6
	jsr	-36(a6)			Integer to Floating Point
	move.l	d0,d3

	move.l	d6,d1
	jsr	-78(a6)			n*2*Pi*t*1000000

	move.l	MathTransBase,a6
	jsr	-42(a6)			Cos(n*2*Pi*t*1000000)

	move.l	d3,d1
	move.l	MathBase,a6
	jsr	-84(a6)			1/n Cos(n*2*Pi*t*1000000)

	tst.b	d4
	beq.s	sign.set

	jsr	-60(a6)			Negate

sign.set
	move.l	d7,d1
	jsr	-66(a6)			Add this Harmonic
	move.l	d0,d7

	addq.l	#2,d5			n+2 -- Next Harmonic
	cmp.l	#1+11*2,d5
	bne.s	add.harmonics		Fundamental + 10 Harmonics


	move.l	t.times.50000000,d0
	move.l	MathBase,a6
	jsr	-36(a6)			Integer to Floating Point

	move.l	TwoPi,d1
	jsr	-78(a6)			2*Pi*t*50000000

	move.l	FP10000,d1
	jsr	-78(a6)			2*Pi*t*50000000*10000

	move.l	FP50000000,d1
	jsr	-84(a6)			2*Pi*t*10000

	move.l	MathTransBase,a6
	jsr	-42(a6)			Cos(2*Pi*t*10000)

	move.l	FP2.5,d1
	move.l	MathBase,a6
	jsr	-78(a6)			2.5 Cos(2*Pi*t*10000)

	move.l	FP6,d1
	jsr	-66(a6)			(2.5 Cos(2*Pi*t*10000)) + 6

	move.l	d7,d1
	jsr	-78(a6)			((2.5 Cos(2*Pi*t*10000)) + 6)
;					*
;					(Cos(2*Pi*t*1000000)
;					- 1/3 Cos(3*2*Pi*t*1000000)
;					+ 1/5 Cos(5*2*Pi*t*1000000)
;					- .....)

	move.l	FP12,d1
	jsr	-78(a6)			Adjust Size to Fill Screen

	jsr	-30(a6)			Floating Point to Integer

	move.l	d0,d1
	neg.l	d1			Convert to Screen Co-Ordinates
	add.l	#240/2+13,d1		Centre Around Horizontal Axis
	move.l	t.times.50000000,d0
	mulu	#300,d0			Width of Graph on Screen
	divu	#5000,d0
	add.w	#15,d0
	move.l	ScreenRastPort,a1
	move.l	GrafBase,a6
	jsr	-324(a6)		Plot Pixel

	addq.l	#1,t.times.50000000
	cmp.l	#5000,t.times.50000000
	bne	next.B.plot		Do 5000 Plots
	rts



;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

IntName	dc.b	'intuition.library',0

GrafName
	dc.b	'graphics.library',0

MathName
	dc.b	'mathffp.library',0

MathTransName
	dc.b	'mathtrans.library',0
	even

ScreenDefinition
	dc.w	0,0		left, top
	dc.w	320,256		width, height
	dc.w	1		depth
	dc.b	0,1		pens
	dc.w	0		view modes
	dc.w	$f		custom screen type
	dc.l	0		font
	dc.l	ScreenTitle	title
	dc.l	0		gadgets
	dc.l	0		bitmap

ScreenTitle
	dc.b	'Stage A -- Amplitude against Time',0
	even



;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

IntBase	dc.l	0
GrafBase	dc.l	0
MathBase	dc.l	0
MathTransBase	dc.l	0
ScreenPointer	dc.l	0
ScreenRastPort	dc.l	0
TwoPi	dc.l	0
t.times.10000000	dc.l	0
t.times.50000000	dc.l	0
FP10000	dc.l	0
FP1000000	dc.l	0
FP10000000	dc.l	0
FP50000000	dc.l	0
FP120	dc.l	0
FP12	dc.l	0
FP2.5	dc.l	0
FP6	dc.l	0
