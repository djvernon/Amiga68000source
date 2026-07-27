	section	ChunkyYPatterns,code
	opt	c+,a+


	include DH0:Devpac/System2.gs

	;incdir	DH0:devpac/include/
	;include	exec/exec_lib.i
	;include	libraries/dos.i
	;include	libraries/dos_lib.i


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


* Open the DOS library

	moveq	#0,d0
	lea	DOS.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_DOSBase
	beq	exit.false

* Get standard output handle

	CALLDOS	Output
	move.l	d0,StdOutHandle

* Analyse Patterns Within Chunky Y Offsets

;	bsr	analyse.chunky.y.patterns
	bsr	arse

exit.close.dos
	move.l	_DOSBase(pc),a1
	CALLEXEC CloseLibrary

exit.false
	moveq	#0,d0
	rts


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

_DOSBase	dc.l	0
StdOutHandle	dc.l	0


*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

DOS.name	DOSNAME
	even


*""""""""""""""""""""""""""""""
*" CALCULATE CHUNKY Y OFFSETS "
*"			      "
*""""""""""""""""""""""""""""""

SOURCE_WIDTH	equ	64
SOURCE_HEIGHT	equ	64


START_HEIGHT	equ	2
END_HEIGHT	equ	255

TOTAL_HEIGHTS	equ	END_HEIGHT-START_HEIGHT+1


chunky.y.offset.ptrs
	ds.l	END_HEIGHT		for heights from 1 to END_HEIGHT
	ds.l	1			for last ptr


calc.chunky.y.offsets
	lea	chunky.y.offsets(pc),a0
	lea	chunky.y.offset.ptrs(pc),a1
	moveq	#6,d7			depends upon SOURCE_WIDTH
	move.l	#(SOURCE_HEIGHT-1)<<16,d0
	move.l	a0,(a1)+
	move.l	a0,(a1)+
	moveq	#START_HEIGHT,d3
	move.w	#TOTAL_HEIGHTS-1,d6	count for dbra

.next.width
	move.l	d3,d2			current height
	subq.w	#1,d2			number of values required (height-1)
	move.l	d0,d1
	divsl.l	d2,d1:d1
	moveq	#0,d4
	moveq	#0,d5

	subq.w	#1,d2			count for dbra

.next.value
	move.w	d4,d5
	swap	d4
	add.l	d1,d4
	swap	d4
	sub.w	d4,d5
	neg.w	d5
;;	asl.w	d7,d5			64 bytes per chunky line
	move.w	d5,(a0)+
	dbra	d2,.next.value

	move.l	a0,(a1)+
	addq.w	#1,d3
	dbra	d6,.next.width
	rts


****************************************


;analyse.chunky.y.patterns
arse	bsr	calc.chunky.y.offsets

	moveq	#0,d0
	moveq	#1,d7			start height

.first.height
	lea	first.height.text(pc),a0
	bsr	print.text

.next.height
	addq.w	#1,d7

* print current height

	lea	height.text+9(pc),a0
	move.w	d7,d0
	bsr	longword.to.ASCII
	move.b	#',',(a0)+
	move.b	#' ',(a0)+
	clr.b	(a0)
	lea	height.text(pc),a0
	bsr	print.text

* print pattern information

	move.w	d7,d6
	subq.w	#1,d6			number of values (height-1)
	lea	chunky.y.offset.ptrs(pc),a0
	move.l	(a0,d6.w*4),a1

	subq.w	#1,d6			count for dbra

.next.pattern
	move.l	a1,a2			pattern address
	moveq	#1,d5			pattern length
	moveq	#0,d4			pattern count

	move.l	a2,a3
.count.pattern
	cmp.w	(a2)+,(a3)+
	bne.s	.print.pattern

.repeat.pattern
	addq.w	#1,d4			increment pattern count
	dbra	d6,.count.pattern

* end of the current height's offsets has been reached

	bsr	print.pattern
	bra.s	.end.height

* pattern has stopped repeating

.print.pattern
	bsr	print.pattern
	dbra	d6,.next.pattern

* move on to next height

.end.height
	lea	end.text(pc),a0
	bsr	print.text

;	cmp.w	#END_HEIGHT,d7
	cmp.w	#4,d7
	bne	.next.height
	rts


* print pattern out, together with its count

print.pattern
	lea	pattern.text+10(pc),a0
	subq.w	#1,d5
.print.loop
	move.w	(a1)+,d0
	bsr	longword.to.ASCII
	move.b	#' ',(a0)+
	dbra	d5,.print.loop
	move.b	#',',(a0)+
	move.b	#' ',(a0)+
	clr.b	(a0)
	lea	pattern.text(pc),a0
	bsr	print.text

	lea	count.text+8(pc),a0
	move.w	d4,d0
	bsr	longword.to.ASCII
	move.b	#',',(a0)+
	move.b	#' ',(a0)+
	clr.b	(a0)
	lea	count.text(pc),a0
	bsr	print.text
	rts


first.height.text
	dc.b	'Height = 1, no offsets required',CR,LF,0
	even

height.text
	dc.b	'Height = xxxxxxxxxx, ',0
	even

pattern.text
	dc.b	'Pattern = xx xx xx xx, ',0
	even

count.text
	dc.b	'Count = xxx, ',0
	even

end.text
	dc.b	CR,LF,0
	even


****************************************


print.text
*
* a0 = address of string
*
	movem.l	d0-d3/a0-a1,-(sp)

	move.l	StdOutHandle(pc),d1
	move.l	a0,d2

.loop	tst.b	(a0)+
	bne.s	.loop

	move.l	a0,d3
	sub.l	d2,d3
	subq.l	#1,d3			calculate string length

	CALLDOS	Write

	movem.l	(sp)+,d0-d3/a0-a1
	rts


****************************************


longword.to.ASCII

* d0 = number (longword)
* a0 = address for ASCII string to be written
* leading zeros are not output
*
* returns with a0 = address of position after last char. of string
*
* uses d0-d4, a0/a2

	movem.l	d0-d4/a2,-(sp)

	tst.l	d0
	beq.s	.decimal.zero

	lea	powers.of.ten(pc),a2
	moveq	#10-1,d3		do 10 digits
	moveq	#0,d4			miss off leading zeros

.loop	moveq	#'0',d1
	move.l	(a2)+,d2		get next power of ten

.calc.digit
	sub.l	d2,d0
	bcs.s	.digit.done
	addq.b	#1,d1			next digit up
	bra.s	.calc.digit

.digit.done
	add.l	d2,d0			restore remaining part of number

	tst.b	d4			if flag is set
	bne.s	.save.digit		then save all digits

	cmp.b	#'0',d1			if digit is zero
	beq.s	.next.position		then miss it

	st	d4			don't miss off any more zeros

.save.digit
	move.b	d1,(a0)+

.next.position
	dbra	d3,.loop
	bra.s	.done

.decimal.zero
	move.b	#'0',(a0)+

.done	movem.l	(sp)+,d0-d4/a2
	rts


powers.of.ten
	dc.l	1000000000,100000000,10000000,1000000
	dc.l	100000,10000,1000,100,10,1


****************************************


START_VALUES	equ	START_HEIGHT-1
END_VALUES	equ	END_HEIGHT-1


chunky.y.offsets
*
* (average height * total heights)
*
	ds.w	((START_VALUES+END_VALUES)*(TOTAL_HEIGHTS))/2


****************************************
