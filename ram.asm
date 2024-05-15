SECTION "stack",HRAM[$FFF0]
ds $E ; reserve $FFF0 to %FFFE as stack memory


section "cursorVariables", WRAM0
wCursorState:: db ; what section is the cursor in
wCursorPos:: db ; offset for the cursor used in numbers


;cursorState1_endOffsetA:: dw $107
;cursorState4_endOffsetA:: dw $110

section "numbers", WRAM0
wNumber0:: ds 5
wNumber1:: ds 5
wResult:: ds 5


SECTION "Input Variables", WRAM0
wCurKeys:: db
wNewKeys:: db

SECTION "temp Variables", WRAM0
tmp1:: dw
tmp2:: dw
tmpH:: db
tmpL:: db