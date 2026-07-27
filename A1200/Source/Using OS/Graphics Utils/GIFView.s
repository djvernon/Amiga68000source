	section	GIFView,code


	include	DH0:Devpac/System2.gs


* Open the intuition library

	moveq	#0,d0
	lea	intuition.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_IntuitionBase
	beq	exit.false

* Open the graphics library

	moveq	#0,d0
	lea	graphics.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_GfxBase
	beq	exit.close.int

* Open the DOS library

	moveq	#0,d0
	lea	DOS.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_DOSBase
	beq	exit.close.graf

* Get standard output handle

	CALLDOS	Output
	move.l	d0,StdOutHandle

* Attempt to view GIF picture

	bsr	gif.view
	bmi	exit.close.dos

* Allocate screen memory

	move.l	width,d0
	lsr.l	#3,d0
	mulu.l	height,d0
	mulu.l	bitsperpixel,d0
	move.l	d0,screen.size
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1
	CALLEXEC AllocMem
	move.l	d0,screen.memory
	beq	exit.close.dos

* Initialize bitmap

	lea	the.bitmap(pc),a0
	move.l	bitsperpixel,d0
	move.w	d0,the.new.screen.depth
	move.l	width,d1
	move.w	d1,the.new.screen.width
	cmp.w	#320,d1
	ble.s	lores
	move.w	#V_HIRES,the.new.screen.modes

lores	move.l	height,d2
	move.w	d2,the.new.screen.height
	cmp.w	#256,d2
	ble.s	.nolace
	or.w	#V_LACE,the.new.screen.modes
.nolace	CALLGRAF InitBitMap

	move.l	screen.memory(pc),a0
	lea	the.bitmap(pc),a1
	lea	bm_Planes(a1),a1
	move.l	bitsperpixel,d0
	subq.w	#1,d0
	move.l	width,d1
	lsr.l	#3,d1
	mulu.l	height,d1

init	move.l	a0,(a1)+
	add.l	d1,a0
	dbra	d0,init

* Open the screen

	lea	the.new.screen(pc),a0
	CALLINT	OpenScreen
	move.l	d0,the.screen
	beq	exit.free.mem

* Change colours

	bsr	convert.colours32
	move.l	the.screen(pc),a0
	lea	sc_ViewPort(a0),a0
	lea	colour.table32(pc),a1
load	CALLGRAF LoadRGB32


;	bsr	make.source.data
	bsr	ChunkyConvert


*"""""""""""""
*" MAIN LOOP "
*"	     "
*"""""""""""""

main	moveq	#10,d1
	CALLDOS	Delay

	btst	#6,$bfe001.l
	bne.s	main


*""""""""""""""""
*" EXIT ROUTINE	"
*"		"
*""""""""""""""""

exit.close.screen
	move.l	the.screen(pc),a0
	CALLINT	CloseScreen

exit.free.mem
	move.l	screen.memory(pc),a1
	move.l	screen.size(pc),d0
	CALLEXEC FreeMem

* Free screen memory (chunky format)

	move.l	chunky(pc),d1
	beq.s	exit.close.dos
	move.l	d1,a1
	move.l	chunky.size,d0
	CALLEXEC FreeMem

exit.close.dos
	move.l	_DOSBase(pc),a1
	CALLEXEC CloseLibrary

exit.close.graf
	move.l	_GfxBase(pc),a1
	CALLEXEC CloseLibrary

exit.close.int
	move.l	_IntuitionBase(pc),a1
	CALLEXEC CloseLibrary

exit.false
	moveq	#0,d0
	rts


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
StdOutHandle	dc.l	0

screen.memory	dc.l	0
screen.size	dc.l	0
the.screen	dc.l	0


*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

intuition.name	INTNAME
graphics.name	GRAFNAME
DOS.name	DOSNAME

screen.title	dc.b	'Dan''s GIF Viewer',0
	even


*""""""""""""""""""""""""
*" INTUITION STRUCTURES "
*"			"
*""""""""""""""""""""""""

the.new.screen	dc.w	0,0		left, top
the.new.screen.width
		dc.w	0
the.new.screen.height
		dc.w	0
the.new.screen.depth
		dc.w	0
		dc.b	0,1		pens
the.new.screen.modes
		dc.w	0		viewmodes
		dc.w	CUSTOMBITMAP!CUSTOMSCREEN	type
		dc.l	0		font
		dc.l	screen.title	title
		dc.l	0		gadgets
		dc.l	the.bitmap	bitmap

the.bitmap	ds.w	1		bytes per row
		ds.w	1		rows
		ds.b	1		flags
		ds.b	1		depth
		ds.w	1		pad
		ds.l	8		plane pointers


*"""""""""""""""""
*" GRAPHICS DATA "
*"		 "
*"""""""""""""""""

	even
colour.table4
	ds.w	256

colour.table32
	dc.w	0		count
	dc.w	0		offset
	ds.l	256*3
	dc.w	0


*"""""""""""""""
*" SUBROUTINES "
*"	       "
*"""""""""""""""

	include	RAM:Debug.s


* ASCII values

BEL	equ	7
BS	equ	8
HT	equ	9
LF	equ	10
CR	equ	13
ESC	equ	$1b
QUOTE	equ	$27
DEL	equ	$7f
CSI	equ	$9b


* Convert colours from 8-bit to 4-bit, for LoadRGB4

convert.colours4
	move.l	colormapsize,d0
	subq.w	#1,d0
	lea	red,a1
	lea	green,a2
	lea	blue,a3
	lea	colour.table4(pc),a4

.loop	move.b	(a1)+,d4
	lsl.w	#4,d4
	and.w	#$f00,d4

	move.b	(a2)+,d3
	and.w	#$0f0,d3
	or.w	d3,d4

	move.b	(a3)+,d3
	lsr.w	#4,d3
	and.w	#$00f,d3
	or.w	d3,d4

	move.w	d4,(a4)+
	dbra	d0,.loop
	rts


* Convert colours from 8-bit to 32-bit, for LoadRGB32

convert.colours32
	lea	colour.table32(pc),a4
	move.l	colormapsize,d0
	move.w	d0,(a4)+
	clr.w	(a4)+

	subq.w	#1,d0
	lea	red,a1
	lea	green,a2
	lea	blue,a3

.loop	move.b	(a1)+,d4
	move.b	d4,d3
	lsl.w	#8,d3
	move.b	d4,d3
	lsl.l	#8,d3
	move.b	d4,d3
	lsl.l	#8,d3
	move.b	d4,d3
	move.l	d3,(a4)+		save red

	move.b	(a2)+,d4
	move.b	d4,d3
	lsl.w	#8,d3
	move.b	d4,d3
	lsl.l	#8,d3
	move.b	d4,d3
	lsl.l	#8,d3
	move.b	d4,d3
	move.l	d3,(a4)+		save green

	move.b	(a3)+,d4
	move.b	d4,d3
	lsl.w	#8,d3
	move.b	d4,d3
	lsl.l	#8,d3
	move.b	d4,d3
	lsl.l	#8,d3
	move.b	d4,d3
	move.l	d3,(a4)+		save blue
	dbra	d0,.loop

	clr.w	(a4)+
	rts


make.source.data
	move.l	chunky(pc),a0
	moveq	#0,d0
	move.w	#256*16-1,d2

.loop
	REPT	10
	move.b	d0,(a0)+
	addq.b	#1,d0
	move.b	d0,(a0)+
	addq.b	#1,d0
	move.b	d0,(a0)+
	addq.b	#1,d0
	move.b	d0,(a0)+
	addq.b	#1,d0
	ENDR
	dbra	d2,.loop
	rts


ChunkyConvert
	move.l	chunky(pc),a0
	move.l	screen.memory(pc),a2

	move.l	a0,a4
	add.l	chunky.size(pc),a4

	move.l	width,d0
	lsr.l	#3,d0
	mulu.l	height,d0
	move.l	d0,plsize

Next32Pixels
	move.w	#0,a5

Next4Pixels
	move.l	(a0)+,d0

	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4
	add.l	d0,d0
	addx.l	d5,d5
	add.l	d0,d0
	addx.l	d6,d6
	add.l	d0,d0
	addx.l	d7,d7
	exg	a1,d1
	add.l	d0,d0
	addx.l	d1,d1
	exg	d1,a1

	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4
	add.l	d0,d0
	addx.l	d5,d5
	add.l	d0,d0
	addx.l	d6,d6
	add.l	d0,d0
	addx.l	d7,d7
	exg	a1,d1
	add.l	d0,d0
	addx.l	d1,d1
	exg	d1,a1

	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4
	add.l	d0,d0
	addx.l	d5,d5
	add.l	d0,d0
	addx.l	d6,d6
	add.l	d0,d0
	addx.l	d7,d7
	exg	a1,d1
	add.l	d0,d0
	addx.l	d1,d1
	exg	d1,a1

	add.l	d0,d0
	addx.l	d1,d1
	add.l	d0,d0
	addx.l	d2,d2
	add.l	d0,d0
	addx.l	d3,d3
	add.l	d0,d0
	addx.l	d4,d4
	add.l	d0,d0
	addx.l	d5,d5
	add.l	d0,d0
	addx.l	d6,d6
	add.l	d0,d0
	addx.l	d7,d7
	exg	a1,d1
	add.l	d0,d0
	addx.l	d1,d1
	exg	d1,a1

	addq.w	#1,a5
	cmp.w	#8,a5
	bne	Next4Pixels

	move.l	a2,a3
	add.l	screen.size,a2
	move.l	bitsperpixel,d0

.pl8	cmp.w	#8,d0
	blt.s	.pl7
	sub.l	plsize,a2
	move.l	d1,(a2)

.pl7	cmp.w	#7,d0
	blt.s	.pl6
	sub.l	plsize,a2
	move.l	d2,(a2)

.pl6	cmp.w	#6,d0
	blt.s	.pl5
	sub.l	plsize,a2
	move.l	d3,(a2)

.pl5	cmp.w	#5,d0
	blt.s	.pl4
	sub.l	plsize,a2
	move.l	d4,(a2)

.pl4	cmp.w	#4,d0
	blt.s	.pl3
	sub.l	plsize,a2
	move.l	d5,(a2)

.pl3	cmp.w	#3,d0
	blt.s	.pl2
	sub.l	plsize,a2
	move.l	d6,(a2)

.pl2	cmp.w	#2,d0
	blt.s	.pl1
	sub.l	plsize,a2
	move.l	d7,(a2)

.pl1	move.l	a3,a2
	move.l	a1,(a2)+

	cmp.l	a0,a4
	bne	Next32Pixels
	rts

plsize	dc.l	0


* GIF constants

IMAGESEP	equ	$2c
INTERLACEMASK	equ	$40
COLORMAPMASK	equ	$80


gif.view

* Allocate raster data stream memory

	move.l	#rawgifsize,d0
	move.l	#MEMF_PUBLIC,d1
	CALLEXEC AllocMem
	move.l	d0,raster
	beq	gif.view.error1

* Check file type is GIF

	lea	rawgif,a2
	lea	gif.id(pc),a3
comp	move.b	(a3)+,d3
	beq.s	ok1
	cmp.b	(a2)+,d3
	bne	gif.view.error2
	bra.s	comp

* Get variables from GIF screen descriptor

* Get first screen dimensions (not used)

ok1	bsr	get.low.high.long
	move.l	d3,rwidth
	bsr	get.low.high.long
	move.l	d3,rheight
	DEBUGL	<Screen Width     : >,rwidth
	DEBUGL	<Screen Height    : >,rheight

* Get colormap flag

	moveq	#0,d2
	move.b	(a2)+,d2
	move.b	d2,d3
	and.b	#COLORMAPMASK,d3
	sne	hascolormap
	DEBUGL	<Has Color Map    : >,hascolormap

* Get bits per pixel, color map size, background

	and.b	#%111,d2
	addq.b	#1,d2
	move.l	d2,bitsperpixel
	moveq	#1,d3
	lsl.l	d2,d3
;	move.l	d3,numcols
	move.l	d3,colormapsize
	subq.l	#1,d3
	move.l	d3,bitmask

	moveq	#0,d2
	move.b	(a2)+,d2
	move.l	d2,background

	DEBUGL	<Bits Per Pixel   : >,bitsperpixel
	DEBUGL	<Color Map Size   : >,colormapsize
	DEBUGL	<Bit Mask         : >,bitmask
	DEBUGL	<Background Color : >,background

* Check next byte is NULL

	move.b	(a2)+,d2
	bne	gif.view.error3

* Read in global colormap

	tst.b	hascolormap
	beq.s	nomap

	lea	red,a3
	lea	green,a4
	lea	blue,a5
	lea	used,a0
	move.l	colormapsize,d0
	subq.w	#1,d0
read	move.b	(a2)+,(a3)+
	move.b	(a2)+,(a4)+
	move.b	(a2)+,(a5)+
	move.b	#0,(a0)+
	dbra	d0,read
	move.l	#0,numused
	bra.s	gotcol

nomap	DEBUGM	<Warning! No colortable in this file>

* Check for image separator

gotcol	move.b	(a2)+,d2
	cmp.b	#IMAGESEP,d2
	bne	gif.view.error4

* Read in values from image descriptor

	bsr	get.low.high.long
	move.l	d3,leftofs
	bsr	get.low.high.long
	move.l	d3,topofs
	bsr	get.low.high.long
	move.l	d3,width
	bsr	get.low.high.long
	move.l	d3,height
	DEBUGL	<Left Offset      : >,leftofs
	DEBUGL	<Top Offset       : >,topofs
	DEBUGL	<Width            : >,width
	DEBUGL	<Height           : >,height

	move.b	(a2)+,d2
	and.b	#INTERLACEMASK,d2
	sne	interlace
	DEBUGL	<Interlace        : >,interlace

* Start reading the raster data, get the initial code size

	moveq	#0,d2
	move.b	(a2)+,d2
	move.l	d2,codesize
	moveq	#1,d3
	lsl.l	d2,d3
	move.l	d3,clearcode
	addq.l	#1,d3
	move.l	d3,eofcode
	addq.l	#1,d3
	move.l	d3,freecode
	move.l	d3,firstfree

	addq.l	#1,codesize
	move.l	codesize,initcodesize

	move.l	codesize,d2
	moveq	#1,d3
	lsl.l	d2,d3
	move.l	d3,maxcode
	subq.l	#1,d3
	move.l	d3,readmask

* Read the raster data from the GIF array, turning it
* from a series of blocks into one long data stream

	move.l	raster,a3
turn	moveq	#0,d2
	move.b	(a2)+,d2
	beq.s	done
	subq.w	#1,d2

block	move.b	(a2)+,(a3)+
	dbra	d2,block

	move.l	a3,d0
	sub.l	raster,d0
	cmp.l	#rawgifsize,d0
	bgt	gif.view.error5
	bra.s	turn

done	DEBUGM
	DEBUGM	<Decompressing...>

* Allocate screen memory (chunky format)

	move.l	width,d0
	mulu.l	height,d0
	move.l	d0,chunky.size
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1
	CALLEXEC AllocMem
	move.l	d0,chunky
	beq	gif.view.error6

	move.l	width,bytesperscanline

* Decompress the file, until EOF code is seen

doit	move.l	chunky,chunky.ptr

decomp	bsr	read.code
	cmp.l	eofcode,d3
	beq	gif.decompd

	cmp.l	clearcode,d3
	bne.s	data
	move.l	initcodesize,codesize
	move.l	codesize,d2
	moveq	#1,d3
	lsl.l	d2,d3
	move.l	d3,maxcode
	subq.l	#1,d3
	move.l	d3,readmask
	move.l	firstfree,freecode
	bsr	read.code
	move.l	d3,curcode
	move.l	d3,oldcode
	and.l	bitmask,d3
	move.l	d3,finchar
	bsr	add.to.pixel
	bra.s	decomp

data	move.l	d3,curcode
	move.l	d3,incode

	cmp.l	freecode,d3
	blt.s	less
	move.l	oldcode,curcode
	lea	outcode,a0
	move.l	outcount,d0
	move.l	finchar,(a0,d0.l*4)
	addq.l	#1,outcount

less	move.l	curcode,d3
	cmp.l	bitmask,d3
	ble.s	last
	cmp.l	#1024,outcount
	bgt	gif.view.error7
	lea	outcode,a0
	move.l	outcount,d0
	lea	suffix,a3
	lea	prefix,a4
	move.l	(a3,d3.l*4),(a0,d0.l*4)
	move.l	(a4,d3.l*4),d3
	move.l	d3,curcode
	addq.l	#1,outcount
	bra.s	less

* The last code in the chain is treated as raw data

last	and.l	bitmask,d3
	move.l	d3,finchar

	lea	outcode,a0
	move.l	outcount,d0
	move.l	d3,(a0,d0.l*4)
	addq.l	#1,outcount

* Now put the data out to the output routine

	lea	outcode,a0
	move.l	outcount,d0
	subq.w	#1,d0
out	move.l	(a0,d0.w*4),d3
	bsr	add.to.pixel
	dbra	d0,out
	move.l	#0,outcount

* Build the hash table on the fly.  No table is stored in the file.

	lea	prefix,a4
	lea	suffix,a3
	move.l	freecode,d0
	move.l	oldcode,(a4,d0.l*4)
	move.l	finchar,(a3,d0.l*4)
	move.l	incode,oldcode

* Point to the next slot in the table

	addq.l	#1,freecode
	move.l	freecode,d1
	cmp.l	maxcode,d1
	blt	decomp

	move.l	codesize,d1
	cmp.l	#12,d1
	bge	decomp
	addq.l	#1,d1
	move.l	d1,codesize
	moveq	#1,d3
	lsl.l	d1,d3
	move.l	d3,maxcode
	subq.l	#1,d3
	move.l	d3,readmask
	bra	decomp

* Could now free raster data stream memory

gif.decompd
	DEBUGL	<Colors Used      : >,numused
	DEBUGM

	move.l	raster(pc),a1
	move.l	#rawgifsize,d0
	CALLEXEC FreeMem

	moveq	#0,d0
	rts

* Free screen memory (chunky format)

gif.view.free2
	move.l	chunky(pc),a1
	move.l	chunky.size,d0
	CALLEXEC FreeMem

* Free raster data stream memory

gif.view.free1
	move.l	raster(pc),a1
	move.l	#rawgifsize,d0
	CALLEXEC FreeMem

gif.view.error
	moveq	#-1,d0
	rts

gif.view.error1
	DEBUGM	<Not enough memory for raster data>
	rts

gif.view.error2
	DEBUGM	<Not a GIF87a file>
	bra	gif.view.free1

gif.view.error3
	DEBUGM	<Corrupt GIF file (bad screen descriptor)>
	bra	gif.view.free1

gif.view.error4
	DEBUGM	<Corrupt GIF file (no image separator)>
	bra	gif.view.free1

gif.view.error5
	DEBUGM	<Corrupt GIF file (unblock)>
	bra	gif.view.free1

gif.view.error6
	DEBUGM	<Not enough memory for chunky data>
	bra	gif.view.free1

gif.view.error7
	DEBUGM	<Corrupt GIF file (OutCount)>
	bra	gif.view.free2


get.low.high.long
	moveq	#0,d3
	move.b	(a2)+,d2
	move.b	(a2)+,d3
	lsl.w	#8,d3
	move.b	d2,d3
	rts


* Fetch next code from raster data stream
* Codes can be 3 to 12 bits long, packed into bytes

read.code
	move.l	bitoffset,d0
	move.l	d0,d1
	lsr.l	#3,d1		get byte offset
	move.l	raster,a0
	add.l	d1,a0
	move.l	d0,d1
	and.l	#%111,d1	get bit offset into byte
	add.l	codesize,d0
	move.l	d0,bitoffset

	moveq	#0,d3
	move.b	2(a0),d3
	lsl.l	#8,d3
	move.b	1(a0),d3
	lsl.l	#8,d3
	move.b	(a0),d3
	lsr.l	d1,d3
	and.l	readmask,d3
	rts


add.to.pixel

* d3 = index

;	move.l	height,d1
;	move.l	yc,d2
;	cmp.l	d1,d2
;	bge.s	.less
;	mulu.l	bytesperscanline,d2
;	add.l	xc,d2
;	move.l	chunky(pc),a1
;	move.b	d3,(a1,d2.l)		set chunky pixel

	move.l	chunky.ptr(pc),a1
	move.b	d3,(a1)+
	move.l	a1,chunky.ptr

.less	and.w	#$ff,d3			may not need this
	lea	used,a1
	tst.b	(a1,d3.w)
	bne.s	.used
	st	(a1,d3.w)
	addq.l	#1,numused
.used	rts

;* Update the X-coordinate.  If it overflows then update the Y-coordinate
;
;.used	move.l	xc,d1
;	addq.l	#1,d1
;	cmp.l	width,d1
;	blt.s	.done
;	moveq	#0,d1
;	addq.l	#1,yc
;.done	move.l	d1,xc
;	rts


gif.id	dc.b	'GIF87a',0

raster	dc.l	0
chunky	dc.l	0
chunky.ptr	dc.l	0
chunky.size	dc.l	0
bitoffset	dc.l	0
xc	dc.l	0
yc	dc.l	0
pass	dc.l	0
outcount	dc.l	0
rwidth	dc.l	0
rheight	dc.l	0
width	dc.l	0
height	dc.l	0
leftofs	dc.l	0
topofs	dc.l	0
bitsperpixel	dc.l	0
bytesperscanline	dc.l	0
colormapsize	dc.l	0
background	dc.l	0
codesize	dc.l	0
initcodesize	dc.l	0
code	dc.l	0
maxcode	dc.l	0
clearcode	dc.l	0
eofcode	dc.l	0
curcode	dc.l	0
oldcode	dc.l	0
incode	dc.l	0
firstfree	dc.l	0
freecode	dc.l	0
finchar	dc.l	0
bitmask	dc.l	0
readmask	dc.l	0
interlace	dc.l	0
hascolormap	dc.b	0
	even

prefix	ds.l	4096
suffix	ds.l	4096

outcode	ds.l	1025

red	ds.b	256
green	ds.b	256
blue	ds.b	256
used	ds.b	256
numused	dc.l	0

rawgif	incbin	DAN:claudia.gif
rawgifsize	equ	*-rawgif

