	section	Ultimate,code
	opt	o+




LF	equ	10




* Save address of CLI command string

	move.l	a0,Command
	clr.b	-1(a0,d0.w)		null-terminate the command string




* Open the DOS library

	moveq	#0,d0
	lea	dosname(pc),a1
	move.l	4.w,a6
	jsr	-552(a6)		OpenLibrary
	move.l	d0,DOSBase
	beq	exit_now




* Get standard output handle

	move.l	d0,a6
	jsr	-60(a6)			Output
	move.l	d0,StdOutHandle




* Print title text

	move.l	StdOutHandle(pc),d1
	move.l	#title,d2
	moveq	#titlelen,d3
;	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write




* Get source filename

	move.l	Command(pc),a0
	move.b	(a0),d0
	beq	error1
	cmp.b	#'.',d0
	beq	error1

	lea	SourceFilename(pc),a1
	moveq	#' ',d1
	moveq	#'.',d2
	moveq	#0,d3

get.source.name
	move.b	(a0)+,d0
	beq.s	got.source.name

	cmp.b	d1,d0
	beq.s	got.source.name

	cmp.b	d2,d0
	bne.s	not.period

	st	d3

not.period
	move.b	d0,(a1)+
	bra.s	get.source.name

got.source.name
	tst.b	d3
	bne.s	source.extension

	move.b	d2,(a1)+
	move.b	#'s',(a1)+		add .s extension

source.extension
	clr.b	(a1)			null-terminate




* Make output filename

	lea	SourceFilename(pc),a0
	lea	OutputFilename(pc),a1

get.output.name
	move.b	(a0)+,d0
	cmp.b	d2,d0
	beq.s	got.output.name

	move.b	d0,(a1)+
	bra.s	get.output.name

got.output.name
	clr.b	(a1)			null-terminate




* Get lock on source file

	move.l	#SourceFilename,d1
	moveq	#-2,d2			ACCESS_READ
;	move.l	DOSBase(pc),a6
	jsr	-84(a6)			Lock
	move.l	d0,SourceLock
	beq	error2




* Examine source file

	move.l	SourceLock(pc),d1
	move.l	#FileInfoBlock,d2
;	move.l	DOSBase(pc),a6
	jsr	-102(a6)		Examine
	tst.l	d0
	beq	error3




* Unlock source file

	move.l	SourceLock(pc),d1
;	move.l	DOSBase(pc),a6
	jsr	-90(a6)			UnLock




* Allocate memory for source file

	move.l	FileInfoBlock+124(pc),d0
	addq.l	#8,d0			+ 8 extra bytes
	move.l	d0,SourceMemLength
	moveq	#0,d1
	move.l	4.w,a6
	jsr	-198(a6)		AllocMem
	move.l	d0,SourceMem
	beq	error4




* Open source file

	move.l	#SourceFilename,d1
	move.l	#1005,d2		MODE_OLDFILE
	move.l	DOSBase(pc),a6
	jsr	-30(a6)			Open
	move.l	d0,SourceHandle
	beq	error5




* Read source file into memory

	move.l	SourceHandle(pc),d1
	move.l	SourceMem(pc),d2
	move.l	FileInfoBlock+124(pc),d3
;	move.l	DOSBase(pc),a6
	jsr	-42(a6)			Read
	tst.l	d0
	bmi	error6




* Close source file

	move.l	SourceHandle(pc),d1
;	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close




* Allocate memory for object code

	move.l	ObjectMemLength(pc),d0
	moveq	#0,d1
	move.l	4.w,a6
	jsr	-198(a6)		AllocMem
	move.l	d0,ObjectMem
	beq	error7




* Assemble file

	bsr	assemble




* Free source file memory

	move.l	SourceMemLength(pc),d0
	move.l	SourceMem(pc),a1
	move.l	4.w,a6
	jsr	-210(a6)		FreeMem




* Create output file

	bsr	create.output
	bmi.s	exit_freeobjectmem




* Print source lines, object code bytes and time taken

	bsr	print.statistics




exit_freeobjectmem
	move.l	ObjectMemLength(pc),d0
	move.l	ObjectMem(pc),a1
	move.l	4.w,a6
	jsr	-210(a6)		FreeMem

	bra.s	exit_closedos




exit_closesource
	move.l	SourceHandle(pc),d1
;	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close




exit_freesourcemem
	move.l	SourceMemLength(pc),d0
	move.l	SourceMem(pc),a1
	move.l	4.w,a6
	jsr	-210(a6)		FreeMem




exit_closedos
	move.l	DOSBase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary




exit_now
	moveq	#0,d0
	rts




;""""""""""""""""""
;" ERROR HANDLING "
;"		  "
;""""""""""""""""""

error1	move.l	StdOutHandle(pc),d1
	move.l	#error1text,d2
	moveq	#error1textlen,d3
;	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	bra.s	exit_closedos



error2	move.l	StdOutHandle(pc),d1
	move.l	#error2text,d2
	moveq	#error2textlen,d3
;	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	bra.s	exit_closedos



error3	move.l	StdOutHandle(pc),d1
	move.l	#error3text,d2
	moveq	#error3textlen,d3
;	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write

	move.l	SourceLock(pc),d1
;	move.l	DOSBase(pc),a6
	jsr	-90(a6)			UnLock
	bra.s	exit_closedos



error4	move.l	StdOutHandle(pc),d1
	move.l	#error4text,d2
	moveq	#error4textlen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	bra.s	exit_closedos



error5	move.l	StdOutHandle(pc),d1
	move.l	#error5text,d2
	moveq	#error5textlen,d3
;	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	bra	exit_freesourcemem



error6	move.l	StdOutHandle(pc),d1
	move.l	#error6text,d2
	moveq	#error6textlen,d3
;	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	bra	exit_closesource



error7	move.l	StdOutHandle(pc),d1
	move.l	#error7text,d2
	moveq	#error7textlen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	bra	exit_freesourcemem



error8	move.l	StdOutHandle(pc),d1
	move.l	#error8text,d2
	moveq	#error8textlen,d3
;	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	moveq	#-1,d0
	rts



error9	move.l	StdOutHandle(pc),d1
	move.l	#error9text,d2
	moveq	#error9textlen,d3
;	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write

	move.l	OutputHandle(pc),d1
;	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close
	moveq	#-1,d0
	rts




;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

create.output
	move.l	StdOutHandle(pc),d1
	move.l	#executable,d2
	moveq	#executablelen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write

	lea	OutputFilename(pc),a0
	lea	TextBuffer(pc),a1
	bsr	copy.text
	move.b	#LF,(a1)+
	move.b	#LF,(a1)+
	move.l	StdOutHandle(pc),d1
	move.l	#TextBuffer,d2
	move.l	a1,d3
	sub.l	d2,d3
;	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write


	move.l	#OutputFilename,d1
	move.l	#1006,d2		MODE_NEWFILE
;	move.l	DOSBase(pc),a6
	jsr	-30(a6)			Open
	move.l	d0,OutputHandle
	beq	error8


	move.l	ObjectSize(pc),d0
	move.w	d0,d6
	moveq	#0,d7
	asr.l	#2,d0			calculate number of longwords
	and.w	#3,d6
	beq.s	longword.multiple
	addq.l	#1,d0			extra longword for last 1-3 bytes
	moveq	#4,d7
	sub.w	d6,d7			bytes extra to align to next longword

longword.multiple
	lea	hunk.header(pc),a0
	move.l	d0,20(a0)
	move.l	d0,28(a0)

	move.l	OutputHandle(pc),d1
	move.l	a0,d2
	moveq	#8*4,d3
;	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	tst.l	d0
	bmi	error9


	move.l	OutputHandle(pc),d1
	move.l	ObjectMem(pc),d2
	move.l	ObjectSize(pc),d3
;	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	tst.l	d0
	bmi	error9


	move.l	OutputHandle(pc),d1
	move.l	#blank.long,d2
	move.l	d7,d3
	beq.s	longword.aligned
;	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	tst.l	d0
	bmi	error9


longword.aligned
	move.l	OutputHandle(pc),d1
	move.l	#hunk.end,d2
	moveq	#4,d3
;	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	tst.l	d0
	bmi	error9


	move.l	OutputHandle(pc),d1
;	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close
	moveq	#0,d0
	rts




hunk.header
	dc.l	$3f3			hunk_header
	dc.l	0			end of the name list
	dc.l	1			highest hunk number + 1
	dc.l	0			number of hunk to be loaded first
	dc.l	0			number of hunk to be loaded last
	dc.l	0			size of first hunk (longwords)

	dc.l	$3e9			hunk_code
	dc.l	0			size of hunk (longwords)


hunk.end
	dc.l	$3f2


blank.long
	dc.l	0



LinesText
	dc.b	' lines assembled into ',0

BytesText
	dc.b	' bytes, took ',0

SecondsText
	dc.b	' seconds.',LF,0
	even



print.statistics
	move.l	SourceLines(pc),d0
	lea	TextBuffer(pc),a1
	bsr	make.decimal

	lea	LinesText(pc),a0
	bsr.s	copy.text

	move.l	ObjectSize(pc),d0
	bsr.s	make.decimal

	lea	BytesText(pc),a0
	bsr.s	copy.text

	move.l	AssemblyTime(pc),d0
	divu	#50,d0			calculate number of seconds
	move.l	d0,d6
	and.l	#$ffff,d0
	bsr.s	make.decimal
	move.b	#'.',(a1)+		save decimal point
	move.l	d6,d0
	swap	d0
	and.l	#$ffff,d0
	add.w	d0,d0			calculate hundreths of a second
	cmp.w	#10,d0
	bge.s	make.hundreths
	move.b	#'0',(a1)+		save zero tenths

make.hundreths
	bsr.s	make.decimal

	lea	SecondsText(pc),a0
	bsr.s	copy.text

	move.l	StdOutHandle(pc),d1
	move.l	#TextBuffer,d2
	move.l	a1,d3
	sub.l	d2,d3
;	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	rts




copy.text
	move.b	(a0)+,(a1)+
	bne.s	copy.text
	subq.l	#1,a1
	rts




powers.of.ten
	dc.l	10000000,1000000,100000,10000,1000,100,10,1



make.decimal				; d0.l = signed number
	tst.l	d0
	beq.s	decimal.zero

	lea	powers.of.ten(pc),a0
	moveq	#8-1,d3			do 8 digits
	moveq	#0,d4			miss leading zeros
	moveq	#'0',d5

next.decimal.digit
	moveq	#'0',d1
	move.l	(a0)+,d2		get next power of ten

calculate.digit
	sub.l	d2,d0
	bcs.s	digit.done
	addq.b	#1,d1			next digit up
	bra.s	calculate.digit

digit.done
	add.l	d2,d0

	tst.b	d4			if flag is set
	bne.s	save.digit		then save all digits

	cmp.b	d5,d1
	beq.s	skip.zero.digit
	st	d4			don't miss off any more zeros

save.digit
	move.b	d1,(a1)+

skip.zero.digit
	dbra	d3,next.decimal.digit
	rts


decimal.zero
	move.b	#'0',(a1)+
	rts




get.time.ticks
	move.l	#Date,d1
	move.l	DOSBase(pc),a6
	jsr	-192(a6)		DateStamp
	lea	Date+4(pc),a0
	move.l	(a0),d0			get minutes
	mulu	#60*50,d0		seconds * ticks per second
	add.l	4(a0),d0		add ticks in current minute
	rts




next.source.line
	addq.l	#1,d7
	bra.s	assem.loop




check.symbol
	beq.s	assemble.end

	cmp.b	d2,d0			line feed
	beq.s	next.source.line

	rts




assemble.end
	move.l	d7,SourceLines

	sub.l	ObjectMem(pc),a1
	move.l	a1,ObjectSize

	bsr.s	get.time.ticks
	sub.l	AssemblyTime(pc),d0
	move.l	d0,AssemblyTime
	rts




assemble
	move.l	StdOutHandle(pc),d1
	move.l	#assembling,d2
	moveq	#assemblinglen,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write

	bsr.s	get.time.ticks
	move.l	d0,AssemblyTime


	move.l	SourceMem(pc),a0
	add.l	FileInfoBlock+124(pc),a0
	subq.l	#1,a0
	moveq	#LF,d2
	cmp.b	(a0)+,d2		ensure text ends with a line feed
	beq.s	null.terminate
	move.b	d2,(a0)+

null.terminate
	clr.b	(a0)


	moveq	#0,d0
	moveq	#$5f,d3			mask to capitalise characters
	moveq	#0,d7
	move.l	SourceMem(pc),a0
	move.l	ObjectMem(pc),a1
	move.l	a1,a2
	add.l	ObjectMemLength(pc),a2
	lea	parse.table+128(pc),a3
	lea	char.check2(pc),a4


assem.loop
	move.b	(a0)+,d0
	move.b	char.check1(pc,d0.w),d0
	bpl.s	check.symbol

skip.space
	move.b	(a0)+,d0
	move.b	char.check1(pc,d0.w),d0
	bmi.s	skip.space

parse.instruction
	moveq	#0,d1
	move.b	-128(a3,d0.w),d1	get first char. offset

	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	127(a3,d0.w),d1		add second char. offset

	moveq	#0,d0
	move.b	(a0)+,d0
	move.b	-128(a3,d0.w),d0	get third char. offset

	add.w	127(a3,d1.w),d0		add offset from first two chars.

	move.w	127(a3,d0.w),d1
	moveq	#0,d0
	jmp	instruction.table(pc,d1.w)

instruction.done
	addq.l	#1,d7

find.next.line
	cmp.b	(a0)+,d2
	bne.s	find.next.line

	cmp.l	a2,a1
	blt.s	assem.loop

object.mem.full
	rts




instruction.table
	nop
	bra.s	instruction.done




char.check1
	dc.b	$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$0a,$ff,$ff,$0d,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$21,$ff,$23,$24,$25,$26,$ff
	dc.b	$28,$29,$2a,$2b,$2c,$2d,$2e,$2f
	dc.b	$30,$31,$32,$33,$34,$35,$36,$37
	dc.b	$38,$39,$3a,$3b,$3c,$3d,$3e,$3f
	dc.b	$40,$41,$42,$43,$44,$45,$46,$47
	dc.b	$48,$49,$4a,$4b,$4c,$4d,$4e,$4f
	dc.b	$50,$51,$52,$53,$54,$55,$56,$57
	dc.b	$58,$59,$5a,$5b,$5c,$5d,$5e,$5f
	dc.b	$60,$41,$42,$43,$44,$45,$46,$47
	dc.b	$48,$49,$4a,$4b,$4c,$4d,$4e,$4f
	dc.b	$50,$51,$52,$53,$54,$55,$56,$57
	dc.b	$58,$59,$5a,$7b,$ff,$7d,$7e,$7f




nop	move.b	(a0),d0
	tst.b	(a4,d0.w)
	bpl.s	garbage.following

	move.w	#$4e71,(a1)+
	bra	instruction.done



rts	move.b	(a0),d0
	tst.b	(a4,d0.w)
	bpl.s	garbage.following

	move.w	#$4e75,(a1)+
	bra	instruction.done



garbage.following
	bra	instruction.done




char.check2
	dc.b	$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$21,$22,$23,$24,$25,$26,$27
	dc.b	$28,$29,$2a,$2b,$ff,$2d,$2e,$2f
	dc.b	$30,$31,$32,$33,$34,$35,$36,$37
	dc.b	$38,$39,$ff,$ff,$3c,$3d,$3e,$3f
	dc.b	$40,$41,$42,$43,$44,$45,$46,$47
	dc.b	$48,$49,$4a,$4b,$4c,$4d,$4e,$4f
	dc.b	$50,$51,$52,$53,$54,$55,$56,$57
	dc.b	$58,$59,$5a,$5b,$5c,$5d,$5e,$5f
	dc.b	$60,$41,$42,$43,$44,$45,$46,$47
	dc.b	$48,$49,$4a,$4b,$4c,$4d,$4e,$4f
	dc.b	$50,$51,$52,$53,$54,$55,$56,$57
	dc.b	$58,$59,$5a,$7b,$7c,$7d,$7e,$7f



nop.offset	equ	nop-instruction.table
rts.offset	equ	rts-instruction.table




	dc.b	0
parse.table
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,2,4,6,8,10,12,14
	dc.b	16,18,20,22,24,26,28,30
	dc.b	32,34,36,38,40,42,44,46
	dc.b	48,50,52,0,0,0,0,0
	dc.b	0,2,4,6,8,10,12,14
	dc.b	16,18,20,22,24,26,28,30
	dc.b	32,34,36,38,40,42,44,46
	dc.b	48,50,52,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0


; second character offsets

	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512

	dc.w	512,566,620,674,728,782,836,890
	dc.w	944,998,1052,1106,1160,1214,1268,1322
	dc.w	1376,1430,1484,1538,1592,1646,1700,1754
	dc.w	1808,1862,1916

	dc.w	512,512,512,512,512

	dc.w	512,566,620,674,728,782,836,890
	dc.w	944,998,1052,1106,1160,1214,1268,1322
	dc.w	1376,1430,1484,1538,1592,1646,1700,1754
	dc.w	1808,1862,1916

	dc.w	512,512,512,512,512

	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512
	dc.w	512,512,512,512,512,512,512,512


; offsets for the first-second character tables

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		error
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?a
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?b
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?c
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?d
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?e
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?f
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?g
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?h
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?i
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?j
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?k
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?l
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?m
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?n
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?o
	dc.w	1970,1970,1970,1970,1970,1970,1970+53*54,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?p
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?q
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?r
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?s
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?t
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970+64*54,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?u
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?v
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?w
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?x
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?y
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970

	dc.w	1970,1970,1970,1970,1970,1970,1970,1970		?z
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970,1970,1970,1970,1970,1970
	dc.w	1970,1970,1970


; first-second character tables
; the third letter determines the position in the table
; the value at this position is the jump-offset for the
; routine to handle this three-letter combination

error	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

ab	dc.w	0,0,0,0,0,0,0,0		; 1
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

ad	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

an	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

as	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

bc	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

be	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

bg	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

bh	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

bk	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

bl	dc.w	0,0,0,0,0,0,0,0		; 10
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

bm	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

bn	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

bp	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

br	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

bs	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

bt	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

bv	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

ch	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

cl	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

cm	dc.w	0,0,0,0,0,0,0,0		; 20
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

cn	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

co	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

da	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

db	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

dc	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

di	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

ds	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

el	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

en	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

eo	dc.w	0,0,0,0,0,0,0,0		; 30
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

eq	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

ev	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

ex	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

fa	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

fo	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

id	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

if	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

ii	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

il	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

in	dc.w	0,0,0,0,0,0,0,0		; 40
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

jm	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

js	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

le	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

li	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

ll	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

ls	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

ma	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

me	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

mo	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

mu	dc.w	0,0,0,0,0,0,0,0		; 50
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

nb	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

ne	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

no	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	nop.offset,0,0,0,0,0,0,0
	dc.w	0,0,0

of	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

op	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

or	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

ou	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

pa	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

pe	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

pl	dc.w	0,0,0,0,0,0,0,0		; 60
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

re	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

ro	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

rs	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

rt	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,rts.offset,0,0,0,0
	dc.w	0,0,0

sb	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

sc	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

se	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

sf	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

sg	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

sh	dc.w	0,0,0,0,0,0,0,0		; 70
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

sl	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

sm	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

sn	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

sp	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

st	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

su	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

sv	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

sw	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

ta	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

tr	dc.w	0,0,0,0,0,0,0,0		; 80
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

ts	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

tt	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

un	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

xd	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0

xr	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

Command	dc.l	0
DOSBase	dc.l	0

StdOutHandle	dc.l	0
SourceHandle	dc.l	0
OutputHandle	dc.l	0

SourceLock	dc.l	0

SourceFilename	ds.b	108
OutputFilename	ds.b	108

SourceMem	dc.l	0
SourceMemLength	dc.l	0

ObjectMem	dc.l	0
ObjectMemLength	dc.l	65536

SourceLines	dc.l	0
ObjectSize	dc.l	0
AssemblyTime	dc.l	0

TextBuffer	ds.b	110

	cnop	0,4			must be longword aligned

FileInfoBlock	ds.l	65

Date	ds.l	3




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

dosname	dc.b	'dos.library',0
	even



title	dc.b	'The Ultimate 68000 Macro Assembler V0.9',10,10,0
titlelen	equ	*-title



assembling
	dc.b	'Assembling, ',0
assemblinglen	equ	*-assembling



executable
	dc.b	'writing executable code to ',0
executablelen	equ	*-executable



error1text
	dc.b	'Invalid command line',10,0
error1textlen	equ	*-error1text



error2text
	dc.b	'Could not get lock on source file',10,0
error2textlen	equ	*-error2text



error3text
	dc.b	'Could not examine source file',10,0
error3textlen	equ	*-error3text



error4text
	dc.b	'Could not allocate memory for source file',10,0
error4textlen	equ	*-error4text



error5text
	dc.b	'Could not open source file',10,0
error5textlen	equ	*-error5text



error6text
	dc.b	'Could not read source file',10,0
error6textlen	equ	*-error6text



error7text
	dc.b	'Could not allocate memory for object code',10,0
error7textlen	equ	*-error7text



error8text
	dc.b	'Could not open output file',10,0
error8textlen	equ	*-error8text



error9text
	dc.b	'An error occured when creating output file',10,0
error9textlen	equ	*-error9text
