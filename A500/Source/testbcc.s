
	moveq	#0,d1

one	move.b	#$0,d0
	cmp.b	#$f0,d0
	bcc	two
	moveq	#1,d1

two	move.b	#$f0,d0
	cmp.b	#$f0,d0
	bcc	three
	moveq	#2,d1

three	move.b	#$f1,d0
	cmp.b	#$f0,d0
	bcc	four
	moveq	#3,d1

four	move.b	#$ff,d0
	cmp.b	#$f0,d0
	bcc	five
	moveq	#4,d1

five	move.b	#$ef,d0
	cmp.b	#$f0,d0
	bcc	end
	moveq	#5,d1

end	rts
