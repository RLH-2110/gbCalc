include "hardware.inc"

SECTION "VBlankInterupt", rom0[$40]
jp Main

SECTION "header", rom0[$100]

jp EntryPoint ; entry point
nop

ds $30,0 ; nintendo logo (rgbfix will instert it)
db $47, $42, $20, $43, $41, $4C, $43, 0,0,0,0 ; game title 
ds 4,0 ; Manufacturer code
db 0 ; CGB flag (we dont use gbc yet, maybe never. having backwards compatability with the gameboy may be nice)
dw 0 ; New licensee code
db 0 ; SGB flag
db 0 ; Cartridge type (let rgbfix figure this out)
db 0 ; ROM size (let rgbfix figure this out)
db 0 ; RAM size (let rgbfix figure this out)
db 0 ; Destination code ( should not be imporant)
db 0 ; Old licensee code
db 0 ; Mask ROM version number (maybe we use this later)
db 0 ; Header checksum (let rgbfix figure this out)
dw 0 ; Global checksum (let rgbfix figure this out, though it should be unused)


SECTION "main", rom0[$150]

EntryPoint:
di ; no interrupts
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

; clear wFinishedWork
ld [wFinishedWork],a ; a = 0

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
ld bc,6
ld d,0
call SetMem ; clears wNumber0, wNumber1 and wResult


;copy multiplication loop into ram
ld de,Math_mul.loop
ld hl,Math_mul_loop_ram
ld bc,$FF
call Memcpy



xor a,a ; a = 0
ld [wFinishedWork],a
ld [wPrintResult],a

; enable vblank interupt
ld a,%0000_0001
ld [rIE],a


waitForever:
  ei ; enable interups
  nop ; not yet enabled 
  halt ; main gets called via interupts, halt in the meantime. ( not yet implemented )
  nop
jr waitForever

Main:

  ; check if we can execute the main without problems

  push af
  ld a,[wFinishedWork]
  cp a,0
  jr z,.doMain ; if we do not have more work to do, then continue the main function

  ;else return since this is an interupt
  pop af
  reti ; we have more work to do

  .doMain:
  pop af


  ld a,$ff
  ld [wFinishedWork],a ; now we have work to do


  ; check if we need to print the result of an operation

  ld a,[wPrintResult]
  cp a,0
  jr z, .noPrint

  call displayResult ; call it now, since I dont know how many cyles a big division or multiplication might take. I dont want to risk writing outside vblank

  .noPrint:

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
      jr z, .checkSelect
      
      ; pressed!
      ld e,4
      call CursorHandler

    .checkSelect:
      ld a, [wNewKeys]
      and a, PADF_SELECT
      jr z, .checkA
      
      ; pressed!
      call clearSelectedNumber
    
    .checkA:
      ld a, [wNewKeys]
      and a, PADF_A
      jr z, .InputDone
      
      ; pressed!
      call Calculate
      
  .InputDone:
    xor a,a ; a = 0
    ld [wFinishedWork],a ; no more work to do
  
    reti

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


