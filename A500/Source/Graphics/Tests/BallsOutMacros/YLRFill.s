

; NB This is not a runnable program.  It is just a macro to create fill routines


N_COLORS	equ	16
N_PLANES	equ	4

PLSIZE		equ	8000

COLORS32	equ	0
COLORS64	equ	0


; No claims to be the fastest, but this routine is at least adequate.
; It is passed a list of y/leftx/rightx triplets. The macro is used to
; generate code specifically for each color. It handles 16, 32, or 64
; colors.

ylrfill	macro	color
; generate a ylrfill subroutine for color 'color' \1
; entr (a4)=ylr list terminated by -1
; register usage:
; A0=ytab
; A1=wordnum
; A2=lwordmask
; A3=rwordmask
; A4=ylr list
; A5=screen mem ptr
; trashes all regs except a6+d5


	xdef	xfill_\1	; name of actual fill routine to be called


wrong_order\@
;	dbugs	'wrong order'
	exg	d1,d2
	bra.s	re_enter\@


one_word\@
	bmi.s	wrong_order\@
	move	0(a2,d1.w),d4	; left mask
	and	0(a3,d2.w),d4	; right mask
	beq.s	wrong_order\@

	move.l	0(a0,d0.w),a5
	add	d3,a5

	ifne	(\1+1)-N_COLORS
	 move	d4,d3
	 not	d3
	endc

	ifne	(\1&2)
	 or	d4,PLSIZE(a5)
	else
	 and	d3,PLSIZE(a5)
	endc

	ifne	(\1&4)
	 or	d4,PLSIZE*2(a5)
	else
	 and	d3,PLSIZE*2(a5)
	endc

	ifne	(\1&8)
	 or	d4,PLSIZE*3(a5)
	else
	 and	d3,PLSIZE*3(a5)
	endc

	ifge	N_PLANES-5
	 ifne	(\1&16)
	  or	d4,PLSIZE*4(a5)
	 endc
	 ifeq	(\1&16)
	  and	d3,PLSIZE*4(a5)
	 endc
	 ifne	COLORS64
	  ifne	(\1&32)
	   or	d4,0(a5,a6.l)
	  endc
	  ifeq	(\1&32)
	   and	d3,0(a5,a6.l)
	  endc
	 endc
	endc

	ifne	(\1&1)
	 or	d4,(a5)
	else
	 and	d3,(a5)
	endc
	bra.s	fill_lp\@


rts1\@
	ifne	COLORS64
;	move.l	#_LinkerDB,a6
	endc
	rts


xfill_\1
	lea	ytab,a0
	lea	wordnum,a1
	lea	lwordmask,a2
	lea	rwordmask,a3
	ifne	COLORS64
	move.l	#PLSIZE*5,a6	; must have because 8000*5>32767
	endc
	moveq	#0,d6
	moveq	#-1,d7

fill_lp\@
	movem	(a4)+,d0/d1/d2	; y l r
;	dbugw	d0
;	dbugw	d1
;	dbugw	d2
	add	d0,d0
	bmi.s	rts1\@
	add	d0,d0
	add	d1,d1
	add	d2,d2

re_enter\@
	move	0(a1,d1.w),d3	; left wordnum
	move	0(a1,d2.w),d4	; right wordnum
	sub	d3,d4
	ble.s	one_word\@

	asr	#1,d4		; d4=#words-1
	move.l	0(a0,d0.w),a5
	add	d3,a5
	move	0(a2,d1.w),d1	; left mask
	move	0(a3,d2.w),d2	; right mask

	ifne	((\1+1)-N_COLORS)
	 move	d1,d3
	 not	d3
	endc

	ifne	(\1&2)
	 or	d1,PLSIZE(a5)
	else
	 and	d3,PLSIZE(a5)
	endc

	ifne	(\1&4)
	 or	d1,PLSIZE*2(a5)
	else
	 and	d3,PLSIZE*2(a5)
	endc

	ifne	(\1&8)
	 or	d1,PLSIZE*3(a5)
	else
	 and	d3,PLSIZE*3(a5)
	endc

	ifne	COLORS32+COLORS64
	 ifne	(\1&16)
	  or	d1,PLSIZE*4(a5)
	 endc
	 ifeq	(\1&16)
	  and	d3,PLSIZE*4(a5)
	 endc
	 ifne	COLORS64
	  ifne	(\1&32)
	   or	d1,0(a5,a6.l)
	  endc
	  ifeq	(\1&32)
	   and	d3,0(a5,a6.l)
	  endc
	 endc
	endc

	ifne	(\1&1)
	 or	d1,(a5)+
	else
	 and	d3,(a5)+
	endc

	subq	#1,d4
	ble.s	skip_lp\@

	lsr	#1,d4
	bcc.s	no_xtra\@
	ifne	(\1&2)
	 move	d7,PLSIZE(a5)
	else
	 move	d6,PLSIZE(a5)
	endc

	ifne	(\1&4)
	 move	d7,PLSIZE*2(a5)
	else
	 move	d6,PLSIZE*2(a5)
	endc

	ifne	(\1&8)
	 move	d7,PLSIZE*3(a5)
	else
	 move	d6,PLSIZE*3(a5)
	endc

	ifne	COLORS32+COLORS64
	 ifne	(\1&16)
	  move	d7,PLSIZE*4(a5)
	 endc
	 ifeq	(\1&16)
	  move	d6,PLSIZE*4(a5)
	 endc
	 ifne	COLORS64
	  ifne	(\1&32)
	   move	d7,0(a5,a6.l)
	  endc
	  ifeq	(\1&32)
	   move	d6,0(a5,a6.l)
	  endc
	 endc
	endc

	ifne	(\1&1)
	 move	d7,(a5)+
	else
	 move	d6,(a5)+
	endc

no_xtra\@
	subq	#1,d4
	bmi.s	skip_lp\@

fill_word\@
	ifne	(\1&2)
	 move.l	d7,PLSIZE(a5)
	else
	 move.l	d6,PLSIZE(a5)
	endc

	ifne	(\1&4)
	 move.l	d7,PLSIZE*2(a5)
	else
	 move.l	d6,PLSIZE*2(a5)
	endc

	ifne	(\1&8)
	 move.l	d7,PLSIZE*3(a5)
	else
	 move.l	d6,PLSIZE*3(a5)
	endc

	ifne	COLORS32+COLORS64
	 ifne	(\1&16)
	  move.l	d7,PLSIZE*4(a5)
	 endc
	 ifeq	(\1&16)
	  move.l	d6,PLSIZE*4(a5)
	 endc
	 ifne	COLORS64
	  ifne	(\1&32)
	   move.l	d7,0(a5,a6.l)
	  endc
	  ifeq	(\1&32)
	   move.l	d6,0(a5,a6.l)
	  endc
	 endc
	endc

	ifne	(\1&1)
	 move.l	d7,(a5)+
	else
	 move.l	d6,(a5)+
	endc
	dbra	d4,fill_word\@

skip_lp\@
	ifne	(\1+1)-N_COLORS
	 move	d2,d3
	 not	d3
	endc

	ifne	(\1&2)
	 or	d2,PLSIZE(a5)
	else
	 and	d3,PLSIZE(a5)
	endc

	ifne	(\1&4)
	 or	d2,PLSIZE*2(a5)
	else
	 and	d3,PLSIZE*2(a5)
	endc

	ifne	(\1&8)
	 or	d2,PLSIZE*3(a5)
	else
	 and	d3,PLSIZE*3(a5)
	endc

	ifne	COLORS32+COLORS64
	 ifne	(\1&16)
	  or	d2,PLSIZE*4(a5)
	 endc
	 ifeq	(\1&16)
	  and	d3,PLSIZE*4(a5)
	 endc
	 ifne	COLORS64
	  ifne	(\1&32)
	   or	d2,0(a5,a6.l)
	  endc
	  ifeq	(\1&32)
	   and	d3,0(a5,a6.l)
	  endc
	 endc
	endc

	ifne	(\1&1)
	 or	d2,(a5)
	else
	 and	d3,(a5)
	endc

	bra.w	fill_lp\@	; in 16 color mode this will be a .s,
				; otherwise it will be a .w
	endm


	ylrfill	0	; generates routine called xfill_0, for colour 0
	ylrfill	1	; generates routine called xfill_1, for colour 1
	ylrfill	2	; and so on ...
	ylrfill	3
	ylrfill	4
	ylrfill	5
	ylrfill	6
	ylrfill	7
	ylrfill	8
	ylrfill	9
	ylrfill	10
	ylrfill	11
	ylrfill	12
	ylrfill	13
	ylrfill	14
	ylrfill	15
	ifne	COLORS32+COLORS64
	ylrfill	16
	ylrfill	17
	ylrfill	18
	ylrfill	19
	ylrfill	20
	ylrfill	21
	ylrfill	22
	ylrfill	23
	ylrfill	24
	ylrfill	25
	ylrfill	26
	ylrfill	27
	ylrfill	28
	ylrfill	29
	ylrfill	30
	ylrfill	31
	ifne	COLORS64
	ylrfill	32
	ylrfill	33
	ylrfill	34
	ylrfill	35
	ylrfill	36
	ylrfill	37
	ylrfill	38
	ylrfill	39
	ylrfill	40
	ylrfill	41
	ylrfill	42
	ylrfill	43
	ylrfill	44
	ylrfill	45
	ylrfill	46
	ylrfill	47
	ylrfill	48
	ylrfill	49
	ylrfill	50
	ylrfill	51
	ylrfill	52
	ylrfill	53
	ylrfill	54
	ylrfill	55
	ylrfill	56
	ylrfill	57
	ylrfill	58
	ylrfill	59
	ylrfill	60
	ylrfill	61
	ylrfill	62
	ylrfill	63
	endc
	endc


ytab	ds.l	200
wordnum	ds.w	320
lwordmask	ds.w	320
rwordmask	ds.w	320


	end
