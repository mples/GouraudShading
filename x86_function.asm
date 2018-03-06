section .data
	XL:		DD	0
	XR:		DD	0

	XC:		DD	0

	BC:		DD	0
	GC:		DD	0
	RC:		DD	0

	DB:		DD	0
	DG:		DD	0
	DR:		DD	0

;FP operations
	RES:	DD	0
	OP1:	DD	0
	OP2:	DD	0

	DAB:	DD	0
	DAC:	DD	0

;LEFT colors
	BLEFT:	DD	0
	GL:		DD	0
	RL:		DD	0

;RIGHT colors
	BR:		DD	0
	GR:		DD	0
	RR:		DD	0

;AB color increments
	BAB:	DD	0
	GAB:	DD	0
	RAB:	DD	0

;AC color increments
	BAC:	DD	0
	GAC:	DD	0
	RAC:	DD	0

;BC	color increments
	BBC:	DD	0
	GBC:	DD	0
	RBC:	DD	0

;Second half
	DXLEFT:		DD	0
	DXRIGHT:	DD	0

	DBLEFT:		DD	0
	DGLEFT:		DD	0
	DRLEFT:		DD	0

	DBRIGHT:	DD	0
	DGRIGHT:	DD	0
	DRRIGHT:	DD	0
	

section .text
	
	global x86_function

x86_function:
	push rbp	; push "calling procedure" frame pointer
	mov rbp, rsp	; set new frame pointer 
			;	- "this procedure" frame pointer

;dst =		rdi
;width =	rsi
;height =	rdx
;rowsize =	rcx
;triangle =	r8

;Ax =		[r15]
;Ay =		[r15 + 4]
;A_colors =	[r15 + 8-10]
;Bx =		[r15 + 12]
;By =		[r15 + 16]
;B_colors =	[r15 + 20-22]
;Cx =		[r15 + 24]
;Cy =		[r15 + 28]
;C_colors =	[r15 + 32-34]

;------------------------------------------------------------------------------

	mov	r15,	r8
	mov 	r14,	rcx
	mov	r13,	rdx
	mov	r12,	rsi
	mov 	r11,	rdi

upper_triangle:
	
	mov		r8d,	dword [r15]
	mov		r9d,	dword [r15 + 4]	;r8=x, r9=y

	mov		r10,	r9
	imul	r10,	r14
	mov		rax,	r8
	imul	rax,	rax,	3
	add		r10,	rax
	add		r10,	r11				;calculate A-vertex

	mov		rdi,	r10
	
	mov		al,		[r15 + 8]
	stosb

	mov		al,		[r15 + 9]
	stosb

	mov		al,		[r15 + 10]
	stosb							;copy A-pixel to result

;CALCULATE DAB BELOW

	mov		eax,	r9d

	sub		eax,	[r15 + 16]

	mov		[OP1],	eax				;Ay - By

	mov		eax,	[r15 + 12]
	sub		eax,	r8d

	mov		[OP2],	eax

	fild	dword [OP2]
	fidiv	dword [OP1]

	fstp	dword [DAB]

;CALCULATE DAC BELOW

	mov		eax,	r9d
	sub		eax,	[r15 + 28]

	mov		[OP1],	eax				;Ay - Cy

	mov		eax,	[r15 + 24]
	sub		eax,	r8d

	mov		[OP2],	eax

	fild	dword [OP2]
	fidiv	dword [OP1]

	fstp	dword [DAC]

;COLOR AB

	mov		esi,	r9d
	sub		esi,	[r15 + 16]		;Ay - By

	mov		[OP1],	esi

;B
	mov		rax,	0
	mov		rbx,	0

	mov		al,		[r15 + 20]
	mov		bl,		[r15 + 8]
	sub		eax,	ebx

	mov		[OP2],	eax

	fild	dword [OP2]
	fidiv	dword [OP1]

	fstp	dword [BAB]

;G
	mov		rax,	0
	mov		rbx,	0

	mov		al,		[r15 + 21]
	mov		bl,		[r15 + 9]
	sub		eax,	ebx

	mov		[OP2],	eax

	fild	dword [OP2]
	fidiv	dword [OP1]

	fstp	dword [GAB]

;R
	mov		rax,	0
	mov		rbx,	0

	mov		al,		[r15 + 22]
	mov		bl,		[r15 + 10]
	sub		eax,	ebx

	mov		[OP2],	eax

	fild	dword [OP2]
	fidiv	dword [OP1]

	fstp	dword [RAB]

;COLOR AC

	mov		esi,	r9d
	sub		esi,	[r15 + 28]

	mov		[OP1],	esi

;B
	mov		rax,	0
	mov		rbx,	0

	mov		al,		[r15 + 32]
	mov		bl,		[r15 + 8]
	sub		eax,	ebx

	mov		[OP2],	eax

	fild	dword [OP2]
	fidiv	dword [OP1]

	fstp	dword [BAC]

;G
	mov		rax,	0
	mov		rbx,	0

	mov		al,		[r15 + 33]
	mov		bl,		[r15 + 9]
	sub		eax,	ebx

	mov		[OP2],	eax

	fild	dword [OP2]
	fidiv	dword [OP1]

	fstp	dword [GAC]

;R
	mov		rax,	0
	mov		rbx,	0

	mov		al,		[r15 + 34]
	mov		bl,		[r15 + 10]
	sub		eax,	ebx

	mov		[OP2],	eax

	fild	dword [OP2]
	fidiv	dword [OP1]

	fstp	dword [RAC]

;################################

	mov		ecx,	r9d

	mov		ebx,	[r15+16]
	cmp		ebx,	[r15+28]
	ja		pickB		

	sub		ecx,	[r15+28]
	jmp		pickDone

pickB:
	sub		ecx,	ebx

pickDone:
	mov		rax,	0

	mov		al,		[r15+8]
	mov		[OP1],	eax
	fild	dword [OP1]
	fst		dword [BLEFT]
	fstp	dword [BR]

	mov		al,		[r15+9]
	mov		[OP1],	eax
	fild	dword [OP1]
	fst		dword [GL]
	fstp	dword [GR]

	mov		al,		[r15+10]
	mov		[OP1],	eax
	fild	dword [OP1]
	fst		dword [RL]
	fstp	dword [RR]

	mov		rdx,	0

	mov		edx,	[r15 + 4]
	dec		edx
	imul	rdx,	r14
	add		rdx,	r11

	mov		eax,	[r15]
	mov		[OP1],	eax
	
	fild	dword [OP1]
	fild	dword [OP1]
	fdecstp

	mov		al,		0

loop:
	
	fxch	st1
	fadd	dword [DAB]
	fist	dword [XL]
	fist	dword [XC]
	fxch	st1

	inc		dword [XC]

	imul	edi,	[XL],	3
	add		rdi,	rdx

	fld		dword [BLEFT]
	fadd	dword [BAB]
	fst		dword [BLEFT]
	fst		dword [BC]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	fld		dword [GL]
	fadd	dword [GAB]
	fst		dword [GL]
	fst		dword [GC]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	fld		dword [RL]
	fadd	dword [RAB]
	fst		dword [RL]
	fst		dword [RC]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	fxch	st2
	fadd	dword [DAC]
	fist	dword [XR]
	fxch	st2

	imul	edi,	[XR],	3
	add		rdi,	rdx

	fld		dword [BR]
	fadd	dword [BAC]
	fst		dword [BR]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	fld		dword [GR]
	fadd	dword [GAC]
	fst		dword [GR]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	fld		dword [RR]
	fadd	dword [RAC]
	fst		dword [RR]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	mov		rdi,	0

	imul	edi,	[XC],	3
	add		rdi,	rdx

;SCANLINE LOOP INIT

	mov		ebx,	[XR]
	sub		ebx,	[XL]
	mov		[OP1],	ebx

;CALC B INC
	fld		dword [BR]
	fsub	dword [BLEFT]
	fidiv	dword [OP1]
	fstp	dword [DB]

;CALC G INC
	fld		dword [GR]
	fsub	dword [GL]
	fidiv	dword [OP1]
	fstp	dword [DG]

;CALC R INC
	fld		dword [RR]
	fsub	dword [RL]
	fidiv	dword [OP1]
	fstp	dword [DR]

	mov		ebx,	[XC]

	cmp		ebx,	[XR]
	jae		skipLoop

fillLoop:
	
	fld		dword [BC]
	fadd	dword [DB]
	fst		dword [BC]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	fld		dword [GC]
	fadd	dword [DG]
	fst		dword [GC]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	fld		dword [RC]
	fadd	dword [DR]
	fst		dword [RC]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	inc		ebx
	cmp		ebx,	[XR]
	jne		fillLoop

skipLoop:

	sub		rdx,	r14

	dec		ecx
	jnz		loop

;SECOND TRIANGLE HALF
	
	mov		ebx,	[r15 + 16]
	mov		ecx,	[r15 + 28]

	cmp		ebx,	ecx
	ja		BGreater

;BY < CY
	mov		r8d,	dword [r15 + 12]
	mov		r9d,	dword [r15 + 16]	;r8=Bx, r9=By

	mov		r10,	r9
	imul	r10,	r14
	mov		rax,	r8
	imul	rax,	rax,	3
	add		r10,	rax
	add		r10,	r11					;calculate B-vertex

	mov		rdi,	r10
	
	mov		al,		[r15 + 20]
	stosb

	mov		al,		[r15 + 21]
	stosb

	mov		al,		[r15 + 22]
	stosb								;copy B-pixel to result

	mov		[OP1],	ecx
	sub		[OP1],	ebx			;[OP1] = Cy - By

	mov		r8d,	[OP1]

	mov		eax,	[r15 + 12]
	sub		eax,	[r15 + 24]
	mov		[OP2],	eax			;[OP2] = Bx - Cx

	fild	dword [OP2]
	fidiv	dword [OP1]
	fstp	dword [DXRIGHT]

	mov		eax,		[DAB]
	mov		[DXLEFT],	eax

	mov		rax,	0
	mov		rbx,	0
;B
	mov		al,		[r15 + 20]
	mov		bl,		[r15 + 32]
	sub		eax,	ebx

	mov		[OP2],	eax

	fild	dword [OP2]
	fidiv	dword [OP1]
	fstp	dword [DBRIGHT]

	mov		rax,	0
	mov		rbx,	0
;G
	mov		al,		[r15 + 21]
	mov		bl,		[r15 + 33]
	sub		eax,	ebx

	mov		[OP2],	eax

	fild	dword [OP2]
	fidiv	dword [OP1]
	fstp	dword [DGRIGHT]

	mov		rax,	0
	mov		rbx,	0
;R
	mov		al,		[r15 + 22]
	mov		bl,		[r15 + 34]
	sub		eax,	ebx

	mov		[OP2],	eax

	fild	dword [OP2]
	fidiv	dword [OP1]
	fstp	dword [DRRIGHT]

	mov		eax,		[BAB]
	mov		[DBLEFT],	eax

	mov		eax,		[GAB]
	mov		[DGLEFT],	eax

	mov		eax,		[RAB]
	mov		[DRLEFT],	eax

	jmp		SecondHalfInit

BGreater:
	mov		r8d,	dword [r15 + 24]
	mov		r9d,	dword [r15 + 28]	;r8=x, r9=y

	mov		r10,	r9
	imul	r10,	r14
	mov		rax,	r8
	imul	rax,	rax,	3
	add		r10,	rax
	add		r10,	r11					;calculate B-vertex

	mov		rdi,	r10
	
	mov		al,		[r15 + 32]
	stosb

	mov		al,		[r15 + 33]
	stosb

	mov		al,		[r15 + 34]
	stosb								;copy B-pixel to result

	mov		[OP1],	ebx
	sub		[OP1],	ecx			;[OP1] = By - Cy

	mov		r8d,	[OP1]

	mov		eax,	[r15 + 24]
	sub		eax,	[r15 + 12]
	mov		[OP2],	eax			;[OP2] = Cx - Bx

	fild	dword [OP2]
	fidiv	dword [OP1]
	fstp	dword [DXLEFT]

	mov		eax,		[DAC]
	mov		[DXRIGHT],	eax

	mov		rax,	0
	mov		rbx,	0
;B
	mov		al,		[r15 + 32]
	mov		bl,		[r15 + 20]
	sub		eax,	ebx

	mov		[OP2],	eax

	fild	dword [OP2]
	fidiv	dword [OP1]
	fstp	dword [DBLEFT]

	mov		rax,	0
	mov		rbx,	0
;G
	mov		al,		[r15 + 33]
	mov		bl,		[r15 + 21]
	sub		eax,	ebx

	mov		[OP2],	eax

	fild	dword [OP2]
	fidiv	dword [OP1]
	fstp	dword [DGLEFT]

	mov		rax,	0
	mov		rbx,	0
;R
	mov		al,		[r15 + 34]
	mov		bl,		[r15 + 22]
	sub		eax,	ebx

	mov		[OP2],	eax

	fild	dword [OP2]
	fidiv	dword [OP1]
	fstp	dword [DRLEFT]

	mov		eax,		[BAC]
	mov		[DBRIGHT],	eax

	mov		eax,		[GAC]
	mov		[DGRIGHT],	eax

	mov		eax,		[RAC]
	mov		[DRRIGHT],	eax

SecondHalfInit:
	
	dec		r8d

SHLoop:
	
	fxch	st1
	fadd	dword [DXLEFT]
	fist	dword [XL]
	fist	dword [XC]
	fxch	st1

	inc		dword [XC]

	imul	edi,	[XL],	3
	add		rdi,	rdx

	fld		dword [BLEFT]
	fadd	dword [DBLEFT]
	fst		dword [BLEFT]
	fst		dword [BC]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	fld		dword [GL]
	fadd	dword [DGLEFT]
	fst		dword [GL]
	fst		dword [GC]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	fld		dword [RL]
	fadd	dword [DRLEFT]
	fst		dword [RL]
	fst		dword [RC]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	fxch	st2
	fadd	dword [DXRIGHT]
	fist	dword [XR]
	fxch	st2

	imul	edi,	[XR],	3
	add		rdi,	rdx

	fld		dword [BR]
	fadd	dword [DBRIGHT]
	fst		dword [BR]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	fld		dword [GR]
	fadd	dword [DGRIGHT]
	fst		dword [GR]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	fld		dword [RR]
	fadd	dword [DRRIGHT]
	fst		dword [RR]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	mov		rdi,	0

	imul	edi,	[XC],	3
	add		rdi,	rdx

;SCANLINE LOOP INIT 2

	mov		ebx,	[XR]
	sub		ebx,	[XL]
	mov		[OP1],	ebx

;CALC B INC
	fld		dword [BR]
	fsub	dword [BLEFT]
	fidiv	dword [OP1]
	fstp	dword [DB]

;CALC G INC
	fld		dword [GR]
	fsub	dword [GL]
	fidiv	dword [OP1]
	fstp	dword [DG]

;CALC R INC
	fld		dword [RR]
	fsub	dword [RL]
	fidiv	dword [OP1]
	fstp	dword [DR]

	mov		ebx,	[XC]

	cmp		ebx,	[XR]
	jae		skipLoop2

fillLoop2:
	
	fld		dword [BC]
	fadd	dword [DB]
	fst		dword [BC]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	fld		dword [GC]
	fadd	dword [DG]
	fst		dword [GC]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	fld		dword [RC]
	fadd	dword [DR]
	fst		dword [RC]
	fistp	dword [RES]
	mov		al,		[RES]
	stosb

	inc		ebx
	cmp		ebx,	[XR]
	jne		fillLoop2

skipLoop2:

	sub		rdx,	r14

	dec		r8d
	jnz		SHLoop

;------------------------------------------------------------------------------

	mov rsp, rbp	; restore original stack pointer
	pop rbp			; restore "calling procedure" frame pointer
	ret

