	section begin,code

* Load Chip / Slow RAM images from dh0:, then transfer them to the lower half of the A1200's Chip RAM,
* i.e. Chip image to (0-$7ffff) and Slow image to ($80000-$fffff).


	jmp	main


IMAGE_SIZE	equ	512*1024

	section ChipData,bss

chipimage	ds.w	IMAGE_SIZE/2


	section SlowData,bss

slowimage	ds.w	IMAGE_SIZE/2


	section SHOstart,code

main
* Open the DOS library

	moveq	#0,d0
	lea	dosname(pc),a1
	move.l	4.w,a6
	jsr	-552(a6)		OpenLibrary
	move.l	d0,DOSBase
	beq	.exit_now

* load chip/slow images

	move.l	#ChipName,d1
	move.l	#chipimage,FileMem
	move.l	#IMAGE_SIZE,FileLength
	bsr	read_file
	tst.w	d7
	beq.s	.ok1
.exit_now
	rts

.ok1

	move.l	#SlowName,d1
	move.l	#slowimage,FileMem
	move.l	#IMAGE_SIZE,FileLength
	bsr	read_file
	tst.w	d7
	beq.s	.ok2
	rts

.ok2

* Close DOS library

	move.l	DOSBase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

* forbid multitasking, switch CPU to Supervisor mode
	move.l	4.w,a6
	addq.b	#1,$127(a6)
	jsr	-150(a6)		SuperState


* disable interrupts / DMA
	move.w	#$2700,sr
	move.w	#$7fff,$00dff09a
	move.w	#$7fff,$00dff096


* transfer remaining program to safe area ($100000) that won't be overwritten by the transfers below
	move.l	#(setup_end-setup)/4,d0
	lea	setup(pc),a0
	lea	$100000,a1
secopy	move.l	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	secopy
	jmp	$100000


* NB code from now until setup_end must be position independent
* transfer Chip RAM
setup	move.l	#(512*1024)/4,d0
	lea	chipimage,a0
	lea	$0,a1
ccopy	move.l	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	ccopy


* transfer Slow RAM
	move.l	#(512*1024)/4,d0
	lea	slowimage,a0
	lea	$80000,a1
scopy	move.l	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	scopy


* update pointers to the 'Slow' region (on an A500 these were both $c00000)
	move.l	#$80000,$180
	move.l	#$80000,$64b6


* initialise custom hardware registers except interrupt / DMA enables
	lea	custom,a5
	move.l	#$65d6,cop1lch(a5)
	move.l	#$6682,cop2lch(a5)
	move.w	#0,copcon(a5)
	move.w	#0,copjmp1(a5)

	move.l	#$0de4f000,bltcon0(a5)

	move.w	#$2c81,diwstrt(a5)
	move.w	#$f4c1,diwstop(a5)
	move.w	#$38,ddfstrt(a5)
	move.w	#$d0,ddfstop(a5)

	move.w	#0,clxcon(a5)
	move.w	#$1500,adkcon(a5)

	move.w	#$4200,bplcon0(a5)
	move.w	#0,bplcon1(a5)
	move.w	#$24,bplcon2(a5)
	move.w	#0,bpl1mod(a5)
	move.w	#0,bpl2mod(a5)

	move.l	#$200,spr0pth(a5)
	move.l	#$200,spr1pth(a5)
	move.l	#$200,spr2pth(a5)
	move.l	#$200,spr3pth(a5)
	move.l	#$200,spr4pth(a5)
	move.l	#$200,spr5pth(a5)
	move.l	#$200,spr6pth(a5)
	move.l	#$200,spr7pth(a5)

	move.w	#32-1,d0
	lea	colours(pc),a0
	lea	color00(a5),a1
.loop	move.w	(a0)+,(a1)+
	dbra	d0,.loop


* initialise CIA registers
	lea	CIAA,a4
	move.b	#%01011000,TALO(a4)
	move.b	#%00001001,TAHI(a4)
	move.b	#%11110110,TBLO(a4)	(runs too fast if TimerB not set)
	move.b	#%00001101,TBHI(a4)
	move.b	#%00000000,$a00(a4)
	move.b	#%00010101,$900(a4)
	move.b	#%11001011,$800(a4)
	move.b	#%01111111,ICR(a4)
	move.b	#%10000010,ICR(a4)
	move.b	#%00000000,CRA(a4)
	move.b	#%00000001,CRB(a4)

	lea	CIAB,a4
	move.b	#%11111111,TALO(a4)
	move.b	#%11111111,TAHI(a4)
	move.b	#%11111111,TBLO(a4)
	move.b	#%11111111,TBHI(a4)
	move.b	#%00011000,$a00(a4)
	move.b	#%10110011,$900(a4)
	move.b	#%01010111,$800(a4)
	move.b	#%01111111,ICR(a4)
	move.b	#%10000000,ICR(a4)
	move.b	#%00000000,CRA(a4)
	move.b	#%00000000,CRB(a4)


* initialise CPU registers
	move.l	#0,d0
	move.l	#$c00200,d1
	move.l	#1,d2
	move.l	#$70,d3
	move.l	#$c00000,d4
	move.l	#$ffffffff,d5
	move.l	#$ffffffff,d6
	move.l	#$ffff,d7

	move.l	#$2fc,a0
	move.l	a0,usp

	move.l	#$48500,a0
	move.l	#$484f8,a1
	move.l	#$dff180,a2
	move.l	#$10bf4,a3
	move.l	#$f5a,a4
	move.l	#$300,a5
	move.l	#$10a04,a6
	move.l	#$180,a7

	move.w	#$7fff,intreq+custom
	move.w	#$c078,intena+custom
	move.w	#$8240,dmacon+custom


* activate cheat
	move.b	#$4e,$119c
	move.b	#$71,$119d
	move.b	#$60,$119e

* switch CPU back to User mode, jump to game start address
	move.w	#$0100,SR
	jmp	$b20
setup_end


* d1 = file name

read_file
	moveq	#1,d7			return code

* Open file

	* d1 = file name
	move.l	#1005,d2		MODE_OLDFILE
	move.l	DOSBase(pc),a6
	jsr	-30(a6)			Open
	move.l	d0,FileHandle
	beq	done

* Read file into memory

	move.l	FileHandle(pc),d1
	move.l	FileMem(pc),d2
	move.l	FileLength(pc),d3
	move.l	DOSBase(pc),a6
	jsr	-42(a6)			Read
	tst.l	d0
	bpl.s	readok

error	moveq	#1,d7
	bra.s	close

* Close file

readok	moveq	#0,d7

close	move.l	FileHandle(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close
done	rts


;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

DOSBase	dc.l	0
FileHandle	dc.l	0
FileMem	dc.l	0
FileLength	dc.l	0


;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

dosname	dc.b	'dos.library',0
	even

ChipName
	dc.b	"dh0:ChipImage",0
	even
SlowName
	dc.b	"dh0:SlowImage",0
	even

colours	dc.w	$000,$500,$222,$333,$444,$888,$666,$a30
	dc.w	$f80,$bbb,$660,$880,$cb0,$f55,$f33,$700
	dc.w	$ff0,$f00,$ff0,$000,$4a0,$f00,$480,$000
	dc.w	$acf,$f00,$69f,$000,$06f,$668,$aac,$00f


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
