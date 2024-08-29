include "defines.inc"

SECTION FRAGMENT "subroutine ROM", rom0

; assumes that diplayed result always matches wResult (except if wResultError is set)
StoreVal::

	ld a,[wResultError]
	or a,a ; set flags
	jr nz, .end ; exit if last calc had an error


	; load value into BC
	ld a,[wResult]
	ld c,a
	ld a,[wResult+1]
	ld b,a

	; check if result is positive
	ld a,[wResultNegative]
	or a,a ; set the flags based on the value of a
	jp z,.positive

	call negateBC ; make negative if number is negative

	.positive:
	;store value
	ld a,c
	ld [wStoredNumber0],a
	ld a,b
	ld [wStoredNumber0+1],a

	.end:
	ret
LoadVal::

	;check what value to load into

	ld a,[wCursorState]
	
	cp a,1 ; if cursor on number0
	jr z, .loadIntoNumber0

	cp a,4 ; if cursor on number1
	jr z, .loadIntoNumber1

	; if somewhere else
	ret

	.loadIntoNumber0:
	
	; WORKAROUND, BECAUE BCD ONLY WORKS WITH RESULT VARIABLE

	;backup result
	ld a,[wResult]
	ld [wTmpNumber],a
	ld a,[wResult+1]
	ld [wTmpNumber+1],a

	; load number 1 into result
	ld a,[wStoredNumber0]
	ld [wResult],a
	ld a,[wStoredNumber0+1]
	ld [wResult+1],a
	
	call prepareResult ; do bcd
	call adjutsBCD


	; do display stuff here:

	call waitStartVBlank 

	ld a,[wStoredNumber0+1] ; if the number is positve, skip to .positive
	and a, %1000_0000 ; only keep sign
	jp z,.positive0

	;number negative

	; write a '-' before the number
	ld a,tile_sub
	ld [screen+num0_prefixI],a
	jp .printNum0

	.positive0: ; write a '+' before the number
	ld a,tile_add
	ld [screen+num0_prefixI],a

	.printNum0:


	ld DE,wDoubleDabble ; SOURCE
	ld HL,screen + num0I ; DESTINATION
	ld BC,doubleDabbleSize ; BYTES
	call Memcpy

	;jr .exit


	jr .exit


	.loadIntoNumber1:
	
	; WORKAROUND, BECAUE BCD ONLY WORKS WITH RESULT VARIABLE

	;backup result
	ld a,[wResult]
	ld [wTmpNumber],a
	ld a,[wResult+1]
	ld [wTmpNumber+1],a

	; load number 1 into result
	ld a,[wStoredNumber0]
	ld [wResult],a
	ld a,[wStoredNumber0+1]
	ld [wResult+1],a
	
	call prepareResult ; do bcd
	call adjutsBCD


	; do display stuff here:

	call waitStartVBlank 

	ld a,[wStoredNumber0+1] ; if the number is positve, skip to .positive
	and a, %1000_0000 ; only keep sign
	jp z,.positive1

	;number negative

	; write a '-' before the number
	ld a,tile_sub
	ld [screen+num1_prefixI],a
	jp .printNum1

	.positive1: ; write a '+' before the number
	ld a,tile_add
	ld [screen+num1_prefixI],a

	.printNum1:


	ld DE,wDoubleDabble ; SOURCE
	ld HL,screen + num1I ; DESTINATION
	ld BC,doubleDabbleSize ; BYTES
	call Memcpy

	;jr .exit

	.exit:

	;restore result variable
	ldh a,[wTmpNumber]
	ld [wResult],a
	ldh a,[wTmpNumber+1]
	ld [wResult+1],a

	ret