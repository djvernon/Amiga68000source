
; click left button five times to finish

	bset	#1,$bfe001
	
	move.b	#%01111111,$bfdd00	clear all ints

	moveq	#5-1,d0
step	bsr.s	delay
	bsr.s	delay
	bsr.s	delay
	bsr.s	delay
	bsr.s	delay
	lea	$bfd100,a0
	bclr	#3,(a0)
	bclr	#1,(a0)
	bclr	#0,(a0)
	nop
	nop
	bset	#1,(a0)
	bset	#3,(a0)
	dbra	d0,step

	bclr	#1,$bfe001
	moveq	#0,d0
	rts


; CIA-B Timer A (and probably the others) count down in such a way that
; the timer counters can't be read as on a real Amiga (they probably count
; down very quickly).  Solution is to wait for the interrupt control bit
; to be set, as done by other Amiga code that works OK (e.g. in Hardware
; Reference Manual)

delay	move.b	#8,$bfde00
	move.b	#0,$bfd400
	move.b	#$c,$bfd500
;	bset	#0,$e00(a0)
	
loop	;btst	#6,$bfe001
	;beq.s	done

;	tst.b	$bfd500		this method doesn't work
;	bne.s	loop

	btst	#0,$bfdd00	wait for ICR bit to be set instead
	beq.s	loop

done	;btst	#6,$bfe001
	;beq.s	done
	rts
