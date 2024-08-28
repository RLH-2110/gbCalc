include "hardware.inc"

SECTION FRAGMENT "subroutine ROM", rom0

waitStartVBlank::
	push AF

	.Wait:
		ld a,[rLY]
		cp 144
		jr nz, .Wait

	pop AF
	ret

WaitVBlank::
	push AF

	.Wait:
		ld a,[rLY]
		cp 144
		jr c, .Wait

	pop AF
	ret

WaitNoVBlank::
	push AF
	
	.Wait:
		ld a,[rLY]
		cp 144
		jr nc, .Wait

	pop AF
	ret


; DE : SOURCE
; HL : DESTINATION
; BC : BYTES
Memcpy::
	push AF


	; check if bc = 0
	ld a,b
	or a,c
	jr nz,.loop

	; bc == 0
	pop AF
	ret

	; bc != 0
	.loop:

		ld a,[de]
		ld [hl+],a
		inc de
		dec bc
		ld a,b
		or a,c
		jr nz,.loop

	pop AF
	ret

; HL : DESTINATION
; BC : BYTES
; D  : VALUE
SetMem::
	push AF

	; check if bc = 0
	ld a,b
	or a,c
	jr nz,.loop

	; bc == 0
	pop AF
	ret

	; bc != 0
	.loop:

		ld a,d
		ld [hl+],a
		dec bc
		ld a,b
		or a,c
		jr nz,.loop

	pop AF
	ret


; HL = number to be multiplied
u16_times10::
	push bc

	; bc is a backup of hl
	ld b,h
	ld c,l 

	;example value (5)

	; shift hl left (5 -> 10)
	sla l
	rl h

	; shift hl left (10 -> 20)
	sla l
	rl h

	; shift hl left (20 -> 40)
	sla l
	rl h

	; bc is still the original value
	add hl,bc ; (40 -> 45)
	add hl,bc ; (45 -> 50) 5 has now been multiplied by 10
	pop bc

	ret






; wDoubleDabble = 5 bytes
; unpacs the BCD and adjust it for displaying
; used a and wDoubleDabble
adjutsBCD::

	; move first digit to rightmost bcd memory
	ld a,[wDoubleDabble+2]
	and a,$0f
	inc a ; numbers start at one, not zero
	ld [wDoubleDabble+4],a

	; move second digit to +4
	ld a,[wDoubleDabble+2]
	and a,$f0
	; shift a right 4 times, no carry
	rrc a
	rrc a
	rrc a
	rrc a
	inc a ; numbers start at one, not zero
	ld [wDoubleDabble+3],a

	; move thirt digit to +3
	ld a,[wDoubleDabble+1]
	and a,$0f
	inc a ; numbers start at one, not zero
	ld [wDoubleDabble+2],a

	; adjust 4th digit to be correctly in +2
	ld a,[wDoubleDabble+1]
	and a,$f0
	; shift a right 4 times, no carry
	rrc a
	rrc a
	rrc a
	rrc a
	inc a ; numbers start at one, not zero
	ld [wDoubleDabble+1],a

	ld a,[wDoubleDabble]
	inc a ; numbers start at one, not zero
	ld [wDoubleDabble],a

	ret

; shift a right 4 times, no carry
.shifta4
	
ret


; negates BC (-5 -> 5. 10 -> - 10)
; input: BC
;  uses: BC, AF
;output: BC (N flag set on overfow)
negateBC::
	
	; load into a, and invert a
	ld a,c
	xor a,$FF
	inc a
	ld c,a
	jr z,.decB ; if inc a == 0

	.negB:
	ld a,b
	xor a,$FF
	ld b,a


	jr .end
	.decB:
		dec b ; if we decrement now, its the same as incremening the inverted value
		jr .negB

	.end:

ret