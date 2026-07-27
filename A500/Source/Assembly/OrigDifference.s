	section	Differences,code
	opt	o+




MAX.WORDS.TO.SHOW	equ	8




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
	move.l	#titlelen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write




* Get file1 name

	move.l	Command(pc),a0
	move.b	(a0),d0
	beq	error1

	lea	File1Name(pc),a1
	bsr	get.filename

	tst.b	d0			check for null
	beq	error2			if null then no file2 name given




* Get file2 name

	lea	File2Name(pc),a1
	bsr	get.filename




* Get lock on file1

	move.l	#File1Name,d1
	moveq	#-2,d2			ACCESS_READ
	move.l	DOSBase(pc),a6
	jsr	-84(a6)			Lock
	move.l	d0,File1Lock
	beq	error3




* Examine file1

	move.l	File1Lock(pc),d1
	move.l	#FileInfoBlock,d2
	move.l	DOSBase(pc),a6
	jsr	-102(a6)		Examine
	tst.l	d0
	beq	error4




* Unlock file1

	move.l	File1Lock(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-90(a6)			UnLock




* Allocate memory for file1 and file2

	move.l	FileInfoBlock+124(pc),d0
	move.l	d0,File1Length
	add.l	d0,d0
	move.l	d0,MemoryLength
	moveq	#0,d1
	move.l	4.w,a6
	jsr	-198(a6)		AllocMem
	move.l	d0,File1Mem
	beq	error5
	add.l	File1Length(pc),d0
	move.l	d0,File2Mem




* Open file1

	move.l	#File1Name,d1
	move.l	#1005,d2		MODE_OLDFILE
	move.l	DOSBase(pc),a6
	jsr	-30(a6)			Open
	move.l	d0,File1Handle
	beq	error6




* Read file1 into memory

	move.l	File1Handle(pc),d1
	move.l	File1Mem(pc),d2
	move.l	File1Length(pc),d3
	move.l	DOSBase(pc),a6
	jsr	-42(a6)			Read
	tst.l	d0
	bmi	error7




* Close file1

	move.l	File1Handle(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close




* Open file2

	move.l	#File2Name,d1
	move.l	#1005,d2		MODE_OLDFILE
	move.l	DOSBase(pc),a6
	jsr	-30(a6)			Open
	move.l	d0,File2Handle
	beq	error8




* Read file2 into memory

	move.l	File2Handle(pc),d1
	move.l	File2Mem(pc),d2
	move.l	File1Length(pc),d3	read same amount as for file1
	move.l	DOSBase(pc),a6
	jsr	-42(a6)			Read
	tst.l	d0
	bmi	error9




* Show differences between files

	bsr	show.differences




exit_closefile2
	move.l	File2Handle(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close




exit_freemem
	move.l	MemoryLength(pc),d0
	move.l	File1Mem(pc),a1
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

	move.l	File1Lock(pc),d1
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

	move.l	File1Handle(pc),d1
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
	bra	exit_closefile2




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




show.differences
	move.l	File1Mem(pc),a3
	move.l	File2Mem(pc),a4
	move.l	a3,a5
	add.l	File1Length(pc),a5

compare	cmp.w	(a3)+,(a4)+
	beq.s	compare.next

	movem.l	a3-a5,-(sp)
	bsr.s	difference.found
	movem.l	(sp)+,a3-a5

	btst	#6,$bfe001
	beq.s	compare.done

compare.next
	cmp.l	a5,a3
	blt.s	compare

	move.l	StdOutHandle(pc),d1	no more differences
	move.l	#no.more.differences,d2
	moveq	#no.more.differenceslen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write

compare.done
	rts

difference.found
	subq.l	#2,a3			get addresses of differing words
	subq.l	#2,a4
	move.l	a3,d0
	sub.l	File1Mem(pc),d0
	lea	offset.text(pc),a0
	bsr	long.to.text

	move.l	StdOutHandle(pc),d1	print offset of differing words
	move.l	#difference.msg1,d2
	moveq	#difference.msg1len,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write

	move.l	File2Mem(pc),d4
	sub.l	a3,d4
	asr.l	#1,d4			number of words to end of file1
	cmp.l	#MAX.WORDS.TO.SHOW,d4
	ble.s	max.or.less
	moveq	#MAX.WORDS.TO.SHOW,d4

max.or.less
	move.l	StdOutHandle(pc),d1	print file1 words
	move.l	#difference.msg2,d2
	moveq	#difference.msg2len,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write

	move.l	a3,a5
	move.l	d4,d5
	bsr.s	print.words

	move.l	StdOutHandle(pc),d1	print file2 words
	move.l	#difference.msg3,d2
	moveq	#difference.msg3len,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write

	move.l	a4,a5
	move.l	d4,d5
	bsr.s	print.words

	move.l	StdOutHandle(pc),d1	tidy end up
	move.l	#end.text,d2
	moveq	#end.textlen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	rts


end.text
	dc.b	10,10
end.textlen	equ	*-end.text
	even




more.words
	move.l	StdOutHandle(pc),d1	print comma
	move.l	#comma.text,d2
	moveq	#comma.textlen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write

print.words
	move.w	(a5)+,d0
	lea	word.text+1(pc),a0
	bsr.s	word.to.text

	move.l	StdOutHandle(pc),d1	print word
	move.l	#word.text,d2
	moveq	#word.textlen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write

	subq.l	#1,d5
	bne.s	more.words
	rts


word.text
	dc.b	'$    '
word.textlen	equ	*-word.text

comma.text
	dc.b	','
comma.textlen	equ	*-comma.text
	even




word.to.text
	lea	hex.digits,a1
	moveq	#0,d1
	moveq	#4-1,d2

.loop	rol.w	#4,d0
	move.b	d0,d1
	and.b	#$f,d1
	move.b	(a1,d1.w),(a0)+
	dbra	d2,.loop
	rts




long.to.text
	lea	hex.digits,a1
	moveq	#0,d1
	moveq	#8-1,d2

.loop	rol.l	#4,d0
	move.b	d0,d1
	and.b	#$f,d1
	move.b	(a1,d1.w),(a0)+
	dbra	d2,.loop
	rts


hex.digits
	dc.b	'0123456789ABCDEF'
	even




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

Command	dc.l	0
DOSBase	dc.l	0

StdOutHandle	dc.l	0
File1Handle	dc.l	0
File2Handle	dc.l	0

File1Lock	dc.l	0

File1Name	ds.b	108
File2Name	ds.b	108

File1Mem	dc.l	0
File1Length	dc.l	0
MemoryLength	dc.l	0
File2Mem	dc.l	0

	cnop	0,4			must be longword aligned

FileInfoBlock	ds.l	65




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

dosname	dc.b	'dos.library',0
	even

title	dc.b	'Differences V1.0  --  Written by Daniel Vernon in 1993',10,10
titlelen	equ	*-title

no.more.differences
	dc.b	10,'No more differences found',10,10
no.more.differenceslen	equ	*-no.more.differences

difference.msg1
	dc.b	10,'Difference found at offset $'
offset.text
	dc.b	'         from beginning',10,10
difference.msg1len	equ	*-difference.msg1

difference.msg2
	dc.b	'  Words at this offset in file1 are :-',10,10,'  '
difference.msg2len	equ	*-difference.msg2

difference.msg3
	dc.b	10,10,'  Words at this offset in file2 are :-',10,10,'  '
difference.msg3len	equ	*-difference.msg3

error1text
	dc.b	'No file1 name specified',10,10
error1textlen	equ	*-error1text

error2text
	dc.b	'No file2 name specified',10,10
error2textlen	equ	*-error2text

error3text
	dc.b	'Could not get lock on file1',10,10
error3textlen	equ	*-error3text

error4text
	dc.b	'Could not examine file1',10,10
error4textlen	equ	*-error4text

error5text
	dc.b	'Could not allocate memory for files',10
error5textlen	equ	*-error5text

error6text
	dc.b	'Could not open file1',10
error6textlen	equ	*-error6text

error7text
	dc.b	'Could not read file1',10
error7textlen	equ	*-error7text

error8text
	dc.b	'Could not open file2',10
error8textlen	equ	*-error8text

error9text
	dc.b	'Could not read file2',10
error9textlen	equ	*-error9text
