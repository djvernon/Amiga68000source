	section	SampleMaker,code_c
	opt	o+,o4-,a+



AMPLITUDE		equ	127	(0 - 127)
AMOUNT.OF.VALUES	equ	1024	(1 - 65535)
AMOUNT.OF.CYCLES	equ	32

MAX.AMPLITUDE		equ	127	Don't change this



* Open the Dos Library

	moveq	#0,d0			any version
	lea	DosName,a1
	move.l	4.w,a6			ExecBase
	jsr	-552(a6)		OpenLibrary
	move.l	d0,DosBase
	beq	exit_now		exit if library could not be opened


* Open the Intuition Library

	moveq	#0,d0
	lea	IntName,a1
	move.l	4.w,a6
	jsr	-552(a6)
	move.l	d0,IntBase
	beq	exit_closedos


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


* Plot Required Graph and Store Sample

	bsr	make.sine


* Save Sample to Required File

	bsr	save.sample


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

exit_closedos
	move.l	DosBase,a1
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

	move.l	#31415927*2*AMOUNT.OF.CYCLES,d0
	jsr	-36(a6)

	move.l	d7,d1
	jsr	-84(a6)			Floating Point Division
	move.l	d0,TwoPi
	rts



make.sine
	move.w	#0,d0
	move.w	#132,d1
	move.l	ScreenRastPort,a1
	move.l	GrafBase,a6
	jsr	-240(a6)		Move Pen

	move.w	#319,d0
	move.w	#132,d1
	move.l	ScreenRastPort,a1
	jsr	-246(a6)		Draw Line

	move.w	#0,t.times.amount.of.values

	move.l	#AMPLITUDE,d0
	move.l	MathBase,a6
	jsr	-36(a6)			Integer to Floating Point
	move.l	d0,fp.amplitude

	move.l	#AMOUNT.OF.VALUES,d0
	jsr	-36(a6)			Integer to Floating Point
	move.l	d0,fp.amount.of.values

	lea	SampleSpace,a5

next.sine.plot
	moveq	#0,d0
	move.w	t.times.amount.of.values,d0
	move.l	MathBase,a6
	jsr	-36(a6)			Integer to Floating Point

	move.l	TwoPi,d1
	jsr	-78(a6)			2*Pi*t*amount

	move.l	fp.amount.of.values,d1
	jsr	-84(a6)			2*Pi*t

	move.l	MathTransBase,a6
	jsr	-36(a6)			Sin(2*Pi*t)

	move.l	fp.amplitude,d1
	move.l	MathBase,a6
	jsr	-78(a6)			A*Sin(2*Pi*t)

	bmi.s	subtract.a.half		Round Result to Closest Value

add.a.half
	move.l	fp.half,d1
	jsr	-66(a6)			Floating Point Addition
	bra.s	rounding.done

subtract.a.half
	move.l	fp.half,d1
	jsr	-72(a6)			Floating Point Subtraction

rounding.done
	jsr	-30(a6)			Floating Point to Integer

	move.b	d0,(a5)+		Save Current Sample

	move.w	d0,d1
	neg.w	d1			Convert to Screen Co-Ordinates
	add.w	#MAX.AMPLITUDE,d1
	mulu	#244,d1
	divu	#MAX.AMPLITUDE*2+1,d1	Compress Vertically
	add.w	#11,d1			Centre Vertically

	move.w	t.times.amount.of.values,d0
	mulu	#320,d0
	divu	#AMOUNT.OF.VALUES,d0	Spread Horizontally
	move.l	ScreenRastPort,a1
	move.l	GrafBase,a6
	jsr	-324(a6)		Plot Pixel

	addq.w	#1,t.times.amount.of.values
	cmp.w	#AMOUNT.OF.VALUES,t.times.amount.of.values
	bne	next.sine.plot
	rts



save.sample
	move.l	#SampleName,d1
	move.l	#1006,d2		MODE_NEWFILE
	move.l	DosBase,a6
	jsr	-30(a6)			Open
	move.l	d0,OutputHandle
	beq.s	sample.saved

	move.l	OutputHandle,d1
	move.l	#SampleSpace,d2
	move.l	#AMOUNT.OF.VALUES,d3
	move.l	DosBase,a6
	jsr	-48(a6)			Write

	move.l	OutputHandle,d1
	move.l	DosBase,a6
	jsr	-36(a6)			Close

sample.saved
	rts



;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

DosName	dc.b	'dos.library',0

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
	dc.b	'Sine Sample Maker V1.0',0
	even

SampleName	dc.b	'ram:Sample',0
	even



;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

DosBase	dc.l	0
IntBase	dc.l	0
GrafBase	dc.l	0
MathBase	dc.l	0
MathTransBase	dc.l	0
ScreenPointer	dc.l	0
ScreenRastPort	dc.l	0
TwoPi	dc.l	0
OutputHandle	dc.l	0

t.times.amount.of.values	dc.w	0
fp.amplitude	dc.l	0
fp.amount.of.values	dc.l	0
fp.half	dc.l	$80000040

SampleSpace	ds.b	AMOUNT.OF.VALUES
