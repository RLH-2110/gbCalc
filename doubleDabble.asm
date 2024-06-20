include "defines.inc"

SECTION FRAGMENT "subroutine ROM", rom0

; will use: A, BC, HL, 
; and (RAM) wTmp1,wTmp2, wTmpH (adressed as wDoubleDabble)
prepareResult::
	push de

	; clear space for Double Dabble
	ld hl,wDoubleDabble		; DESTINATION
	ld bc,doubleDabbleSize	; BYTES
	ld d,0 					; VALUE
	call SetMem

	; load the number into double dable
	ld a,[wResult+1] ; little endian
	ld [wDoubleDabble + dd_numberIndex],a ; big endian
	ld a,[wResult] ; little endian
	ld [wDoubleDabble + dd_numberIndex+1],a ; big endian


	ld c,16 ; counter (for every bit)
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
doubleDabbleShift: 
	
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
		ld l,a
		;
		ld a,h
		adc a,0 ; just adds carry
		ld h,a


		; check first segment
		ld a,[hl]
		and $0f

		cp a,$05
		jr c, .doubleDabbleCheck_segment2 ; if a < 5

		; add 3 to first segment
		ld a,[hl]
		add a,$03
		ld [hl],a


		.doubleDabbleCheck_segment2

		;check second segment
		ld a,[hl]
		and $f0

		cp a,$50
		jr c, .doubleDabbleCheck_next ; if a < 5

		; add 3 to second segment
		ld a,[hl]
		add a,$30
		ld [hl],a

		.doubleDabbleCheck_next

		dec b
		ld a,b
		cp a,0
		jr nz, .doubleDabbleCheck_loop

	ret