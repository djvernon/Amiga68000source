*""""""""""""""""""""
*" THE FILL ROUTINE "
*"		    "
*""""""""""""""""""""

fill	move.l	a6,-(sp)
	movem.l	d0-d2,-(sp)
	st	(a1)			end-of-fill marker
	move.l	screen1(pc),a0
	lea	fillCoords(pc),a1
	move.w	(a1)+,d0		get y-start
	add.w	d0,d0
	add.w	d0,d0			longword offset
	lea	yTable(pc),a2
	add.l	(a2,d0.w),a0		add y offset

	move.w	(a1)+,d0		first x-start
	bpl.s	fillColour
	movem.l	(sp)+,d0-d2
	move.l	(sp)+,a6
	rts


fillColour
	move.w	currentFillColour(pc),d1
	move.l	fillColourTable(pc,d1.w),a2
	jmp	(a2)



fillColourTable
	dc.l	fillColour0,fillColour1,fillColour2,fillColour3
	dc.l	fillColour4,fillColour5,fillColour6,fillColour7
	dc.l	fillColour8,fillColour9,fillColour10,fillColour11
	dc.l	fillColour12,fillColour13,fillColour14,fillColour15



fillColour0
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	lea	fillColour0First(pc),a2
	lea	fillColour0Last(pc),a3
	bra	fillSetPtrs

fillColour1
	moveq	#-1,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	lea	fillColour1First(pc),a2
	lea	fillColour1Last(pc),a3
	bra	fillSetPtrs

fillColour2
	moveq	#0,d4
	moveq	#-1,d5
	moveq	#0,d6
	moveq	#0,d7
	lea	fillColour2First(pc),a2
	lea	fillColour2Last(pc),a3
	bra	fillSetPtrs

fillColour3
	moveq	#-1,d4
	moveq	#-1,d5
	moveq	#0,d6
	moveq	#0,d7
	lea	fillColour3First(pc),a2
	lea	fillColour3Last(pc),a3
	bra	fillSetPtrs

fillColour4
	moveq	#0,d4
	moveq	#0,d5
	moveq	#-1,d6
	moveq	#0,d7
	lea	fillColour4First(pc),a2
	lea	fillColour4Last(pc),a3
	bra	fillSetPtrs

fillColour5
	moveq	#-1,d4
	moveq	#0,d5
	moveq	#-1,d6
	moveq	#0,d7
	lea	fillColour5First(pc),a2
	lea	fillColour5Last(pc),a3
	bra	fillSetPtrs

fillColour6
	moveq	#0,d4
	moveq	#-1,d5
	moveq	#-1,d6
	moveq	#0,d7
	lea	fillColour6First(pc),a2
	lea	fillColour6Last(pc),a3
	bra	fillSetPtrs

fillColour7
	moveq	#-1,d4
	moveq	#-1,d5
	moveq	#-1,d6
	moveq	#0,d7
	lea	fillColour7First(pc),a2
	lea	fillColour7Last(pc),a3
	bra	fillSetPtrs

fillColour8
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#-1,d7
	lea	fillColour8First(pc),a2
	lea	fillColour8Last(pc),a3
	bra.s	fillSetPtrs

fillColour9
	moveq	#-1,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#-1,d7
	lea	fillColour9First(pc),a2
	lea	fillColour9Last(pc),a3
	bra.s	fillSetPtrs

fillColour10
	moveq	#0,d4
	moveq	#-1,d5
	moveq	#0,d6
	moveq	#-1,d7
	lea	fillColour10First(pc),a2
	lea	fillColour10Last(pc),a3
	bra.s	fillSetPtrs

fillColour11
	moveq	#-1,d4
	moveq	#-1,d5
	moveq	#0,d6
	moveq	#-1,d7
	lea	fillColour11First(pc),a2
	lea	fillColour11Last(pc),a3
	bra.s	fillSetPtrs

fillColour12
	moveq	#0,d4
	moveq	#0,d5
	moveq	#-1,d6
	moveq	#-1,d7
	lea	fillColour12First(pc),a2
	lea	fillColour12Last(pc),a3
	bra.s	fillSetPtrs

fillColour13
	moveq	#-1,d4
	moveq	#0,d5
	moveq	#-1,d6
	moveq	#-1,d7
	lea	fillColour13First(pc),a2
	lea	fillColour13Last(pc),a3
	bra.s	fillSetPtrs

fillColour14
	moveq	#0,d4
	moveq	#-1,d5
	moveq	#-1,d6
	moveq	#-1,d7
	lea	fillColour14First(pc),a2
	lea	fillColour14Last(pc),a3
	bra.s	fillSetPtrs

fillColour15
	moveq	#-1,d4
	moveq	#-1,d5
	moveq	#-1,d6
	moveq	#-1,d7
	lea	fillColour15First(pc),a2
	lea	fillColour15Last(pc),a3

fillSetPtrs
	btst	#6,dmaconr+$dff000.l
	bne.s	fillSetPtrs

	move.l	a2,firstWordsPtr
	move.l	a3,lastWordsPtr
	bra.s	fillLoop



startMasks
	dc.w	$ffff,$7fff,$3fff,$1fff,$0fff,$07ff,$03ff,$01ff
	dc.w	$00ff,$007f,$003f,$001f,$000f,$0007,$0003,$0001

endMasks
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff



fillLoop
	move.w	(a1)+,d1		next x-end
	sub.w	d0,d1
	blt.s	nextLine		if x-end is less than x-start

	moveq	#$f,d2
	and.w	d0,d2			low four bits from x-start
	sub.w	d2,d0

	lsr.w	#3,d0			x-start offset in even bytes
	lea	(a0,d0.w),a2		start address of fill -	bitplane 1
;	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a2),a3		bitplane 2
;	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a3),a4		bitplane 3
;	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a4),a5		bitplane 4
	lea	SCREEN_WIDTH/8(a2),a3		bitplane 2
	lea	SCREEN_WIDTH/8(a3),a4		bitplane 3
	lea	SCREEN_WIDTH/8(a4),a5		bitplane 4

	add.w	d2,d1			correct bit position for x-end

	add.w	d2,d2
	move.w	startMasks(pc,d2.w),d0	get positive start mask

	moveq	#$f,d2
	and.w	d1,d2			low four bits from x-end
	sub.w	d2,d1

	add.w	d2,d2
	move.w	endMasks(pc,d2.w),d2	get positive end mask

	lsr.w	#2,d1			width of fill - 1, in words * 4
	beq.s	oneWordFill

setFirstWords
	move.l	firstWordsPtr(pc),a6
	jmp	(a6)

setMiddleWords
	move.l	fillWidthTable-4(pc,d1.w),a6
	jmp	(a6)

oneWordFill
	and.w	d0,d2			combine start and end masks

setLastWords
words2	move.l	lastWordsPtr(pc),a6
	jmp	(a6)

nextLine
	lea	SCREEN_WIDTH/8*SCREEN_DEPTH(a0),a0	next line
	move.w	(a1)+,d0		next x-start
	bpl.s	fillLoop
	movem.l	(sp)+,d0-d2
	move.l	(sp)+,a6
	rts



fillWidthTable

* one word fill is handled above

	dc.l	words2,words3,words4,words5,words6,words7,words8
	dc.l	words9,words10,words11,words12,words13,words14
	dc.l	words15,words16,words17,words18,words19,words20



words19	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words17	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words15	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words13	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words11	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words9	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words7	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words5	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words3	move.w	d4,(a2)+
	move.w	d5,(a3)+
	move.w	d6,(a4)+
	move.w	d7,(a5)+

	bra	setLastWords



words20	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words18	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words16	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words14	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words12	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words10	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words8	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words6	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

words4	move.l	d4,(a2)+
	move.l	d5,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+

	bra	setLastWords



firstWordsPtr	dc.l	0
lastWordsPtr	dc.l	0



fillColour0First
	not.w	d0
	and.w	d0,(a2)+
	and.w	d0,(a3)+
	and.w	d0,(a4)+
	and.w	d0,(a5)+
	bra	setMiddleWords

fillColour0Last
	not.w	d2
	and.w	d2,(a2)
	and.w	d2,(a3)
	and.w	d2,(a4)
	and.w	d2,(a5)
	bra	nextLine



fillColour1First
	or.w	d0,(a2)+
	not.w	d0
	and.w	d0,(a3)+
	and.w	d0,(a4)+
	and.w	d0,(a5)+
	bra	setMiddleWords

fillColour1Last
	or.w	d2,(a2)
	not.w	d2
	and.w	d2,(a3)
	and.w	d2,(a4)
	and.w	d2,(a5)
	bra	nextLine



fillColour2First
	or.w	d0,(a3)+
	not.w	d0
	and.w	d0,(a2)+
	and.w	d0,(a4)+
	and.w	d0,(a5)+
	bra	setMiddleWords

fillColour2Last
	or.w	d2,(a3)
	not.w	d2
	and.w	d2,(a2)
	and.w	d2,(a4)
	and.w	d2,(a5)
	bra	nextLine



fillColour3First
	or.w	d0,(a2)+
	or.w	d0,(a3)+
	not.w	d0
	and.w	d0,(a4)+
	and.w	d0,(a5)+
	bra	setMiddleWords

fillColour3Last
	or.w	d2,(a2)
	or.w	d2,(a3)
	not.w	d2
	and.w	d2,(a4)
	and.w	d2,(a5)
	bra	nextLine



fillColour4First
	or.w	d0,(a4)+
	not.w	d0
	and.w	d0,(a2)+
	and.w	d0,(a3)+
	and.w	d0,(a5)+
	bra	setMiddleWords

fillColour4Last
	or.w	d2,(a4)
	not.w	d2
	and.w	d2,(a2)
	and.w	d2,(a3)
	and.w	d2,(a5)
	bra	nextLine



fillColour5First
	or.w	d0,(a2)+
	or.w	d0,(a4)+
	not.w	d0
	and.w	d0,(a3)+
	and.w	d0,(a5)+
	bra	setMiddleWords

fillColour5Last
	or.w	d2,(a2)
	or.w	d2,(a4)
	not.w	d2
	and.w	d2,(a3)
	and.w	d2,(a5)
	bra	nextLine



fillColour6First
	or.w	d0,(a3)+
	or.w	d0,(a4)+
	not.w	d0
	and.w	d0,(a2)+
	and.w	d0,(a5)+
	bra	setMiddleWords

fillColour6Last
	or.w	d2,(a3)
	or.w	d2,(a4)
	not.w	d2
	and.w	d2,(a2)
	and.w	d2,(a5)
	bra	nextLine



fillColour7First
	or.w	d0,(a2)+
	or.w	d0,(a3)+
	or.w	d0,(a4)+
	not.w	d0
	and.w	d0,(a5)+
	bra	setMiddleWords

fillColour7Last
	or.w	d2,(a2)
	or.w	d2,(a3)
	or.w	d2,(a4)
	not.w	d2
	and.w	d2,(a5)
	bra	nextLine



fillColour8First
	or.w	d0,(a5)+
	not.w	d0
	and.w	d0,(a2)+
	and.w	d0,(a3)+
	and.w	d0,(a4)+
	bra	setMiddleWords

fillColour8Last
	or.w	d2,(a5)
	not.w	d2
	and.w	d2,(a2)
	and.w	d2,(a3)
	and.w	d2,(a4)
	bra	nextLine



fillColour9First
	or.w	d0,(a2)+
	or.w	d0,(a5)+
	not.w	d0
	and.w	d0,(a3)+
	and.w	d0,(a4)+
	bra	setMiddleWords

fillColour9Last
	or.w	d2,(a2)
	or.w	d2,(a5)
	not.w	d2
	and.w	d2,(a3)
	and.w	d2,(a4)
	bra	nextLine



fillColour10First
	or.w	d0,(a3)+
	or.w	d0,(a5)+
	not.w	d0
	and.w	d0,(a2)+
	and.w	d0,(a4)+
	bra	setMiddleWords

fillColour10Last
	or.w	d2,(a3)
	or.w	d2,(a5)
	not.w	d2
	and.w	d2,(a2)
	and.w	d2,(a4)
	bra	nextLine



fillColour11First
	or.w	d0,(a2)+
	or.w	d0,(a3)+
	or.w	d0,(a5)+
	not.w	d0
	and.w	d0,(a4)+
	bra	setMiddleWords

fillColour11Last
	or.w	d2,(a2)
	or.w	d2,(a3)
	or.w	d2,(a5)
	not.w	d2
	and.w	d2,(a4)
	bra	nextLine



fillColour12First
	or.w	d0,(a4)+
	or.w	d0,(a5)+
	not.w	d0
	and.w	d0,(a2)+
	and.w	d0,(a3)+
	bra	setMiddleWords

fillColour12Last
	or.w	d2,(a4)
	or.w	d2,(a5)
	not.w	d2
	and.w	d2,(a2)
	and.w	d2,(a3)
	bra	nextLine



fillColour13First
	or.w	d0,(a2)+
	or.w	d0,(a4)+
	or.w	d0,(a5)+
	not.w	d0
	and.w	d0,(a3)+
	bra	setMiddleWords

fillColour13Last
	or.w	d2,(a2)
	or.w	d2,(a4)
	or.w	d2,(a5)
	not.w	d2
	and.w	d2,(a3)
	bra	nextLine



fillColour14First
	or.w	d0,(a3)+
	or.w	d0,(a4)+
	or.w	d0,(a5)+
	not.w	d0
	and.w	d0,(a2)+
	bra	setMiddleWords

fillColour14Last
	or.w	d2,(a3)
	or.w	d2,(a4)
	or.w	d2,(a5)
	not.w	d2
	and.w	d2,(a2)
	bra	nextLine



fillColour15First
	or.w	d0,(a2)+
	or.w	d0,(a3)+
	or.w	d0,(a4)+
	or.w	d0,(a5)+
	bra	setMiddleWords

fillColour15Last
	or.w	d2,(a2)
	or.w	d2,(a3)
	or.w	d2,(a4)
	or.w	d2,(a5)
	bra	nextLine



currentFillColour	dc.w	0



fillCoords
	ds.w	SCREEN_HEIGHT*2+2




	IFD	ORIGINAL_VERSION
	;; t0 -> x
	;; t1 -> y
	;; t2 -> colour

	;; On exit t3,t4 are the transformed address and X is the colour lookup

.plotPixel
	{
	LDA t1
	LSR A
	LSR A
	AND #&FE
	TAX
	LDA t0
	AND #&FE
	ASL A
	ASL A
	STA t3
	TXA
	ADC #&40
	STA t4
	LDA t1
	AND #7
	TAY
	LDA t0
	LSR A
	LDA t2
	ROL A
	TAX
	LDA colours,X
	EOR (t3),Y		; This can be change to two NOPs to stop the XOR
	STA (t3),Y
	RTS
	}

.plotPixelSet
	{
	LDA t1
	LSR A
	LSR A
	AND #&FE
	TAX
	LDA t0
	AND #&FE
	ASL A
	ASL A
	STA t3
	TXA
	ADC #&40
	STA t4
	LDA t1
	AND #7
	TAY
	LDA t0
	LSR A
	LDA t2
	ROL A
	TAX
	LDA (t3),Y
	BNE noPlot
	LDA colours,X
	STA (t3),Y
	SEC
	RTS
.noPlot
	CLC
	RTS
	}	

PRINT "* Plot pixel size:", P%-plotPixel
	
IF FALSE
	; Draws a box at t0,t1 with width and height at t2,t3 in colour t4
.drawBox
	{
	LDA t0
	STA orgX
	LDA t1
	STA orgY
	LDA t2
	STA width
	LDA t3
	STA height
	LDA t4
	STA t2
	
	; t0,t1   -> t0+w,t1
	LDA orgX
	STA t0
	LDA orgY
	STA t1
	LDA width
	STA t5
	; change to inc &70
	LDA #t0
	STA iter+1
	JSR drawLineLoop
	
	; t0+w,t1 -> t0+w,t1+h
	LDA orgX
	CLC
	ADC width
	STA t0
	LDA orgY
	STA t1
	LDA height
	STA t5
	; change to inc &71
	LDA #t1 
	STA iter+1
	JSR drawLineLoop
	
	; t0,t1   -> t0,t1+h
	LDA orgX
	STA t0
	LDA orgY
	STA t1
	INC t1
	; change to inc &71
	LDA #t1
	STA iter+1
	LDA height
	STA t5
	JSR drawLineLoop
	
	; t0,t1+h -> t0+w,t1+h
	LDA orgX
	STA t0
	INC t0
	LDA orgY
	CLC
	ADC height
	STA t1
	; change to inc &71
	LDA #t0
	STA iter+1
	LDA width
	STA t5
	JSR drawLineLoop
	
	RTS
	
.orgX
	SKIP 1
.orgY
	SKIP 1
.width
	SKIP 1
.height
	SKIP 1
	
.drawLineLoop
	JSR plotPixel
.iter
	INC t0
	DEC t5
	BNE drawLineLoop
	RTS
	}
	
ENDIF
	ENDC
