	section	DiskIn,code




* Flashes the power light if a disk is in drive 0

	move.w	$dff01c,d1
	move.w	#$7fff,$dff09a

	move.b	#%01111111,$bfd100	motor on
	nop
	nop
	move.b	#%11110111,$bfd100	select drive 0, motor on
	nop
	nop
	move.b	#%11110111,$bfd100	select drive 0, motor off
	nop
	nop
	move.b	#%11111111,$bfd100	select no drive

	btst	#2,$bfe001
	beq.s	no.disk.in.drive

	bchg	#1,$bfe001

no.disk.in.drive
	or.w	#$c000,d1
	move.w	d1,$dff09a
	moveq	#0,d0
	rts
