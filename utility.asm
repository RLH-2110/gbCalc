include "hardware.inc"

SECTION FRAGMENT "subroutine ROM", rom0

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
