include "hardware.inc"

SECTION "header", rom0[$100]

jp EntryPoint
ds $150-@,0 ; reserve space for the header

EntryPoint:
call WaitVBlank

; turn off LCD
ld a,0
ld [rLCDC], a

; copy tile data
ld DE, Tiles
ld HL, $9000
ld BC, TilesEnd - Tiles
call Memcpy

; copy tilemap
ld DE, Tilemap
ld HL, $9800
ld BC, TilemapEnd - Tilemap
call Memcpy

; clear OAM
ld a,0
ld b,160
ld hl,_OAMRAM
ClearOAM:
  ld [hl+],a
  dec b
  jp nz, ClearOAM

; load objects
ld de,Objects
ld hl,_OAMRAM
ld bc,ObjectsEnd - Objects
call Memcpy

; enable LCD
ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
ld [rLCDC],a

;init display registers
ld a,%11_10_01_00
ld [rBGP],a
ld [rOBP0],a

; init ram
ld a,1
ld [wCursorState],a ; wCursorState = 1
xor a,a ; a = 0
ld [wCursorPos],a ; wCursorPos = 0

ld hl,wNumber0
ld bc,15
call Clear_mem ; clears wNumber0, wNumber1 and wResult

Main:
	call WaitVBlank
	call UpdateKeys

	.check_dpad
		.CheckUp
		  ld a, [wNewKeys]
   		and a, PADF_UP
    	jr z, .CheckDown
    	
    	; pressed!
    	ld e,1
      call CursorHandler

    .CheckDown:
		  ld a, [wNewKeys]
   		and a, PADF_DOWN
    	jr z, .CheckLeft
    	
    	; pressed!
    	ld e,2
      call CursorHandler


    .CheckLeft
      ld a, [wNewKeys]
      and a, PADF_LEFT
      jr z, .CheckRight
      
      ; pressed!
      ld e,3
      call CursorHandler

    .CheckRight:
      ld a, [wNewKeys]
      and a, PADF_RIGHT
      jr z, .InputDone
      
      ; pressed!
      ld e,4
      call CursorHandler
      
  .InputDone:
    jp Main


; functions
SECTION FRAGMENT "subroutine ROM", rom0[$1000]

UpdateKeys:
  ; Poll half the controller
  ld a, P1F_GET_BTN
  call .onenibble
  ld b, a ; B7-4 = 1; B3-0 = unpressed buttons

  ; Poll the other half
  ld a, P1F_GET_DPAD
  call .onenibble
  swap a ; A3-0 = unpressed directions; A7-4 = 1
  xor a, b ; A = pressed buttons + directions
  ld b, a ; B = pressed buttons + directions

  ; And release the controller
  ld a, P1F_GET_NONE
  ldh [rP1], a

  ; Combine with previous wCurKeys to make wNewKeys
  ld a, [wCurKeys]
  xor a, b ; A = keys that changed state
  and a, b ; A = keys that changed to pressed
  ld [wNewKeys], a
  ld a, b
  ld [wCurKeys], a
  ret

.onenibble
  ldh [rP1], a ; switch the key matrix
  call .knownret ; burn 10 cycles calling a known ret
  ldh a, [rP1] ; ignore value while waiting for the key matrix to settle
  ldh a, [rP1]
  ldh a, [rP1] ; this read counts
  or a, $F0 ; A7-4 = 1; A3-0 = unpressed keys
.knownret
  ret


