	section	GimmeText,code
	opt	o+




TAB	equ	9
LF	equ	10
CLOSE.QUOTE	equ	39




* Save address of CLI command string

	move.l	a0,Command
	clr.b	-1(a0,d0.w)		null-terminate the command string




* Open the DOS library

	moveq	#0,d0
	lea	dosname(pc),a1
	move.l	4.w,a6
	jsr	-552(a6)		OpenLibrary
	move.l	d0,DOSBase
	beq	exit_now




* Get standard output handle

	move.l	DOSBase(pc),a6
	jsr	-60(a6)			Output
	move.l	d0,StdOutHandle




* Print title text

	move.l	StdOutHandle(pc),d1
	move.l	#title,d2
	moveq	#titlelen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write




* Get input filename

	move.l	Command(pc),a0
	move.b	(a0),d0
	beq	error1

	lea	InputFilename(pc),a1
	bsr	get.filename

	tst.b	d0			check for null
	beq	error2			if null then no output filename given




* Get output filename

	lea	OutputFilename(pc),a1
	bsr	get.filename




* Get lock on input file

	move.l	#InputFilename,d1
	moveq	#-2,d2			ACCESS_READ
	move.l	DOSBase(pc),a6
	jsr	-84(a6)			Lock
	move.l	d0,InputLock
	beq	error3




* Examine input file

	move.l	InputLock(pc),d1
	move.l	#FileInfoBlock,d2
	move.l	DOSBase(pc),a6
	jsr	-102(a6)		Examine
	tst.l	d0
	beq	error4




* Unlock input file

	move.l	InputLock(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-90(a6)			UnLock




* Allocate memory for input file and output file

	move.l	FileInfoBlock+124(pc),d0
	move.l	d0,InputLength
	add.l	d0,d0
	move.l	d0,d1
	add.l	d1,d1
	add.l	d1,d0
	move.l	d0,MemoryLength		+ 5 lots more for output file
	moveq	#0,d1
	move.l	4.w,a6
	jsr	-198(a6)		AllocMem
	move.l	d0,InputMem
	beq	error5
	add.l	InputLength(pc),d0
	move.l	d0,OutputMem




* Open input file

	move.l	#InputFilename,d1
	move.l	#1005,d2		MODE_OLDFILE
	move.l	DOSBase(pc),a6
	jsr	-30(a6)			Open
	move.l	d0,InputHandle
	beq	error6




* Read input file into memory

	move.l	InputHandle(pc),d1
	move.l	InputMem(pc),d2
	move.l	InputLength(pc),d3
	move.l	DOSBase(pc),a6
	jsr	-42(a6)			Read
	tst.l	d0
	bmi	error7




* Close input file

	move.l	InputHandle(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close




* Make output data

	bsr	make.output




* Open output file

	move.l	#OutputFilename,d1
	move.l	#1006,d2		MODE_NEWFILE
	move.l	DOSBase(pc),a6
	jsr	-30(a6)			Open
	move.l	d0,OutputHandle
	beq	error8




* Write data to output file

	move.l	OutputHandle(pc),d1
	move.l	OutputMem(pc),d2
	move.l	OutputLength(pc),d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	tst.l	d0
	bmi	error9




exit_closeoutput
	move.l	OutputHandle(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close




exit_freemem
	move.l	MemoryLength(pc),d0
	move.l	InputMem(pc),a1
	move.l	4.w,a6
	jsr	-210(a6)		FreeMem




exit_closedos
	move.l	DOSBase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary




exit_now
	moveq	#0,d0
	rts




;""""""""""""""""""
;" ERROR HANDLING "
;"		  "
;""""""""""""""""""

error1	move.l	StdOutHandle(pc),d1
	move.l	#error1text,d2
	moveq	#error1textlen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	bra.s	exit_closedos




error2	move.l	StdOutHandle(pc),d1
	move.l	#error2text,d2
	moveq	#error2textlen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	bra.s	exit_closedos




error3	move.l	StdOutHandle(pc),d1
	move.l	#error3text,d2
	moveq	#error3textlen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	bra.s	exit_closedos




error4	move.l	StdOutHandle(pc),d1
	move.l	#error4text,d2
	moveq	#error4textlen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write

	move.l	InputLock(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-90(a6)			UnLock
	bra.s	exit_closedos




error5	move.l	StdOutHandle(pc),d1
	move.l	#error5text,d2
	moveq	#error5textlen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	bra	exit_closedos




error6	move.l	StdOutHandle(pc),d1
	move.l	#error6text,d2
	moveq	#error6textlen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	bra	exit_freemem




error7	move.l	StdOutHandle(pc),d1
	move.l	#error7text,d2
	moveq	#error7textlen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write

	move.l	InputHandle(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close
	bra	exit_freemem




error8	move.l	StdOutHandle(pc),d1
	move.l	#error8text,d2
	moveq	#error8textlen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	bra	exit_freemem




error9	move.l	StdOutHandle(pc),d1
	move.l	#error9text,d2
	moveq	#error9textlen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	bra	exit_closeoutput




;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

get.filename
	move.b	(a0)+,d0
	beq.s	got.filename

	cmp.b	#' ',d0
	beq.s	got.filename

	move.b	d0,(a1)+
	bra.s	get.filename

got.filename
	clr.b	(a1)			null-terminate the filename
	rts




make.output
	move.l	InputMem(pc),a0
	move.l	OutputMem(pc),a1
	move.l	a0,a2
	add.l	InputLength(pc),a2
	sf	InsideQuotes

more.input.data
	moveq	#0,d7			items on line
	bsr.s	line.header

more.items.on.line
	moveq	#0,d0
	move.b	(a0)+,d0		next input character
	bsr.s	output.in.correct.format
	addq.w	#1,d7			1 more item on this line
	cmp.l	a2,a0
	bge.s	end.this.line

not.input.data.end
	cmp.w	#16,d7			16 items per line
	blt.s	more.items.on.line

end.this.line
	tst.b	InsideQuotes
	beq.s	not.inside.quotes
	move.b	#CLOSE.QUOTE,(a1)+
	sf	InsideQuotes

not.inside.quotes
	move.b	#LF,(a1)+
	cmp.l	a2,a0
	blt.s	more.input.data

	sub.l	OutputMem(pc),a1
	move.l	a1,OutputLength
	rts




line.header
	move.b	#' ',(a1)+		SPACE,'dc.b',TAB
	move.b	#'d',(a1)+
	move.b	#'c',(a1)+
	move.b	#'.',(a1)+
	move.b	#'b',(a1)+
	move.b	#TAB,(a1)+
	rts




output.in.correct.format
	cmp.w	#31,d0
	ble.s	format.decimal
	cmp.w	#127,d0
	bge.s	format.decimal

	cmp.w	#CLOSE.QUOTE,d0
	beq.s	format.close.quote




format.character
	tst.b	InsideQuotes
	bne.s	inside.quotes
	tst.w	d7
	beq.s	no.items.on.line
	move.b	#',',(a1)+

no.items.on.line
	move.b	#CLOSE.QUOTE,(a1)+
	st	InsideQuotes

inside.quotes
	move.b	d0,(a1)+		output as character
	rts




format.decimal
	tst.b	InsideQuotes
	beq.s	not.inside.quotes2
	move.b	#CLOSE.QUOTE,(a1)+
	sf	InsideQuotes

not.inside.quotes2
	tst.w	d7
	beq.s	no.items.on.line2
	move.b	#',',(a1)+

no.items.on.line2
	bra.s	output.as.decimal




format.close.quote
	tst.b	InsideQuotes
	beq.s	not.inside.quotes3
	move.b	#CLOSE.QUOTE,(a1)+
	move.b	#CLOSE.QUOTE,(a1)+
	rts

not.inside.quotes3
	tst.w	d7
	beq.s	no.items.on.line3
	move.b	#',',(a1)+

no.items.on.line3
;	bra.s	output.as.decimal




output.as.decimal
	sf	SomeHundreds

	move.l	d0,d1
	divu	#100,d1
	beq.s	hundreds.done
	move.b	d1,d2
	add.b	#'0',d2
	move.b	d2,(a1)+		save hundreds
	st	SomeHundreds

	mulu	#100,d1
	sub.l	d1,d0

hundreds.done
	move.l	d0,d1
	divu	#10,d1
	bne.s	some.tens
	tst.b	SomeHundreds
	beq.s	tens.done

some.tens
	move.b	d1,d2
	add.b	#'0',d2
	move.b	d2,(a1)+		save tens

	mulu	#10,d1
	sub.l	d1,d0

tens.done
	add.b	#'0',d0
	move.b	d0,(a1)+		save units
	rts




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

Command	dc.l	0
DOSBase	dc.l	0

StdOutHandle	dc.l	0
InputHandle	dc.l	0
OutputHandle	dc.l	0

InputLock	dc.l	0

InputFilename	ds.b	108
OutputFilename	ds.b	108

InputMem	dc.l	0
InputLength	dc.l	0
MemoryLength	dc.l	0
OutputMem	dc.l	0
OutputLength	dc.l	0

InsideQuotes	dc.b	0
SomeHundreds	dc.b	0

	cnop	0,4			must be longword aligned

FileInfoBlock	ds.l	65




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

dosname	dc.b	'dos.library',0
	even

title	dc.b	'GimmeText V1.0  --  Written by Daniel Vernon in 1992',10,10,0
titlelen	equ	*-title

error1text
	dc.b	'No input filename specified',10,10,0
error1textlen	equ	*-error1text

error2text
	dc.b	'No output filename specified',10,10,0
error2textlen	equ	*-error2text

error3text
	dc.b	'Could not get lock on input file',10,10,0
error3textlen	equ	*-error3text

error4text
	dc.b	'Could not examine input file',10,10,0
error4textlen	equ	*-error4text

error5text
	dc.b	'Could not allocate memory for files',10,0
error5textlen	equ	*-error5text

error6text
	dc.b	'Could not open input file',10,0
error6textlen	equ	*-error6text

error7text
	dc.b	'Could not read input file',10,0
error7textlen	equ	*-error7text

error8text
	dc.b	'Could not open output file',10,0
error8textlen	equ	*-error8text

error9text
	dc.b	'Could not write output file',10,0
error9textlen	equ	*-error9text
