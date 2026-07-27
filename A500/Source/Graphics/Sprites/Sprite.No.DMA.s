	section	Sprite,code_c
	opt	o+




start	move.l	4.w,a6
	jsr	-132(a6)		Forbid


	move.l	#5*40*256,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	exit_now
	move.l	d0,screen.mem


	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exit_freemem

	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)		OwnBlitter




;"""""""""""""""""""""""""
;" INITIALISE INTERRUPTS "
;"			 "
;"""""""""""""""""""""""""

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts

	move.l	$6c.w,old.level3
	move.l	#new.level3,$6c.w

	move.w	#$c010,intena(a6)	enable copper interrupt


	move.l	$14.w,old.dbz		division-by-zero exception handler
	move.l	#rte.ins,$14.w		set to rte instruction




;"""""""""""""""""""""""""""""
;" INITIALISE SCREEN DISPLAY "
;"			     "
;"""""""""""""""""""""""""""""

vp.wait	move.l	vposr(a6),d0		get vertical beam position
	and.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#312,d0			wait for bottom line
	bne.s	vp.wait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off


	lea	colour.table(pc),a0	initialise colours
	lea	color0(a6),a1
	moveq	#16-1,d0

set.colours
	move.l	(a0)+,(a1)+
	dbra	d0,set.colours


	move.w	#$5200,bplcon0(a6)	initialise screen
	move.w	#$27a1,diwstrt(a6)
	move.w	#$25a0,diwstop(a6)
	move.w	#$48,ddfstrt(a6)
	move.w	#$c0,ddfstop(a6)
	move.w	#0,bplcon1(a6)
	move.w	#%100100,bplcon2(a6)
	move.w	#4*40,d0
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)


	move.l	screen.mem(pc),d0	initialise copper
	lea	copper.list(pc),a0
	bsr	init.copper

	move.l	#sprite.null,d0
	move.w	d0,sp0l
	swap	d0
	move.w	d0,sp0h

	move.l	#sprite.null,d0
	move.w	d0,sp1l
	swap	d0
	move.w	d0,sp1h

	move.l	#sprite.null,d0
	move.w	d0,sp2l
	swap	d0
	move.w	d0,sp2h

	move.l	#sprite.null,d0
	move.w	d0,sp3l
	swap	d0
	move.w	d0,sp3h

	move.l	#sprite.null,d0
	move.w	d0,sp4l
	swap	d0
	move.w	d0,sp4h

	move.l	#sprite.null,d0
	move.w	d0,sp5l
	swap	d0
	move.w	d0,sp5h

	move.l	#sprite.null,d0
	move.w	d0,sp6l
	swap	d0
	move.w	d0,sp6h

	move.l	#sprite.null,d0
	move.w	d0,sp7l
	swap	d0
	move.w	d0,sp7h

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$87e0,dmacon(a6)	DMA on
	move.w	#$0020,dmacon(a6)	DMA off




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	sf	next.frame
vbl	tst.b	next.frame
	beq.s	vbl

	btst	#6,$bfe001
	bne.s	loop




;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""

wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


	move.w	#$7fff,intena(a6)	disable all interrupts

	move.l	old.level3(pc),$6c.w

	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


	move.l	old.dbz(pc),$14.w	restore division-by-zero handler


	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	gfxbase(pc),a0
	move.l	38(a0),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on


	move.l	a0,a6
	jsr	-462(a6)		DisownBlitter

	move.l	a6,a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exit_freemem
	move.l	#5*40*256,d0
	move.l	screen.mem(pc),a1
	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		Permit

	moveq	#0,d0
	rts




;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level3
;	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$10,intreq(a6)

	st	next.frame

;	movem.l	(sp)+,d0-d7/a0-a6
rte.ins	rte




;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

init.copper
	moveq	#5-1,d1
	moveq	#40,d2			width of one bitplane

next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	add.l	d2,d0			next bitplane
	addq.l	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts




;"""""""""""""""""""
;" THE COPPER LIST "
;"		   "
;"""""""""""""""""""


copper.list
	dc.w	bpl1pth,0		5 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0
	dc.w	bpl5pth,0
	dc.w	bpl5ptl,0

	dc.w	spr0pth
sp0h	dc.w	0,spr0ptl
sp0l	dc.w	0,spr1pth
sp1h	dc.w	0,spr1ptl
sp1l	dc.w	0,spr2pth
sp2h	dc.w	0,spr2ptl
sp2l	dc.w	0,spr3pth
sp3h	dc.w	0,spr3ptl
sp3l	dc.w	0,spr4pth
sp4h	dc.w	0,spr4ptl
sp4l	dc.w	0,spr5pth
sp5h	dc.w	0,spr5ptl
sp5l	dc.w	0,spr6pth
sp6h	dc.w	0,spr6ptl
sp6l	dc.w	0,spr7pth
sp7h	dc.w	0,spr7ptl
sp7l	dc.w	0

	dc.w	$0180,$0000
	dc.w	$0182,$0830
	dc.w	$0184,$0ccc
	dc.w	$0186,$0aa4
	dc.w	$0188,$0883
	dc.w	$018a,$0662
	dc.w	$018c,$0552
	dc.w	$018e,$0e10
	dc.w	$0190,$0a9b
	dc.w	$0192,$0879
	dc.w	$0194,$0e90
	dc.w	$0196,$0546
	dc.w	$0198,$0e61
	dc.w	$019a,$0657
	dc.w	$019c,$0435
	dc.w	$019e,$0620
	dc.w	$01a0,$0a50
	dc.w	$01a2,$00f0
	dc.w	$01a4,$0d09
	dc.w	$01a6,$0904
	dc.w	$01a8,$0940
	dc.w	$01aa,$0dee
	dc.w	$01ac,$09ac
	dc.w	$01ae,$067b
	dc.w	$01b0,$0c72
	dc.w	$01b2,$000f
	dc.w	$01b4,$066f
	dc.w	$01b6,$0aaf
	dc.w	$01b8,$0b60
	dc.w	$01ba,$0abf
	dc.w	$01bc,$0aae
	dc.w	$01be,$0779

	dc.w	$0001,$ff00
	dc.w	$01a4,$0000

	dc.w	$2935,$fffe
	dc.w	$01a2,$003e
	dc.w	$01a6,$003e
	dc.w	$0146,$0000
	dc.w	$0144,$3c3c
	dc.w	$0140,$295a
	dc.w	$014e,$0000
	dc.w	$014c,$38fc
	dc.w	$0148,$2962
	dc.w	$0146,$0000
	dc.w	$0144,$fe00
	dc.w	$0140,$296a
	dc.w	$0146,$0000
	dc.w	$0144,$f03c
	dc.w	$0140,$2986
	dc.w	$014e,$0000
	dc.w	$014c,$c6fe
	dc.w	$0148,$298e
	dc.w	$0146,$0000
	dc.w	$0144,$3c00
	dc.w	$0140,$2996
	dc.w	$014e,$0000
	dc.w	$014c,$663c
	dc.w	$0148,$29b4
	dc.w	$0146,$0000
	dc.w	$0144,$3c66
	dc.w	$0140,$29bc

	dc.w	$2a35,$fffe
	dc.w	$01a2,$006f
	dc.w	$01a6,$006f
	dc.w	$0146,$1e1e
	dc.w	$0144,$6666
	dc.w	$0140,$2a5a
	dc.w	$014e,$1c7e
	dc.w	$014c,$6c66
	dc.w	$0148,$2a62
	dc.w	$0146,$7f00
	dc.w	$0144,$6600
	dc.w	$0140,$2a6a
	dc.w	$0146,$781e
	dc.w	$0144,$6018
	dc.w	$0140,$2a86
	dc.w	$014e,$637f
	dc.w	$014c,$c666
	dc.w	$0148,$2a8e
	dc.w	$0146,$1e00
	dc.w	$0144,$6600
	dc.w	$0140,$2a96
	dc.w	$014e,$331e
	dc.w	$014c,$6618
	dc.w	$0148,$2ab4
	dc.w	$0146,$1e33
	dc.w	$0144,$6666
	dc.w	$0140,$2abc

	dc.w	$2b35,$fffe
	dc.w	$01a2,$05af
	dc.w	$01a6,$05af
	dc.w	$0146,$3333
	dc.w	$0144,$70c0
	dc.w	$0140,$2b5a
	dc.w	$014e,$3633
	dc.w	$014c,$c666
	dc.w	$0148,$2b62
	dc.w	$0146,$3300
	dc.w	$0144,$6000
	dc.w	$0140,$2b6a
	dc.w	$0146,$300c
	dc.w	$0144,$6018
	dc.w	$0140,$2b86
	dc.w	$014e,$6333
	dc.w	$014c,$6c60
	dc.w	$0148,$2b8e
	dc.w	$0146,$3300
	dc.w	$0144,$7000
	dc.w	$0140,$2b96
	dc.w	$014e,$330c
	dc.w	$014c,$6618
	dc.w	$0148,$2bb4
	dc.w	$0146,$3333
	dc.w	$0144,$c066
	dc.w	$0140,$2bbc

	dc.w	$2c35,$fffe
	dc.w	$01a2,$0fc9
	dc.w	$01a6,$0fc9
	dc.w	$0146,$3860
	dc.w	$0144,$3cc0
	dc.w	$0140,$2c5a
	dc.w	$014e,$6333
	dc.w	$014c,$c67c
	dc.w	$0148,$2c62
	dc.w	$0146,$3000
	dc.w	$0144,$7800
	dc.w	$0140,$2c6a
	dc.w	$0146,$300c
	dc.w	$0144,$6018
	dc.w	$0140,$2c86
	dc.w	$014e,$3630
	dc.w	$014c,$6c78
	dc.w	$0148,$2c8e
	dc.w	$0146,$3800
	dc.w	$0144,$3c00
	dc.w	$0140,$2c96
	dc.w	$014e,$330c
	dc.w	$014c,$7e18
	dc.w	$0148,$2cb4
	dc.w	$0146,$6033
	dc.w	$0144,$ce7e
	dc.w	$0140,$2cbc

	dc.w	$2d35,$fffe
	dc.w	$01a2,$0f92
	dc.w	$01a6,$0f92
	dc.w	$0146,$1e60
	dc.w	$0144,$0ec0
	dc.w	$0140,$2d5a
	dc.w	$014e,$633e
	dc.w	$014c,$c66c
	dc.w	$0148,$2d62
	dc.w	$0146,$3c00
	dc.w	$0144,$6000
	dc.w	$0140,$2d6a
	dc.w	$0146,$300c
	dc.w	$0144,$6218
	dc.w	$0140,$2d86
	dc.w	$014e,$363c
	dc.w	$014c,$3860
	dc.w	$0148,$2d8e
	dc.w	$0146,$1e00
	dc.w	$0144,$0e00
	dc.w	$0140,$2d96
	dc.w	$014e,$3f0c
	dc.w	$014c,$6618
	dc.w	$0148,$2db4
	dc.w	$0146,$673f
	dc.w	$0144,$c666
	dc.w	$0140,$2dbc

	dc.w	$2e35,$fffe
	dc.w	$01a2,$0f70
	dc.w	$01a6,$0f70
	dc.w	$0146,$0760
	dc.w	$0144,$6666
	dc.w	$0140,$2e5a
	dc.w	$014e,$6336
	dc.w	$014c,$6c66
	dc.w	$0148,$2e62
	dc.w	$0146,$3000
	dc.w	$0144,$6600
	dc.w	$0140,$2e6a
	dc.w	$0146,$310c
	dc.w	$0144,$6618
	dc.w	$0140,$2e86
	dc.w	$014e,$1c30
	dc.w	$014c,$3866
	dc.w	$0148,$2e8e
	dc.w	$0146,$0700
	dc.w	$0144,$6600
	dc.w	$0140,$2e96
	dc.w	$014e,$330c
	dc.w	$014c,$6618
	dc.w	$0148,$2eb4
	dc.w	$0146,$6333
	dc.w	$0144,$6666
	dc.w	$0140,$2ebc

	dc.w	$2f35,$fffe
	dc.w	$01a2,$0d30
	dc.w	$01a6,$0d30
	dc.w	$0146,$3333
	dc.w	$0144,$3c3c
	dc.w	$0140,$2f5a
	dc.w	$014e,$3633
	dc.w	$014c,$38e6
	dc.w	$0148,$2f62
	dc.w	$0146,$3300
	dc.w	$0144,$fe00
	dc.w	$0140,$2f6a
	dc.w	$0146,$330c
	dc.w	$0144,$fe3c
	dc.w	$0140,$2f86
	dc.w	$014e,$1c33
	dc.w	$014c,$10fe
	dc.w	$0148,$2f8e
	dc.w	$0146,$3300
	dc.w	$0144,$3c00
	dc.w	$0140,$2f96
	dc.w	$014e,$330c
	dc.w	$014c,$663c
	dc.w	$0148,$2fb4
	dc.w	$0146,$3333
	dc.w	$0144,$3e66
	dc.w	$0140,$2fbc

	dc.w	$3035,$fffe
	dc.w	$01a2,$0fff
	dc.w	$01a6,$0fff
	dc.w	$0146,$1e1e
	dc.w	$0144,$0000
	dc.w	$0140,$305a
	dc.w	$014e,$1c73
	dc.w	$014c,$0000
	dc.w	$0148,$3062
	dc.w	$0146,$7f00
	dc.w	$0144,$0000
	dc.w	$0140,$306a
	dc.w	$0146,$7f1e
	dc.w	$0144,$0000
	dc.w	$0140,$3086
	dc.w	$014e,$087f
	dc.w	$014c,$0000
	dc.w	$0148,$308e
	dc.w	$0146,$1e00
	dc.w	$0144,$0000
	dc.w	$0140,$3096
	dc.w	$014e,$331e
	dc.w	$014c,$0000
	dc.w	$0148,$30b4
	dc.w	$0146,$1f33
	dc.w	$0144,$0000
	dc.w	$0140,$30bc

	dc.w	$3101,$fffe
	dc.w	$0140,$0000
	dc.w	$0148,$0000

	dc.w	$3201,$fffe
	dc.w	$0140,$0000
	dc.w	$0148,$0000

	dc.w	$3339,$fffe
	dc.w	$01a2,$0fff
	dc.w	$0146,$0000
	dc.w	$014e,$0000
	dc.w	$0144,$3c3c
	dc.w	$0140,$3354
	dc.w	$014c,$3c18
	dc.w	$0148,$335c
	dc.w	$0144,$7e1c
	dc.w	$0140,$3364
	dc.w	$014c,$7e3c
	dc.w	$0148,$336c
	dc.w	$0144,$3838
	dc.w	$0140,$3380
	dc.w	$014c,$3801
	dc.w	$0148,$3388
	dc.w	$0144,$8038
	dc.w	$0140,$c390
	dc.w	$014c,$3838
	dc.w	$0148,$c398
	dc.w	$0144,$3c3c
	dc.w	$0140,$33ac
	dc.w	$014c,$3c7e
	dc.w	$0148,$33b4
	dc.w	$0144,$3c3c
	dc.w	$0140,$33bc
	dc.w	$014c,$3c3c
	dc.w	$0148,$33c4

	dc.w	$3439,$fffe
	dc.w	$01a2,$0fff
	dc.w	$0146,$0000
	dc.w	$014e,$0000
	dc.w	$0144,$6666
	dc.w	$0140,$3454
	dc.w	$014c,$6638
	dc.w	$0148,$345c
	dc.w	$0144,$6630
	dc.w	$0140,$3464
	dc.w	$014c,$6066
	dc.w	$0148,$346c
	dc.w	$0144,$4444
	dc.w	$0140,$3480
	dc.w	$014c,$4403
	dc.w	$0148,$3488
	dc.w	$0144,$8044
	dc.w	$0140,$3490
	dc.w	$014c,$4444
	dc.w	$0148,$3498
	dc.w	$0144,$6666
	dc.w	$0140,$34ac
	dc.w	$014c,$6660
	dc.w	$0148,$34b4
	dc.w	$0144,$6666
	dc.w	$0140,$34bc
	dc.w	$014c,$6666
	dc.w	$0148,$34c4

	dc.w	$3539,$fffe
	dc.w	$01a2,$0fff
	dc.w	$0146,$0000
	dc.w	$014e,$0000
	dc.w	$0144,$6e6e
	dc.w	$0140,$3554
	dc.w	$014c,$6e18
	dc.w	$0148,$355c
	dc.w	$0144,$0660
	dc.w	$0140,$3564
	dc.w	$014c,$7c6e
	dc.w	$0148,$356c
	dc.w	$0144,$dede
	dc.w	$0140,$3580
	dc.w	$014c,$de01
	dc.w	$0148,$3588
	dc.w	$0144,$80de
	dc.w	$0140,$3590
	dc.w	$014c,$dede
	dc.w	$0148,$3598
	dc.w	$0144,$6e6e
	dc.w	$0140,$35ac
	dc.w	$014c,$6e7c
	dc.w	$0148,$35b4
	dc.w	$0144,$6e6e
	dc.w	$0140,$35bc
	dc.w	$014c,$6e6e
	dc.w	$0148,$35c4

	dc.w	$3639,$fffe
	dc.w	$01a2,$0fff
	dc.w	$0146,$0000
	dc.w	$014e,$0000
	dc.w	$0144,$7e7e
	dc.w	$0140,$3654
	dc.w	$014c,$7e18
	dc.w	$0148,$365c
	dc.w	$0144,$0c7c
	dc.w	$0140,$3664
	dc.w	$014c,$067e
	dc.w	$0148,$366c
	dc.w	$0144,$cece
	dc.w	$0140,$3680
	dc.w	$014c,$ce01
	dc.w	$0148,$3688
	dc.w	$0144,$80c6
	dc.w	$0140,$3690
	dc.w	$014c,$c6c6
	dc.w	$0148,$3698
	dc.w	$0144,$7e7e
	dc.w	$0140,$36ac
	dc.w	$014c,$7e06
	dc.w	$0148,$36b4
	dc.w	$0144,$7e7e
	dc.w	$0140,$36bc
	dc.w	$014c,$7e7e
	dc.w	$0148,$36c4

	dc.w	$3739,$fffe
	dc.w	$01a2,$0fff
	dc.w	$0146,$0000
	dc.w	$014e,$0000
	dc.w	$0144,$7676
	dc.w	$0140,$3754
	dc.w	$014c,$7618
	dc.w	$0148,$375c
	dc.w	$0144,$1866
	dc.w	$0140,$3764
	dc.w	$014c,$0676
	dc.w	$0148,$376c
	dc.w	$0144,$dede
	dc.w	$0140,$3780
	dc.w	$014c,$de01
	dc.w	$0148,$3788
	dc.w	$0144,$80f6
	dc.w	$0140,$3790
	dc.w	$014c,$f6f6
	dc.w	$0148,$3798
	dc.w	$0144,$7676
	dc.w	$0140,$37ac
	dc.w	$014c,$7606
	dc.w	$0148,$37b4
	dc.w	$0144,$7676
	dc.w	$0140,$37bc
	dc.w	$014c,$7676
	dc.w	$0148,$37c4

	dc.w	$3839,$fffe
	dc.w	$01a2,$0fff
	dc.w	$0146,$0000
	dc.w	$014e,$0000
	dc.w	$0144,$6666
	dc.w	$0140,$3854
	dc.w	$014c,$6618
	dc.w	$0148,$385c
	dc.w	$0144,$1866
	dc.w	$0140,$3864
	dc.w	$014c,$6666
	dc.w	$0148,$386c
	dc.w	$0144,$4444
	dc.w	$0140,$3880
	dc.w	$014c,$4401
	dc.w	$0148,$3888
	dc.w	$0144,$8044
	dc.w	$0140,$3890
	dc.w	$014c,$4444
	dc.w	$0148,$3898
	dc.w	$0144,$6666
	dc.w	$0140,$38ac
	dc.w	$014c,$6666
	dc.w	$0148,$38b4
	dc.w	$0144,$6666
	dc.w	$0140,$38bc
	dc.w	$014c,$6666
	dc.w	$0148,$38c4

	dc.w	$3939,$fffe
	dc.w	$01a2,$0fff
	dc.w	$0146,$0000
	dc.w	$014e,$0000
	dc.w	$0144,$3c3c
	dc.w	$0140,$3954
	dc.w	$014c,$3c7e
	dc.w	$0148,$395c
	dc.w	$0144,$183c
	dc.w	$0140,$3964
	dc.w	$014c,$3c3c
	dc.w	$0148,$396c
	dc.w	$0144,$3838
	dc.w	$0140,$3980
	dc.w	$014c,$3807
	dc.w	$0148,$3988
	dc.w	$0144,$e038
	dc.w	$0140,$3990
	dc.w	$014c,$3838
	dc.w	$0148,$3998
	dc.w	$0144,$3c3c
	dc.w	$0140,$39ac
	dc.w	$014c,$3c3c
	dc.w	$0148,$39b4
	dc.w	$0144,$3c3c
	dc.w	$0140,$39bc
	dc.w	$014c,$3c3c
	dc.w	$0148,$39c4

	dc.w	$3a01,$ff00
	dc.w	$01a2,$0494
	dc.w	$01a4,$0d09
	dc.w	$01a6,$0904
	dc.w	$0142,$0000
	dc.w	$0140,$0000
	dc.w	$014a,$0000
	dc.w	$0148,$0000
	dc.w	$0142,$3b00
	dc.w	$0140,$50a0
	dc.w	$014a,$3b00
	dc.w	$0140,$50a0
	dc.w	$0120,$0001
	dc.w	$0122,$2000
	dc.w	$0124,$0001
	dc.w	$0126,$2400

	dc.w	$9b01,$ff00
	dc.w	$01aa,$0abf
	dc.w	$01ac,$088c
	dc.w	$01ae,$0557

	dc.w	$c301,$ff00
	dc.w	$01aa,$0abf
	dc.w	$01ac,$088c
	dc.w	$01ae,$0557

	dc.w	$c301,$ff00
	dc.w	$01b2,$0994
	dc.w	$01b4,$096f
	dc.w	$01b6,$0baf

	dc.w	$c301,$ff00
	dc.w	$01ba,$074d
	dc.w	$01bc,$063b
	dc.w	$01be,$0529

	dc.w	$c401,$ff00
	dc.w	$01aa,$0abf
	dc.w	$01ac,$088c
	dc.w	$01ae,$0557

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe
	dc.w	$ffff,$fffe


;""""""""""""""""""""""
;" HARDWARE REGISTERS "
;"		      "
;""""""""""""""""""""""

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
aud0vol	equ	$0a8
aud1vol	equ	$0b8
aud2vol	equ	$0c8
aud3vol	equ	$0d8
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
spr0pos	equ	$140
spr1pos	equ	$148
spr2pos	equ	$150
spr3pos	equ	$158
spr4pos	equ	$160
spr5pos	equ	$168
spr6pos	equ	$170
spr7pos	equ	$178
spr0ctl	equ	$142
spr1ctl	equ	$14a
spr2ctl	equ	$152
spr3ctl	equ	$15a
spr4ctl	equ	$162
spr5ctl	equ	$16a
spr6ctl	equ	$172
spr7ctl	equ	$17a
spr0data equ	$144
spr1data equ	$14c
spr2data equ	$154
spr3data equ	$15c
spr4data equ	$164
spr5data equ	$16c
spr6data equ	$174
spr7data equ	$17c
spr0datb equ	$146
spr1datb equ	$14e
spr2datb equ	$156
spr3datb equ	$15e
spr4datb equ	$166
spr5datb equ	$16e
spr6datb equ	$176
spr7datb equ	$17e
color0	equ	$180
color1	equ	$182
color2	equ	$184
color4	equ	$188
color8	equ	$190
color16	equ	$1a0




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

screen.mem	dc.l	0

gfxbase		dc.l	0
old.ints	dc.w	0
old.level3	dc.l	0
old.dbz		dc.l	0
next.frame	dc.b	0,0




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

graf.name	dc.b	'graphics.library',0
		even




;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

sprite.null
	dc.w	0,0

colour.table
	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dc.w	$888,$999,$aaa,$bbb,$ccc,$ddd,$eee,$fff
	dc.w	$000,$558,$001,$012,$023,$003,$310,$850
	dc.w	$640,$740,$a72,$850,$a71,$d93,$fc5,$530
