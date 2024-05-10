; defines

; fixed 
	def last_cursor_state equ $04
	def tile_add equ $0C
	def tile_sub equ $0D
	def tile_modulus equ $10
	def tile_zero equ $01
	def tile_nine equ $0A

	; how much the cursor grapics are away from the cursor position
	def cursorOffset equ $20 ; = size of a row


; tilemap adresses:

	; num*_prefixA is currently unused, but it could be used as an - sign
	; operatorA is the tilemap adress of where the operator should be located
	; num1A is the stat tile of the first number
	def num1_prefixA equ $102
	def num1A equ $103
	def operatorA equ $109
	def num2_prefixA equ $10B
	def num2A equ $10C

	;resA is the adress of where the result should be written to
	def resA equ $148


	