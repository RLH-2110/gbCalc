include "defines.inc"

SECTION FRAGMENT "subroutine ROM", rom0

;data:

	;indexes for the cursor array
	CursorArray::
	dw .cs0, .cs1, .cs2, .cs3, .cs4

	;tilemap offset, inc routine, dec routine, left routine, right routine
	.cs0:
	dw screen + $102, CursorSignToggle, CursorSignToggle, CursorWrapToRight, CursorRight
	.cs1:
	dw screen + $103, CursorNumberInc, CursorNumberDec, CursorNumberLeft, CursorNumberRight
	.cs2:
	dw screen + $109, CursorOperatorInc, CursorOperatorDec, CursorLeft, CursorRight
	.cs3:
	dw screen + $10B, CursorSignToggle, CursorSignToggle, CursorLeft, CursorRight
	.cs4:
	dw screen + $10C, CursorNumberInc, CursorNumberDec, CursorNumberLeft, CursorNumberRight


; code:
nop_function:
ret

; this subroutine jumps to a subroutine defined in an array thats indexed by the cursor state and the A register
; E: function selector
CursorHandler::
	push af
	push hl
	push bc
	push de


	; note: 
	; [CursorArray+CursorState]->CursorData
	; [CursorData-+offset]->functionPointer

	ld hl,CursorArray ; base adress

	;bc = wCursorState (used as an offset)
	ld b, 0
	ld a,[wCursorState] 
	ld c,a


	add hl,bc ; combine base adress with the offset
	add hl,bc ; do it twice, since the data is 2 byte big

	; get pointer to new base adress
	ld c,[hl] ;load lower part of the new base adress
	inc hl
	ld b,[hl] ;load upper part

	;transfer to hl
	ld h,b
	ld l,c

	;load tilemap adress into bc
	ld c,[hl] ; load lower part
	inc hl
	ld b,[hl] ; load upper part
	dec hl
	push bc ; save tilemap address

	ld d,0

	; e * 2 (since the data is 2 bytes long)
	SLA e 

	add hl,de ; apply offset parameter to new base adress

	; get the pointer thats behind the new adress
	ld c,[hl] ;load lower part of the pointer
	inc hl
	ld b,[hl] ;load upper part

	;transfer to hl
	ld h,b
	ld l,c

	;HL now contains the pointer.

	;get the tilemap adress into de
	pop de
	;call the function
	ld bc,.CursorHanlderReturnAdress
	push bc ; push return adress onto the stack
	jp hl ; call the function pased on the pointer we got

	.CursorHanlderReturnAdress
	pop de
	pop bc 
	pop hl
	pop af
	ret


; DE: tilemap adress
;! assumes that all registers are free to use. !
CursorNumberInc:
	;load offset io the tile with the number into hl
	ld h,d
	ld l,e
	
	;offset hl by the cursor pos inside the number
	ld a,[wCursorPos]
	ld b,0
	ld c,a

	add hl,bc ; apply offset

	inc [hl] ; increment number

	ld a,tile_nine
	cp a,[hl]
	
	jr c, .overflow ; if the tile is bigger than the tile displaying 9

	call validateInput
	ret

	.overflow: 
	ld [hl],tile_zero ; set to the tile that displays 0

	call validateInput
	ret


; DE: tilemap adress
;! assumes that all registers are free to use. !
CursorNumberDec:
	;load offset io the tile with the number into hl
	ld h,d
	ld l,e
	
	;offset hl by the cursor pos inside the number
	ld a,[wCursorPos]
	ld b,0
	ld c,a

	add hl,bc ; apply offset

	dec [hl] ; increment number

	jr z, .underflow ; if its an empy tile now

	call validateInput
	ret

	.underflow:
	ld [hl],tile_nine ; set to the tile that displays 9

	call validateInput
	ret



; DE: tilemap adress
;! assumes that all registers are free to use. !
CursorOperatorInc:
	ld h,d
	ld l,e
	inc [hl]

	ld a,tile_modulus
	cp a,[hl]
	jr c, .overflow ; if the tile is bigger than the tile displaying %
	ret

	.overflow: 
	ld [hl],tile_add ; set to the tile that displays +
	ret


; DE: tilemap adress
;! assumes that all registers are free to use. !
CursorOperatorDec:
	;load offset io the tile with the number into hl
	ld h,d
	ld l,e
	dec [hl]

	ld a,[hl]
	cp a,tile_add
	jr c, .underflow ; if its under a +
	ret

	.underflow:
	ld [hl],tile_modulus ; set to the tile that displays %
	ret



; DE: tilemap adress
;! assumes that all registers are free to use. !
CursorSignToggle:
	;load offset io the tile with the number into hl
	ld h,d
	ld l,e
	
	; if it is '+'
	ld a,[hl]
	cp a,tile_add
	jr z,.setMinus ; set it to minus

	;else set it to plus
	ld [hl],tile_add

	call validateInput
	ret
.setMinus	
	ld [hl],tile_sub

	call validateInput
	ret


;! assumes that all registers are free to use. !
CursorLeft: ; for non numbers
	push hl

	; load dc, old cursor state
	ld d,0
	ld a,[wCursorState]
	ld e,a

	; load bc, 0
	ld bc,0

	; aplly new cursor positon
	ld hl,wCursorState
	dec [hl]

	; update grapics
	call CursotSetPosition

	pop hl
	ret

;! assumes that all registers are free to use. !
CursorRight: ; for non numbers
	push hl

	; load dc, old cursor state
	ld d,0
	ld a,[wCursorState]
	ld e,a

	; load bc, 0
	ld bc,0

	; aplly new cursor positon
	ld hl,wCursorState
	inc [hl]

	; update grapics
	call CursotSetPosition

	pop hl
	ret

;! assumes that all registers are free to use. !
CursorWrapToLeft: ; unused
	push hl

	; load dc, old cursor state
	ld d,0
	ld a,[wCursorState]
	ld e,a

	; load bc, 0
	ld bc,0

	; aplly new cursor positon
	ld hl,wCursorState
	ld [hl],0

	; update grapics
	call CursotSetPosition

	pop hl
	ret

;! assumes that all registers are free to use. !
CursorWrapToRight:
	push hl

	; load dc, old cursor state
	ld d,0
	ld a,[wCursorState]
	ld e,a

	; load bc, 0
	ld bc,0

	; aplly new cursor positon
	ld hl,wCursorState
	ld [hl],last_cursor_state

	; update grapics
	call CursotSetPosition

	pop hl
	ret

;! assumes that all registers are free to use. !
CursorNumberLeft:
	push hl

	; load dc, current cursor state
	ld d,0
	ld a,[wCursorState]
	ld e,a


	; load cursor pos into bc
	ld a,[wCursorPos]
	ld b,0
	ld c,a

	; if cursor pos = 0, switch state
	ld a,[wCursorPos]
	or a,a ;set flags
	jr z, .switchState

	
	; decrement cursor pos
	ld hl,wCursorPos
	dec [hl]

	jr .done
	.switchState:

	;reset cursor pos:
	ld a,0
	ld [wCursorPos],a

	; aplly new cursor positon
	ld hl,wCursorState
	dec [hl]

	.done
	; update grapics
	call CursotSetPosition

	pop hl
	ret

;! assumes that all registers are free to use. !
CursorNumberRight:
push hl

	; load dc, current cursor state
	ld d,0
	ld a,[wCursorState]
	ld e,a

	; load cursor pos into bc
	ld a,[wCursorPos]
	ld b,0
	ld c,a

	; if cursor pos = 0, switch state
	ld a,[wCursorPos]
	cp a,4 ; if we are in the last position
	jr z, .switchState

	; incement cursor pos
	ld hl,wCursorPos
	inc [hl]


	jr .done
	.switchState:

	;reset cursor pos:
	ld a,0
	ld [wCursorPos],a

	; aplly new cursor positon
	ld hl,wCursorState
	inc [hl]

	; edge case, hl is bigger than any cursorState
	ld a,[hl]
	cp a,5
	jr c, .done ; if we dont have the edgecase, skip ahead

	ld [hl],0 ; set cursor state to zero (wraping around)

	.done
	; update grapics
	call CursotSetPosition

	pop hl
	ret


; BC:	old cursor pos
; DE:	old cursor state  (D is expected to be zero)
; wCursorState:	new cursor pos
CursotSetPosition:
	push hl
	push af

	; note: 
	; [CursorArray+CursorState]->CursorData
	; [CursorData+0] = normal cursor pos 
	; normal cursor pos + cursor pos = actually cursor pos

	ld hl,CursorArray ; base adress
	sla e
	add hl,de ; apply offset

	; get the adress we point at.
	ld e,[hl]
	inc hl
	ld d,[hl]

	; load adress into hl
	ld h,d
	ld l,e

	; now load the old default cursor pos
	ld e,[hl]
	inc hl
	ld d,[hl]

	; add the old cursor pos
	ld a, d
	add a,b
	ld d,a 

	ld a, e
	add a,c
	ld e,a 

	;load into HL
	ld h,d
	ld l,e

	; HL and DL = the adress of the old cursor pos in the tilemap

	ld bc,cursorOffset ; bc = offset of how much the cursor grapics are away from the cursor position

	; remove the lower cursor grapic
	add HL,bc	; apply offset to put hl at the adress of the upper lower grapic
	ld [hl],tile_empty ; set tile to nothing

	;restet hl to cursor position
	ld h,d
	ld l,e



	; remove the upper cursor grapic

	; substact bc and hl (apply offset to put hl at the adress of the upper cursor grapic)
	ld a,l
	sub a,c
	ld l,a

	ld a,h
	sbc a,b ; sub with carry!
	ld h,a

	

	; set tile to nothing
	ld [hl],tile_empty



	;
	;
	; the old cursor grapics have been removed, now its time to draw the new ones.
	;
	;


	; DE = wCursorState
	ld d,0
	ld a,[wCursorState]
	ld e,a

	ld hl,CursorArray ; base adress
	sla e
	add hl,de ; apply offset

	; get the adress we point at.
	ld e,[hl] 
	inc hl
	ld d,[hl]

	; load adress into hl
	ld h,d
	ld l,e

	; now load the old default cursor pos
	ld e,[hl]
	inc hl
	ld d,[hl]

	; add the new cursor pos
	ld b,e
	ld a,[wCursorPos]
	add a,b
	ld e,a

	;load into HL
	ld h,d
	ld l,e




	; HL and DL = the adress of the new cursor pos in the tilemap

	ld bc,cursorOffset ; bc = offset of how much the cursor grapics are away from the cursor position

	; add the lower cursor grapic
	add HL,bc	; apply offset to put hl at the adress of the upper lower grapic
	ld [hl],lower_cursor

	;restet hl to cursor position
	ld h,d
	ld l,e



	; add the upper cursor grapic

	; substact bc and hl (apply offset to put hl at the adress of the upper cursor grapic)
	ld a,l
	sub a,c
	ld l,a

	ld a,h
	sbc a,b ; sub with carry!
	ld h,a

	ld [hl], upper_cursor


	pop af
	pop hl
	ret
