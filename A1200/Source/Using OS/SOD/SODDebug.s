

DEBUG.DEST	dc.l	$180000


debug.copy
	tst.l	d3
	beq.s	.done
	move.l	d2,a0
	move.l	DEBUG.DEST,a1
.copy	move.b	(a0)+,(a1)+
	subq.l	#1,d3
	bne.s	.copy
	move.l	a1,DEBUG.DEST
.done	rts


DEBUGM	MACRO	; <MESSAGE>

	movem.l	d0-d3/a0-a1,-(sp)

	move.l	#.debugm\@,d2
	move.l	#.debugm.len\@,d3
	jsr	debug.copy

	movem.l	(sp)+,d0-d3/a0-a1
	bra.s	.debugm\@.done

.debugm\@	dc.b	LF,'\1'
.debugm.len\@	equ	*-.debugm\@
	even

.debugm\@.done

	ENDM


DEBUGS	MACRO	; <COMMENT>, STRING ADDRESS, [STRING LENGTH]

	movem.l	d0-d3/a0-a1,-(sp)

	move.l	#.debugs\@,d2
	move.l	#.debugs.len\@,d3
	jsr	debug.copy

	move.l	\2,d2
	IFC	'\3',''
	jsr	debugs.string.len	calculate length, if not specified
	ELSE
	move.l	\3,d3
	ENDC
	jsr	debug.copy

	movem.l	(sp)+,d0-d3/a0-a1
	bra.s	.debugs\@.done

.debugs\@	dc.b	LF,'\1'
.debugs.len\@	equ	*-.debugs\@
	even

.debugs\@.done

	ENDM


debugs.string.len
	move.l	d2,a0

.loop	tst.b	(a0)+
	bne.s	.loop

	move.l	a0,d3
	sub.l	d2,d3
	subq.l	#1,d3
	rts


DEBUGW	MACRO	; <COMMENT>, WORD

	movem.l	d0-d3/a0-a1,-(sp)

	move.l	#.debugw\@,d2
	move.l	#.debugw.len\@,d3
	jsr	debug.copy

	move.w	\2,d0
	bsr	debug.make.hex.word
	move.l	#debug.hex.text,d2
	moveq	#4,d3
	jsr	debug.copy

	movem.l	(sp)+,d0-d3/a0-a1
	bra.s	.debugw\@.done

.debugw\@	dc.b	LF,'\1$'
.debugw.len\@	equ	*-.debugw\@
	even

.debugw\@.done

	ENDM


DEBUGL	MACRO	; <COMMENT>, WORD

	movem.l	d0-d3/a0-a1,-(sp)

	move.l	#.debugl\@,d2
	move.l	#.debugl.len\@,d3
	jsr	debug.copy

	move.l	\2,d0
	bsr	debug.make.hex.long
	move.l	#debug.hex.text,d2
	moveq	#8,d3
	jsr	debug.copy

	movem.l	(sp)+,d0-d3/a0-a1
	bra.s	.debugl\@.done

.debugl\@	dc.b	LF,'\1$'
.debugl.len\@	equ	*-.debugl\@
	even

.debugl\@.done

	ENDM


debug.make.hex.word			; d0.w = number
	moveq	#4-1,d1
	bra.s	debug.make.hex
debug.make.hex.long			; d0.l = number
	moveq	#8-1,d1
debug.make.hex
	lea	debug.hex.text(pc),a0
	lea	debug.hex.digits(pc),a1

.loop	move.w	d0,d2
	and.w	#$f,d2
	move.b	(a1,d2.w),(a0,d1.w)
	ror.l	#4,d0
	dbra	d1,.loop
	rts

debug.hex.digits
	dc.b	'0123456789ABCDEF'

debug.hex.text
	ds.b	8
	even
