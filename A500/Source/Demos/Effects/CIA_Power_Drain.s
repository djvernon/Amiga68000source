	section	CIA_Power_Drain,code_c
	opt	c-,o+




intenar	equ	$1c
dmacon	equ	$96
intena	equ	$9a

CIAA	equ	$bfe001
TALO	equ	$400
TAHI	equ	$500
TBLO	equ	$600
TBHI	equ	$700
ICR	equ	$d00
CRA	equ	$e00
CRB	equ	$f00




	move.l	4.w,a6
	jsr	-132(a6)		Forbid




;"""""""""""""""""""""""""
;" INITIALISE INTERRUPTS "
;"			 "
;"""""""""""""""""""""""""

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts




;"""""""""""""""""""""""""""""
;" INITIALISE SCREEN DISPLAY "
;"			     "
;"""""""""""""""""""""""""""""

	move.w	#$03ff,dmacon(a6)	DMA off




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

A.TICKS	equ	2000
B.TICKS	equ	4500

FADE.SPEED	equ	45

	lea	CIAA,a0
	move.b	#%00001000,CRA(a0)
	move.b	#%00001000,CRB(a0)
	move.b	#%01111111,ICR(a0)
	move.b	#(A.TICKS&$ff),TALO(a0)
	move.b	#(A.TICKS>>8),TAHI(a0)	start timer A

	move.w	#B.TICKS,d7
	move.w	#-FADE.SPEED,d6

timer.A.wait
	btst	#0,ICR(a0)		TA
	beq.s	timer.A.wait

	bclr	#1,CIAA			power light ON

	move.w	d7,d2
	move.b	d2,TBLO(a0)
	lsr.w	#8,d2
	move.b	d2,TBHI(a0)		start Timer B with current ON time

timer.B.wait
	btst	#1,ICR(a0)
	beq.s	timer.B.wait

	bset	#1,CIAA			power light OFF

	btst	#6,CIAA
	beq.s	exit

	tst.w	d6
	bpl.s	increase.ON.time

reduce.ON.time
	add.w	d6,d7
	bgt.s	ON.time.ok
	neg.w	d6

increase.ON.time
	add.w	d6,d7
	cmp.w	#B.TICKS,d7
	ble.s	ON.time.ok
	neg.w	d6

ON.time.ok
	bset	#0,CRA(a0)		restart Timer A
	bra.s	timer.A.wait




;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""

exit	move.b	#%10011011,ICR(a0)	restore CIA-A ICR

	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


	move.w	#$87f0,dmacon(a6)	DMA on

	move.l	4.w,a6
	jsr	-138(a6)		Permit

	bclr	#1,CIAA			power light ON

	moveq	#0,d0
	rts



old.ints
	dc.w	0
