SECTION "highScratch",HRAM[$FF80]
wCounter::	 dw ; counter that can be used
wTmpNumber:: dw ; saves a number
wTmpByte:: db ; saves a byte

SECTION "stack",HRAM[$FFE0]
ds $1E ; reserve $FFE0 to %FFFE as stack memory (30 bytes (15 pushes))


section "cursorVariables", WRAM0
wCursorState:: db ; what section is the cursor in
wCursorPos:: db ; offset for the cursor used in numbers


;cursorState1_endOffsetA:: dw $107
;cursorState4_endOffsetA:: dw $110

section "numbers", WRAM0
wNumber0:: dw
wNumber1:: dw
wResult:: dw
wResultError:: db ; 0 = false FF = true
wResultNegative:: db ; z = positive, nz = negative
wNumber0Negative:: db ; z = positive, nz = negative
wNumber1Negative:: db ; z = positive, nz = negative

wStoredNumber0:: dw ; nuber stored by the user (init 0)
wStoredNumber1:: dw ; (unused in this version) number stored by the user (init 0)

SECTION "Input Variables", WRAM0
wCurKeys:: db
wNewKeys:: db

SECTION "temp Variables", WRAM0
wDoubleDabble:: ; uses 5 bytes (wTmp1,wTmp2,wTmpH)
wTmp1:: dw
wTmp2:: dw
wTmpH:: db
wTmpL:: db

section "control", WRAM0
wFinishedWork:: db ; z = finished work, nz = did not finish work
wPrintResult:: db ; z = do not print, nz = print



section "MUL code RAM", WRAM0[$CF00]
Math_mul_loop_ram:: ds $FF ; reserve the rest of the memory for the multiplication loop