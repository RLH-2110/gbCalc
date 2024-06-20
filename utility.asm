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

