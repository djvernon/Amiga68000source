	section	GimmeSource,code
	opt	o+,a+


print	macro
	move.l	stdout,d1
	move.l	\1,d2
	move.l	\2,d3
	move.l	_DOSBase,a6
	jsr	-48(a6)			Write
	endm


start	move.l	a0,command		save address of CLI command string
	move.l	d0,cmdlen		save length of CLI command string


opendos	move.l	4.w,a6
	lea	dosname,a1
	moveq	#0,d0
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exit
	move.l	d0,_DOSBase


getstdout
	move.l	_DOSBase,a6
	jsr	-60(a6)			Output
	move.l	d0,stdout


main	move.l	command,a0
	move.l	cmdlen,d0
	clr.b	-1(a0,d0.w)		null-terminate the command string


	print	#title,#titlelen
	move.l	command,a0
	cmpi.b	#'?',(a0)
	beq	showusage
	cmpi.b	#'',(a0)
	beq	showusage


getinputfile
	lea	inputfile,a1
	bsr	getfilename
	tst.b	d0			check for null
	beq	error1			if null then no output filename given


getoutputfile
	lea	outputfile,a1
	bsr	getfilename
	tst.b	d0			if null then no data type specified
	bne.s	getdatatype


default	move.w	#2,datatype		set data type - words
	move.w	#0,datawidth		set data width - 2 words per line
	bra	lockinput


getdatatype
	move.b	(a0)+,d0
	cmpi.b	#'b',d0
	bne.s	dt1
	move.w	#1,datatype		set data type - bytes
	bra.s	getdatawidth

dt1	cmpi.b	#'w',d0
	bne.s	dt2
	move.w	#2,datatype		set data type - words
	bra.s	getdatawidth

dt2	cmpi.b	#'l',d0
	bne.s	dt3
	move.w	#4,datatype		set data type - longwords
	bra.s	getdatawidth

dt3	move.w	#2,datatype		set default data type - words


getdatawidth
	move.b	(a0)+,d0
	cmpi.b	#'2',d0
	bne.s	dl1
	move.w	#0,datawidth		set data width - 2
	bra.s	lockinput

dl1	cmpi.b	#'4',d0
	bne.s	dl2
	move.w	#4,datawidth		set data width - 4
	bra.s	lockinput

dl2	cmpi.b	#'8',d0
	bne.s	dl3
	move.w	#8,datawidth		set data width - 8
	bra.s	lockinput

dl3	cmpi.b	#'1',d0
	bne.s	dl4
	cmpi.b	#'6',(a0)
	bne.s	dl4
	cmpi.w	#1,datatype		if width = 16, type must be bytes
	bne.s	dl4
	move.w	#12,datawidth		set data width - 16
	bra.s	lockinput

dl4	move.w	#0,datawidth		set default data width - 2


lockinput
	move.l	#inputfile,d1		get lock on input file
	moveq	#-2,d2			access_read
	move.l	_DOSBase,a6
	jsr	-84(a6)			Lock
	tst.l	d0
	beq	error2
	move.l	d0,inputfilelock


examine	move.l	inputfilelock,d1	get information about file
	move.l	#diskkey,d2		start of file-info-block
	move.l	_DOSBase,a6
	jsr	-102(a6)		Examine
	tst.l	d0
	beq	error3


unlock	move.l	inputfilelock,d1	unlock input file
	move.l	_DOSBase,a6
	jsr	-90(a6)			UnLock


newlen	move.l	size,d0			round off to next word or longword
	move.l	d0,d1
	moveq	#0,d2
	move.w	datatype,d2
	neg.l	d2			make mask
	and.l	d2,d1			mask off unwanted bits
	cmp.l	d0,d1
	beq.s	lengthok
	neg.l	d2			make positive again
	add.l	d2,d1
lengthok
	move.l	d1,newinputlen


getinputmem
	move.l	4.w,a6			allocate memory for input file
	move.l	newinputlen,d0
	move.l	#$10002,d1		chip+clear
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	error4
	move.l	d0,memory1


openinput
	move.l	#inputfile,d1		open input file
	move.l	#1005,d2		mode_oldfile
	move.l	_DOSBase,a6
	jsr	-30(a6)			Open
	tst.l	d0
	beq	error5
	move.l	d0,input


readinput
	move.l	input,d1		read input file into memory
	move.l	memory1,d2
	move.l	size,d3
	move.l	_DOSBase,a6
	jsr	-42(a6)			Read
	tst.l	d0
	beq	error6


calcoutputmem				; calculate approx. memory required
	move.l	newinputlen,d0
	move.w	datatype,d1
	cmp.w	#1,d1
	bne.s	calcoutputmem2
	move.w	datawidth,d1
	lea	jumptable1,a0
	move.l	(a0,d1.w),a0		get subroutine address
	jsr	(a0)			calculate output length
	move.l	d0,outputmemsize
	bra.s	getoutputmem


calcoutputmem2				; calculate approx. memory required
	cmp.w	#2,d1
	bne.s	calcoutputmem3
	lsr.l	#1,d0			get total number of words in file
	move.w	datawidth,d1
	lea	jumptable2,a0
	move.l	(a0,d1.w),a0		get subroutine address
	jsr	(a0)			calculate output length
	move.l	d0,outputmemsize
	bra.s	getoutputmem


calcoutputmem3				; calculate approx. memory required
	lsr.l	#2,d0			get total number of longwords in file
	move.w	datawidth,d1
	lea	jumptable3,a0
	move.l	(a0,d1.w),a0		get subroutine address
	jsr	(a0)			calculate output length
	move.l	d0,outputmemsize


getoutputmem
	move.l	4.w,a6			allocate memory for output file
	move.l	outputmemsize,d0
	moveq	#2,d1			chip
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	error7
	move.l	d0,memory2


convertbytes				; convert file to source code
	move.w	datatype,d0
	cmp.w	#1,d0
	bne.s	convertwords
	move.l	newinputlen,d3
	lea	datawidthtable,a0
	move.w	datawidth,d0
	move.l	(a0,d0.w),d4		get actual data width
	moveq	#0,d5
	move.l	memory2,a0		destination
	move.l	memory1,a1		source
convertbytes1
	moveq	#0,d6
	move.b	#$09,(a0)+		TAB
	move.b	#'d',(a0)+
	move.b	#'c',(a0)+
	move.b	#'.',(a0)+
	move.b	#'b',(a0)+
	move.b	#$09,(a0)+		TAB
	move.b	#'$',(a0)+
	bra.s	convertbytes3
convertbytes2
	move.b	#',',(a0)+
	move.b	#'$',(a0)+
convertbytes3
	move.b	(a1)+,d0		convert hex byte
	bsr	bytetotext

	addq.l	#1,d5
	cmp.l	d3,d5			end of file reached ?
	beq	calcoutputsize
	addq.w	#1,d6
	cmp.w	d4,d6			end of line reached ?
	bne.s	convertbytes2
	move.b	#$0a,(a0)+		linefeed
	bra.s	convertbytes1


convertwords				; convert file to source code
	cmp.w	#2,d0
	bne.s	convertlongs
	move.l	newinputlen,d3
	lea	datawidthtable,a0
	move.w	datawidth,d0
	move.l	(a0,d0.w),d4		get actual data width
	moveq	#0,d5
	move.l	memory2,a0		destination
	move.l	memory1,a1		source
convertwords1
	moveq	#0,d6
	move.b	#$09,(a0)+		TAB
	move.b	#'d',(a0)+
	move.b	#'c',(a0)+
	move.b	#'.',(a0)+
	move.b	#'w',(a0)+
	move.b	#$09,(a0)+		TAB
	move.b	#'$',(a0)+
	bra.s	convertwords3
convertwords2
	move.b	#',',(a0)+
	move.b	#'$',(a0)+
convertwords3
	move.b	(a1)+,d0		convert hex byte
	bsr	bytetotext
	move.b	(a1)+,d0		convert hex byte
	bsr	bytetotext

	addq.l	#2,d5
	cmp.l	d3,d5			end of file reached ?
	beq.s	calcoutputsize
	addq.w	#1,d6
	cmp.w	d4,d6			end of line reached ?
	bne.s	convertwords2
	move.b	#$0a,(a0)+		linefeed
	bra.s	convertwords1


convertlongs				; convert file to source code
	move.l	newinputlen,d3
	lea	datawidthtable,a0
	move.w	datawidth,d0
	move.l	(a0,d0.w),d4		get actual data width
	moveq	#0,d5
	move.l	memory2,a0		destination
	move.l	memory1,a1		source
convertlongs1
	moveq	#0,d6
	move.b	#$09,(a0)+		TAB
	move.b	#'d',(a0)+
	move.b	#'c',(a0)+
	move.b	#'.',(a0)+
	move.b	#'l',(a0)+
	move.b	#$09,(a0)+		TAB
	move.b	#'$',(a0)+
	bra.s	convertlongs3
convertlongs2
	move.b	#',',(a0)+
	move.b	#'$',(a0)+
convertlongs3
	move.b	(a1)+,d0		convert hex byte
	bsr	bytetotext
	move.b	(a1)+,d0		convert hex byte
	bsr	bytetotext
	move.b	(a1)+,d0		convert hex byte
	bsr	bytetotext
	move.b	(a1)+,d0		convert hex byte
	bsr	bytetotext

	addq.l	#4,d5
	cmp.l	d3,d5			end of file reached ?
	beq.s	calcoutputsize
	addq.w	#1,d6
	cmp.w	d4,d6			end of line reached ?
	bne.s	convertlongs2
	move.b	#$0a,(a0)+		linefeed
	bra.s	convertlongs1


calcoutputsize
	move.b	#$0a,(a0)+
	sub.l	memory2,a0		calculate exact size of output file
	move.l	a0,outputlen


openoutput
	move.l	#outputfile,d1		open output file
	move.l	#1006,d2		mode_newfile
	move.l	_DOSBase,a6
	jsr	-30(a6)			Open
	tst.l	d0
	beq	error8
	move.l	d0,output


writeoutput
	move.l	output,d1		write output file
	move.l	memory2,d2
	move.l	outputlen,d3
	move.l	_DOSBase,a6
	jsr	-48(a6)			Write


exitcloseoutput
	move.l	output,d1
	move.l	_DOSBase,a6
	jsr	-36(a6)			Close


exitfreemem2
	move.l	4.w,a6
	move.l	memory2,a1
	move.l	outputmemsize,d0
	jsr	-210(a6)		FreeMem


exitcloseinput
	move.l	input,d1
	move.l	_DOSBase,a6
	jsr	-36(a6)			Close


exitfreemem1
	move.l	4.w,a6
	move.l	memory1,a1
	move.l	newinputlen,d0
	jsr	-210(a6)		FreeMem


exitclosedos
	move.l	4.w,a6
	move.l	_DOSBase,a1
	jsr	-414(a6)		CloseLibrary


exit	moveq	#0,d0
	rts



; Subroutines

showusage
	print	#usage,#usagelen
	bra.s	exitclosedos


getfilename
	move.b	(a0)+,d0
	cmpi.b	#' ',d0			space
	beq.s	donefilename
	cmpi.b	#'',d0			null
	beq.s	donefilename
	move.b	d0,(a1)+
	bra.s	getfilename
donefilename
	clr.b	(a1)			null-terminate the filename
	rts



jumptable1	dc.l	mult14,mult22,mult38,mult70

mult14	lsr.l	#1,d0			divide by two
	addq.l	#1,d0			total number of lines
	move.l	d0,d1
	move.l	d1,d2
	lsl.l	#3,d0			*8
	lsl.l	#2,d1			*4
	lsl.l	#1,d2			*2
	add.l	d1,d0			*4 + *8 = *12
	add.l	d2,d0			*2 + *12 = *14
	rts

mult22	lsr.l	#2,d0			divide by four
	addq.l	#1,d0			total number of lines
	move.l	d0,d1
	move.l	d1,d2
	lsl.l	#4,d0			*16
	lsl.l	#2,d1			*4
	lsl.l	#1,d2			*2
	add.l	d1,d0			*4 + *16 = *20
	add.l	d2,d0			*2 + *20 = *22
	rts

mult38	lsr.l	#3,d0			divide by eight
	addq.l	#1,d0			total number of lines
	move.l	d0,d1
	move.l	d1,d2
	lsl.l	#5,d0			*32
	lsl.l	#2,d1			*4
	lsl.l	#1,d2			*2
	add.l	d1,d0			*4 + *32 = *36
	add.l	d2,d0			*2 + *36 = *38
	rts

mult70	lsr.l	#4,d0			divide by sixteen
	addq.l	#1,d0			total number of lines
	move.l	d0,d1
	move.l	d1,d2
	lsl.l	#6,d0			*64
	lsl.l	#2,d1			*4
	lsl.l	#1,d2			*2
	add.l	d1,d0			*4 + *64 = *68
	add.l	d2,d0			*2 + *68 = *70
	rts


jumptable2	dc.l	mult18,mult30,mult54

mult18	lsr.l	#1,d0			divide by two
	addq.l	#1,d0			total number of lines
	move.l	d0,d1
	lsl.l	#4,d0			*16
	lsl.l	#1,d1			*2
	add.l	d1,d0			*2 + *16 = *18
	rts

mult30	lsr.l	#2,d0			divide by four
	addq.l	#1,d0			total number of lines
	move.l	d0,d1
	move.l	d1,d2
	move.l	d2,d3
	lsl.l	#4,d0			*16
	lsl.l	#3,d1			*8
	lsl.l	#2,d2			*4
	lsl.l	#1,d3			*2
	add.l	d1,d0			*8 + *16 = *24
	add.l	d2,d0			*4 + *24 = *28
	add.l	d3,d0			*2 + *28 = *30
	rts

mult54	lsr.l	#3,d0			divide by eight
	addq.l	#1,d0			total number of lines
	move.l	d0,d1
	move.l	d1,d2
	move.l	d2,d3
	lsl.l	#5,d0			*32
	lsl.l	#4,d1			*16
	lsl.l	#2,d2			*4
	lsl.l	#1,d3			*2
	add.l	d1,d0			*16 + *32 = *48
	add.l	d2,d0			*4 + *48 = *52
	add.l	d3,d0			*2 + *52 = *54
	rts


jumptable3	dc.l	mult26,mult46,mult86

mult26	lsr.l	#1,d0			divide by two
	addq.l	#1,d0			total number of lines
	move.l	d0,d1
	move.l	d1,d2
	lsl.l	#4,d0			*16
	lsl.l	#3,d1			*8
	lsl.l	#1,d2			*2
	add.l	d1,d0			*8 + *16 = *24
	add.l	d2,d0			*2 + *24 = *26
	rts

mult46	lsr.l	#2,d0			divide by four
	addq.l	#1,d0			total number of lines
	move.l	d0,d1
	move.l	d1,d2
	move.l	d2,d3
	lsl.l	#5,d0			*32
	lsl.l	#3,d1			*8
	lsl.l	#2,d2			*4
	lsl.l	#1,d3			*2
	add.l	d1,d0			*8 + *32 = *40
	add.l	d2,d0			*4 + *40 = *44
	add.l	d3,d0			*2 + *44 = *46
	rts

mult86	lsr.l	#3,d0			divide by eight
	addq.l	#1,d0			total number of lines
	move.l	d0,d1
	move.l	d1,d2
	move.l	d2,d3
	lsl.l	#6,d0			*64
	lsl.l	#4,d1			*16
	lsl.l	#2,d2			*4
	lsl.l	#1,d3			*2
	add.l	d1,d0			*16 + *64 = *80
	add.l	d2,d0			*4 + *80 = *84
	add.l	d3,d0			*2 + *84 = *86
	rts



bytetotext
	lea	hexdigits,a2
	moveq	#0,d1
	moveq	#2-1,d2
textloop
	rol.b	#4,d0
	move.b	d0,d1
	andi.b	#$f,d1
	move.b	(a2,d1.w),(a0)+
	dbra	d2,textloop
	rts



; Error handling

error1	print	#error1text,#error1textlen
	bra	exitclosedos


error2	print	#error2text,#error2textlen
	bra	exitclosedos


error3	print	#error3text,#error3textlen
	move.l	inputfilelock,d1	unlock input file
	move.l	_DOSBase,a6
	jsr	-90(a6)			UnLock
	bra	exitclosedos


error4	print	#error4text,#error4textlen
	bra	exitclosedos


error5	print	#error5text,#error5textlen
	bra	exitfreemem1


error6	print	#error6text,#error6textlen
	bra	exitcloseinput


error7	print	#error7text,#error7textlen
	bra	exitcloseinput


error8	print	#error8text,#error8textlen
	bra	exitfreemem2



; Constants

dosname	dc.b	'dos.library',0
	even


datawidthtable
	dc.l	2,4,8,16		actual width values


hexdigits
	dc.b	'0123456789abcdef'
	even


title	dc.b	10,9,'GimmeSource V1.1 by Daniel Vernon.',10,10,0
	even

titlelen	equ	*-title


usage	dc.b	9,'This program reads in an input file and gives you a',10
	dc.b	9,'source code representation of it in hexadecimal.',10,10
	dc.b	9,'Usage:-',10,10
	dc.b	9,'GimmeSource <input file> '
	dc.b	'<required source file> [data format]',10,10
	dc.b	9,'Data format is specified as follows:-',10,10
	dc.b	9,'b2, b4, b8 or b16 - byte sized data - 2, 4, 8 or 16'
	dc.b	' bytes per line',10
	dc.b	9,'w2, w4 or w8      - word sized data - 2, 4 or 8'
	dc.b	' words per line',10
	dc.b	9,'l2, l4 or l8      - long sized data - 2, 4 or 8'
	dc.b	' longwords per line',10,10
	dc.b	9,'For example, b8 would give a source file in dc.b'
	dc.b	' $xx format with 8',10,9,'bytes per line.',10,0
	even

usagelen	equ	*-usage


error1text
	dc.b	'No output filename specified',10,10,0
	even

error1textlen	equ	*-error1text


error2text
	dc.b	'Could not lock input file',10,10,0
	even

error2textlen	equ	*-error2text


error3text
	dc.b	'Could not examine input file',10,10,0
	even

error3textlen	equ	*-error3text


error4text
	dc.b	'Could not allocate memory for input file',10,10,0
	even

error4textlen	equ	*-error4text


error5text
	dc.b	'Could not open input file',10,10,0
	even

error5textlen	equ	*-error5text


error6text
	dc.b	'Could not read input file',10,10,0
	even

error6textlen	equ	*-error6text


error7text
	dc.b	'Could not allocate memory for output file',10,10,0
	even

error7textlen	equ	*-error7text


error8text
	dc.b	'Could not open output file',10,10,0
	even

error8textlen	equ	*-error8text



; Variables

command		dc.l	0
cmdlen		dc.l	0
_DOSBase	dc.l	0
stdout		dc.l	0
datatype	dc.w	0
datawidth	dc.w	0
inputfilelock	dc.l	0
newinputlen	dc.l	0
outputmemsize	dc.l	0
outputlen	dc.l	0
memory1		dc.l	0
memory2		dc.l	0
input		dc.l	0
output		dc.l	0

inputfile	dcb.b	108,0
outputfile	dcb.b	108,0


; FileInfoBlock

	cnop	0,4			must be longword aligned

diskkey		dc.l	0
direntrytype	dc.l	0
filename	dcb.b	108,0
protection	dc.l	0
entrytype	dc.l	0
size		dc.l	0
numblocks	dc.l	0
datestamp	dcb.l	3,0
comment		dcb.b	116,0

	end
