	section	GetBody,code
	opt	o+




print	macro
	move.l	StdOutHandle(pc),d1
	move.l	\1,d2
	move.l	\2,d3
	move.l	_DOSBase(pc),a6
	jsr	-48(a6)			Write
	endm




* Save address of CLI command string

	move.l	a0,Command
	clr.b	-1(a0,d0.w)		null-terminate the command string




* Open the DOS library

	moveq	#0,d0
	lea	dosname(pc),a1
	move.l	4.w,a6
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exit_now
	move.l	d0,_DOSBase




* Get standard output handle

	move.l	_DOSBase(pc),a6
	jsr	-60(a6)			Output
	move.l	d0,StdOutHandle




* Print title text

	print	#title,#titlelen




* Examine command string

	move.l	Command(pc),a0
	cmp.b	#'?',(a0)
	beq	showusage

	cmp.b	#'',(a0)
	beq	showusage




* Get input filename

	lea	InputFilename(pc),a1
	bsr	getfilename

	tst.b	d0			check for null
	beq	error1			if null then no output filename given




* Get output filename

	lea	OutputFilename(pc),a1
	bsr	getfilename




* Open input file

	move.l	#InputFilename,d1
	move.l	#1005,d2		MODE_OLDFILE
	move.l	_DOSBase(pc),a6
	jsr	-30(a6)			Open
	tst.l	d0
	beq	error2
	move.l	d0,InputHandle




* Check file is IFF ILBM

	move.l	InputHandle(pc),d1
	move.l	#FormBuffer,d2
	moveq	#12,d3			'FORM',length,'ILBM'
	move.l	_DOSBase(pc),a6
	jsr	-42(a6)			Read
	tst.l	d0
	beq	error3
	bmi	error3

	lea	FormBuffer(pc),a0
	cmp.l	#'FORM',(a0)+
	bne	error4

	move.l	(a0)+,RemainingLength

	cmp.l	#'ILBM',(a0)
	bne	error5

	subq.l	#4,RemainingLength	remove 'ILBM' length




* Allocate memory for rest of file

	move.l	RemainingLength(pc),d0
	move.l	d0,InputMemLength
	moveq	#0,d1
	move.l	4.w,a6
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	error6
	move.l	d0,InputMem




* Read rest of file into memory

	move.l	InputHandle(pc),d1
	move.l	InputMem(pc),d2
	move.l	InputMemLength(pc),d3
	move.l	_DOSBase(pc),a6
	jsr	-42(a6)			Read
	tst.l	d0
	beq	error7
	bmi	error7




* Check rest of file

	move.l	InputMem(pc),a0
	cmp.l	#'BMHD',(a0)+
	bne	error8

	subq.l	#4,RemainingLength	remove 'BMHD' length

	move.l	(a0)+,d0		get BMHD length
	subq.l	#4,RemainingLength	remove number's length

	add.l	d0,a0			skip BMHD data
	sub.l	d0,RemainingLength	remove data's length

	cmp.l	#'CMAP',(a0)+
	bne	error9

	subq.l	#4,RemainingLength	remove 'CMAP' length

	move.l	(a0)+,d0		get CMAP length
	subq.l	#4,RemainingLength	remove number's length

	move.l	a0,CmapAddress
	add.l	d0,a0			skip CMAP data
	sub.l	d0,RemainingLength	remove data's length
	divu	#3,d0			calculate number of colours
	move.w	d0,NumColours




* Search for 'BODY'

BODYsearch
	cmp.l	#'BODY',(a0)+
	beq.s	BODYfound

	subq.l	#4,RemainingLength	remove length of leaf chunk's name

	move.l	(a0)+,d0		get length of leaf chunk
	subq.l	#4,RemainingLength	remove number's length

	addq.l	#1,d0
	bclr	#0,d0			make length even

	add.l	d0,a0			skip leaf chunk's data
	sub.l	d0,RemainingLength	remove data's length
	bra.s	BODYsearch




* Check length of BODY data

BODYfound
	subq.l	#4,RemainingLength	remove 'BODY' length

	move.l	(a0)+,d0		get BODY length
	subq.l	#4,RemainingLength	remove number's length

	addq.l	#1,d0
	bclr	#0,d0			make length even

	cmp.l	RemainingLength(pc),d0
	bne	error10

	move.l	a0,BodyAddress




* Calculate size of output file

	move.w	NumColours(pc),d1
	add.w	d1,d1			two bytes per colour value
	ext.l	d1
	add.l	d1,d0
	move.l	d0,OutputMemLength




* Allocate memory for output file

	moveq	#0,d1
	move.l	4.w,a6
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	error11
	move.l	d0,OutputMem




* Make colour values

	move.l	CmapAddress(pc),a0
	move.l	OutputMem(pc),a1
	move.w	NumColours(pc),d0
	subq.w	#1,d0

make.colours
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.b	(a0)+,d1		Red component
	move.b	(a0)+,d2		Green component
	move.b	(a0)+,d3		Blue component

	lsl.w	#4,d1			Red component to correct place
	lsr.w	#4,d3			Blue component to correct place

	or.w	d3,d1
	or.w	d2,d1			combine components to give colour

	move.w	d1,(a1)+		save colour value

	dbra	d0,make.colours




* Copy body data

	move.l	BodyAddress(pc),a0
	move.l	RemainingLength(pc),d0
	lsr.l	#1,d0			number of words
	subq.w	#1,d0

copy.body
	move.w	(a0)+,(a1)+
	dbra	d0,copy.body




* Open output file

	move.l	#OutputFilename,d1
	move.l	#1006,d2		MODE_NEWFILE
	move.l	_DOSBase(pc),a6
	jsr	-30(a6)			Open
	tst.l	d0
	beq	error12
	move.l	d0,OutputHandle




* Write data to output file

	move.l	OutputHandle(pc),d1
	move.l	OutputMem(pc),d2
	move.l	OutputMemLength(pc),d3
	move.l	_DOSBase(pc),a6
	jsr	-48(a6)			Write




exit_closeoutput
	move.l	OutputHandle(pc),d1
	move.l	_DOSBase(pc),a6
	jsr	-36(a6)			Close




exit_freeoutputmem
	move.l	OutputMemLength(pc),d0
	move.l	OutputMem(pc),a1
	move.l	4.w,a6
	jsr	-210(a6)		FreeMem




exit_freeinputmem
	move.l	InputMemLength(pc),d0
	move.l	InputMem(pc),a1
	move.l	4.w,a6
	jsr	-210(a6)		FreeMem




exit_closeinput
	move.l	InputHandle(pc),d1
	move.l	_DOSBase(pc),a6
	jsr	-36(a6)			Close




exit_closedos
	move.l	_DOSBase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary




exit_now
	moveq	#0,d0
	rts




;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

showusage
	print	#usage,#usagelen
	bra.s	exit_closedos




getfilename
	move.b	(a0)+,d0
	beq.s	donefilename

	cmp.b	#' ',d0			space
	beq.s	donefilename

	move.b	d0,(a1)+
	bra.s	getfilename

donefilename
	clr.b	(a1)			null-terminate the filename
	rts




;""""""""""""""""""
;" ERROR HANDLING "
;"		  "
;""""""""""""""""""

error1	print	#error1text,#error1textlen
	bra.s	exit_closedos


error2	print	#error2text,#error2textlen
	bra.s	exit_closedos


error3	print	#error3text,#error3textlen
	bra	exit_closeinput


error4	print	#error4text,#error4textlen
	bra	exit_closeinput


error5	print	#error5text,#error5textlen
	bra	exit_closeinput


error6	print	#error6text,#error6textlen
	bra	exit_closeinput


error7	print	#error7text,#error7textlen
	bra	exit_freeinputmem


error8	print	#error8text,#error8textlen
	bra	exit_freeinputmem


error9	print	#error9text,#error9textlen
	bra	exit_freeinputmem


error10	print	#error10text,#error10textlen
	bra	exit_freeinputmem


error11	print	#error11text,#error11textlen
	bra	exit_freeinputmem


error12	print	#error12text,#error12textlen
	bra	exit_freeoutputmem




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

Command		dc.l	0
_DOSBase	dc.l	0

StdOutHandle	dc.l	0
InputHandle	dc.l	0
OutputHandle	dc.l	0

InputFilename	ds.b	108
OutputFilename	ds.b	108

FormBuffer	ds.b	12
RemainingLength	dc.l	0
CmapAddress	dc.l	0
NumColours	dc.w	0
BodyAddress	dc.l	0

InputMem	dc.l	0
InputMemLength	dc.l	0

OutputMem	dc.l	0
OutputMemLength	dc.l	0




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

dosname	dc.b	'dos.library',0
	even



title	dc.b	10,9,'GetBody V1.0 by Daniel Vernon.',10,10,0
	even
titlelen	equ	*-title



usage	dc.b	9,'This program reads in an IFF ILBM file and produces',10
	dc.b	9,'a binary file containing the colour and body data.',10,10
	dc.b	9,'Usage:-',10,10
	dc.b	9,'GetBody <input file> <required output file>',10,10,0
	even
usagelen	equ	*-usage



error1text
	dc.b	9,'Error  --  no output filename specified',10,10,0
	even
error1textlen	equ	*-error1text



error2text
	dc.b	9,'Error  --  could not open input file',10,10,0
	even
error2textlen	equ	*-error2text



error3text
	dc.b	9,'Error  --  could not read start of input file',10,10,0
	even
error3textlen	equ	*-error3text



error4text
	dc.b	9,'Error  --  file does not contain a FORM group chunk',10,10,0
	even
error4textlen	equ	*-error4text



error5text
	dc.b	9,'Error  --  FORM is not of subtype ILBM',10,10,0
	even
error5textlen	equ	*-error5text



error6text
	dc.b	9,'Error  --  could not allocate memory for input file',10,10,0
	even
error6textlen	equ	*-error6text



error7text
	dc.b	9,'Error  --  could not read rest of input file',10,10,0
	even
error7textlen	equ	*-error7text



error8text
	dc.b	9,'Error  --  FORM does not contain a BMHD leaf chunk',10,10,0
	even
error8textlen	equ	*-error8text



error9text
	dc.b	9,'Error  --  FORM does not contain a CMAP leaf chunk',10,10,0
	even
error9textlen	equ	*-error9text



error10text
	dc.b	9,'Error  --  BODY length is incorrect',10,10,0
	even
error10textlen	equ	*-error10text



error11text
	dc.b	9,'Error  --  could not allocate memory for output file',10,10,0
	even
error11textlen	equ	*-error11text



error12text
	dc.b	9,'Error  --  could not open output file',10,10,0
	even
error12textlen	equ	*-error12text
