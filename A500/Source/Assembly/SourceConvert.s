	section	SourceConvert,code
	opt	o+




TAB	equ	9
LF	equ	10




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
	add.l	d0,d0			+ same amount for output file
	move.l	d0,MemoryLength
	moveq	#0,d1
	move.l	4.w,a6
	jsr	-198(a6)		AllocMem
	move.l	d0,InputMem
	beq	error5
	add.l	FileInfoBlock+124(pc),d0
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




* Convert input file

	bsr	source.convert




* Open output file

	move.l	#OutputFilename,d1
	move.l	#1006,d2		MODE_NEWFILE
	move.l	DOSBase(pc),a6
	jsr	-30(a6)			Open
	move.l	d0,OutputHandle
	beq	error8




* Write to output file

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




convert.space
	cmp.b	(a0)+,d1
	beq.s	convert.space

	move.b	d2,(a1)+		replace the spaces with a TAB
	subq.l	#1,a0
	bra.s	check.for.end




remove.top.lines
	moveq	#LF,d1
	moveq	#7-1,d2			remove first 7 lines

.loop	cmp.b	(a0)+,d1
	bne.s	.loop

	dbra	d2,.loop
	rts




source.convert
	move.l	InputMem(pc),a0		source address
	move.l	a0,a2
	add.l	InputLength(pc),a2	calculate end address
	move.l	OutputMem(pc),a1	destination address

	bsr.s	remove.top.lines

	moveq	#' ',d1			first convert spaces to tabs
	moveq	#TAB,d2			and all characters to lower case
	moveq	#'A',d3
	moveq	#'Z',d4
	moveq	#$20,d5

convert.loop
	move.b	(a0)+,d0
	cmp.b	d1,d0
	beq.s	convert.space

	cmp.b	d3,d0			if character is in upper case
	blt.s	in.lower.case

	cmp.b	d4,d0
	bgt.s	in.lower.case

	add.b	d5,d0			convert it to lower case

in.lower.case
	move.b	d0,(a1)+

check.for.end
	cmp.l	a2,a0
	blt.s	convert.loop		if end of file not reached

	sub.l	OutputMem(pc),a1	calculate output length
	move.l	a1,OutputLength




convert.special
	move.l	OutputMem(pc),d6	now convert special words
	move.l	InputMem(pc),d7

	lea	word.conversions(pc),a3
	moveq	#'=',d5

convert.special.loop
	move.l	d6,a0			source address
	move.l	d7,a1			destination address

	move.l	a0,a2
	add.l	OutputLength(pc),a2	calculate end address

	move.l	a3,d3			address of special word

find.replacement
	move.b	(a3)+,d4		get next character of special word
	beq.s	end.word.convert

	cmp.b	d5,d4
	bne.s	find.replacement	if '=' sign not found

	move.l	a3,d4			address of replacement word

find.next.word
	tst.b	(a3)+
	bne.s	find.next.word		point to next special word



search.for.word
	move.l	d3,a4			set to start of special word
	moveq	#0,d2			number of matching characters
	sf	wild.card.found
	move.b	(a4)+,d1		get first character of special word

check.next.character
	cmp.b	#'?',d1
	beq.s	wildcard

	cmp.b	(a0)+,d1		get next character from source
	bne.s	continue.search		if characters do not match

one.more.char
	addq.w	#1,d2			one more matching character

	move.b	(a4)+,d1		get next character of special word
	cmp.b	d5,d1
	bne.s	check.next.character	if '=' sign not found

;					otherwise the word was found

	move.l	d4,a4			set to start of replacement word

replace.word
	move.b	(a4)+,d0
	beq.s	check.for.end2

	cmp.b	#'?',d0
	beq.s	copy.wild.card.char

	move.b	d0,(a1)+		insert replacement word
	bra.s	replace.word

copy.wild.card.char
	move.b	(a5)+,(a1)+		copy character from source
	bra.s	replace.word



wildcard
	tst.b	wild.card.found
	bne.s	got.wild.card.ptr

	move.l	a0,a5			address of first wildcard character
	st	wild.card.found

got.wild.card.ptr
	addq.l	#1,a0			skip source character
	bra.s	one.more.char

wild.card.found
	dc.b	0,0



continue.search
	move.w	d2,d1
	neg.w	d1
	lea	-1(a0,d1.w),a0		set to position where search started

.loop	move.b	(a0)+,(a1)+		copy all characters that were read
	dbra	d2,.loop



check.for.end2
	cmp.l	a2,a0
	blt.s	search.for.word		if end of file not reached



exchange.buffers
	sub.l	d7,a1			calculate output length
	move.l	a1,OutputLength

	exg	d6,d7			exchange source with destination
	bra.s	convert.special.loop



end.word.convert
	move.l	d6,OutputMem		save address of output file
	rts




word.conversions
	dc.b	':=',0
	dc.b	'$0000000=$',0
	dc.b	'$000000=$',0
	dc.b	'$00000=$',0
	dc.b	'$0000=$',0
	dc.b	'$000=$',0
	dc.b	'adda=add',0
	dc.b	'addi=add',0
	dc.b	'andi=and',0
	dc.b	'bchg.b=bchg',0
	dc.b	'bclr.b=bclr',0
	dc.b	'bset.b=bset',0
	dc.b	'btst.b=btst',0
	dc.b	'bchg.l=bchg',0
	dc.b	'bclr.l=bclr',0
	dc.b	'bset.l=bset',0
	dc.b	'btst.l=btst',0
	dc.b	'cmpa=cmp',0
	dc.b	'cmpi=cmp',0
	dc.b	'cmpm=cmp',0
	dc.b	'divu.w=divu',0
	dc.b	'divs.w=divs',0
	dc.b	'eori=eor',0
	dc.b	'exg.l=exg',0
	dc.b	'lea.l=lea',0
	dc.b	'movea=move',0
	dc.b	'moveq.l=moveq',0
	dc.b	'mulu.w=mulu',0
	dc.b	'muls.w=muls',0
	dc.b	'ori=or',0
	dc.b	'rts',9,'=rts',0
	dc.b	'suba=sub',0
	dc.b	'subi=sub',0
	dc.b	'swap.w=swap',0

	dc.b	LF,'l??????',LF,'=',LF,LF,'l??????',0
	dc.b	'dbf',TAB,'d?????????(pc)=dbra',TAB,'d?????????',0
	dc.b	0




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

	cnop	0,4			must be longword aligned

FileInfoBlock	ds.l	65




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

dosname	dc.b	'dos.library',0
	even

title	dc.b	'SourceConvert V1.0  --  Written by Daniel Vernon in 1992',10,10,0
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
