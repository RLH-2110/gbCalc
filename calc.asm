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

	or a,a ; set flags based on a
	jr z, .ppp

	.mpm: ; - + -
		ld a,h ; 
		and a,%1000_0000 ; only select the sign
		jr nz,.done ; if there is a sign, skip
		jr .err

	.ppp: ; + + +
		ld a,h ; 
		and a,%1000_0000 ; only select the sign
		jr z,.done ; if there is no sign, skip
	
	.err
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
	jr z,.skip1 ; positive

	inc b
	.skip1:

	;if number1 = -
	ld a,[wNumber1Negative]
	or a,a ; reset flags
	jr z,.skip2 ; positive

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
	
	; see what number is bigger
	ld a,[wNumber0+1]
	ld b,a
	ld a,[wNumber1+1]

	cp a,b
	jr c, .swap ; num0 is bigger than num1
	jr nz,.noSwap ; number 1 is bigger than number 0 AND we dont need to check the least significant byte

	; compare least significant byte
	ld a,[wNumber0]
	ld b,a
	ld a,[wNumber1]

	cp a,b
	jr nc, .noSwap ; num1 is bigger than num0

	.swap:
	
	; store number 1 in HL
	ld a,[wNumber1+1]
	ld h,a
	ld a, [wNumber1]
	ld l,a

	;store number 0 in BC
	ld a,[wNumber0+1]
	ld b,a
	ld a, [wNumber0]
	ld c,a 

	jr .done
	.noSwap:

	; store number 0 in HL
	ld a,[wNumber0+1]
	ld h,a
	ld a, [wNumber0]
	ld l,a

	;store number 1 in BC
	ld a,[wNumber1+1]
	ld b,a
	ld a, [wNumber1]
	ld c,a 



	.done:

	; hl holds the smaller number
	; bc holds the bigger number


	; set up bounds checking
		ld d,0 ; counter for negative numbers

		;if number0 = -
		ld a,[wNumber0Negative]
		or a,a ; reset flags
		jr z,.skip1 ; positive

		inc d
		.skip1:

		;if number1 = -
		ld a,[wNumber1Negative]
		or a,a ; reset flags
		jr z,.skip2 ; positive

		inc d
		.skip2

		ld a,d ; get the counter
		or a,a ; set flags for a
		jr z,.normalBounds ; if counter == 0, normal bounds

		cp a,2
		jr z,.makeNumsPositive ; if counter == 2, make numbers positive, normal bounds



		; negative bounds
		ld a, %001_01_000 ; opcode: jr z,
		ld [Math_mul_loop_ram + .boundChek - Math_mul.loop],a ; replace opcode in the bounds check
		jr .zeroCheck

	.normalBounds:
		ld a, %001_00_000; opcode: jr nz,
		ld [Math_mul_loop_ram + .boundChek - Math_mul.loop],a ; replace opcode in the bounds check
		jr .zeroCheck


	.makeNumsPositive:


		; invert hl
		ld a,l
		xor a,$ff
		inc a
		ld l,a
		jr z,.incH ; jmp carry, but INC A does not set carry, so we check for Z

		ld a,h
		xor a,$ff
		ld h,a
		jr .invBC

		.incH:
		ld a,h
		xor a,$ff
		inc a
		ld h,a


		; invert BC
		.invBC:

		call negateBC
		jr .normalBounds


	.zeroCheck:
	; if HL != 0, then calculate
	ld a,l
	or a,a ; set flags
	jr nz,.do
	ld a,h
	or a,a ; set flags
	jp nz,.do 

	jr .save ; hl is zero, we are done with the multiplication before we even calculate



	.do
	call loop_doubleBC_halfHL ; minimize HL, maximize BC, without changing the outcome of the multiplication.

	; de = counter for loop (e is inverted, since I cant detect it when e overflows with a dec)
	; for e FF = 00 and 00 = FF
	ld d,h
	ld e,l 

	ld a,e
	xor a,$ff ;invert
	ld e,a


	; set hl to 0 (will contain result later)
	ld h,0
	ld l,0

	; multiply by adding
	jp Math_mul_loop_ram ; reroute to ram, so self modifying code can work

	Math_mul.loop::
		add hl,bc ; 16 bit add

		;bounds checks here
		ld a,h
		and a,%1000_0000 ; get sign
		.boundChek: ; label for self modifiying code
		jr nz,.err

		;decrement counter
		inc e
		jr nz, .noCarry
		dec d

		.noCarry:
		ld a,$00 ; value to compare against

		; if de != 00ff, then contine the loop
		cp a,d
		jr nz,Math_mul.loop

		ld a,$FF ; for e FF = 00
		cp a,e
		jr nz,Math_mul.loop


		; meaning, if d overflows, we know that we need to break out of the loop

	.save

	; store result into wResult (little endian)
	ld a,h
	ld [wResult+1],a
	ld a,l
	ld [wResult],a

	ret

	.err:
	ld a,$ff
	ld [wResultError],a

	ret


Math_div:

	ret

Math_mod:
	call Common_div

	; store result into wResult (little endian)
	ld a,h
	ld [wResult+1],a
	ld a,l
	ld [wResult],a

	ret




; a general div routine
;uses:
; AF, HL, BC, DE, wCounter, wTmpNumber
;output:
; wCounter = result
; HL = remainder
Common_div::

	; wCounter will store the result
	xor a,a
	ldh [wCounter],a
	ldh [wCounter+1],a


	; load first number into hl
	ld a,[wNumber0+1]
	ld h,a
	ld a,[wNumber0]
	ld l,a


	;see if number 1 is bigger than number 0

		;load second number into DE (tmp)
		ld a,[wNumber1]
		ld e,a
		ld a,[wNumber1+1]
		ld d,a


		; like cp h,d
		ld a,h
		cp a,d
		jr c, .notNormal
		
		; like cp l,e
		ld a,l
		cp a,e
		jr nc, .normal 

		.notNormal:
		; number1 > number0!

		;result was already initalized to 0
		;remainder is already initalized to number0
		ret ; we got our values now

	.normal:

	; see if number 1 is 0
		ld a,d
		or a,a ; set flags
		jr nz,.notZero

		ld a,e
		or a,a ; set flags
		jr nz,.notZero

		; number1 is zero!

		;set error
		ld a,$ff
		ld [wResultError],a

		ret

	.notZero:

	;load second number into wTmpNumber
	ld a,[wNumber1]
	ldh [wTmpNumber],a
	ld a,[wNumber1+1]
	ldh [wTmpNumber+1],a

	; HL is number0 wTmpNumber is number1


	.loop:

		;load second number into bc
		ldh a,[wTmpNumber]
		ld c,a
		ldh a,[wTmpNumber+1]
		ld b,a
		
		ld de,1 ; counter for how much fits into HL
		call .findBigestSub


		; apply
		call negateBC ; invert it (there is no 16 but sub, so we do an add with the invese number)
		add hl,bc 



		; add wCounter,de
		ldh a,[wCounter]
		add a,e
		ldh [wCounter],a
		jr nc, .skipCarry

		inc d

		;upper half
		.skipCarry:
		ldh a,[wCounter]
		add a,d
		ldh [wCounter],a

	jr .evaluateLoopExit ; compares and jumps if HL is bigger or equal to wTmpNumber
	
	.done:

	ret

; compares and jumps if HL is bigger or equal to wTmpNumber
.evaluateLoopExit:

	; like cp h,[wTmpNumber+1]
	ldh a,[wTmpNumber+1]
	ld d,a

	ld a,h
	cp a,d
	jr c, .done
	jr nz, .loop
	; now H == D

	; like cp l,[wTmpNumber]
	ldh a,[wTmpNumber]
	ld e,a

	ld a,l
	cp a,e
	jr nc, .loop 


	; exit  loop
	jr .done


; finds biggest substraction we can do for the divide
;input
;HL : number that we divide from
;BC : how much to divide by
;DE : how much we add to the result
;output
;BC : how much to substract
;DE : how much we add to the result
.findBigestSub:
	push bc

	.FBC_loop:


		call .evaluateLoopExit_FBS
	.FBC_done:

	pop bc
	ret



; compares and jumps if BC is bigger than HL
.evaluateLoopExit_FBS:

	; like cp b,h
	ld a,b
	cp a,h
	jr c, .FBC_done
	jr nz, .FBC_loop
	; now H == D

	; like cp c,l
	ld a,c
	cp a,l
	jr nc, .FBC_loop 


	; exit  loop
	jr .FBC_done

; if HL can be halfed without losing a set bit, then half HL and double BC
; repet the comment above until hl can not be halved
; used HL and BC
; CANT HANDLE HL BEING 0!!
loop_doubleBC_halfHL::
	push af
	
	; hl is 0, dont go into the loop
	jr .done

	.loop:
		ld a,l 
		and a,1
		jr nz, .done ; HL can not be halved

		; half hl
		srl h
		rr l

		; double bc
		sla c
		rl b

		jr .loop


	.done:
	pop af
	ret