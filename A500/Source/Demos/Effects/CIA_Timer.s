	section	CIA_Timer,code_c
	opt	c-,o+




intenar	equ	$1c
dmacon	equ	$96
intena	equ	$9a

CIAA	equ	$bfe001
TALO	equ	$400
TAHI	equ	$500
ICR	equ	$d00
CRA	equ	$e00




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

SECONDS	equ	10
COUNT	equ	20*SECONDS
TICKS	equ	7159*5			1/20th second

	lea	CIAA,a0
	move.b	#%00001000,CRA(a0)
	move.b	#%01111111,ICR(a0)
	move.b	#(TICKS&$ff),TALO(a0)
	move.b	#(TICKS>>8),TAHI(a0)

	move.w	#count,d0

timer.wait
	btst	#0,ICR(a0)		TA
	beq.s	timer.wait

	bchg	#1,CIAA			blink power light

	subq.w	#1,d0
	beq.s	exit

	bset	#0,CRA(a0)		restart Timer A
	bra.s	timer.wait




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

	moveq	#0,d0
	rts



old.ints
	dc.w	0
