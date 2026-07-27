	section	makemasks,code_c


start	lea	source,a0
	lea	30(a0),a1
	lea	30(a1),a2
	lea	30(a2),a3
	lea	masks,a4
	moveq	#111,d0		112 lines
loop	moveq	#14,d1		15 words per line
lineloop
	move.w	(a0)+,d2
	or.w	(a1)+,d2
	or.w	(a2)+,d2
	or.w	(a3)+,d2
	move.w	d2,90(a4)
	move.w	d2,60(a4)
	move.w	d2,30(a4)
	move.w	d2,(a4)+
	dbra	d1,lineloop	do all words in current line
	add.l	#90,a0		align registers for next line
	add.l	#90,a1
	add.l	#90,a2
	add.l	#90,a3
	add.l	#90,a4
	dbra	d0,loop		do all lines


	move.l	4,a6
	lea	dosname,a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,dosbase
	beq	error

	move.l	#name,d1
	move.l	#1006,d2
	move.l	dosbase,a6
	jsr	-30(a6)
	beq	error
	move.l	d0,handle

print	move.l	handle,d1
	move.l	#source,d2
	move.l	#26880,d3	4*112*30*2
	jsr	-48(a6)
	beq	error

error	move.l	handle,d1
	move.l	dosbase,a6
	jsr	-36(a6)

	move.l	dosbase,a1
	move.l	4,a6
	jsr	-414(a6)
	rts


source	incbin	Invaders.bin
masks	ds.b	13440		4*112*30

dosbase	dc.l	0
handle	dc.l	0

dosname	dc.b	'dos.library',0
	even

name	dc.b	'ram:file'
	even
