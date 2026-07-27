	section	GimmeSPG,code
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
	move.l	size,inputlen


unlock	move.l	inputfilelock,d1	unlock input file
	move.l	_DOSBase,a6
	jsr	-90(a6)			UnLock


getinputmem
	move.l	4.w,a6			allocate memory for input file
	move.l	inputlen,d0
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
	move.l	inputlen,d3
	move.l	_DOSBase,a6
	jsr	-42(a6)			Read
	tst.l	d0
	beq	error6


calcoutputmem				; calculate approx. memory required
	move.l	inputlen,d0
	sub.l	#36,d0			remove AmigaDOS header size
	lsr.l	#1,d0			get total number of words in file
	move.l	d0,d1
	lsl.l	#2,d0			*4
	add.l	d1,d0			*4 + *1 = *5
	move.l	d0,outputmemsize


getoutputmem
	move.l	4.w,a6			allocate memory for output file
	move.l	outputmemsize,d0
	moveq	#2,d1			chip
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	error7
	move.l	d0,memory2


convertwords				; convert file to source code
	move.l	memory2,a0		destination
	move.l	memory1,a1		source
	move.l	a1,a3
	lea	32(a1),a1		skip AmigaDOS header
	add.l	inputlen,a3
	subq.w	#4,a3			address of end of data

convertwords1
	move.b	(a1)+,d0		convert hex byte
	bsr	bytetotext
	move.b	(a1)+,d0		convert hex byte
	bsr	bytetotext

	move.b	#$0a,(a0)+		linefeed

	cmp.l	a3,a1			end of file reached ?
	blt.s	convertwords1


calcoutputsize
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
	move.l	inputlen,d0
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
	bra.s	exitclosedos


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


hexdigits
	dc.b	'0123456789ABCDEF'
	even


title	dc.b	10,9,'GimmeSPG V1.0 by Daniel Vernon.',10,10,0
	even

titlelen	equ	*-title


usage	dc.b	9,'Reads in an executable file, skips AmigaDOS headers,',10
	dc.b	9,'produces file in SIM68''s .spg format.',10,10
	dc.b	9,'Usage:-',10,10
	dc.b	9,'GimmeSPG <input file> <required output file>',10,10,0
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
inputfilelock	dc.l	0
inputlen	dc.l	0
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
