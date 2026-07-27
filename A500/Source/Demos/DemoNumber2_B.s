
*** DEMO NUMBER TWO BY DANIEL VERNON ***
*** ALTERNATE VERSION 1.1   DATE: 27-2-90 ***
*** FULL SCREEN, 4 LAYER SPRITE STARFIELD AND MOUSE POINTER ***
*** BOTTOM SCROLLING MESSAGE ***

	section dan,code_c
	opt c-

start	bset	#1,$bfe001	low pass filter off

	move.l	4.w,a6
	jsr	-132(a6)	turn off multitasking

	move.w	#$01e0,$dff096	DMA off

	move.l	#top,d0		set up bitplanes
	move.w	d0,bp1l1
	swap	d0
	move.w	d0,bp1h1
	swap	d0
	add.l	#11264,d0

	move.w	d0,bp2l1
	swap	d0
	move.w	d0,bp2h1
	swap	d0
	add.l	#11264,d0

	move.w	d0,bp3l1
	swap	d0
	move.w	d0,bp3h1
	swap	d0
	add.l	#11264,d0

	move.w	d0,bp4l1
	swap	d0
	move.w	d0,bp4h1
	swap	d0
	add.l	#11264,d0

	move.l	d0,a0		initialise colours
	lea	colours1(pc),a1
	move.w	#color0,d1
	moveq	#15,d0
nextc1	move.w	d1,(a1)+
	add.w	#2,d1
	move.w	(a0)+,(a1)+
	dbra	d0,nextc1


;""""""""""""""""""""""""""""""""""""""""""""
;	MAKE SPRITES FOR STARFIELD
;

;sprite2
	move.l	#sprite2,a0
	bsr	spricol1
;sprite3
	move.l	#sprite3,a0
	bsr	spricol2
;sprite4
	move.l	#sprite4,a0
	bsr	spricol1
;sprite5
	move.l	#sprite5,a0
	bsr	spricol2
	jmp	set

spricol1
	moveq	#26,d0		27 sprites
	move.l	#$2c002d00,d1	start = $2c, height = 1
spc11
	move.l	d1,(a0)+
	move.l	#$80000000,(a0)+	%1000000000000000 0000000000000000
	add.l	#$08000800,d1	update position (8 pixels lower)
	swap	d1
	move.b	$dff007,d2
	eor.b	d2,d1
	swap	d1
	dbf	d0,spc11
	moveq	#4,d0		5 sprites
	move.l	#$4000506,d1	start = $4+256 = 260, height = 1
spc12
	move.l	d1,(a0)+
	move.l	#$80000000,(a0)+	%1000000000000000 0000000000000000
	add.l	#$08000800,d1	update position (8 pixels lower)
	swap	d1
	move.b	$dff007,d2
	eor.b	d2,d1
	swap	d1
	dbf	d0,spc12
	rts


spricol2
	moveq	#26,d0		27 sprites
	move.l	#$2c002d00,d1	start = $2c, height = 1
spc21
	move.l	d1,(a0)+
	move.l	#$8000,(a0)+	%0000000000000000 1000000000000000
	add.l	#$08000800,d1	update position (8 pixels lower)
	swap	d1
	move.b	$dff007,d2
	eor.b	d2,d1
	swap	d1
	dbf	d0,spc21
	moveq	#4,d0		5 sprites
	move.l	#$4000506,d1	start = $4+256 = 260, height = 1
spc22
	move.l	d1,(a0)+
	move.l	#$8000,(a0)+	%0000000000000000 1000000000000000
	add.l	#$08000800,d1	update position (8 pixels lower)
	swap	d1
	move.b	$dff007,d2
	eor.b	d2,d1
	swap	d1
	dbf	d0,spc22
	rts


;"""""""""""""""""""""""""""""""""""""""""""""
;	SET UP SPRITE POINTERS
;
set	move.l	#sprite1,d0
	move.w	d0,sp1l
	swap	d0
	move.w	d0,sp1h
	move.l	#sprite2,d0
	move.w	d0,sp2l
	swap	d0
	move.w	d0,sp2h
	move.l	#sprite3,d0
	move.w	d0,sp3l
	swap	d0
	move.w	d0,sp3h
	move.l	#sprite4,d0
	move.w	d0,sp4l
	swap	d0
	move.w	d0,sp4h
	move.l	#sprite5,d0
	move.w	d0,sp5l
	swap	d0
	move.w	d0,sp5h
	move.l	#sprite6,d0
	move.w	d0,sp6l
	swap	d0
	move.w	d0,sp6h
	move.l	#sprite7,d0
	move.w	d0,sp7l
	swap	d0
	move.w	d0,sp7h


;""""""""""""""""""""""""""""""""""""""""""""
;	SET THE NEW COPPER LOCATION

	lea	$dff000,a5

	move.l	4.w,a6
	lea	grafname(pc),a1
	moveq	#0,d0
	jsr	-552(a6)	openlibrary
	tst.l	d0
	beq	end
	move.l	d0,gfxbase

	move.l	gfxbase,a6
	add.l	#$32,a6
	move.w	#$80,$dff096
	move.l	(a6),oldcopper
	move.l	#new,(a6)
	move.w	#$81e0,dmacon(a5)	DMA on (bitplane, copper,
;						blitter, sprite)


;"""""""""""""""""""""""""""""""""
;" SET UP INTERRUPT FROM COPPER  "
;"				 "
;"""""""""""""""""""""""""""""""""
	move.w	#$8010,intena(a5)
	move.l	$6c,old
	move.l	#copint,$6c


;""""""""""""""""""""""""""""""""""""""""
;	LOOP TO TEST MOUSE BUTTON

loop	btst	#6,$bfe001
	bne.s	loop

	move.l	old,$6c
	move.l	#$10,intena(a5)
	move.l	gfxbase,a6
	add.l	#$32,a6
	move.w	#$80,dmacon(a5)
	move.l	oldcopper,(a6)
	move.w	#$8080,dmacon(a5)
	move.l	gfxbase,a1
	move.l	4.w,a6
	jsr	-414(a6)	closelibrary
end
	move.l	4.w,a6
	jsr	-138(a6)	turn on multitasking

	move.w	#$f,dmacon(a5)		sound off
	clr.w	aud0vol(a5)
	clr.w	aud1vol(a5)
	clr.w	aud2vol(a5)
	clr.w	aud3vol(a5)
	bclr	#1,$bfe001	low pass filter on
	moveq.l	#0,d0
	rts


;interrupt routine

copint	movem.l	d0-d7/a0-a6,-(sp)
	and	#$10,intreqr(a5)
	beq	out
	move.w	#$10,intreq(a5)

	btst	#7,$bfe001
	beq	out

	bsr	starfield
	bsr	scroll

out	movem.l	(sp)+,d0-d7/a0-a6
	dc.w	$4ef9		jump to old interrupt routine
old	dc.l	0

gfxbase	dc.l	0


;""""""""""""""""""""""""""""""""""""""""
;	" INTERRUPT ROUTINES "
;	"		     "
;	""""""""""""""""""""""

starfield
;sprite2
	moveq	#31,d0		32 sprites
	move.l	#sprite2,a1
update2
	addq.b	#2,1(a1)	4 pixels
	add.l	#8,a1		next sprite
	dbf	d0,update2


;sprite3
	moveq	#31,d0		32 sprites
	move.l	#sprite3,a1
update3
	move.b	3(a1),d1
	andi.b	#1,d1
	beq	fine3		1 pixel
	andi.b	#$fe,3(a1)
	addq.b	#1,1(a1)
fdone3
	addq.b	#1,1(a1)	2 more pixels (3 in total)
	add.l	#8,a1		next sprite
	dbf	d0,update3


;sprite4
	moveq	#31,d0		32 sprites
	move.l	#sprite4,a1
update4
	addq.b	#1,1(a1)	2 pixels
	add.l	#8,a1		next sprite
	dbf	d0,update4


;sprite5
	moveq	#31,d0		32 sprites
	move.l	#sprite5,a1
update5
	move.b	3(a1),d1
	andi.b	#1,d1
	beq	fine5		1 pixel
	andi.b	#$fe,3(a1)
	addq.b	#1,1(a1)
fdone5
	add.l	#8,a1		next sprite
	dbf	d0,update5
	rts

fine3	eori.b	#$01,3(a1)
	bra	fdone3
fine5	eori.b	#$01,3(a1)
	bra	fdone5



prnchr	lea 	font,a0
	lea 	top+224*44+40,a1		; destination
	sub.b 	#32,d0			; de-ascii
	mulu 	#512,d0			; find position in font
	add.l 	d0,a0
	moveq 	#3,d1
lp1	moveq 	#31,d2
	move.l 	a1,a2
lp2	move.l	(a0)+,(a2)
	add.l #44,a2
	dbra d2,lp2
	add.l #11264,a1
	dbra d1,lp1
	rts


scroll	cmp.b #0,scrlctd	font is 32 pixels high and 224 lines from top
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


blitscr	moveq 	#3,d0
	lea 	top+224*44,a0
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
	move.w	#22+32*64,$dff058
	add.l 	#11264,a0
	dbra d0,blitlp
blitfin	btst 	#6,$dff002
	bne.s	blitfin	
	rts


scrlptr	dc.b	6
scrlctd	dc.b	0
	even
txtptr	dc.l 	text
text	dc.b 	"                         IT'S CHRISTMAS TIME AND TIME FOR A FAIRLY SEASONAL AMIGA COMPUTING DEMO. "
	dc.b 	" THIS DEMO EVOLVED IN THE PRESENCE OF JOLYON RALPH. THE NICE PICCY BELOW WAS"
	dc.b	" DRAWN BY RUSSEL WARK AND HE ALSO DREW THIS FONT.  "
	dc.b    " FIRSTLY I "
	dc.b 	"MUST APOLOGISE TO MY FAN FOR NOT DOING A DEMO LAST MONTH, BUT THINGS GOT TOO BUSY! SORRY! "
	dc.b 	"     SPECIAL MESSAGES AND ADVERTISMENTS....  HAVE YOU GOT A MODEM? PHONE THE BEST BBS IN THE WHOLE "
	dc.b 	"WORLD,          MAX!     ",254,"  PHONE MAX ON (0905) 52536/56610/57822/754127/754151 NOW!   ALL SPEEDS FROM 300 BAUD (SLOOOOOOW) "
	dc.b 	"TO MEGA-SUPER-DOOPER FAST 19.2K BAUD WITH HST AND MNP LEVEL 5 ERROR CORRECTION (LOG ON AND SAY - I SAW THIS ADVERT "
	dc.b 	" GET ON AND BOOGY DOWN TO THE HOTTEST BOARD THIS SIDE OF THE UKRAINE. "
	dc.b 	" SORRY TO MARK FOR FORGETTING YOU IN THE LAST DEMO. ERM. SORRY I'VE FORGOTTEN WHAT YOU ASKED ME TO SAY.  PERHAPS "
	dc.b 	"THE NEXT ONE.  " 
	dc.b 	"   MESSAGE TO ALL YOU ST OWNERS OUT THERE...  THE SECRET IS TO BANG THE ROCKS TOGETHER...    "
	dc.b 	"OH YES, THE CREDITS... CODE CODED BY THE ONE AND ONLY (EXCEPT FOR ALL THE OTHERS) ---- JOLYON RALPH ----   "
	dc.b 	"AND NOW IT'S MY GOOD OLE BUDDY ---- RUSS WARK ---- WRITING INTO THE ETHER..  WATCH OUT FOR HIS WEIRD CARTOONS IN THE MAGAZINE - SMUT - "
	dc.b	" HI THIS IS RUSS HERE.  I DREW ALL THE GRAPHICS FOR THIS GREAT DEMO, AND I'M ALWAYS AVAILABLE FOR OTHER GRAPHIC WORK. "
	dc.b	"JUST A FEW PERSONAL GREETS: HI TO... NADEEM (FLASH GIT), DEREK LEIGH-GILCHRIST (SEE YOU SOON), KEVIN COLLIER (TOO LATE FOR AN XMAS TUNE NOW), "
	dc.b 	"STEVE HOGG (HOWAY MAN! YA GEET GEORDIE!!!), ADAM LUCAS (HAVE YOU HAD ANOTHER HAIRCUT YET?), RICHARD APLIN (THE LAST ONE TO THE 'OFFY IS A WOMAN!! OH, AND "
	dc.b 	"DOUBLE DRAGON II LOOKS CANNY...), JOBY WOOD (DON'T FALL ASLEEP AT THE COMMODORE SHOW), GARETH (I WANNA SEE YOUR PARTY TRICKS...)   (YUUUK. THEY'RE DISGUSTING!  - JOLYON) "
	dc.b	"RASIKA (I WOULDN'T MIND MY VIDEO BACK SOMETIME...)  (AND MINE! - JOLYON). HELLO TO EVERYONE AT CROYDON COLLEGE (SELHURST CENTRE)... "
	dc.b 	" AND A REMINDER TO...    TIM      YOU OWE ME FIVE DISKS FROM A YEAR AGO. PAY UP OR DIE!!!!!    "
	dc.b 	" WELL DONE TO RED SECTOR FOR THE BEST MEGADEMO SO FAR.. IT WAS AWESOME...       TOMAS DAHLGREN - YOUR MUSIC IS MEGA     "
	dc.b 	" MESSAGE TO MATTIAS - TRY NOT TO HAVE TOO MANY MORE 3000 POUND PHONEBILLS!   "
	dc.b	" GOODBYE AND SO LONG - RUSS...    "
	dc.b    "  OK ITS JOLYON BACK ON THE KEYS... "
	dc.b 	"FIRST A MESSAGE TO ALL YOU BORING OS PROGRAMMERS OUT THERE "
	dc.b 	"  DON'T COMPLAIN AT ME IF YOU DON'T LIKE MY CODE. I CODE FOR FUN "
	dc.b	" IF COMMODORE FINALLY RELEASE A BUG-FREE OS THAT'S FAST ENOUGH TO USE THEN "
	dc.b 	"I'LL USE IT (WE DON'T RE-INVENT THE WHEEL FOR FUN YOU KNOW, WE WRITE OUR OWN LINE "
	dc.b 	"ROUTINES, SCREEN ROUTINES, ETC BECAUSE THE ROM ROUTINES ARE SO SLOW!)  "
	dc.b	"I DON'T LIKE THE IDEA OF SOMEONE TELLING ME WHICH WAY TO WRITE MY CODE. I'LL WRITE IT HOWEVER I LIKE, AND I LIKE HITTING THE HARDWARE "
	dc.b 	"  DAVE PARKINSON - IF YOU REALLY THINK YOU COULD WRITE A FAST ARCADE GAME WITH MULTITASKING "
	dc.b 	"THEN GO AHEAD AND WRITE ONE, I'LL GUARANTEE IT WILL BE A PILE OF JUNK. CAN YOU SERIOUSLY TELL US "
	dc.b	"THAT THE AMIGA'S MULTITASKING CAN LOAD IN GRAPHICS FOR THE NEXT LEVEL WHILE THE GAME IS PLAYING. "
	dc.b	"IF YOU'VE GOT ENOUGH RASTER TIME LEFT TO DO THAT, THE GAME MUST BE REAL CRAP!    FOR FAST ARCADE GAMES "
	dc.b	"YOU MUST DITCH THE OS. NO QUESTION.    OK?   "
	dc.b 	"ONE FINAL CUTTING COMMENT...  IF YOU HAD DITCHED MULTITASKING IN BBC EMULATOR IT WOULD HAVE BEEN MUCH EASIER "
	dc.b	"FOR YOU TO MAKE THE EMULATOR READ BBC FORMAT DISKS, MAKING YOUR BBC EMULATOR ACTUALLY RATHER USEFUL. "
	dc.b	"AND NOW I WILL TELL YOU THE REAL SECRETS OF PROGRAMMING THIS "
	dc.b	"WONDERFUL MACHINE, THE SORT OF FACTS THAT NOT EVEN MY ARTICLES "
	dc.b	"COULD EXPOSE. FIRSTLY. LEARN TO USE 68000 WELL. LEARN THE INSTRUCTIONS VERY WELL. TRY USING MOVE.W, IT'S A VERY NICE INSTRUCTION "
	dc.b	"(MY FAVOURITE). REGISTERS ARE USEFUL TOO. A0 AND D0 ARE MY PERSONAL FAVOURITES, ALTHOUGH I QUITE LIKE D1 TOO. DON`T TOUCH THE "
	dc.b	"STACK WITH A BARGE POLE, AND IF YOU DO TOUCH IT WITH A BARGE "
	dc.b	"POLE, REMEMBER TO REMOVE THE POLE BEFORE YOU EXIT. IF YOU EVER RUN OUT OF REGISTERS, REMEMBER "
	dc.b	"THAT YOU MAY HAVE TO USE SOME OF THEM TWICE. IT WAS VERY THOUGHTLESS OF MOTOROLA TO GIVE US A CHIP THAT COULD ACCESS 16 MEGABYTES "
	dc.b	"BUT ONLY TO GIVE US A HANDFULL OF REGISTERS TO ACCESS IT. "
	dc.b	"REMEMBER THAT ASSEMBLING YOUR FILE BEFORE EXECUTION IS THE NORM "
	dc.b	"NOWDAYS.     AND NOW A SHORT WORD FROM MY GOOD FRIEND RUSS... "
	dc.b	"    HI.    YES RUSS, THAT WAS A VERY SHORT WORD. WELL DONE. AND "
	dc.b	"COMING UP NOW SOME SPECIAL MESSAGES.... HEY DEREK, IGNORE "
	dc.b	"THE REVIEWS, I THOUGHT YOUR GAME (BATTLE VALLEY) WAS VERY GOOD. "
	dc.b	"TO MARK IN BELFAST. I HOPE "
	dc.b	"THE CGA CARD WORKED. THANKS FOR ALL YOUR HELP. TO JON "
	dc.b	"OF MAX. SORRY `BOUT THE OTHER DEMOS, HOPE THIS ADVERT MAKES UP "
	dc.b	"FOR IT ALL... TO STEVE.... MONEY SOON I PROMISE.... TO "
	dc.b	"KEVIN.... SMART MUSIC DESERVES A SMART MUSICDEMO. I`LL SEE WHAT I "
	dc.b	"CAN CONJURE UP... TO DAVE FROM 17 BIT. WHY HAVEN`T I HEARD FROM "
	dc.b	"YOU IN SUCH A LONG TIME? TO MY SISTER. LOOK AT ALL THE TROUBLE "
	dc.b	"YOUR SPURIOUS COMMENTS ABOUT POLAND CAUSED. THE WHOLE EASTERN "
	dc.b	"BLOCK IS NOW IN TURMOIL DUE TO YOUR INSENSITIVE REMARKS. TO "
	dc.b	"MY CATS. MEEEOOOWW. AND NOW ANOTHER FREE (ERHM. DONATIONS "
	dc.b	"WELCOME) ADVERTISMENT: THE BEST COMPUTER SHOP IN THE WHOLE "
	dc.b	"WORLD. NOT ONLY DO THEY SELL CHEAP COMPUTER HARDWARE AND SOFTWARE, BUT EVERY PURCHASE BRINGS THE CUSTOMER 5 YEARS GOOD LUCK "
	dc.b	"AND GUARANTEED PROTECTION FROM ALL KNOWN VAMPIRES. WHO AM I "
	dc.b	"TALKING ABOUT? SABRE COMPUTER CENTRE, IN-SHOPS, CROYDON. ASK "
	dc.b	"FOR TONY, AND SAY `I`VE BEEN STUPID ENOUGH TO READ ALL THE SCROLLY "
	dc.b	"MESSAGE IN THAT BORING AMIGA COMPUTING CHRISTMAS DEMO AND I SAW THE ADVERT AND CAME TO YOUR SHOP', AND YOU'LL GET A MASSIVE "
	dc.b	"0.5% DISCOUNT ON ANY PURCHASE OVER 4000 QUID. "
	dc.b	"   SERIOUSLY NOW, SEE TONY IF YOU WANT A GOOD DEAL.    OH, AND TONY,  THANKS FOR LENDING ME THE ARCHIMEDES, I STILL THINK "
	dc.b	"THE AMIGA IS A NICER COMPUTER  (MAY NOT BE AS FAST, BUT IT'S A LOT MORE FUN TO PLAY WITH)....   "
	dc.b	"  OH WELL, I'VE RUN OUT OF THINGS TO SAY AGAIN.   PERHAPS WE WILL MEET AGAIN IN SOME DISTANT SCROLLY-MESSAGE, PERHAPS NOT. "
	dc.b	" WELL, FOR THE MOMENT, IT'S JOLYON RALPH SAYING.   BYEBYE AND HAVE FUN KIDDIES....       ",0
	even


;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

new	dc.w	bplcon0,$4200
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon1,$0
	dc.w	bplcon2,$0
	dc.w	bpl1mod,$4
	dc.w	bpl2mod,$4

	dc.w	bpl1pth		4 bitplane display
bp1h1	dc.w	0,bpl1ptl
bp1l1	dc.w	0,bpl2pth
bp2h1	dc.w	0,bpl2ptl
bp2l1	dc.w	0,bpl3pth
bp3h1	dc.w	0,bpl3ptl
bp3l1	dc.w	0,bpl4pth
bp4h1	dc.w	0,bpl4ptl
bp4l1	dc.w	0,spr1pth
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

colours1	ds.w	32

	dc.w	$1aa,$fff	sprite colours
	dc.w	$1ac,$ccc
	dc.w	$1b2,$999
	dc.w	$1b4,$666

	dc.w	$ffdf,$fffe	PAL copper enable

	dc.w	$1009,$fffe,$186,$100,intreq,$8010     colours for scrolltext
	dc.w	$1109,$fffe,$186,$200
	dc.w	$1209,$fffe,$186,$300
	dc.w	$1309,$fffe,$186,$400
	dc.w	$1409,$fffe,$186,$500
	dc.w	$1509,$fffe,$186,$600
	dc.w	$1609,$fffe,$186,$700
	dc.w	$1709,$fffe,$186,$800
	dc.w	$1809,$fffe,$186,$900
	dc.w	$1909,$fffe,$186,$a00
	dc.w	$2109,$fffe,$186,$a10
	dc.w	$2209,$fffe,$186,$a20
	dc.w	$2309,$fffe,$186,$a30
	dc.w	$2409,$fffe,$186,$a40
	dc.w	$2509,$fffe,$186,$a50
	dc.w	$2609,$fffe,$186,$a60
	dc.w	$2709,$fffe,$186,$a70
	dc.w	$2809,$fffe,$186,$a80
	dc.w	$2909,$fffe,$186,$a90
	
	dc.w	$ffff,$fffe	END


;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

oldcopper	dc.l	0


;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

grafname	dc.b	'graphics.library',0
		even

;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

sprite1	dc.w	0,0,0,0
sprite2	ds.w	32*4
	dc.w	0,0
sprite3	ds.w	32*4
	dc.w	0,0
sprite4	ds.w	32*4
	dc.w	0,0
sprite5	ds.w	32*4
	dc.w	0,0
sprite6	dc.w	0,0,0,0
sprite7	dc.w	0,0,0,0


top	ds.b	45056		256*44*4
	dc.w	$000,$000,$eee,$ddd,$ccc,$bbb,$aaa,$999
	dc.w	$888,$777,$666,$555,$444,$333,$222,$111

font	dcb.l	128,0		for `space' character
	incbin	font.bin


;""""""""""""""""""""""
;" Hardware registers "
;"		      "
;""""""""""""""""""""""

bltddat	EQU   $000
dmaconr	EQU   $002
vposr	EQU   $004
vhposr	EQU   $006
dskdatr	EQU   $008
joy0dat	EQU   $00A
joy1dat	EQU   $00C
clxdat	EQU   $00E
adkconr	EQU   $010
pot0dat	EQU   $012
pot1dat	EQU   $014
potinp	EQU   $016
serdatr	EQU   $018
dskbytr	EQU   $01A
intenar	EQU   $01C
intreqr	EQU   $01E
dskpt	EQU   $020
dsklen	EQU   $024
dskdat	EQU   $026
refptr	EQU   $028
vposw	EQU   $02A
vhposw	EQU   $02C
copcon	EQU   $02E
serdat	EQU   $030
serper	EQU   $032
potgo	EQU   $034
joytest	EQU   $036
strequ	EQU   $038
strvbl	EQU   $03A
strhor	EQU   $03C
strlong	EQU   $03E
bltcon0	EQU   $040
bltcon1	EQU   $042
bltafwm	EQU   $044
bltalwm	EQU   $046
bltcpth	EQU   $048
bltcptl EQU   $04A
bltbpth	EQU   $04C
bltbptl EQU   $04E
bltapth	EQU   $050
bltaptl EQU   $052
bltdpth	EQU   $054
bltdptl EQU   $056
bltsize	EQU   $058
bltcmod	EQU   $060
bltbmod	EQU   $062
bltamod	EQU   $064
bltdmod	EQU   $066
bltcdat	EQU   $070
bltbdat	EQU   $072
bltadat	EQU   $074
dsksync	EQU   $07E
cop1lc	EQU   $080
cop2lc	EQU   $084
copjmp1	EQU   $088
copjmp2	EQU   $08A
copins	EQU   $08C
diwstrt	EQU   $08E
diwstop	EQU   $090
ddfstrt	EQU   $092
ddfstop	EQU   $094
dmacon	EQU   $096
clxcon	EQU   $098
intena	EQU   $09A
intreq	EQU   $09C
adkcon	EQU   $09E
aud0vol	EQU   $0A8
aud1vol EQU   $0B8
aud2vol	EQU   $0C8
aud3vol	EQU   $0D8
bpl1pth	EQU   $0E0
bpl1ptl	EQU   $0E2
bpl2pth	EQU   $0E4
bpl2ptl	EQU   $0E6
bpl3pth	EQU   $0E8
bpl3ptl	EQU   $0EA
bpl4pth	EQU   $0EC
bpl4ptl	EQU   $0EE
bpl5pth	EQU   $0F0
bpl5ptl	EQU   $0F2
bpl6pth	EQU   $0F4
bpl6ptl	EQU   $0F6
bplcon0	EQU   $100
bplcon1	EQU   $102
bplcon2	EQU   $104
bpl1mod	EQU   $108
bpl2mod	EQU   $10A
bpldat	EQU   $110
spr0pth	EQU   $120
spr0ptl EQU   $122
spr1pth EQU   $124
spr1ptl EQU   $126
spr2pth	EQU   $128
spr2ptl EQU   $12A
spr3pth EQU   $12C
spr3ptl EQU   $12E
spr4pth	EQU   $130
spr4ptl EQU   $132
spr5pth EQU   $134
spr5ptl EQU   $136
spr6pth	EQU   $138
spr6ptl EQU   $13A
spr7pth EQU   $13C
spr7ptl EQU   $13E
spr0pos	EQU   $140
spr1pos	EQU   $148
spr2pos EQU   $150
spr3pos EQU   $158
spr4pos EQU   $160
spr5pos EQU   $168
spr6pos EQU   $170
spr7pos EQU   $178
spr0ctl	EQU   $142
spr1ctl	EQU   $14A
spr2ctl EQU   $152
spr3ctl EQU   $15A
spr4ctl EQU   $162
spr5ctl EQU   $16A
spr6ctl EQU   $172
spr7ctl EQU   $17A
spr0data EQU  $144
spr1data EQU  $14c
spr2data EQU  $154
spr3data EQU  $15c
spr4data EQU  $164
spr5data EQU  $16c
spr6data EQU  $174
spr7data EQU  $17c
spr0datb EQU  $146
spr1datb EQU  $14e
spr2datb EQU  $156
spr3datb EQU  $15e
spr4datb EQU  $166
spr5datb EQU  $16e
spr6datb EQU  $176
spr7datb EQU  $17e
color0	EQU   $180
color1 	EQU   $182
color2	EQU   $184
color4  EQU   $188
color8	EQU   $190
color16 EQU   $1A0
