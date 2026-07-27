
LOADFILE	MACRO		; \1 = pointer to name \2 = size
				; \3 = address to load to
* Get lock on input file

	move.l	\1,d1
	moveq	#-2,d2			ACCESS_READ
	CALLDOS	Lock
	tst.l	d0
	beq.s	\@1

* Unlock input file

	move.l	d0,d1
	CALLDOS	UnLock

* Open input file

	move.l	\1,d1
	move.l	#1005,d2		MODE_OLDFILE
	CALLDOS	Open
	move.l	d0,InputHandle
	beq.s	\@2

* Read input file into memory

	move.l	InputHandle(pc),d1
	move.l	\3,d2
	move.l	\2,d3
	CALLDOS	Read
	tst.l	d0
	bmi.s	\@3

* Close input file

	move.l	InputHandle(pc),d1
	CALLDOS	Close
	moveq	#0,d0
	bra.s	\@

\@1
	moveq	#1,d0			could not locate input file
	bra.s	\@
\@2
	moveq	#2,d0			could not open file
	bra.s	\@
\@3
	move.l	InputHandle(pc),d1
	CALLDOS	Close
	moveq	#3,d0			could not read file

\@
	ENDM

SAVEFILE	MACRO		; \1 = Filename \2 = filesize
				; \3 = address to save

* Open output file

	move.l	\1,d1
	move.l	#1006,d2		MODE_NEWFILE
	CALLDOS	Open
	move.l	d0,OutputHandle
	beq.s	\@4

* Write to output file

	move.l	OutputHandle(pc),d1
	move.l	\3,d2
	move.l	\2,d3
	CALLDOS	Write
	tst.l	d0
	bmi.s	\@5

* Close output file

	move.l	OutputHandle(pc),d1
	CALLDOS	Close
	moveq	#0,d0
	bra.s	\@

\@4	moveq	#2,d0			could not open file
	bra.s	\@

\@5
	move.l	OutputHandle(pc),d1
	CALLDOS	Close
	moveq	#4,d0			could not write to file

\@
	ENDM

**********************************************

FREQ_LOAD	equ	0
FREQ_SAVE	equ	2

FILE_NAME_LENGTH	equ	110


request.dir.name

* d7 = function (FREQ_LOAD / FREQ_SAVE)

	moveq	#RT_FILEREQ,d0		initialise file requester
	sub.l	a0,a0
	CALLRT	AllocRequestA
	move.l	d0,file.req
	beq.s	.requester.not.allocated

	lea	file.req.tags1(pc),a0
	move.l	file.req(pc),a1
	CALLRT	ChangeReqAttrA

	move.l	UFO_EditorWnd(pc),file.req.window
	moveq	#FREQF_PATGAD!FREQF_NOFILES,d0
	cmp.w	#FREQ_SAVE,d7
	bne.s	.flags
	or.l	#FREQF_SAVE,d0

.flags	move.l	d0,file.req.flags
	lea	file.req.tags2(pc),a0
	move.l	file.req(pc),a1
	lea	file.name(pc),a2
	lsl.w	#2,d7
	lea	file.req.prompts(pc),a3
	move.l	(a3,d7.w),a3

.freq	CALLRT	FileRequestA		request file name from user

	tst.l	d0
	beq.s	.not.selected

	move.l	file.req(pc),a0
	move.l	rtfi_Dir(a0),SelectedDir

.done	move.l	file.req(pc),a1
	CALLRT	FreeRequest

	moveq	#0,d0
	rts

.not.selected
	move.l	file.req(pc),a1
	CALLRT	FreeRequest

.requester.not.allocated
	moveq	#-1,d0
	rts

file.req.tags1
	dc.l	RTFI_Dir,file.req.dir
	dc.l	TAG_END

file.req.tags2
	dc.l	RTFI_Flags
file.req.flags
	dc.l	FREQF_PATGAD!FREQF_SAVE!FREQF_NOFILES
	dc.l	RTFI_Height,230
	dc.l	RT_ReqPos,REQPOS_CENTERSCR
	dc.l	RT_TopOffset,6
	dc.l	RT_Window
file.req.window
	dc.l	0
	dc.l	TAG_END


SelectedDir	dc.l	0

file.name	ds.b	FILE_NAME_LENGTH

file.req.dir	dc.b	'SYS:',0
	even

file.req.prompts
	dc.l	req.load.text
	dc.l	0
	dc.l	req.save.text


req.load.text	dc.b	'Select Save Game Directory',0
	even

req.save.text	dc.b	'Select Directory To Save To',0
	even

file.req	dc.l	0

*---------------------------------------------------------------------------*

Directory.Path	ds.b	FILE_NAME_LENGTH
TemporyFullPath	ds.b	FILE_NAME_LENGTH

Load.Files.And.Process
	move.l	SelectedDir,a0
	lea	Directory.Path,a1

.Next.Letter
	move.b	(a0)+,d0
	beq.s	.Directory.Found

	move.b	d0,(a1)+
	bra.s	.Next.Letter

.Directory.Found
	move.b	#'/',(a1)+
	move.b	#0,(a1)

	lea	Directory.Path,a0
	lea	BaseFilename,a1
	bsr	MakeFullName

	LOADFILE	#TemporyFullPath,#2320,#Base.Dat
	bne	LoadErrorHandler

	bsr	CopyDataToRequesterTables
	bsr	InitiliseStoresValues
	bsr	CountNumberOfBases
	bsr	SetBaseNames

	lea	Directory.Path,a0
	lea	ResearchFilename,a1
	bsr	MakeFullName

	LOADFILE	#TemporyFullPath,#1536,#Research.Dat
	bne	LoadErrorHandler

	lea	Directory.Path,a0
	lea	MoneyFilename,a1
	bsr	MakeFullName

	LOADFILE	#TemporyFullPath,#148,#Money.Dat
	bne.s	LoadErrorHandler

LoadOk
	move.l	Money.Dat,Money

	lea	UFO_EditorGadgets,a3
	moveq	#10-1,d7

EnableNext
	move.l	(a3)+,a0
	move.l	UFO_EditorWnd,a1
	sub.l	a2,a2
	CALLINT	OnGadget

	dbra	d7,EnableNext

	move.l	#0,SliderOn
	move.l	#1,SliderDefault

	sf	SaveFacility
	sf	SaveUfoPedia
	sf	SaveResearch
	sf	SaveProducts

	rts

LoadErrorHandler
	lea	ErrorTable,a0
	subq.w	#1,d0
	mulu	#4,d0
	move.l	(a0,d0.w),a0		string
	sub.l	a1,a1
	bsr	printf
	rts

*---------------------------------------------------------------------------*

Process.Files.And.Save
	lea	Directory.Path,a0
	lea	BaseFilename,a1
	bsr	MakeFullName

	bsr	CopyTablesToBaseDat

	SAVEFILE	#TemporyFullPath,#2320,#Base.Dat
	bne	SaveErrorHandler

	move.l	Money(pc),Money.Dat

	lea	Directory.Path,a0
	lea	MoneyFilename,a1
	bsr	MakeFullName

	SAVEFILE	#TemporyFullPath,#148,#Money.Dat
	bne	SaveErrorHandler

	tst.b	SaveFacility
	beq.s	CheckSaveResearch

	lea	Directory.Path,a0
	lea	FacilitiesFilename,a1
	bsr	MakeFullName

	SAVEFILE	#TemporyFullPath,#FACILLENGTH,#Facil.Dat
	bne	SaveErrorHandler

CheckSaveResearch
	tst.b	SaveResearch
	beq.s	CheckSaveProduct

	lea	Directory.Path,a0
	lea	ResearchFilename,a1
	bsr	MakeFullName

	SAVEFILE	#TemporyFullPath,#RESEARCHLENGTH,#Research.Dat
	bne	SaveErrorHandler

CheckSaveProduct
	tst.b	SaveProducts
	beq.s	CheckSaveUfoPedia

	lea	Directory.Path,a0
	lea	ProductFilename,a1
	bsr	MakeFullName

	SAVEFILE	#TemporyFullPath,#PRODUCTLENGTH,#Product.Dat
	bne.s	SaveErrorHandler

CheckSaveUfoPedia
	tst.b	SaveUfoPedia
	beq.s	SaveOk

	lea	Directory.Path,a0
	lea	UfopediaFilename,a1
	bsr	MakeFullName

	SAVEFILE	#TemporyFullPath,#UFOPEDIALENGTH,#UfoPedia.Dat
	bne.s	SaveErrorHandler

SaveOk
	rts

SaveErrorHandler
	lea	ErrorTable,a0
	subq.w	#1,d0
	mulu	#4,d0
	move.l	(a0,d0.w),a0		string
	sub.l	a1,a1
	bsr	printf
	rts

*---------------------------------------------------------------------------*

BaseFilename	dc.b	'base.dat',0
	even
MoneyFilename	dc.b	'liglob.dat',0
	even
FacilitiesFilename	dc.b	'facil.dat',0
	even
ResearchFilename	dc.b	'Research.dat',0
	even
ProductFilename		dc.b	'product.dat',0
	even
UfopediaFilename	dc.b	'up.dat',0
	even

InputHandle	dc.l	0
OutputHandle	dc.l	0

CopyCounts	dc.w	10,5,19,9,13,18,10
SkipValues	dc.w	0,6,0,6

BASESTART	equ	22
CONSTTIME	equ	58
STORESA		equ	96
STORESB		equ	194

*---------------------------------------------------------------------------*

MakeFullName
	lea	TemporyFullPath,a2

.NextDirLetter
	move.b	(a0)+,d0
	beq.s	.CopyFilename

	move.b	d0,(a2)+
	bra.s	.NextDirLetter

.CopyFilename
	move.b	(a1)+,(a2)+
	bne.s	.CopyFilename

	rts

*---------------------------------------------------------------------------*

CountNumberOfBases

	lea	Base.Dat,a1
	moveq	#1,d0

.NextBaseCheck
	lea	290(a1),a1
	lea	BASESTART(a1),a2

	moveq	#36-1,d7

.CheckLoop
	cmp.b	#19,(a2)
	ble.s	.ByteOk

	cmp.b	#$ff,(a2)
	beq.s	.ByteOk

	bra.s	.ExitBaseCheck

.ByteOk
	addq.l	#1,a2
	dbra	d7,.CheckLoop

	addq.w	#1,d0
	cmp.w	#8,d0
	beq.s	.ExitBaseCheck

	bra.s	.NextBaseCheck

.ExitBaseCheck
	move.w	d0,BaseCount
	move.w	#0,BaseToEdit
	rts

BaseCount	dc.w	1

*---------------------------------------------------------------------------*

SetBaseNames
	move.w	BaseCount,d0
	subq.w	#1,d0		get number of bases to read name

	lea	Base.Dat,a0
	lea	BaseName1,a1

.NextBase
	moveq	#30-1,d7	read 30 characters
	moveq	#0,d1

.ReadName
	move.b	(a0,d1.w),(a1,d1.w)
	addq.w	#1,d1
	dbra	d7,.ReadName

	lea	290(a0),a0
	lea	40(a1),a1
	dbra	d0,.NextBase

	rts

BaseName1	ds.b	40
BaseName2	ds.b	40
BaseName3	ds.b	40
BaseName4	ds.b	40
BaseName5	ds.b	40
BaseName6	ds.b	40
BaseName7	ds.b	40
BaseName8	ds.b	40

*---------------------------------------------------------------------------*

SetBaseEditGadgets
	move.w	BaseToEdit,d2
	mulu	#290,d2

	lea	Base.Dat,a0
	lea	BASESTART(a0,d2.w),a0

	lea	Base.Text(pc),a1
	lea	FacilityTextPointers(pc),a2

	moveq	#36-1,d7
	moveq	#0,d6

.BaseLoop
	moveq	#0,d0
	move.b	(a0)+,d0		get map building byte

	cmp.b	#$ff,d0
	beq.s	.BlankSquare

	add.w	d0,d0

	move.w	(a1,d0.w),d1		get text for that building
	bra.s	.WriteSquare

.BlankSquare
	move.w	#'  ',d1

.WriteSquare
	move.w	d6,d5
	add.w	d5,d5
	add.w	d5,d5

	move.l	(a2,d5.w),a3		get icon text pointer
	move.w	d1,(a3)			write new base text

	addq.w	#1,d6
	dbra	d7,.BaseLoop

	move.w	BaseToEdit,d0
	mulu	#40,d0

	lea	BaseName1,a0
	lea	(a0,d0.w),a0

	lea	FacilityTitle,a1
	moveq	#40-1,d7
.CopyName
	move.b	(a0)+,(a1)+
	dbra	d7,.CopyName	

	rts

*---------------------------------------------------------------------------*

CopyDataToRequesterTables
	lea	CopyCounts(pc),a0
	lea	CraftWeaponTable(pc),a1
	lea	Base.Dat,a2
	lea	STORESA(a2),a2
	lea	SkipValues(pc),a3

	moveq	#4-1,d7
.Copylop1
	move.w	(a0)+,d6	d6 = number of items in this section
	subq.w	#1,d6		minus 1 for dbra
.Copylop2
	move.w	(a2)+,(a1)+	
	dbra	d6,.Copylop2
	add.w	(a3)+,a1	skip value is double for words. It is used
	dbra	d7,.Copylop1	for skipping the extra tableB's.

	lea	Base.Dat,a2
	lea	STORESB(a2),a2

	moveq	#3-1,d7
.Copylop3
	move.w	(a0)+,d6
	subq.w	#1,d6
.Copylop4
	move.w	(a2)+,(a1)+	
	dbra	d6,.Copylop4
	dbra	d7,.Copylop3

	lea	XcomMiscTableB,a1
	move.w	(a2)+,(a1)+
	move.w	(a2)+,(a1)+
	move.w	(a2)+,(a1)
	lea	HWPTableB,a1
	move.w	(a2)+,(a1)+
	move.w	(a2)+,(a1)+
	move.w	(a2),(a1)

	rts

InitiliseStoresValues
	moveq	#0,d0
	move.w	CraftWeaponTable(pc),d0
	move.l	d0,Val1				Val* = string requester
	move.w	HWPTableA(pc),d0
	move.l	d0,Val2
	move.w	XcomArmTable(pc),d0
	move.l	d0,Val3
	move.w	XcomMiscTableA(pc),d0
	move.l	d0,Val4
	move.w	AlienWeaponsTable(pc),d0
	move.l	d0,Val5
	move.w	AliensTable(pc),d0
	move.l	d0,Val6
	move.w	AlienMiscTable(pc),d0
	move.l	d0,Val7

	move.w	#0,CraftWeaponCount
	move.w	#0,HWPCount
	move.w	#0,XCOMWeaponCount
	move.w	#0,XCOMMiscCount
	move.w	#0,AlienWeaponCount
	move.w	#0,AlienCount
	move.w	#0,AlienMiscCount

	rts

*---------------------------------------------------------------------------*

ResetEditor
	sf	SaveFacility
	sf	SaveUfoPedia
	sf	SaveResearch
	sf	SaveProducts

	lea	UFO_EditorGadgets+4*6,a3
	moveq	#4-1,d7

DisableNext1
	move.l	(a3)+,a0
	move.l	UFO_EditorWnd,a1
	sub.l	a2,a2
	CALLINT	OffGadget

	dbra	d7,DisableNext1

	lea	UFO_EditorGadgets,a3
	moveq	#3-1,d7

DisableNext2
	move.l	(a3)+,a0
	move.l	UFO_EditorWnd,a1
	sub.l	a2,a2
	CALLINT	OffGadget

	dbra	d7,DisableNext2

	lea	UFO_EditorGadgets+4*4,a3
	move.l	(a3)+,a0
	move.l	UFO_EditorWnd,a1
	sub.l	a2,a2
	CALLINT	OffGadget

	move.l	#1,SliderOn

	move.l	#1,MaxBase
	lea	UFO_EditorGadgets+4*10,a0
	move.l	(a0),a0
	move.l	UFO_EditorWnd,a1
	sub.l	a2,a2
	lea	SliderAttr,a3

	CALLGAD	SetGadgetAttrsA

	lea	UFO_EditorGadgets+4*10,a0
	move.l	(a0),a0
	move.l	UFO_EditorWnd,a1
	sub.l	a2,a2
	CALLINT	RefreshGadgets

	rts

*---------------------------------------------------------------------------*

CopyTablesToBaseDat

	lea	CraftWeaponTable(pc),a0
	lea	Base.Dat,a1
	lea	STORESA(a1),a1
	lea	SkipValues(pc),a2
	lea	CopyCounts(pc),a3

	moveq	#4-1,d7
.CopyLop1
	move.w	(a3)+,d6
	subq.w	#1,d6
.CopyLop2
	move.w	(a0)+,(a1)+
	dbra	d6,.CopyLop2

	add.w	(a2)+,a0
	dbra	d7,.CopyLop1

	lea	Base.Dat,a1
	lea	STORESB(a1),a1

	moveq	#3-1,d7
.Copylop3
	move.w	(a3)+,d6
	subq.w	#1,d6
.Copylop4
	move.w	(a0)+,(a1)+
	dbra	d6,.Copylop4
	dbra	d7,.Copylop3

	lea	XcomMiscTableB(pc),a0
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0),(a1)+

	lea	HWPTableB(pc),a0
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0),(a1)

	rts

*---------------------------------------------------------------------------*


Error1	dc.b	10,9,'Could Not Locate Data Files.',10,0
	even
Error2	dc.b	10,9,'Could Not Open Load Files.',10,0
	even
Error3	dc.b	10,9,'Could Not Read Files.',10,0
	even
Error4	dc.b	10,9,'Could Not Write Files.',10,0
	even

ErrorTable	dc.l	Error1,Error2,Error3,Error4

