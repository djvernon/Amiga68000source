	section	LotteryPatterns,code
	opt	c+,a+


	incdir	DH0:include/
	include	exec/exec_lib.i
	include	libraries/dos.i
	include	libraries/dos_lib.i


NUMBERS_PER_WEEK	equ	6


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

* Work out totals for each number from 1 to 49

	moveq	#LOTTERY_WEEKS-1,d7
	lea	lottery.results(pc),a6
	lea	number.totals(pc),a5
next.week
	moveq	#NUMBERS_PER_WEEK-1,d6
next.number
	move.l	(a6)+,d5
	subq.l	#1,d5
	addq.l	#1,(a5,d5.l*4)
	dbra	d6,next.number
	dbra	d7,next.week

* Print out totals for each number from 1 to 49

	moveq	#1,d7
	lea	number.totals(pc),a5
	lea	number.total.text(pc),a4
	lea	17(a4),a3
next.total
	move.l	a3,a0
	move.l	d7,d0
	bsr	longword.to.ASCII
	move.b	#' ',(a0)+
	move.b	#'=',(a0)+
	move.b	#' ',(a0)+
	move.l	(a5)+,d0
	bsr	longword.to.ASCII
	move.b	#LF,(a0)+
	clr.b	(a0)

	move.l	StdOutHandle(pc),d1
	move.l	a4,d2
	move.l	a0,d3
	sub.l	a4,d3
	CALLDOS	Write

	addq.l	#1,d7
	cmp.l	#50,d7
	bne.s	next.total

exit.close.dos
	move.l	_DOSBase(pc),a1
	CALLEXEC CloseLibrary

exit.false
	moveq	#0,d0
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
	rts

.decimal.zero
	move.b	#'0',(a0)+
	rts


powers.of.ten
	dc.l	1000000000,100000000,10000000,1000000
	dc.l	100000,10000,1000,100,10,1


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

_DOSBase	dc.l	0
StdOutHandle	dc.l	0

number.totals	dcb.l	49,0

number.total.text
	dc.b	'Total for number xx = xxxxxxxxxx',LF,0
	even

*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

DOS.name	DOSNAME
	even

lottery.results
	dc.l	30,03,05,44,14,22
	dc.l	16,06,44,31,12,15
	dc.l	11,17,21,29,30,40
	dc.l	26,47,49,43,35,38
	dc.l	13,03,38,05,14,09
	dc.l	27,29,39,03,44,02
	dc.l	17,44,36,32,09,42
	dc.l	02,05,21,22,25,32
	dc.l	07,17,23,32,38,42
	dc.l	06,16,20,30,31,47
	dc.l	04,16,25,26,31,43
	dc.l	01,07,37,38,42,46
	dc.l	15,18,29,35,38,48
	dc.l	45,16,36,19,21,29
	dc.l	18,33,08,31,05,10
	dc.l	17,36,11,12,42,26
	dc.l	02,13,22,27,29,46
	dc.l	41,19,31,18,09,24
	dc.l	04,49,41,44,42,17
	dc.l	43,41,22,25,30,32
	dc.l	42,17,22,24,47,14
	dc.l	01,23,26,04,06,49
	dc.l	33,36,08,20,38,18
	dc.l	09,15,22,31,34,48
	dc.l	35,14,48,17,43,05
	dc.l	41,16,28,25,07,26
	dc.l	46,15,17,28,16,32
	dc.l	12,13,25,37,44,45
	dc.l	31,01,29,40,21,32
	dc.l	44,15,26,46,12,49
	dc.l	48,30,40,27,38,33
	dc.l	05,43,45,21,15,42
	dc.l	25,07,08,05,48,44
	dc.l	03,14,11,20,01,40
	dc.l	01,04,43,20,31,41
	dc.l	03,21,22,02,23,40
	dc.l	41,34,49,28,46,45
	dc.l	01,08,25,30,35,45
	dc.l	25,33,28,47,11,34
	dc.l	05,08,23,24,28,48
	dc.l	21,41,18,38,16,27
	dc.l	01,15,22,28,40,49
	dc.l	12,22,41,02,20,45
	dc.l	02,10,14,25,37,41
	dc.l	10,34,24,19,05,46
	dc.l	11,33,40,10,32,29
	dc.l	28,37,10,30,36,22
	dc.l	25,30,09,05,04,47
	dc.l	17,19,02,21,06,47
	dc.l	16,33,44,27,35,07
	dc.l	06,14,18,48,27,44
	dc.l	23,28,48,10,07,30
	dc.l	04,07,18,33,45,48
	dc.l	16,23,28,30,42,46
	dc.l	26,16,19,46,15,35
	dc.l	05,26,29,12,11,33
	dc.l	07,08,23,28,35,49
	dc.l	06,11,34,40,47,49
	dc.l	06,32,39,42,43,45
LOTTERY_WEEKS	equ	(*-lottery.results)/24
