	section	BinaryConvert,code_c
	opt c-


Print	MACRO
	move.l	StdOutHandle(pc),d1
	move.l	#\1,d2
	move.l	#\2,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	ENDM


* Open the DOS library

	moveq	#0,d0
	lea	dosname(pc),a1
	move.l	4.w,a6
	jsr	-552(a6)		OpenLibrary
	move.l	d0,DOSBase
	beq	exit_now

* Get standard output handle

	move.l	DOSBase(pc),a6
	jsr	-60(a6)			Output
	move.l	d0,StdOutHandle

* Print program title

	print	Title,Titlelen

* Request source file

	print	SourceText,Sourcetextlen
	move.l	Dosbase(pc),a6
	move.l	StdOutHandle(pc),d1
	move.l	#InputFilename,d2
	moveq	#108,d3
	jsr	-42(a6)				Read
	lea	InputFilename(pc),a0
	cmp.b	#$0a,(a0)
	beq	Error1

	lea	InputFilename(pc),a0
	bsr	Null.Terminate.Filename

* Get lock on input file

	move.l	#InputFilename,d1
	moveq	#-2,d2			ACCESS_READ
	move.l	DOSBase(pc),a6
	jsr	-84(a6)			Lock
	move.l	d0,InputLock
	beq	Error3

* Examine input file

	move.l	InputLock(pc),d1
	move.l	#FileInfoBlock,d2
	move.l	DOSBase(pc),a6
	jsr	-102(a6)		Examine
	tst.l	d0
	beq	Error4

* Unlock input file

	move.l	InputLock(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-90(a6)			UnLock

* Allocate memory for input file

	move.l	4.w,a6
	move.l	Size(pc),d0
	move.l	#$10002,d1
	jsr	-198(a6)
	tst.l	d0
	beq	Error10
	move.l	d0,Inputmem

* Open input file

	move.l	#InputFilename,d1
	move.l	#1005,d2		MODE_OLDFILE
	move.l	DOSBase(pc),a6
	jsr	-30(a6)			Open
	move.l	d0,InputHandle
	beq	Error6

* Read input file into memory

	move.l	InputHandle(pc),d1
	move.l	Inputmem(pc),d2
	move.l	Size(pc),d3
	move.l	DOSBase(pc),a6
	jsr	-42(a6)			Read
	tst.l	d0
	bmi	Error7

* Close input file

	move.l	InputHandle(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close

* Check file for FORM ILBM 

	move.l	Inputmem(pc),a0

	cmp.l	#'FORM',(a0)
	bne	Error12

	cmp.l	#'ILBM',8(a0)
	bne	Error12

	tst.b	30(a0)			Test to see if Crunched
	bne.s	File.Crunched

	st	File.Not.Crunched

File.Crunched

* Get bitplane size and find BODY data

	move.l	Inputmem(pc),a0
	lea	20(a0),a0
	moveq	#0,d0
	move.w	(a0)+,d0
	ror.l	#3,d0
	swap	d0
	tst.w	d0
	beq.s	Set.Width

	swap	d0
	addq.w	#1,d0
	move.w	d0,BitplaneWidth
	bra.s	Do.Height
Set.Width
	swap	d0
	move.w	d0,BitplaneWidth

Do.Height
	move.w	(a0)+,d0
	move.w	d0,d1
	subq.w	#1,d0
	move.w	d0,BitplaneHeight

	addq.l	#4,a0

	move.w	BitplaneWidth(pc),d2
	mulu	d1,d2
	move.l	d2,PlaneSizeSkip

	moveq	#0,d0
	move.b	(a0),d0
	mulu	d0,d2
	move.l	d2,PictureSize
	subq.w	#1,d0
	move.w	d0,NumberOfPlanes

Find.Body
	move.w	#1000,d7
	subq.l	#1,d7
Body.Loop
	cmp.l	#'BODY',(a0)
	beq.s	File.OK.Body.Found
	addq.l	#2,a0
	dbra	d7,Body.Loop

	bra	Error13

File.OK.Body.Found
	addq.l	#8,a0
	move.l	a0,BODY.Data.Address

* Allocate memory for output file

	move.l	4.w,a6
	move.l	PictureSize(pc),d0
	add.l	#1024,d0
	move.l	#$10002,d1
	jsr	-198(a6)
	tst.l	d0
	beq	Error11
	move.l	d0,Outputmem

* Request options

	print	Optionstext,Optionstextlen
	move.l	Dosbase(pc),a6
	move.l	StdOutHandle(pc),d1
	move.l	#Option.Space,d2
	moveq	#4,d3
	jsr	-42(a6)				Read


	lea	Option.Space(pc),a0

	bsr	Option.Reader


* Convert input file

	move.l	Inputmem(pc),a0
Find.CMAP
	move.w	#1000,d7
	subq.l	#1,d7
CMAP.Loop
	cmp.l	#'CMAP',(a0)
	beq.s	CMAP.Found
	addq.l	#2,a0
	dbra	d7,CMAP.Loop

	bra	Error13

CMAP.Found
	addq.l	#6,a0
	move.l	a0,Colours.Address

	bsr	Get.Colours
	bsr	Decrunch.Picture

* Request destination file

	print	DestinationText,Destinationtextlen
	move.l	Dosbase(pc),a6
	move.l	StdOutHandle(pc),d1
	move.l	#OutputFilename,d2
	moveq	#108,d3
	jsr	-42(a6)				Read
	lea	OutputFilename(pc),a0
	cmp.b	#$0a,(a0)
	beq	Error2

	lea	OutputFilename(pc),a0
	bsr	Null.Terminate.Filename

	lea	OutputFilename(pc),a0
	lea	ColoursOutputFilename(pc),a1

	moveq	#0,d0
NextChar
	move.b	(a0)+,d0
	beq.s	SetFileExtension

	move.b	d0,(a1)+
	bra.s	NextChar

SetFileExtension
	move.b	#'.',(a1)+
	move.b	#'C',(a1)+
	move.b	#'O',(a1)+
	move.b	#'L',(a1)

* Open output file

	move.l	#OutputFilename,d1
	move.l	#1006,d2		MODE_NEWFILE
	move.l	DOSBase(pc),a6
	jsr	-30(a6)			Open
	move.l	d0,OutputHandle
	beq	Error8

* Write to output file

	move.l	OutputHandle(pc),d1
	move.l	Outputmem(pc),d2
	move.l	NewSize(pc),d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	tst.l	d0
	bmi	Error9

exit_closeoutput
	move.l	OutputHandle(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close


	lea	CommandTable(pc),a5

	tst.b	SeparateCols(a5)
	beq.s	QuitIffBinary

	lea	ColourSaveArea(pc),a1

	bsr	CopyColourValues

* Open output file for colours

	move.l	#ColoursOutputFilename,d1
	move.l	#1006,d2		MODE_NEWFILE
	move.l	DOSBase(pc),a6
	jsr	-30(a6)			Open
	move.l	d0,ColoursOutputHandle
	beq	Error8

* Write to output file

jim
	bsr	GetColourSize

	move.l	ColoursOutputHandle(pc),d1
	move.l	#ColourSaveArea,d2
	move.l	d0,d3
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
	tst.l	d0
	bmi	Error5

exit_closeoutput2
	move.l	OutputHandle(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close

QuitIffBinary

exit_freemem2
	move.l	4.w,a6
	move.l	Outputmem(pc),a1
	move.l	PictureSize(pc),d0
	add.l	#1024,d0
	jsr	-210(a6)

exit_freemem
	move.l	4.w,a6
	move.l	Inputmem(pc),a1
	move.l	Size(pc),d0
	jsr	-210(a6)

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

Error1	print	Error1text,Error1textlen
	bra.s	exit_closedos

Error2	print	Error2text,Error2textlen
	bra.s	exit_freemem2

Error3	print	Error3text,Error3textlen
	bra.s	exit_closedos

Error4	print	error4text,Error4textlen

	move.l	InputLock(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-90(a6)			UnLock
	bra	exit_closedos

Error5	print	Error5text,Error5textlen
	bra	exit_closeoutput2

Error6	print	Error6text,Error6textlen
	bra	exit_freemem

Error7	print	Error7text,Error7textlen

	move.l	InputHandle(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close
	bra	exit_freemem

Error8	print	Error8text,Error8textlen
	bra	exit_freemem2

Error9	print	Error9text,Error9textlen
	bra	exit_closeoutput

Error10	print	Error10text,Error10textlen
	bra	exit_closedos

Error11	print	Error11text,Error11textlen
	bra	exit_freemem

Error12	print	Error12text,Error12textlen

	move.l	InputHandle(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close

	bra	exit_freemem

Error13	print	Error13text,Error13textlen
	bra	exit_freemem

***************
* SUBROUTINES *
***************

Null.Terminate.Filename

Next.Letter
	move.b	(a0),d0
	cmp.b   #$0a,d0
	beq.s	End.Found
	addq.l	#1,a0
	bra.s	Next.Letter
End.Found
	move.b   #0,(a0)
	rts      


********************
* DeCrunch Routine *
********************

Decrunch.Picture
	move.l	BODY.Data.Address(pc),a0

	lea	CommandTable(pc),a5
	move.l	Outputmem(pc),a1

	tst.b	ColoursOnOff(a5)
	bne.s	NoColours

	tst.b	SeparateCols(a5)
	bne.s	NoColours		No colours in binary file at least

	tst.b	ColmapLocation(a5)
	bne.s	NoColours		No colours at front of pic at least

	bsr	CopyColourValues

NoColours

	tst.b	File.Not.Crunched
	bne	Copy.File.To.Outputmem

	tst.b	BitmapType(a5)
	bne.s	Sequential.Decrunch

InterLeaved.Decrunch

	move.w	BitplaneHeight(pc),d7

Next.Line
	move.w	NumberOfPlanes(pc),d6

Next.Bitplane
	move.w	BitplaneWidth(pc),d5

Next.Byte
	moveq	#0,d0
	move.b	(a0)+,d0
	bpl.s	Copy.n.Bytes

Repeat.n.Bytes
	neg.b	d0
	bmi.s	Next.Byte

	sub.b	d0,d5
	subq.b	#1,d5

	move.b	(a0)+,d1
.Loop1
	move.b	d1,(a1)+
	dbra	d0,.Loop1
	bra.s	Check.Count

Copy.n.Bytes
	sub.b	d0,d5
	subq.b	#1,d5

.Loop2
	move.b	(a0)+,(a1)+
	dbra	d0,.Loop2

Check.Count
	tst.b	d5
	bne.s	Next.Byte

	dbra	d6,Next.Bitplane
	dbra	d7,Next.Line

	bra.s	Calc.Size.And.Quit

Sequential.Decrunch

	moveq	#0,d7
	move.w	BitplaneWidth(pc),d7
	sub.l	PictureSize(pc),d7

	move.l	a1,a2
	move.w	BitplaneHeight(pc),d6
d.line	move.w	NumberOfPlanes(pc),d5
d.bitplane
	move.l	a2,a1
	add.l	PlaneSizeSkip(pc),a2		next bitplane
	move.w	BitplaneWidth(pc),d3
d.byte	moveq	#0,d0
	move.b	(a0)+,d0
	bmi.s	next.byte.n.times

next.n.bytes.literally
	sub.b	d0,d3
	subq.b	#1,d3
.loop	move.b	(a0)+,(a1)+
	dbra	d0,.loop
	bra.s	check.byte.count

next.byte.n.times
	neg.b	d0
	bmi.s	d.byte
	sub.b	d0,d3
	subq.b	#1,d3
	move.b	(a0)+,d4
.loop	move.b	d4,(a1)+
	dbra	d0,.loop

check.byte.count
	tst.b	d3
	bne.s	d.byte
	dbra	d5,d.bitplane
	add.l	d7,a2			Skip back to 1st plane nextline
	dbra	d6,d.line

Calc.Size.And.Quit
	moveq	#0,d0

	tst.b	ColoursOnOff(a5)
	bne.s	GetFileSize

	tst.b	SeparateCols(a5)
	bne.s	GetFileSize

	tst.b	ColmapLocation(a5)
	beq.s	NoColoursAtEndofPiccy

	bsr	CopyColourValues

NoColoursAtEndofPiccy
	bsr	GetColourSize

GetFileSize
	add.l	PictureSize(pc),d0

	move.l	d0,NewSize

Exit.DeCrunch
	rts


Copy.File.To.Outputmem
	move.l	-4(a0),d0
	subq.l	#1,d0

.Copy.Loop
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bge.s	.Copy.Loop

	moveq	#0,d0

	tst.b	ColoursOnOff(a5)
	bne.s	GetFileSize2

	tst.b	SeparateCols(a5)
	bne.s	GetFileSize

	tst.b	ColmapLocation(a5)
	beq.s	NoColoursAtEndofPiccy2

	bsr	CopyColourValues

NoColoursAtEndofPiccy2
	bsr	GetColourSize

GetFileSize2
	add.l	PictureSize(pc),d0

	move.l	d0,NewSize

	rts

********************************
* GET ADJUSTMENT FOR FILE SIZE *
* PLUS COLOURS		       *
********************************

GetColourSize
	lea	CommandTable(pc),a5

	tst.b	ColoursOnOff(a5)
	bne.s	ExitColourSize

	moveq	#0,d0

	tst.b	PaletteSize(a5)
	bne.s	P12BitSizeOnly

	move.w	NumberOfColours,d0
	lsl.w	#2,d0
	bra.s	ExitColourSize
	
P12BitSizeOnly
	move.w	NumberOfColours,d0
	lsl.w	#1,d0

ExitColourSize
	rts


***************************************
* MOVE COLOUR VALUES TO CORRECT PLACE *
***************************************


CopyColourValues
	move.w	NumberofColours(pc),d0
	subq.w	#1,d0
	lea	Top4bits(pc),a2
.Loop3
	move.w	(a2)+,(a1)+
	dbra	d0,.Loop3

	tst.b	PaletteSize(a5)
	bne.s	Only.12Bit

	move.w	NumberofColours(pc),d0
	subq.w	#1,d0
	lea	Bottom4bits(pc),a2
.Loop4
	move.w	(a2)+,(a1)+
	dbra	d0,.Loop4

Only.12Bit
	rts

	

*********************
* GET COLOUR VALUES *
*********************

Get.Colours
	lea	Top4bits(pc),a1
	lea	Bottom4bits(pc),a2
	move.l	Colours.Address(pc),a3
	lea	CommandTable(pc),a5

	moveq	#0,d0
	move.w	(a3),d0
	divu	#3,d0

	tst.b	Ham8Colours(a5)
	beq.s	No.Ordinary.Palette

	moveq	#64,d0

No.Ordinary.Palette

	move.w	d0,NumberofColours
	subq.w	#1,d0
	addq.l	#2,a3
.Loop
	moveq	#0,d1
	move.b	(a3)+,d1
	move.w	d1,d2
	and.b	#$f0,d1
	and.b	#$0f,d2
	lsl.w	#4,d1
	lsl.w	#8,d2

	moveq	#0,d3
	move.b	(a3)+,d3
	move.w	d3,d4
	and.b	#$f0,d3
	and.b	#$0f,d4
	lsl.w	#4,d4

	moveq	#0,d5
	move.b	(a3)+,d5
	move.w	d5,d6
	and.b	#$f0,d5
	and.b	#$0f,d6
	lsr.w	#4,d5
	
	or.w	d1,d3
	or.w	d3,d5

	or.w	d2,d4
	or.w	d4,d6

	move.w	d5,(a1)+
	move.w	d6,(a2)+

	dbra	d0,.Loop

	rts



**********************************************
* CMD READER *
**************


Option.Reader
	lea	CommandTable(pc),a1

NextOption
	cmp.b	#$a,(a0)
	beq.s	ExitReader

	moveq	#0,d0
	move.b	(a0)+,d0

	cmp.b	#'A',d0
	blt.s	NextOption

	cmp.b	#'z',d0
	bgt.s	NextOption

	cmp.b	#'a',d0
	blt.s	CheckUpperCase

	sub.b	#'a',d0		Get lower case offset 0-25
	bra.s	SetTableByte

CheckUpperCase
	cmp.b	#'Z',d0
	bgt.s	NextOption

	sub.b	#'A',d0		Get Upper case offset 0-25

SetTableByte
	st	(a1,d0.w)
	bra	NextOption

ExitReader
	rts



CommandTable	ds.b	26


*************
* VARIABLES *
*************

Command	dc.l	0
DOSBase	dc.l	0

StdOutHandle	dc.l	0
InputHandle	dc.l	0
OutputHandle	dc.l	0
ColoursOutputHandle
		dc.l	0

Inputmem	dc.l	0
Outputmem	dc.l	0
Newsize		dc.l	0
InputLock	dc.l	0

BitplaneWidth	dc.w	0
BitplaneHeight	dc.w	0
NumberOfPlanes
		dc.w	0
NumberofColours	dc.w	0

Colours.Address	dc.l	0
BODY.Data.Address
		dc.l	0
PictureSize	dc.l	0
PlaneSizeSkip	dc.l	0
File.Not.Crunched
		dc.b	0
	even

InputFilename	ds.b	108
OutputFilename	ds.b	108
ColoursOutputFilename
		ds.b	108

Option.Space	ds.b	4
Top4bits	ds.w	256
Bottom4bits	ds.w	256

ColourSaveArea	ds.w	512

	cnop	0,4			must be longword aligned

FileInfoBlock
DiskKey		dc.l	0
Direntrytype	dc.l	0
Filename	dcb.b	108,0
Protection	dc.l	0
Entrytype	dc.l	0
Size		dc.l	0
NumBlocks	dc.l	0
Days		dc.l	0
Minute		dc.l	0
Tick		dc.l	0
Comment		dcb.b	116,0


*****************
* FLAGS OFFSETS *
*****************

	rsreset

Blank1		rs.b	1

ColMaplocation	rs.b	1
ColoursOnOff	rs.b	1

Blank2		rs.b	2

SeparateCols	rs.b	1

Blank3		rs.b	1

Ham8Colours	rs.b	1

Blank4		rs.b	10

BitmapType	rs.b	1
PaletteSize	rs.b	1

Blank5		rs.b	6



*************
* CONSTANTS *
*************

dosname	dc.b	'dos.library',0
	even

title	dc.b	10,'  IFF-Binary V1.4  --  Written AUG 1994 by Jason Lucas',10,10
	dc.b	9,' For a list of the options available and their',10
	dc.b	9,' use refer to the Docfile.',10,10
	even
titlelen	equ	*-title

Sourcetext
	dc.b	9,'Source File :- ',0
	even
Sourcetextlen	equ	*-Sourcetext

Optionstext
	dc.b	'    Specify Options :- ',0
	even
Optionstextlen	equ	*-Optionstext

Destinationtext
	dc.b	'   Destination File :- ',0
	even
Destinationtextlen	equ	*-Destinationtext

Error1text
	dc.b	10,9,'Error -- No input filename specified',10,10,0
	even
Error1textlen	equ	*-Error1text

Error2text
	dc.b	10,9,'Error -- No output filename specified',10,10,0
	even
Error2textlen	equ	*-Error2text

Error3text
	dc.b	10,9,'Error -- Could not get lock on input file',10,10,0
	even
Error3textlen	equ	*-Error3text

Error4text
	dc.b	10,9,'Error -- Could not examine input file',10,10,0
	even
Error4textlen	equ	*-Error4text

Error5text
	dc.b	10,9,'Error -- Could not write output file',10,10,0
	even
Error5textlen	equ	*-Error5text

Error6text
	dc.b	10,9,'Error -- Could not open input file',10,10,0
	even
Error6textlen	equ	*-Error6text

Error7text
	dc.b	10,9,'Error -- Could not read input file',10,10,0
	even
Error7textlen	equ	*-Error7text

Error8text
	dc.b	10,9,'Error -- Could not open output file',10,10,0
	even
Error8textlen	equ	*-Error8text

Error9text
	dc.b	10,9,'Error -- Could not write output file',10,10,0
	even
Error9textlen	equ	*-Error9text

Error10text
	dc.b	10,9,'Error -- Could not allocate source memory',10,10,0
	even
Error10textlen	equ	*-Error10text

Error11text
	dc.b	10,9,'Error -- Could not allocate destination memory',10,10,0
	even
Error11textlen	equ	*-Error11text

Error12text
	dc.b	10,9,'Error -- File not of required type',10,10,0
	even
Error12textlen	equ	*-Error12text

Error13text
	dc.b	10,9,'Error -- Cannot find BODY ',10,10,0
	even
Error13textlen	equ	*-Error13text
