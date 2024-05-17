; defines
include "hardware.inc"

; fixed 

	def screen equ _SCRN0	
	def last_cursor_state equ $04

	; how much the cursor grapics are away from the cursor position
	def cursorOffset equ $20 ; = size of a row

	def cursorState_Number0Sign equ $00
	def cursorState_Number0 equ $01
	def cursorState_Operator equ $02
	def cursorState_Number1Sign equ $03
	def cursorState_Number1 equ $04

; tilemap indexes:

	; operatorI is the tilemap index of where the operator should be located
	; num0I is the index of the start tile of the first number
	def num0_prefixI equ $102
	def num0I equ $103
	def operatorI equ $109
	def num1_prefixI equ $10B
	def num1I equ $10C

	;resI is the adress of where the result should be written to
	def resI equ $148


; tiles
	def tile_empty equ $00

	def tile_zero equ $01
	def tile_one equ $02
	def tile_two equ $03
	def tile_three equ $04
	def tile_four equ $05
	def tile_five equ $06
	def tile_six equ $07
	def tile_seven equ $08
	def tile_eight equ $09
	def tile_nine equ $0A

	def tile_add equ $0C
	def tile_sub equ $0D
	def tile_mul equ $0E
	def tile_div equ $0F
	def tile_modulus equ $10
	
	def tile_c equ $0B
	def tile_e equ $14

	def tile_equals equ $11

	def upper_cursor equ $12
	def lower_cursor equ $13

