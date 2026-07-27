	section CCstart,code


	jmp	start


game		incbin	binary/CCGame
		dc.w	0		* pad to next longword
gamesize	equ	*-game


* forbid multitasking, switch CPU to Supervisor mode
start	move.l	4.w,a6
	addq.b	#1,$127(a6)
	jsr	-150(a6)		SuperState


* disable interrupts / DMA
	move.w	#$2700,sr
	move.w	#$7fff,$00dff09a
	move.w	#$7fff,$00dff096


* transfer loading screen $77400 - $7f120 ($77400 - $80000 read from disk)
main	move.l	#loadscreensize/4,d0
	lea	loadscreen,a0
	lea	$77400,a1
lscopy	move.l	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	lscopy


* transfer game $400 - $5038a ($400 - $57c00 read from disk)
	move.l	#gamesize/4,d0
	lea	game,a0
	lea	$400,a1
gcopy	move.l	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	gcopy


* force program protection to always request word 0 - 'being', by changing and.w #$3f,d0 to and.w #0,d0
*	move.w	#0,$ca8c

* disable program protection
	move.l	#$4e714e71,$6052.w
	move.w	#$4e75,$ca40


* modify level 2 interrupt handler to use a software handshake loop
* (because emulators don't generate CIA-A interrupt when SP is set to output)
	move.l	#handshakesize/4,d0
	lea	handshake,a0
	lea	$1a8c8,a1
hcopy	move.l	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	hcopy


* initialise CPU registers
	move.l	#$77400,a0	* loading screen start


* jump to game start address
	jmp	$400.w


handshake
	bset #6,$e00(a5)
	moveq #54,d0
.loop	dbra d0,.loop
	bclr #6,$e00(a5)
	nop
	nop
	nop
	nop
	nop
	nop
	nop
handshakesize	equ	*-handshake


loadscreen	incbin	binary/CCLoadScreen
loadscreensize	equ	*-loadscreen


*""""""""""""""""""""""
*" HARDWARE REGISTERS "
*"		      "
*""""""""""""""""""""""

custom	equ	$dff000
dmaconr	equ	$002
vposr	equ	$004
vhposr	equ	$006
joy0dat	equ	$00a
joy1dat	equ	$00c
clxdat	equ	$00e
adkconr	equ	$010
pot0dat	equ	$012
pot1dat	equ	$014
potgor	equ	$016
serdatr	equ	$018
dskbytr	equ	$01a
intenar	equ	$01c
intreqr	equ	$01e
dskpth	equ	$020
dsklen	equ	$024
copcon	equ	$02e
serdat	equ	$030
serper	equ	$032
potgo	equ	$034
joytest	equ	$036
bltcon0	equ	$040
bltcon1	equ	$042
bltafwm	equ	$044
bltalwm	equ	$046
bltcpth	equ	$048
bltbpth	equ	$04c
bltapth	equ	$050
bltdpth	equ	$054
bltsize	equ	$058
bltcmod	equ	$060
bltbmod	equ	$062
bltamod	equ	$064
bltdmod	equ	$066
bltcdat	equ	$070
bltbdat	equ	$072
bltadat	equ	$074
dsksync	equ	$07e
cop1lch	equ	$080
cop2lch	equ	$084
copjmp1	equ	$088
copjmp2	equ	$08a
diwstrt	equ	$08e
diwstop	equ	$090
ddfstrt	equ	$092
ddfstop	equ	$094
dmacon	equ	$096
clxcon	equ	$098
intena	equ	$09a
intreq	equ	$09c
adkcon	equ	$09e
aud0lch	equ	$0a0
aud0len	equ	$0a4
aud0per	equ	$0a6
aud0vol	equ	$0a8
bpl1pth	equ	$0e0
bpl1ptl	equ	$0e2
bpl2pth	equ	$0e4
bpl2ptl	equ	$0e6
bpl3pth	equ	$0e8
bpl3ptl	equ	$0ea
bpl4pth	equ	$0ec
bpl4ptl	equ	$0ee
bpl5pth	equ	$0f0
bpl5ptl	equ	$0f2
bpl6pth	equ	$0f4
bpl6ptl	equ	$0f6
bplcon0	equ	$100
bplcon1	equ	$102
bplcon2	equ	$104
bpl1mod	equ	$108
bpl2mod	equ	$10a
spr0pth	equ	$120
spr0ptl	equ	$122
spr1pth	equ	$124
spr1ptl	equ	$126
spr2pth	equ	$128
spr2ptl	equ	$12a
spr3pth	equ	$12c
spr3ptl	equ	$12e
spr4pth	equ	$130
spr4ptl	equ	$132
spr5pth	equ	$134
spr5ptl	equ	$136
spr6pth	equ	$138
spr6ptl	equ	$13a
spr7pth	equ	$13c
spr7ptl	equ	$13e
color00	equ	$180

CIAA	equ	$bfe001
CIAB	equ	$bfd000
TALO	equ	$400			CIA equates
TAHI	equ	$500
TBLO	equ	$600
TBHI	equ	$700
KEY	equ	$c00
ICR	equ	$d00
CRA	equ	$e00
CRB	equ	$f00
