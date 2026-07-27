  	section merry-xmas,code_c	; Put into chip memory
 	opt 	c-,o+,o3-		; No case sensitivity, Optimize on



	move.l 4.w,a6
	jsr -132(a6)			; CALLEXEC FORBID()

 	lea 	gfxlib,a1
 	moveq 	#0,d0
 	move.l  4.w,a6
 	jsr 	-$228(a6) 		; Open Graphics library
 	tst.l 	d0
 	beq 	error
 	move.l  D0,gfxbse

	move.l #deadptr,d0
	move.w d0,sk0l
	swap d0
	move.w d0,sk0h
					; generate snow-fields
	lea 	sprite0,a0	
	move.l 	#$2c002d00,d0		; first longword
	moveq 	#69,d1			; 60 sprites
spr0lp	swap	d0
	move.b 	$dff007,d2
	eor.b 	d2,d0
	swap 	d0
	
	mulu d3,d3	
	mulu d3,d3
	mulu d3,d3
	mulu d3,d3

	move.l d0,(a0)+
	move.l #$10000,(a0)+
	add.l #$02000200,d0	
	dbra d1,spr0lp	

	move.l #sprite0,d0
	move.w d0,sp0l
	swap d0
	move.w d0,sp0h

				
	lea 	sprite1,a0	
	move.l 	#$2d002e00,d0		; first longword
	moveq 	#69,d1			; 60 sprites
spr1lp	swap	d0
	move.b 	$dff007,d2
	eor.b 	d2,d0
	swap 	d0
	
	mulu d3,d3	
	mulu d3,d3
	mulu d3,d3
	mulu d3,d3

	move.l d0,(a0)+
	move.l #$10000,(a0)+
	add.l #$03000300,d0	
	dbra d1,spr1lp	

	move.l #sprite1,d0
	move.w d0,sp1l
	swap d0
	move.w d0,sp1h

	lea 	sprite2,a0	
	move.l 	#$2c002d00,d0		; first longword
	moveq 	#69,d1			; 60 sprites
spr2lp	swap	d0
	move.b 	$dff007,d2
	eor.b 	d2,d0
	swap 	d0
	
	mulu d3,d3	
	mulu d3,d3
	mulu d3,d3
	mulu d3,d3

	move.l d0,(a0)+
	move.l #$10001,(a0)+
	add.l #$04000400,d0	
	dbra d1,spr2lp	

	move.l #sprite2,d0
	move.w d0,sp2l
	swap d0
	move.w d0,sp2h

				
	lea 	sprite3,a0	
	move.l 	#$2c002d00,d0		; first longword
	moveq 	#69,d1			; 60 sprites
spr3lp	swap	d0
	move.b 	$dff007,d2
	eor.b 	d2,d0
	swap 	d0
	
	mulu d3,d3	
	mulu d3,d3
	mulu d3,d3
	mulu d3,d3

	move.l d0,(a0)+
	move.l #$10001,(a0)+
	add.l #$03000300,d0	
	dbra d1,spr3lp	

	move.l #sprite3,d0
	move.w d0,sp3l
	swap d0
	move.w d0,sp3h

	move.l #name+80,d0
 	move.w d0,bl0l
	swap	d0
	move.w d0,bl0h

 	move.l  #logo,d0		; Store screen address in
 	move.w  d0,pl0l			; Copper list
 	swap    d0
 	move.w  d0,pl0h
	swap	d0
	add.l 	#3920,d0
	move.w 	d0,pl1l
	swap	d0
	move.w	d0,pl1h
	swap 	d0
	add.l 	#3920,d0
	move.w 	d0,pl2l
	swap	d0
	move.w	d0,pl2h
	swap 	d0
	add.l 	#3920,d0
	move.w 	d0,pl3l
	swap	d0
	move.w	d0,pl3h
	swap 	d0
	add.l	#3920,d0

	
	lea topcols,a1
	move.l d0,a0
	move.w #$180,d0
	moveq #15,d1
toplp	move.w d0,(a1)+
	move.w (a0)+,(a1)+
	addq.w #2,d0
	dbra d1,toplp


	bsr mt_init

 
 	move.l  #piccy,d0		; Store screen address in
 	move.w  d0,mp0l			; Copper list
 	swap    d0
 	move.w  d0,mp0h
	swap	d0
	add.l 	#6440,d0
	move.w 	d0,mp1l
	swap	d0
	move.w	d0,mp1h
	swap 	d0
	add.l 	#6440,d0
	move.w 	d0,mp2l
	swap	d0
	move.w	d0,mp2h
	swap 	d0
	add.l 	#6440,d0
	move.w 	d0,mp3l
	swap	d0
	move.w	d0,mp3h
	swap 	d0
	add.l	#6440,d0
	move.w 	d0,mp4l
	swap 	d0
	move.w	d0,mp4h
	swap	d0
	add.l 	#6440,d0

	
	lea botcols,a1
	move.l d0,a0
	move.w #$180,d0
	moveq #31,d1
botlp	move.w d0,(a1)+
	move.w (a0)+,(a1)+
	addq.w #2,d0
	dbra d1,botlp

 	move.l  #first,d0		; Store screen address in
 	move.w  d0,zl0l			; Copper list
 	swap    d0
 	move.w  d0,zl0h
	swap	d0
	add.l 	#4200,d0
	move.w 	d0,zl1l
	swap	d0
	move.w	d0,zl1h
	swap 	d0
	add.l 	#4200,d0
	move.w 	d0,zl2l
	swap	d0
	move.w	d0,zl2h
	swap 	d0
	add.l 	#4200,d0
	move.w 	d0,zl3l
	swap	d0
	move.w	d0,zl3h
	swap 	d0
	add.l	#4200,d0
	move.w 	d0,zl4l
	swap 	d0
	move.w	d0,zl4h
	swap	d0
	add.l 	#4200,d0

	
	lea fcols,a1
	move.l d0,a0
	move.w #$180,d0
	moveq #31,d1
fotlp	move.w d0,(a1)+
	move.w (a0)+,(a1)+
	addq.w #2,d0
	dbra d1,fotlp

 	move.l  gfxbse,a6		; Set up copper list
 	add.l	#$32,a6
 	move.w  #$80,$dff096
 	move.l  (a6),oldcpr
 	move.l  #firstcr,(a6)
 	move.w  #$8080,$dff096
 	move.w  #$8010,$dff09a
 	move.l  $6c.w,old
	move.l  $6c.w,old2
	move.l  #new2,$6c.w

WAIT:	btst	#6,$bfe001		; Test for left mousebutton
 	bne.s 	wait


	; and heres a nice little cheat.

	moveq #4,d3
fadelp	

	
	move.w #8000,d6
pause	mulu d5,d5		; yes i know processor timings dont work in
				; faster machines, but do you really want
				; to run this demo on a 68030 amiga?????

	dbra d6,pause	
	
	
	lea fcols+2,a0
	moveq #31,d0
falp1	move.w (a0),d1
	lsr.w #1,d1
	and.w #%011101110111,d1
	move.w d1,(a0)
	addq.l #4,a0
	dbra d0,falp1
		
 	dbra d3,fadelp



	move.l gfxbse,a6
	add.l 	#$32,a6
 	move.l  #newcpr,(a6)
 	move.w  #$8080,$dff096
 	move.w  #$8010,$dff09a
 	move.l  #new,$6c.w

wait2 	btst #2,$dff016
	bne.s wait2






 	move.l  old,$6c.w		; Return to workbench
 	move.l  gfxbse,a6		; copper list
 	add.l	#$32,a6
 	move.w	#$0080,$dff096
 	move.l  oldcpr,(a6)
 	move.w  #$8080,$dff096
	
	move.l	gfxbse,a1		; Close graphics library
	move.l  $4.w,a6
	jsr 	-$19e(a6)
	bsr mt_end

error:  
	
	move.l 4.w,a6
	jsr -138(a6)			; CALLEXEC PERMIT()

	clr.l  d0			; exit routine
 	rts

new2:	movem.l d0-d7/a0-a6,-(sp)
	and.w	#$10,$dff01e
	beq.s	out2
	move.w	#$10,$dff09c

	bsr mt_music

out2:	movem.l (sp)+,d0-d7/a0-a6
 	dc.w 	$4ef9			; jsr instruction
old2: 	dc.l 	0			

new: 	movem.l d0-d7/a0-a6,-(sp)	; save all registers
 	and.w 	#$10,$dff01e        	; check if it is 
 	beq.s 	out
 	move.w 	#$10,$dff09c

	bsr starmov

	bsr.s scroll
	bsr mt_music


	bsr aniami

	bsr robin
	bsr snow1
	bsr sle1
	bsr flashit

	bsr barqual
out:	movem.l (sp)+,d0-d7/a0-a6
 	dc.w 	$4ef9			; jsr instruction
old: 	dc.l 	0			


prnchr: lea 	font,a0
	lea 	logo+40,a1			; destination
	sub.b 	#32,d0			; de-ascii
	mulu 	#512,d0			; find position in font
	add.l 	d0,a0
	moveq 	#3,d1
lp1	moveq 	#31,d2
	move.l 	a1,a2
lp2	move.l	(a0)+,(a2)
	add.l #44,a2
	dbra d2,lp2
	add.l #3920,a1
	dbra d1,lp1
	rts

SCROLL	cmp.b #0,scrlctd
	beq.s scrl2
	subq.b #1,scrlctd
	rts
scrl2	bsr.s blitscr
	move.b scrlptr,d0
	subq.b #1,d0
	beq.s zero
 	move.b d0,scrlptr
	rts
zero	move.b #8,scrlptr
	move.l txtptr,a0
	moveq #0,d0
	move.b (a0)+,d0
	cmp.b #0,d0
 	bne.s charok
	move.l #text,txtptr
	bra.s zero
charok	cmp.b #254,d0
	bne.s notpuse
	move.b #80,scrlctd
	move.l a0,txtptr
	moveq #32,d0
	bsr prnchr
	rts
notpuse move.l a0,txtptr
	bsr prnchr
	rts	



blitscr	
	moveq 	#3,d0
	lea 	logo,a0

blitlp	btst 	#6,$dff002
	bne.s 	blitlp
	move.l 	a0,$dff050
	move.l 	a0,a1
	subq.l 	#2,a1
	move.l 	a1,$dff054
	clr.l 	$dff064
	move.l 	#-1,$dff044
	move.w 	#%1101100111110000,$dff040
	clr.w	$dff042
	move.w	#22+33*64,$dff058
	add.l 	#3920,a0
	dbra d0,blitlp
blitfin	btst 	#6,$dff002
	bne.s	blitfin	
	rts




barqual	move.w chn1,d0	
	lsr.w #1,d0
	move.w d0,chn1

	move.w chn2,d0	
	lsr.w #1,d0
	move.w d0,chn2

	move.w chn3,d0	
	lsr.w #1,d0
	move.w d0,chn3

	move.w chn4,d0	
	lsr.w #1,d0
	move.w d0,chn4

	rts




starmov	bsr.s  	move0
	bsr.s 	move1
	bsr.s 	move2
	bsr 	move3
	rts

move0	lea sprite0+69*8,a0
	moveq #68,d0
	move.b 1(a0),saveval
mv0lp	move.b -7(a0),1(a0)
	subq.l #8,a0
	dbra d0,mv0lp
	move.b	saveval,d0
	move.b $dff007,d1
	eor.b d1,d0	
	move.b d0,1(a0)
	rts

move1	lea sprite1+69*8,a0
	moveq #68,d0
	move.b 1(a0),saveval
mv1lp	move.b -7(a0),1(a0)
	subq.l #8,a0
	dbra d0,mv1lp
	move.b	saveval,d0
	move.b $dff007,d1
	eor.b d1,d0	
	move.b d0,1(a0)
	rts


move2	lea sprite2+69*8,a0
	moveq #68,d0
	move.b 1(a0),saveval
mv2lp	move.b -7(a0),1(a0)
	subq.l #8,a0
	dbra d0,mv2lp
	move.b	saveval,d0
	move.b $dff007,d1
	eor.b d1,d0	
	move.b d0,1(a0)
	rts

move3	lea sprite3+69*8,a0
	moveq #68,d0
	move.b 1(a0),saveval
mv3lp	move.b -7(a0),1(a0)
	subq.l #8,a0
	dbra d0,mv3lp
	move.b	saveval,d0
	move.b $dff007,d1
	eor.b d1,d0	
	move.b d0,1(a0)
	rts




aniami	bchg #0,amion
	beq.s goami
	rts
goami
	move.b amiset,d0
	cmp.b #0,d0
	bne.s notfr1
	bra.s amifr1
notfr1	cmp.b #1,d0
	bne.s notfr2
	bra.s amifr2
notfr2	cmp.b #2,d0
	bne.s amifr4
	bra.s amifr3

amifr2  lea ami2,a0
 	bsr.s plami
	move.b #2,amiset
	rts
amifr3
	lea ami3,a0
	bsr.s plami
	move.b #3,amiset
	rts
amifr4
	lea ami4,a0
	bsr.s plami
	move.b #0,amiset
	rts

amifr1	lea ami1,a0


plami	lea piccy+20,a1
	moveq #4,d0		; 5 bitplanes
af1l1	move.l a1,a2		; keep a1 clean
	moveq #31,d1		; 32 lines
af1l2	move.l (a0)+,(a2)+	
	move.l (a0)+,(a2)	
	add.l #36,a2
	dbra d1,af1l2
	add.l #6440,a1
	dbra d0,af1l1
	move.b #1,amiset
	rts
	



robin	move.w chn1,d0
	cmp.w #%1111,d0
	beq.s robfr4
	cmp.b #%111,d0
 	beq.s robfr3
	cmp.b #%11,d0
	beq.s robfr2
	cmp.b #%1,d0
	beq.s robfr1
	rts

robfr1	lea rob1,a0
	bra.s robon
robfr2	lea rob2,a0
	bra.s robon
robfr3	lea rob3,a0
	bra.s robon
robfr4	lea rob4,a0


robon	lea piccy+8+40*23,a1
	moveq #4,d0		; 5 bitplanes
ro1l1	move.l a1,a2		; keep a1 clean
	moveq #31,d1		; 32 lines
ro1l2	move.l (a0)+,(a2)+	
	add.l #36,a2
	dbra d1,ro1l2
	add.l #6440,a1
	dbra d0,ro1l1
	rts




snow1	move.w chn3,d0
	cmp.w #%1111,d0
	beq.s sn1fr4
	cmp.b #%111,d0
 	beq.s sn1fr3
	cmp.b #%11,d0
	beq.s sn1fr2
	cmp.b #%1,d0
	beq.s sn1fr1
	rts

sn1fr1	lea sno1,a0
	bra.s sn1on
sn1fr2	lea sno2,a0
	bra.s sn1on
sn1fr3	lea sno3,a0
	bra.s sn1on
sn1fr4	lea sno4,a0


sn1on	lea piccy+4+40*74,a1
	moveq #4,d0		; 5 bitplanes
sn1l1	move.l a1,a2		; keep a1 clean
	moveq #31,d1		; 32 lines
sn1l2	move.w (a0)+,(a2)+	
	addq.l #2,a0
	add.l #38,a2
	dbra d1,sn1l2
	add.l #6440,a1
	dbra d0,sn1l1
	rts




sle1	move.w chn4,d0
	cmp.w #%1111,d0
	beq.s sl1fr4
	cmp.b #%111,d0
 	beq.s sl1fr3
	cmp.b #%11,d0
	beq.s sl1fr2
	cmp.b #%1,d0
	beq.s sl1fr1
	rts

sl1fr1	lea sley1,a0
	bra.s sl1on
sl1fr2	lea sley2,a0
	bra.s sl1on
sl1fr3	lea sley3,a0
	bra.s sl1on
sl1fr4	lea sley4,a0


sl1on	lea piccy+12+40*15,a1
	moveq #4,d0		; 5 bitplanes
sl1l1	move.l a1,a2		; keep a1 clean
	moveq #31,d1		; 32 lines
sl1l2	move.l (a0)+,(a2)+	
	add.l #36,a2
	dbra d1,sl1l2
	add.l #6440,a1
	dbra d0,sl1l1
	rts




flashit	move.l flashptr,a0
	move.w (a0)+,d0
	cmp.w #$ffff,d0
	bne.s flash2
	move.l #flashdata,flashptr
	bra.s flashit
flash2	move.l a0,flashptr
	move.w d0,flcol
	rts




amion dc.b 0
amiset	dc.b	0
saveval	dc.b 	0
scrlptr	dc.b	6
scrlctd	dc.b	0
	even
txtptr	dc.l 	text
text	dc.b 	"                         IT'S CHRISTMAS TIME AND TIME FOR A FAIRLY SEASONAL AMIGA COMPUTING DEMO. "
	DC.B 	" THIS DEMO EVOLVED IN THE PRESENCE OF JOLYON RALPH. THE NICE PICCY BELOW WAS"
	DC.B	" DRAWN BY RUSSEL WARK AND HE ALSO DREW THIS FONT.  "
	dc.b    " FIRSTLY I "
	DC.B 	"MUST APOLOGISE TO MY FAN FOR NOT DOING A DEMO LAST MONTH, BUT THINGS GOT TOO BUSY! SORRY! "
	dc.b 	"     SPECIAL MESSAGES AND ADVERTISMENTS....  HAVE YOU GOT A MODEM? PHONE THE BEST BBS IN THE WHOLE "
	DC.B 	"WORLD,          MAX!     ",254,"  PHONE MAX ON (0905) 52536/56610/57822/754127/754151 NOW!   ALL SPEEDS FROM 300 BAUD (SLOOOOOOW) "
	DC.B 	"TO MEGA-SUPER-DOOPER FAST 19.2K BAUD WITH HST AND MNP LEVEL 5 ERROR CORRECTION (LOG ON AND SAY - I SAW THIS ADVERT "
	DC.B 	" GET ON AND BOOGY DOWN TO THE HOTTEST BOARD THIS SIDE OF THE UKRAINE. "
	dc.b 	" SORRY TO MARK FOR FORGETTING YOU IN THE LAST DEMO. ERM. SORRY I'VE FORGOTTEN WHAT YOU ASKED ME TO SAY.  PERHAPS "
	DC.B 	"THE NEXT ONE.  " 
	DC.B 	"   MESSAGE TO ALL YOU ST OWNERS OUT THERE...  THE SECRET IS TO BANG THE ROCKS TOGETHER...    "
	DC.B 	"OH YES, THE CREDITS... CODE CODED BY THE ONE AND ONLY (EXCEPT FOR ALL THE OTHERS) ---- JOLYON RALPH ----   "
	DC.B 	"AND NOW IT'S MY GOOD OLE BUDDY ---- RUSS WARK ---- WRITING INTO THE ETHER..  WATCH OUT FOR HIS WEIRD CARTOONS IN THE MAGAZINE - SMUT - "

	dc.b	" HI THIS IS RUSS HERE.  I DREW ALL THE GRAPHICS FOR THIS GREAT DEMO, AND I'M ALWAYS AVAILABLE FOR OTHER GRAPHIC WORK. "
	DC.B	"JUST A FEW PERSONAL GREETS: HI TO... NADEEM (FLASH GIT), DEREK LEIGH-GILCHRIST (SEE YOU SOON), KEVIN COLLIER (TOO LATE FOR AN XMAS TUNE NOW), "
	DC.B 	"STEVE HOGG (HOWAY MAN! YA GEET GEORDIE!!!), ADAM LUCAS (HAVE YOU HAD ANOTHER HAIRCUT YET?), RICHARD APLIN (THE LAST ONE TO THE 'OFFY IS A WOMAN!! OH, AND "
	DC.B 	"DOUBLE DRAGON II LOOKS CANNY...), JOBY WOOD (DON'T FALL ASLEEP AT THE COMMODORE SHOW), GARETH (I WANNA SEE YOUR PARTY TRICKS...)   (YUUUK. THEY'RE DISGUSTING!  - JOLYON) "
	DC.B	"RASIKA (I WOULDN'T MIND MY VIDEO BACK SOMETIME...)  (AND MINE! - JOLYON). HELLO TO EVERYONE AT CROYDON COLLEGE (SELHURST CENTRE)... "
	DC.B 	" AND A REMINDER TO...    TIM      YOU OWE ME FIVE DISKS FROM A YEAR AGO. PAY UP OR DIE!!!!!    "
	DC.B 	" WELL DONE TO RED SECTOR FOR THE BEST MEGADEMO SO FAR.. IT WAS AWESOME...       TOMAS DAHLGREN - YOUR MUSIC IS MEGA     "
	DC.B 	" MESSAGE TO MATTIAS - TRY NOT TO HAVE TOO MANY MORE 3000 POUND PHONEBILLS!   "
	DC.B	" GOODBYE AND SO LONG - RUSS...    "
	DC.B    "  OK ITS JOLYON BACK ON THE KEYS... "

 dc.b 	"FIRST A MESSAGE TO ALL YOU BORING OS PROGRAMMERS OUT THERE "
 dc.b 	"  DON'T COMPLAIN AT ME IF YOU DON'T LIKE MY CODE. I CODE FOR FUN "
 DC.B	" IF COMMODORE FINALLY RELEASE A BUG-FREE OS THAT'S FAST ENOUGH TO USE THEN "
 DC.B 	"I'LL USE IT (WE DON'T RE-INVENT THE WHEEL FOR FUN YOU KNOW, WE WRITE OUR OWN LINE "
 DC.B 	"ROUTINES, SCREEN ROUTINES, ETC BECAUSE THE ROM ROUTINES ARE SO SLOW!)  "
 DC.B	"I DON'T LIKE THE IDEA OF SOMEONE TELLING ME WHICH WAY TO WRITE MY CODE. I'LL WRITE IT HOWEVER I LIKE, AND I LIKE HITTING THE HARDWARE "
 DC.B 	"  DAVE PARKINSON - IF YOU REALLY THINK YOU COULD WRITE A FAST ARCADE GAME WITH MULTITASKING "
 DC.B 	"THEN GO AHEAD AND WRITE ONE, I'LL GUARANTEE IT WILL BE A PILE OF JUNK. CAN YOU SERIOUSLY TELL US "
 DC.B	"THAT THE AMIGA'S MULTITASKING CAN LOAD IN GRAPHICS FOR THE NEXT LEVEL WHILE THE GAME IS PLAYING. "
 DC.B	"IF YOU'VE GOT ENOUGH RASTER TIME LEFT TO DO THAT, THE GAME MUST BE REAL CRAP!    FOR FAST ARCADE GAMES "
 DC.B	"YOU MUST DITCH THE OS. NO QUESTION.    OK?   "

 DC.B 	"ONE FINAL CUTTING COMMENT...  IF YOU HAD DITCHED MULTITASKING IN BBC EMULATOR IT WOULD HAVE BEEN MUCH EASIER "
 DC.B	"FOR YOU TO MAKE THE EMULATOR READ BBC FORMAT DISKS, MAKING YOUR BBC EMULATOR ACTUALLY RATHER USEFUL. "

 dc.b "AND NOW I WILL TELL YOU THE REAL SECRETS OF PROGRAMMING THIS "
 dc.b "WONDERFUL MACHINE, THE SORT OF FACTS THAT NOT EVEN MY ARTICLES "
 dc.b "COULD EXPOSE. FIRSTLY. LEARN TO USE 68000 WELL. LEARN THE INSTRUCTIONS VERY WELL. TRY USING MOVE.W, IT'S A VERY NICE INSTRUCTION "
 dc.b "(MY FAVOURITE). REGISTERS ARE USEFUL TOO. A0 AND D0 ARE MY PERSONAL FAVOURITES, ALTHOUGH I QUITE LIKE D1 TOO. DON`T TOUCH THE "
 dc.b "STACK WITH A BARGE POLE, AND IF YOU DO TOUCH IT WITH A BARGE "
 dc.b "POLE, REMEMBER TO REMOVE THE POLE BEFORE YOU EXIT. IF YOU EVER RUN OUT OF REGISTERS, REMEMBER "
 dc.b "THAT YOU MAY HAVE TO USE SOME OF THEM TWICE. IT WAS VERY THOUGHTLESS OF MOTOROLA TO GIVE US A CHIP THAT COULD ACCESS 16 MEGABYTES "
 dc.b "BUT ONLY TO GIVE US A HANDFULL OF REGISTERS TO ACCESS IT. "
 dc.b "REMEMBER THAT ASSEMBLING YOUR FILE BEFORE EXECUTION IS THE NORM "
 dc.b "NOWDAYS.     AND NOW A SHORT WORD FROM MY GOOD FRIEND RUSS... "
 dc.b "    HI.    YES RUSS, THAT WAS A VERY SHORT WORD. WELL DONE. AND "
 dc.b "COMING UP NOW SOME SPECIAL MESSAGES.... HEY DEREK, IGNORE "
 dc.b "THE REVIEWS, I THOUGHT YOUR GAME (BATTLE VALLEY) WAS VERY GOOD. "
 dc.b "TO MARK IN BELFAST. I HOPE "
 dc.b "THE CGA CARD WORKED. THANKS FOR ALL YOUR HELP. TO JON "
 dc.b "OF MAX. SORRY `BOUT THE OTHER DEMOS, HOPE THIS ADVERT MAKES UP "
 dc.b "FOR IT ALL... TO STEVE.... MONEY SOON I PROMISE.... TO "
 dc.b "KEVIN.... SMART MUSIC DESERVES A SMART MUSICDEMO. I`LL SEE WHAT I "
 dc.b "CAN CONJURE UP... TO DAVE FROM 17 BIT. WHY HAVEN`T I HEARD FROM "
 dc.b "YOU IN SUCH A LONG TIME? TO MY SISTER. LOOK AT ALL THE TROUBLE "
 dc.b "YOUR SPURIOUS COMMENTS ABOUT POLAND CAUSED. THE WHOLE EASTERN "
 dc.b "BLOCK IS NOW IN TURMOIL DUE TO YOUR INSENSITIVE REMARKS. TO "
 dc.b "MY CATS. MEEEOOOWW. AND NOW ANOTHER FREE (ERHM. DONATIONS "
 dc.b "WELCOME) ADVERTISMENT: THE BEST COMPUTER SHOP IN THE WHOLE "
 dc.b "WORLD. NOT ONLY DO THEY SELL CHEAP COMPUTER HARDWARE AND SOFTWARE, BUT EVERY PURCHASE BRINGS THE CUSTOMER 5 YEARS GOOD LUCK "
 dc.b "AND GUARANTEED PROTECTION FROM ALL KNOWN VAMPIRES. WHO AM I "
 dc.b "TALKING ABOUT? SABRE COMPUTER CENTRE, IN-SHOPS, CROYDON. ASK "
 dc.b "FOR TONY, AND SAY ""I`VE BEEN STUPID ENOUGH TO READ ALL THE SCROLLY "
 dc.b "MESSAGE IN THAT BORING AMIGA COMPUTING CHRISTMAS DEMO AND I SAW THE ADVERT AND CAME TO YOUR SHOP"", AND YOU'LL GET A MASSIVE "
 dc.b "0.5% DISCOUNT ON ANY PURCHASE OVER 4000 QUID. "
 dc.b "   SERIOUSLY NOW, SEE TONY IF YOU WANT A GOOD DEAL.    OH, AND TONY,  THANKS FOR LENDING ME THE ARCHIMEDES, I STILL THINK "
 DC.B "THE AMIGA IS A NICER COMPUTER  (MAY NOT BE AS FAST, BUT IT'S A LOT MORE FUN TO PLAY WITH)....   "
 DC.B "  OH WELL, I'VE RUN OUT OF THINGS TO SAY AGAIN.   PERHAPS WE WILL MEET AGAIN IN SOME DISTANT SCROLLY-MESSAGE, PERHAPS NOT. "
 DC.B " WELL, FOR THE MOMENT, IT'S JOLYON RALPH SAYING.   BYEBYE AND HAVE FUN KIDDIES....       ",0




deadptr dc.l	0			; kill da pointer

oldcpr: dc.l	0			; Workbench copperlist

firstcr	dc.w 	$100,$4200,$102,$0,$104,0,$108,0,$10a,0
 	dc.w 	$92,$38,$94,$d0,$8e,$7081,$90,$d4c1,$e0
zl0h: 	dc.w	0,$e2
zl0l: 	dc.w	0,$e4
zl1h: 	dc.w 	0,$e6
zl1l: 	dc.w	0,$e8
zl2h:	dc.w	0,$ea
zl2l: 	dc.w	0,$ec
zl3h:	dc.w	0,$ee	
zl3l:	dc.w	0,$f0
zl4h:	dc.w	0,$f2
zl4l:	dc.w 	0,$120
sk0h:	dc.w	0,$122
sk0l:	dc.w	0
fcols	ds.w	64
	dc.w 	$9c,$8010,$ffff,$fffe

	
newcpr:	dc.w 	$100,$4200,$102,$0,$104,0,$108,4,$10a,4
 	dc.w 	$92,$38,$94,$d0,$8e,$2c81,$90,$2cc1,$e0
pl0h: 	dc.w	0,$e2
pl0l: 	dc.w	0,$e4
pl1h: 	dc.w 	0,$e6
pl1l: 	dc.w	0,$e8
pl2h:	dc.w	0,$ea
pl2l: 	dc.w	0,$ec
pl3h:	dc.w	0,$ee	
pl3l:	dc.w	0,$120
sp0h:	dc.w	0,$122
sp0l:	dc.w	0,$124
sp1h:	dc.w	0,$126
sp1l:	dc.w	0,$128
sp2h:	dc.w	0,$12a
sp2l:	dc.w	0,$12c
sp3h:	dc.w	0,$12e
sp3l:	dc.w	0

topcols	ds.w	32
	dc.w	$180,0,$182,0


	dc.w $3009,$fffe,$186,$1
	dc.w $3109,$fffe,$186,$2
	dc.w $3209,$fffe,$186,$3
	dc.w $3309,$fffe,$186,$4
	dc.w $3409,$fffe,$186,$5
	dc.w $3509,$fffe,$186,$6
	dc.w $3609,$fffe,$186,$7
	dc.w $3709,$fffe,$186,$8
	dc.w $3809,$fffe,$186,$9
	dc.w $3909,$fffe,$186,$a

	dc.w $4109,$fffe,$186,$1a
	dc.w $4209,$fffe,$186,$3a
	dc.w $4309,$fffe,$186,$4a
	dc.w $4409,$fffe,$186,$5a
	dc.w $4509,$fffe,$186,$6a
	dc.w $4609,$fffe,$186,$7a
	dc.w $4709,$fffe,$186,$8a
	dc.w $4809,$fffe,$186,$9a
	dc.w $4909,$fffe,$186,$aa


	dc.w $7709,$fffe,$108,0,$10a,0,$104,%100100

	dc.w $7809,$fffe,$100,$5200
	dc.w $e0
mp0h	dc.w 0,$e2
mp0l	dc.w 0,$e4
mp1h	dc.w 0,$e6
mp1l 	dc.w 0,$e8
mp2h	dc.w 0,$ea
mp2l	dc.w 0,$ec
mp3h	dc.w 0,$ee
mp3l	dc.w 0,$f0
mp4h	dc.w 0,$f2
mp4l	dc.w 0
botcols	ds.w	64



	dc.w $f009,$fffe
	dc.w $ffdf,$fffe

	dc.w $1609,$fffe,$100,$1200,$e0
bl0h	dc.w	0,$e2
bl0l	dc.w	0,$182
flcol	dc.w	0
	
	dc.w $1709,$fffe,$180,$1,$9c,$8010
	dc.w $1809,$fffe,$180,$1
	dc.w $1909,$fffe,$180,$2
	dc.w $1a09,$fffe,$180,$2
	dc.w $1b09,$fffe,$180,$3
	dc.w $1c09,$fffe,$180,$3
	dc.w $1d09,$fffe,$180,$4
	dc.w $1e09,$fffe,$180,$5
	dc.w $1f09,$fffe,$180,$6
	dc.w $2009,$fffe,$180,$7
	dc.w $2109,$fffe,$180,$9
	dc.w $2209,$fffe,$180,$b
	dc.w $2309,$fffe,$180,$9
	dc.w $2409,$fffe,$180,$7
	dc.w $2509,$fffe,$180,$6
	dc.w $2609,$fffe,$180,$5
	dc.w $2709,$fffe,$180,$4
	dc.w $2809,$fffe,$180,$3
	dc.w $2909,$fffe,$180,$3
	dc.w $2a09,$fffe,$180,$2
	dc.w $2b09,$fffe,$180,$2
	dc.w $2c09,$fffe,$180,$1

  	dc.w $ffff,$fffe 		; End copper




gfxlib: dc.b 	"graphics.library",0	; library name
					; yes I know you can use
					; the cop2ptr for your
					; copperlist and return
					; to cop1ptr for workbench
					; but this is so neat.


flashdata ds.w 400
	dc.w $444,$888,$ccc,$fff,$eee,$ddd,$ccc,$bbb
	dc.w $aaa,$999,$888,$777,$666,$555,$444,$333
	dc.w $222,$111,$000,$ffff



flashptr dc.l flashdata

gfxbse: dc.l 0	



chn1 dc.w 0
chn2 dc.w 0
chn3 dc.w 0
chn4 dc.w 0
eq1p dc.w 381
eq2p dc.w 381
eq3p dc.w 381
eq4p dc.w 381
eqtab dcb.w 40



mt_init:lea	mt_data,a0
	add.l	#$03b8,a0
	moveq	#$7f,d0
	moveq	#0,d1
mt_init1:
	move.l	d1,d2
	subq.w	#1,d0
mt_init2:
	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	mt_init1
	dbf	d0,mt_init2
	addq.b	#1,d2

mt_init3:
	lea	mt_data,a0
	lea	mt_sample1(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$438,d2
	add.l	a0,d2
	moveq	#$1e,d0
mt_init4:
	move.l	d2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,d2
	add.l	#$1e,a0
	dbf	d0,mt_init4

	lea	mt_sample1(PC),a0
	moveq	#0,d0
mt_clear:
	move.l	(a0,d0.w),a1
	clr.l	(a1)
	addq.w	#4,d0
	cmp.w	#$7c,d0
	bne.s	mt_clear

	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.l	mt_partnrplay
	clr.l	mt_partnote
	clr.l	mt_partpoint

	move.b	mt_data+$3b6,mt_maxpart+1
	rts

; call 'mt_end' to switch the sound off

mt_end:	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

; the playroutine - call this every frame

mt_music:
	addq.w	#1,mt_counter
mt_cool:cmp.w	#6,mt_counter
	bne.s	mt_notsix
	clr.w	mt_counter
	bra	mt_rout2

mt_notsix:
	lea	mt_aud1temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp1
	lea	$dff0a0,a5		
	bsr.s	mt_arprout
mt_arp1:lea	mt_aud2temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp2
	lea	$dff0b0,a5
	bsr.s	mt_arprout
mt_arp2:lea	mt_aud3temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp3
	lea	$dff0c0,a5
	bsr.s	mt_arprout
mt_arp3:lea	mt_aud4temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp4
	lea	$dff0d0,a5
	bra.s	mt_arprout
mt_arp4:rts

mt_arprout:
	move.b	2(a6),d0
	and.b	#$0f,d0
	tst.b	d0
	beq	mt_arpegrt
	cmp.b	#$01,d0
	beq.s	mt_portup
	cmp.b	#$02,d0
	beq.s	mt_portdwn
	cmp.b	#$0a,d0
	beq.s	mt_volslide
	rts

mt_portup:
	moveq	#0,d0
	move.b	3(a6),d0
	sub.w	d0,22(a6)
	cmp.w	#$71,22(a6)
	bpl.s	mt_ok1
	move.w	#$71,22(a6)
mt_ok1:	move.w	22(a6),6(a5)
	rts

mt_portdwn:
	moveq	#0,d0
	move.b	3(a6),d0
	add.w	d0,22(a6)
	cmp.w	#$538,22(a6)
	bmi.s	mt_ok2
	move.w	#$538,22(a6)
mt_ok2:	move.w	22(a6),6(a5)
	rts

mt_volslide:
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldwn
	add.w	d0,18(a6)
	cmp.w	#64,18(a6)
	bmi.s	mt_ok3
	move.w	#64,18(a6)
mt_ok3:	move.w	18(a6),8(a5)
	rts
mt_voldwn:
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	sub.w	d0,18(a6)
	bpl.s	mt_ok4
	clr.w	18(a6)
mt_ok4:	move.w	18(a6),8(a5)
	rts

mt_arpegrt:
	move.w	mt_counter(PC),d0
	cmp.w	#1,d0
	beq.s	mt_loop2
	cmp.w	#2,d0
	beq.s	mt_loop3
	cmp.w	#3,d0
	beq.s	mt_loop4
	cmp.w	#4,d0
	beq.s	mt_loop2
	cmp.w	#5,d0
	beq.s	mt_loop3
	rts

mt_loop2:
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_cont
mt_loop3:
	moveq	#$00,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	bra.s	mt_cont
mt_loop4:
	move.w	16(a6),d2
	bra.s	mt_endpart
mt_cont:
	add.w	d0,d0
	moveq	#0,d1
	move.w	16(a6),d1
	and.w	#$fff,d1
	lea	mt_arpeggio(PC),a0
mt_loop5:
	move.w	(a0,d0),d2
	cmp.w	(a0),d1
	beq.s	mt_endpart
	addq.l	#2,a0
	bra.s	mt_loop5
mt_endpart:
	move.w	d2,6(a5)
	rts

mt_rout2:
	lea	mt_data,a0
	move.l	a0,a3
	add.l	#$0c,a3
	move.l	a0,a2
	add.l	#$3b8,a2
	add.l	#$43c,a0
	move.l	mt_partnrplay(PC),d0
	moveq	#0,d1
	move.b	(a2,d0),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.l	mt_partnote(PC),d1
	move.l	d1,mt_partpoint
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_aud1temp(PC),a6
	bsr	mt_playit
	lea	$dff0b0,a5
	lea	mt_aud2temp(PC),a6
	bsr	mt_playit
	lea	$dff0c0,a5
	lea	mt_aud3temp(PC),a6
	bsr	mt_playit
	lea	$dff0d0,a5
	lea	mt_aud4temp(PC),a6
	bsr	mt_playit
	move.w	#$01f4,d0
mt_rls:	dbf	d0,mt_rls

	move.w	#$8000,d0
	or.w	mt_dmacon,d0
	move.w	d0,$dff096

	lea	mt_aud4temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice3
	move.l	10(a6),$dff0d0

	move.w (a6),eq4p
	cmp.w #0,(a6)
	beq.s noplus4
	move.w #$f,chn4
noplus4



	move.w	#1,$dff0d4
mt_voice3:
	lea	mt_aud3temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice2
	move.l	10(a6),$dff0c0

	move.w (a6),eq3p
	cmp.w #0,(a6)
	beq.s noplus3
	move.w #$f,chn3
noplus3
	move.w	#1,$dff0c4
mt_voice2:
	lea	mt_aud2temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice1
	move.l	10(a6),$dff0b0

	move.w (a6),eq2p
	cmp.w #0,(a6)
	beq.s noplus2
	move.w #$f,chn2
noplus2


	move.w	#1,$dff0b4
mt_voice1:
	lea	mt_aud1temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice0
	move.l	10(a6),$dff0a0
	move.w (a6),eq1p
	cmp.w #0,(a6)
	beq.s noplus1
	move.w #$f,chn1
noplus1

	move.w	#1,$dff0a4
mt_voice0:
	move.l	mt_partnote(PC),d0
	add.l	#$10,d0
	move.l	d0,mt_partnote
	cmp.l	#$400,d0
	bne.s	mt_stop
mt_higher:
	clr.l	mt_partnote
	addq.l	#1,mt_partnrplay
	moveq	#0,d0
	move.w	mt_maxpart(PC),d0
	move.l	mt_partnrplay(PC),d1
	cmp.l	d0,d1
	bne.s	mt_stop
	clr.l	mt_partnrplay
;	st	Pflag
mt_stop:tst.w	mt_status
	beq.s	mt_stop2
	clr.w	mt_status
	bra.s	mt_higher
mt_stop2:
	rts

mt_playit:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2

	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_nosamplechange

	moveq	#0,d3
	lea	mt_samples(PC),a1
	move.l	d2,d4
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2),4(a6)
	move.w	(a3,d4.l),8(a6)
	move.w	2(a3,d4.l),18(a6)
	move.w	4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_displace
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,4(a6)
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),8(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
	bra.s	mt_nosamplechange

mt_displace:
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
mt_nosamplechange:
	move.w	(a6),d0
	and.w	#$fff,d0
	tst.w	d0
	beq.s	mt_retrout
	move.w	(a6),16(a6)
	move.w	20(a6),$dff096
	move.l	4(a6),(a5)
	move.w	8(a6),4(a5)
	move.w	(a6),d0
	and.w	#$fff,d0
	move.w	d0,6(a5)
	move.w	20(a6),d0
	or.w	d0,mt_dmacon

mt_retrout:
	tst.w	(a6)
	beq.s	mt_nonewper
	move.w	(a6),22(a6)

mt_nonewper:
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$0b,d0
	beq.s	mt_posjmp
	cmp.b	#$0c,d0
	beq.s	mt_setvol
	cmp.b	#$0d,d0
	beq.s	mt_break
	cmp.b	#$0e,d0
	beq.s	mt_setfil
	cmp.b	#$0f,d0
	beq.s	mt_setspeed
	rts

mt_posjmp:
	not.w	mt_status
	moveq	#0,d0
	move.b	3(a6),d0
	subq.b	#1,d0
	move.l	d0,mt_partnrplay
	rts

mt_setvol:
	move.b	3(a6),8(a5)
	rts

mt_break:
	not.w	mt_status
	rts

mt_setfil:
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#1,d0
	rol.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_setspeed:
	move.b	3(a6),d0
	and.b	#$0f,d0
	beq.s	mt_back
	clr.w	mt_counter
	move.b	d0,mt_cool+3
mt_back:rts

mt_aud1temp:
	dcb.w	10,0
	dc.w	1
	dcb.w	2,0
mt_aud2temp:
	dcb.w	10,0
	dc.w	2
	dcb.w	2,0
mt_aud3temp:
	dcb.w	10,0
	dc.w	4
	dcb.w	2,0
mt_aud4temp:
	dcb.w	10,0
	dc.w	8
	dcb.w	2,0

mt_partnote:	dc.l	0
mt_partnrplay:	dc.l	0
mt_counter:	dc.w	0
mt_partpoint:	dc.l	0
mt_samples:	dc.l	0
mt_sample1:	dcb.l	31,0
mt_maxpart:	dc.w	0
mt_dmacon:	dc.w	0
mt_status:	dc.w	0

mt_arpeggio:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
	dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
	dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
	dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
	dc.w $008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000


notetable:	dc.w	856,808,762,720,678,640,604,570
		dc.w	538,508,480,453,428,404,381,360
		dc.w	339,320,302,285,269,254,240,226  
		dc.w	214,202,190,180,170,160,151,143
		dc.w	135,127,120,113,000


mt_data	incbin modules/MOD.grymg2




sprite0	ds.l 2*70
sprite1	ds.l 2*70
sprite2 ds.l 2*70
sprite3 ds.l 2*70

logo	ds.b 15712-32
	dc.w 0,$fff,$eee,$ddd,$ccc,$bbb,$aaa,$999,$888,$777
	dc.w $666,$555,$444,$333,$222,$111


font 	ds.b	512
	incbin graphics_data/font2 


piccy	incbin graphics_data/snowbot


ami1	incbin graphics_data/amiga1
ami2	incbin graphics_data/amiga2
ami3	incbin graphics_data/amiga3
ami4	incbin graphics_data/amiga4

rob1	incbin graphics_data/robin1
rob2	incbin graphics_data/robin2
rob3	incbin graphics_data/robin3
rob4	incbin graphics_data/robin4

sno1	incbin graphics_data/snowman1
sno2	incbin graphics_data/snowman2
sno3	incbin graphics_data/snowman3
sno4	incbin graphics_data/snowman4

sley1	incbin graphics_data/sleigh1
sley2	incbin graphics_data/sleigh2
sley3	incbin graphics_data/sleigh3
sley4	incbin graphics_data/sleigh4

name	incbin graphics_data/amigacompname

first	incbin graphics_data/amigalogo5
