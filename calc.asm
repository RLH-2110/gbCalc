include "hardware.inc"
include "defines.inc"

SECTION FRAGMENT "subroutine ROM", rom0

; uses A,HL,BC
; by proxy: (RAM) wTmp1,wTmp2, wTmpH
MathOpJumpTable:
	dw Math_add, Math_sub, Math_mul, Math_div, Math_mod

Calculate::
	
	call setNegatives ; get the variables that show what numbers are negative

	call waitStartVBlank ; we need to read vram

	call ConvertInputs

	xor a,a ; a = 0
	ld [wResultError],a ; reset error boolean

	call waitStartVBlank ; we need to read vram soon

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

	; load de,[hl]
	ld e,[hl]
	inc hl
	ld d,[hl]

	; ld hl,de
	ld h,d
	ld l,e

	ld bc,.returnAdress
	push bc 
	jp hl

	.returnAdress:

	; we did the math, now we need to display stuff

	; prepare number with double dable, so it can be quickly displayed
	call prepareResult

	call adjutsBCD

	ld a,$ff
  	ld [wPrintResult],a ; tells the main to print the result

	ret

; uses: A, BC, HL
; output: wResult, wResultError
Math_add:

	; load number 0 into hl (little endian)
	ld a, [wNumber0+1]
	ld h, a
	ld a, [wNumber0]
	ld l, a


	; load number 1 into bc (little endian)
	ld a, [wNumber1+1]
	ld b, a
	ld a, [wNumber1]
	ld c, a


	add HL,BC ; add them
	
	ld a,h ; 
	and a,%1000_0000 ; only select the sign
	jr z,.done ; if there is no sign, skip

	; overflow between numbers with the same signs will be treated as an error.

	;check if numbers have the same sign
	ld a,[wNumber0+1]
	and a, %1000_0000 ; only get the sign
	ld b,a
	ld a,[wNumber1+1]
	and a, %1000_0000 ; only get the sign
	cp a,b ; same sign?
	jr nz,.done ; if different sign, jump over error code

	;same sign found!
	ld a,$ff
	ld [wResultError],a

	.done:
	; store result into wResult (little endian)
	ld a,h
	ld [wResult+1],a
	ld a,l
	ld [wResult],a
	
	ret


; uses: A, BC, HL
; output: wResult, wResultError
Math_sub:

	; load number 0 into BA (little endian)
	ld a, [wNumber0+1]
	ld b, a
	ld a, [wNumber0]


	; load address of number 1 into HL 
	ld hl,wNumber1


	sub a,[HL] ; substract the lower byte of number 1 from number 0
	ld c,a ; store the result in c

	ld a,b ; load upper byte of number 0
	inc hl ; address of upper byte of number 1
	sbc a,[hl] ; subscract with carry
	ld h,a


; overflow between numbers with the same signs will be treated as an error.

	;check if there is an even amount of '-' (meaning we are adding)

	ld b,1 ; counter for '-' (we are in the sub subroutine, so we already have 1 minus)

	;if number0 = -
	ld a,[wNumber0Negative]
	or a,a ; reset flags
	jr z,.skip1

	inc b
	.skip1:

	;if number1 = -
	ld a,[wNumber1Negative]
	or a,a ; reset flags
	jr z,.skip2

	inc b
	.skip2:


	ld a,b
	cp a,2
	jr nz,.done ; if uneven amount of '-', jump over error code


	;even amount of minus!


	; get scenario
	;if number0 = +, then jump to pmm
	ld a,[wNumber0Negative]
	or a,a ; reset flags
	jr z,.pmm


	; - - +
	.mmp:
	ld a,h
	and a,%1000_0000 ; only select the sign
	jr nz,.done ; if there is no sign, skip
	jr .err 

	; + + -
	.pmm:
	ld a,h
	and a,%1000_0000 ; only select the sign
	jr z,.done ; if there is a sign, skip

	.err
	ld a,$ff
	ld [wResultError],a

	.done:
	; store result into wResult (little endian)
	ld a,h ; load the result we stored for the upper byte
	ld [wResult+1],a
	ld a,c ; load the result we stored for the lower byte
	ld [wResult],a
	

	ret


Math_mul:

	ret

Math_div:

	ret

Math_mod:

	ret