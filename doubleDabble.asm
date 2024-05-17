include "defines.inc"

SECTION FRAGMENT "subroutine ROM", rom0

; will use: A, BC, HL, 
; and (RAM) wTmp1,wTmp2, wTmpH (adressed ass wDoubleDabble)
prepareResult::
	push de

	; clear space for Double Dabble
	ld hl,wDoubleDabble		; DESTINATION
	ld bc,doubleDabbleSize	; BYTES
	ld d,0 					; VALUE
	call SetMem

	; load the number into double dable
	ld a,[wResult+1] ; little endian
	ld [dd_numberIndex],a ; big endian
	ld a,[wResult] ; little endian
	ld [dd_numberIndex+1],a ; big endian


	ld c,2*8 ; counter (for every bit)
	.doubleDabbleLoop

		call doubleDabbleShift
		call doubleDabbleCheck

		dec c

		; if c > 0
		ld a,c
		cp a,0
		jr nz, .doubleDabbleLoop

	pop de
	ret


; uses a
doubleDabbleShift: ; i could make is a loop using B as counter, but Im to lazy rn and this way its faster
	
	ld a,[wDoubleDabble+4]
	sla a
	ld [wDoubleDabble+4],a


    ld a,[wDoubleDabble+3]
	rla
	ld [wDoubleDabble+3],a


    ld a,[wDoubleDabble+2]
	rla
	ld [wDoubleDabble+2],a


    ld a,[wDoubleDabble+1]
	rla
	ld [wDoubleDabble+1],a


    ld a,[wDoubleDabble]
	rla
	ld [wDoubleDabble],a
	
	ret

; uses A,B,HL
doubleDabbleCheck:
	
	ld b,dd_numberIndex-1 ; the first byte thats not the orignal number
	
	.doubleDabbleCheck_loop

		; load adress into hl and apply offset
		ld hl,wDoubleDabble
		ld a,l
		add a,b
		ld l,h
		;
		ld a,h
		adc a,0 ; just adds carry
		ld h,a


		ld a,[hl]
		cp a,4
		jr nc, .doubleDabbleCheck_next ; if a < 5

		add a,3

		.doubleDabbleCheck_next

		ld [hl],a

		dec b
		ld a,b
		cp a,0
		jr nz, .doubleDabbleCheck_loop

	ret