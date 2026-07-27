current:
;	move.l	(a0)+,d0		.A.B.C.D	*
;	move.l	(a0)+,d1		.E.F.G.H
;	move.l	(a0)+,d2		.I.J.K.L	*
;	move.l	(a0)+,d3		.M.N.O.P
;	move.l	(a0)+,d4		.Q.R.S.T	*
;	move.l	(a0)+,d5		.U.V.W.X
;	move.l	(a0)+,d6		.Y.Z.a.b	*
;	move.l	(a0)+,d7		.c.d.e.f

Order in memory:
	.A.B.C.D	.E.F.G.H	.I.J.K.L	.M.N.O.P	.Q.R.S.T	.U.V.W.X	.Y.Z.a.b	.c.d.e.f


want:
	A.I.Q.Y.
	.E.M.U.c
	B.J.R.Z.
	.F.N.V.d
	C.K.S.a.
	.G.O.W.e
	D.L.T.b.
	.H.P.X.f

Order in memory:
	A.I.Q.Y.	B.J.R.Z.	C.K.S.a.	D.L.T.b.	.E.M.U.c	.F.N.V.d	.G.O.W.e	.H.P.X.f



.next.32.pixels
;	move.l	(a0)+,d0		.A.B.C.D	*
;	move.l	(a0)+,d1		.E.F.G.H
;	move.l	(a0)+,d2		.I.J.K.L	*
;	move.l	(a0)+,d3		.M.N.O.P
;	move.l	(a0)+,d4		.Q.R.S.T	*
;	move.l	(a0)+,d5		.U.V.W.X
;	move.l	(a0)+,d6		.Y.Z.a.b	*
;	move.l	(a0)+,d7		.c.d.e.f
	movem.l	(a0)+,d0-d6		68

	lsl.l	#4,d0			A.B.C.D.	16
	lsl.l	#4,d2			I.J.K.L.	16
	lsl.l	#4,d4			Q.R.S.T.	16
	lsl.l	#4,d6			Y.Z.a.b.	16
	or.l	d1,d0			AEBFCGDH	8
	or.l	d3,d2			IMJNKOLP	8
	or.l	d5,d4			QURVSWTX	8
	or.l	(a0)+,d6		YcZdaebf	14

	swap	d4			SWTXQURV	4
	move.w	d0,d1			....CGDH	4
	move.w	d4,d0			AEBFQURV	4
	move.w	d1,d4			SWTXCGDH	4
	swap	d4			CGDHSWTX	4

	swap	d6			aebfYcZd	4
	move.w	d2,d3			....KOLP	4
	move.w	d6,d2			IMJNYcZd	4
	move.w	d3,d6			aebfKOLP	4
	swap	d6			KOLPaebf	4

	move.l	a5,d5					4

	move.l	d0,d1					4
	and.l	d5,d1			..BF..RV	8
	eor.l	d1,d0			AE..QU..	8
	move.l	d2,d3					4
	and.l	d5,d3			..JN..Zd	8
	eor.l	d3,d2			IM..Yc..	8
	lsl.l	#8,d1			BF..RV..	24
	lsr.l	#8,d2			..IM..Yc	24
	or.l	d2,d0			AEIMQUYc	8
	or.l	d3,d1			BFJNRVZd	8

	move.l	d4,d2					4
	and.l	d5,d4			..DH..TX	8
	eor.l	d4,d2			CG..SW..	8
	move.l	d6,d3					4
	and.l	d5,d3			..LP..bf	8
	eor.l	d3,d6			KO..ae..	8
	lsl.l	#8,d4			DH..TX..	24
	lsr.l	#8,d6			..KO..ae	24
	or.l	d6,d2			CGKOSWae	8
	or.l	d4,d3			DHLPTXbf	8

; now continue here
	move.l	a6,d6					4

	move.l	d0,d4	4
	and.l	d6,d0	8		.A.E.I.M.Q.U.Y.c	bits 10
	eor.l	d0,d4	8		A.E.I.M.Q.U.Y.c.	bits 32
	move.l	d2,d5	4
	and.l	d6,d5	8		.C.G.K.O.S.W.a.e	bits 10
	eor.l	d5,d2	8		C.G.K.O.S.W.a.e.	bits 32
	lsl.l	#2,d0	12		A.E.I.M.Q.U.Y.c.	bits 10
	lsr.l	#2,d2	12		.C.G.K.O.S.W.a.e	bits 32
	or.l	d5,d0	8		ACEGIKMOQSUWYace	bits 10
	or.l	d4,d2	8		ACEGIKMOQSUWYace	bits 32

	move.l	d1,d4	4
	and.l	d6,d1	8		.B.F.J.N.R.V.Z.d	bits 10
	eor.l	d1,d4	8		B.F.J.N.R.V.Z.d.	bits 32
	move.l	d3,d5	4
	and.l	d6,d5	8		.D.H.L.P.T.X.b.f	bits 10
	eor.l	d5,d3	8		D.H.L.P.T.X.b.f.	bits 32
	lsl.l	#2,d1	12		B.F.J.N.R.V.Z.d.	bits 10
	lsr.l	#2,d3	12		.D.H.L.P.T.X.b.f	bits 32
	or.l	d5,d1	8		BDFHJLNPRTVXZbdf	bits 10
	or.l	d4,d3	8		BDFHJLNPRTVXZbdf	bits 32

	move.l	a7,d6	4

	move.l	d0,d4	4
	and.l	d6,d0	8	.A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e    bits 0
	eor.l	d0,d4	8	A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e.    bits 1
	add.l	d0,d0	8	A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e.    bits 0
	move.l	d1,d5	4
	and.l	d6,d5	8	.B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f    bits 0
	or.l	d5,d0	8	ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef    bits 0
	move.l	d0,(a4)+	12	plane 0
	eor.l	d5,d1	8	B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f.    bits 1
	lsr.l	#1,d1	10	.B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f    bits 1
	or.l	d4,d1	8	ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef    bits 1
	move.l	d1,(a3)+	12	plane 1

	move.l	d2,d4	4
	and.l	d6,d2	8	.A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e    bits 2
	eor.l	d2,d4	8	A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e.    bits 3
	add.l	d2,d2	8	A.C.E.G.I.K.M.O.Q.S.U.W.Y.a.c.e.    bits 2
	move.l	d3,d5	4
	and.l	d6,d5	8	.B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f    bits 2
	or.l	d5,d2	8	ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef    bits 2
	move.l	d2,(a2)+	12	plane 2
	eor.l	d5,d3	8	B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f.    bits 3
	lsr.l	#1,d3	10	.B.D.F.H.J.L.N.P.R.T.V.X.Z.b.d.f    bits 3
	or.l	d4,d3	8	ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef    bits 3
	move.l	d3,(a1)+	12	plane 3

;	move.l	d3,(a1)+		plane 3
;	move.l	d2,(a2)+		plane 2
;	move.l	d1,(a3)+		plane 1
;	move.l	d0,(a4)+		plane 0
	dbra	d7,.next.32.pixels	14

	move.l	saved.a7(pc),a7		16
	rts				16


saved.a7	dc.l	0
chunky.memory	dc.l	0
screen1		dc.l	0




/*	======================================================================================= */
/*	Function:		TextureScansFaster8														*/
/*																							*/
/*	Description:	Fill display buffer scan-lines (8 bits per pixel) with texture			*/
/*					Uses linear interpolation to reduce the number of divides performed		*/
/*	======================================================================================= */

#define	LINEAR_SIZE		16

#define	LOG_TX_PRECISION	10


static void TextureScansFaster8( BYTE *p,
								 long next_scan,
								 long *end_marker,
								 long max_x )
{
	BYTE	*cp;	// current pointer
	long	y, x0, x1, length, offset;
	long	*info;

	long	ui, uj, uc;		// co-efficients for x mapping equation
	long	vi, vj, vc;		// co-efficients for y mapping equation
	long	zi, zj, zc;		// co-efficients for x and y mapping equations

	long	uline, vline, zline;	// values for a whole scan-line
	long	zpixel;					// value for a specific pixel

	long	txstart, tystart;		// position within texture
	long	txend, tyend;			// position within texture
	long	txinc, tyinc;			// increments per pixel

	long	txmax = (0x1<<(Log_Texture_Width+LOG_TX_PRECISION)) - 0x1,	// texture limits
			tymax = (0x1<<(Log_Texture_Height+LOG_TX_PRECISION)) - 0x1;


	// include precision within Log_Texture_Scale, for the duration of this function
	Log_Texture_Scale += LOG_TX_PRECISION;

	// get start y
	info = FillInfo;
	y = *info++;

	if (info >= end_marker)
		return;

	// calculate co-efficients for texture mappin
/*
	ui = (Vz*Oy) - (Vy*Oz);
	uj = (Vx*Oz) - (Vz*Ox);
	uc = (Vy*Ox) - (Vx*Oy);

	vi = (Uy*Oz) - (Uz*Oy);
	vj = (Uz*Ox) - (Ux*Oz);
	vc = (Ux*Oy) - (Uy*Ox);

	zi = (Vy*Uz) - (Vz*Uy);
	zj = (Vz*Ux) - (Vx*Uz);
	zc = (Vx*Uy) - (Vy*Ux);
*/
	special case for y rotation only - Vx = Vz = Uy = 0
	ui = 0 - (Vy*Oz);
	uj = 0;
	uc = (Vy*Ox);

	vi = 0 - (Uz*Oy);
	vj = (Uz*Ox) - (Ux*Oz);
	vc = (Ux*Oy);

	zi = (Vy*Uz);
	zj = 0;
	zc = 0 - (Vy*Ux);


	// point to start scan-line
	p += (y * next_scan);

	// remove origin translation
	y -= Screen_Height/2;

	// loop, drawing each scan-line
	do
		{
		x0 = *info++;	// start
		x1 = *info++;	// end

		// limit to screen boundaries
		if (x0 < 0)
			if (x1 < 0)
				goto next_line;
			else
				x0 = 0;

		if (x1 > max_x)
			if (x0 > max_x)
				goto next_line;
			else
				x1 = max_x;

		// get pointer to first byte
		cp = p + x0;

		// remove origin translation
		x0 -= Screen_Width/2;
		x1 -= Screen_Width/2;

		// calculate y and constant part of equations
		// i.e. these values are constant for a whole scan-line
		uline = ((y*uj)>>Log_Focus) + uc;
		vline = ((y*vj)>>Log_Focus) + vc;
		zline = ((y*zj)>>Log_Focus) + zc;

		// calculate initial position within texture
		if ((zpixel = zline + ((x0*zi)>>Log_Focus)) != 0)
			{
			txend = ((uline + ((x0*ui)>>Log_Focus)) << Log_Texture_Scale) / zpixel;
			tyend = ((vline + ((x0*vi)>>Log_Focus)) << Log_Texture_Scale) / zpixel;
			}

		// limit to texture size - this method is better than simple
		// masking because it eliminates the wrap-around fringes

		// for extra speed, this is now only done on the start and end positions
		// of a linear run, rather than on every single position within the run
		// (this isn't totally correct, but it's faster !!)

		// note: (for example Texture_Scale, Texture_Width and Texture_Height of 64)
		//       Texture_Scale would also ideally be 63 rather than 64
		//       Alternatively, Texture could be 65 wide and we then limit to 64

		if (txend < 0)
			txend = 0;
		else
			if (txend > txmax)
				txend = txmax;

		if (tyend < 0)
			tyend = 0;
		else
			if (tyend > tymax)
				tyend = tymax;

		// loop, drawing each pixel on current scan-line
		do
			{
			length = LINEAR_SIZE;

			x0 += length;
			if (x0 >= x1)
				{
				length -= ((x0 - x1) - 1);
				x0 = x1;
				}

			txstart = txend;
			tystart = tyend;

			// calculate next position within texture
			if ((zpixel = zline + ((x0*zi)>>Log_Focus)) != 0)
				{
				txend = ((uline + ((x0*ui)>>Log_Focus)) << Log_Texture_Scale) / zpixel;
				tyend = ((vline + ((x0*vi)>>Log_Focus)) << Log_Texture_Scale) / zpixel;
				}

			// limit to texture size
			if (txend < 0)
				txend = 0;
			else
				if (txend > txmax)
					txend = txmax;

			if (tyend < 0)
				tyend = 0;
			else
				if (tyend > tymax)
					tyend = tymax;

			// calculate texture position increments
			if (length != 0)
				{
				txinc = (txend - txstart) / length;
				tyinc = (tyend - tystart) / length;
				}

			// do a linear run of pixels
			do
				{
				// draw pixel
				*cp++ = *(Fill_Texture + ((tystart>>LOG_TX_PRECISION)<<Log_Texture_Width) +
										  (txstart>>LOG_TX_PRECISION));

				offset = ((tystart>>LOG_TX_PRECISION)<<Log_Texture_Width) +
						 (txstart>>LOG_TX_PRECISION);

				// special case where LOG_TX_PRECISION = Log_Texture_Width is faster :-
				//*cp++ = *(Fill_Texture + (tystart & tymask) + (txstart>>LOG_TX_PRECISION));

				// update position within texture
				txstart += txinc;
				tystart += tyinc;
				}
			while (--length > 0);
			}
		while (x0 < x1);

next_line:
		y++;
		p += next_scan;
		}
	while (info < end_marker);

	// remove precision from Log_Texture_Scale
	Log_Texture_Scale -= LOG_TX_PRECISION;
}

