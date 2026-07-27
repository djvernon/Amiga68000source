	section trackdisplay,code_c




	tst.l	d0
	beq.s	workbench




cli	cmp.b	#'d',(a0)
	bne	syntax
	cmp.b	#'f',1(a0)
	bne	syntax
	cmp.b	#':',3(a0)
	bne	syntax
	move.b	2(a0),d0
	sub.b	#48,d0
	move.b	d0,drive
	bra.s	start




workbench
	move.l	4.w,a6
	move.l	#0,a1
	jsr	-294(a6)
	move.l	d0,a4
	tst.l	$ac(a4)
	bne.s	start
	move.l	4.w,a6
	lea	$5c(a4),a0
	jsr	-384(a6)
	jsr	-372(a6)
	clr.b	drive




start	moveq	#0,d0
	cmp.b	#3,drive
	bgt	error1
	cmp.b	#0,drive
	blt	error1

	bsr	openlibs

opendevs
	move.l	4.w,a6
	sub.l	a1,a1
	jsr	-294(a6)
	move.l	d0,readreply+16
	lea	readreply(pc),a1
	jsr	-354(a6)
	moveq	#0,d0
	move.b	drive(pc),d0
	moveq	#0,d1
	lea	diskio(pc),a1
	lea	trackdisk(pc),a0
	jsr	-444(a6)
	tst.l	d0
	bne	error2

	move.l	intbase(pc),a6
	move.l	56(a6),screenhd

	move.b	drive(pc),d0
	add.b	#48,d0
	move.b	d0,windowtitle+8

	move.l	intbase(pc),a6
	lea	windowstructure(pc),a0
	jsr	-204(a6)
	move.l	d0,windowhd

	move.l	gfxbase(pc),a6
	moveq	#8,d0
	moveq	#17,d1
	move.l	windowhd(pc),a1
	move.l	50(a1),a1
	jsr	-240(a6)
	move.l	windowhd(pc),a1
	move.l	50(a1),a1
	lea	outputtxt(pc),a0
	moveq	#17,d0
	jsr	-60(a6)
	move.l	gfxbase(pc),a6
	moveq	#8,d0
	moveq	#25,d1
	move.l	windowhd(pc),a1
	move.l	50(a1),a1
	jsr	-240(a6)
	move.l	windowhd(pc),a1
	move.l	50(a1),a1
	lea	voltxt(pc),a0
	moveq	#9,d0
	jsr	-60(a6)

	bsr	checkchange




print
	move.l	dosbase(pc),a6
	moveq	#10,d1
	jsr	-198(a6)

	move.l	diskio+20(pc),a0
	moveq	#0,d0
	move.b	drive(pc),d0
	mulu	#4,d0
	move.l	36(a0,d0),a2
	cmp.l	#0,a2
	beq	quit

	move.w	72(a2),d1
	move.w	74(a2),d2
	move.l	d2,d3
	mulu	#11,d3
	add.w	d1,d3
	cmp.w	block(pc),d3
	beq	wait

	move.w	d1,ssector
	move.w	d2,strack
	move.w	d3,sblock
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3

	move.l	gfxbase(pc),a6
	moveq	#3*8,d0
	moveq	#17,d1
	move.l	windowhd(pc),a1
	move.l	50(a1),a1
	jsr	-240(a6)
	moveq	#100,d1
	move.w	strack(pc),d0
	bsr	subprint

	move.l	gfxbase(pc),a6
	moveq	#9*8,d0
	moveq	#17,d1
	move.l	windowhd(pc),a1
	move.l	50(a1),a1
	jsr	-240(a6)
	moveq	#10,d1
	move.w	ssector(pc),d0
	bsr	subprint

	move.l	gfxbase(pc),a6
	moveq	#14*8,d0
	moveq	#17,d1
	move.l	windowhd(pc),a1
	move.l	50(a1),a1
	jsr	-240(a6)
	move.l	#1000,d1
	move.w	sblock(pc),d0
	move.w	d0,block
	bsr	subprint

wait	move.l	windowhd(pc),a0
	move.l	86(a0),a0
	move.l	4.w,a6
	jsr	-372(a6)
	tst.l	d0
	bne	quit

	lea	diskio(pc),a1
	move.w	#14,28(a1)
	move.l	4.w,a6
	jsr	-456(a6)
	cmp.l	#0,32(a1)
	bne	diskchange
	bra	print




openlibs
	move.l	4.w,a6
	lea	gfxname(pc),a1
	moveq	#0,d0
	jsr	-408(a6)
	move.l	d0,gfxbase
	lea	intname(pc),a1
	moveq	#0,d0
	jsr	-408(a6)
	move.l	d0,intbase
	lea	dosname(pc),a1
	moveq	#0,d0
	jsr	-408(a6)
	move.l	d0,dosbase
finish	rts




closelibs
	move.l	4.w,a6
	move.l	gfxbase(pc),a1
	jsr	-414(a6)
	move.l	intbase(pc),a1
	jsr	-414(a6)
	move.l	dosbase(pc),a1
	jsr	-414(a6)
	rts




error1	bsr.s	openlibs
	moveq	#0,d0
	move.l	dosbase(pc),a6
	jsr	-60(a6)
	move.l	d0,d1
	move.l	#errortxt1,d2
	moveq	#err1end-errortxt1,d3
	move.l	dosbase(pc),a6
	jsr	-48(a6)
	bsr.s	closelibs
	moveq	#0,d0
	rts




quit	bsr	closedevs
	bsr.s	closewind
	bra.s	closelibs




error2	moveq	#0,d0
	move.l	dosbase(pc),a6
	jsr	-60(a6)
	move.l	d0,d1
	move.l	#errortxt2,d2
	moveq	#err2end-errortxt2,d3
	move.l	dosbase(pc),a6
	jsr	-48(a6)
	bsr.s	closelibs
	move.l	4.w,a6
	lea	readreply(pc),a1
	jsr	-360(a6)
	moveq	#0,d0
	rts




closewind
	move.l	intbase(pc),a6
	move.l	windowhd(pc),a0
	jsr	-72(a6)
	rts




subprint
	move.l	d0,d2
	divu	d1,d2
	move.l	d2,d3
	mulu	d1,d2
	sub.w	d2,d0
	divu	#10,d1
	move.l	d0,saved0
	move.l	d1,saved1
	add.w	#48,d3
	move.b	d3,string
	move.l	gfxbase(pc),a6
	move.l	windowhd(pc),a1
	move.l	50(a1),a1
	lea	string(pc),a0
	moveq	#1,d0
	jsr	-60(a6)
	move.l	saved0(pc),d0
	move.l	saved1(pc),d1
	cmp.w	#0,d1
	bne.s	subprint
	rts




diskchange
	move.l	gfxbase(pc),a6
	move.w	#8,d0
	move.w	#33,d1
	move.l	windowhd(pc),a1
	move.l	50(a1),a1
	jsr	-240(a6)
	move.l	windowhd(pc),a1
	move.l	50(a1),a1
	lea	nodisk(pc),a0
	moveq	#18,d0
	jsr	-60(a6)

	bsr.s	checkchange
	tst.b	gadget
	bne	quit
	bra	print




checkchange
	move.l	windowhd(pc),a0
	move.l	86(a0),a0
	move.l	4.w,a6
	jsr	-372(a6)
	tst.l	d0
	bne.s	closegaddout
	lea	diskio(pc),a1
	move.w	#14,28(a1)
	move.l	4.w,a6
	jsr	-456(a6)
	cmp.l	#0,32(a1)
	bne.s	checkchange
	lea	diskio+32(pc),a0
	clr.l	(a0)
	bsr.s	readdiskname
	rts




closegaddout
	st	gadget
	rts




readdiskname
	lea	diskio(pc),a1
	move.l	#readreply,14(a1)
	move.w	#2,28(a1)
	move.l	#buffer,40(a1)
	move.l	#512,36(a1)
	move.l	#880*512,44(a1)
	move.l	4.w,a6
	jsr	-456(a6)
	lea	diskio(pc),a1
	move.w	#9,28(a1)
	move.l	#0,36(a1)
	jsr	-456(a6)

	move.l	gfxbase(pc),a6
	moveq	#8,d0
	moveq	#33,d1
	move.l	windowhd(pc),a1
	move.l	50(a1),a1
	jsr	-240(a6)
	move.l	windowhd(pc),a1
	move.l	50(a1),a1
	lea	clearline(pc),a0
	moveq	#18,d0
	jsr	-60(a6)

	move.l	gfxbase(pc),a6
	moveq	#8,d0
	moveq	#33,d1
	move.l	windowhd(pc),a1
	move.l	50(a1),a1
	jsr	-240(a6)
	move.l	windowhd(pc),a1
	move.l	50(a1),a1
	lea	buffer+433(pc),a0
	move.b	buffer+432(pc),d0
	cmp.b	#18,d0
	ble.s	shortname
	moveq	#18,d0
shortname
	jsr	-60(a6)
	rts




closedevs
	move.l	4.w,a6
	lea	readreply(pc),a1
	jsr	-360(a6)
	lea	diskio(pc),a1
	jsr	-450(a6)
	rts




syntax	bsr	openlibs
	moveq	#0,d0
	move.l	dosbase(pc),a6
	jsr	-60(a6)
	move.l	d0,d1
	move.l	#syntaxtxt,d2
	move.l	#syntaxend-syntaxtxt,d3
	move.l	dosbase(pc),a6
	jsr	-48(a6)
	bsr	closelibs
	moveq	#0,d0
	rts




syntaxtxt
	dc.b	$a
	dc.b	"TrackDisplay by Oliver Prill."
	dc.b	$a
	dc.b	"(C) 1990 Amiga Computing."
	dc.b	$a
	dc.b	"SYNTAX: run trackdisplay "
	dc.b	"<df0:|df1:|df2:|df3:>",$a
syntaxend
	even


clearline	dc.b	"                  "
	even
nodisk	dc.b	"-No disk in drive-"
	even


gfxbase	dc.l	0
intbase	dc.l	0
dosbase	dc.l	0
string	dc.w	0
diskio	ds.l	20
block	dc.w	0
drive	dc.b	0
gadget	dc.b	0
readreply	ds.l	8
buffer	ds.b	512

saved0	dc.l	0
saved1	dc.l	0
strack	dc.w	0
ssector	dc.w	0
sblock	dc.w	0


errortxt1
	dc.b	"Invalid drive number.",$a
err1end
	even


errortxt2
	dc.b	"Drive is not connected.",$a
err2end
	even


trackdisk
	dc.b	"trackdisk.device",0
	even


windowhd
	dc.l	0


windowstructure
	dc.w	475,0,165,37
	dc.b	2,1
	dc.l	$200,14,0,0,windowtitle
screenhd
	dc.l	0,0
	dc.w	165,37,165,37,1


windowtitle
	dc.b	"Drive df :",0
	even


voltxt	dc.b	"Diskname:"
	even


gfxname	dc.b	"graphics.library",0
	even


intname	dc.b	"intuition.library",0
	even


dosname	dc.b	"dos.library",0
	even


outputtxt	dc.b	"T:000 S:00 B:0000",0
	even
