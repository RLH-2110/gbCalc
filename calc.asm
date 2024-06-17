include "hardware.inc"
include "defines.inc"

SECTION FRAGMENT "subroutine ROM", rom0

; uses A,HL,BC
MathOpJumpTable:
	dw Math_add, Math_sub, Math_mul, Math_div, Math_mod

Calculate::
	call ConvertInputs

	xor a,a ; a = 0
	ld [wResultError],a ; reset error boolean

	; get operator
	ld hl, screen + operatorI
	ld a,[hl] 
	sub a,tile_add ; + tile is now zero. this can now be used as an index. (ORDER: +-*/%)

	; adjust index, since we use dw instead of db
	SLA a ; index * 2

	; index into table and call subroutine
	ld hl,MathOpJumpTable
	ld b,0
	ld c,a
	add hl,bc ; aplly offset

	ld bc,.returnAdress
	push bc 
	jp hl

	.returnAdress:

	; we did the math, now we need to display stuff
	
	ld a,[wResultError]
	cp a,0
	jp nz, ErrorResult ; if an error occured (like the result being out of boudns), then jump somewhere else

	call displayResult

	ret

ErrorResult:
	ld hl, screen + resI; destination
	ld bc,5 	; bytes to write
	ld d,tile_e ; value to write
	call SetMem
	ret

; uses: A, BC, HL
; output: wResult, wResultError
Math_add:

	; load number 0 into hl (little endian)
	ld a, [wNumber1+1]
	ld h, a
	ld a, [wNumber1]
	ld l, a


	; load number 1 into bc (little endian)
	ld a, [wNumber1+1]
	ld b, a
	ld a, [wNumber1]
	ld c, a


	add HL,BC ; add them
	jr nc, .Done

	; overflow
	ld a,$ff
	ld [wResultError],a

	.Done:
	; store result into wResult (little endian)
	ld a,h
	ld [wResult+1],a
	ld a,l
	ld [wResult],a
	
	ret


Math_sub:

	ret


Math_mul:

	ret

Math_div:

	ret

Math_mod:

	ret