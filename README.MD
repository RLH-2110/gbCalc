# gbCalc
This is a simple calculator for the gameboy.  
[Code documentation](https://github.com/RLH-2110/gbCalc/wiki#gbcalc-overview)

# how to compile

you need [RGBDS](https://rgbds.gbdev.io/install/) to be installed:  
  
Optionally, it's useful to have make installed:  
(Linux Terminal) sudo apt-get install make  
(Windows) https://gnuwin32.sourceforge.net/packages/make.htm  
  
To compile, simply run `make`  
  
If you don't have ***make*** installed, run these commands:  
```
rgbasm -o main.o main.asm
rgbasm -o calc.o calc.asm
rgbasm -o cursorLogic.o cursorLogic.asm
rgbasm -o grapicsROM.o grapicsROM.asm
rgbasm -o utility.o utility.asm
rgbasm -o ram.o ram.asm
rgbasm -o numbers.o numbers.asm
rgbasm -o doubleDabble.o doubleDabble.asm
rgbasm -o store.o store.asm
rgblink -n calc.sym -o calc.gb main.o calc.o cursorLogic.o grapicsROM.o utility.o ram.o numbers.o doubleDabble.o store.o
rgbfix -v -p 0xff calc.gb
```

# how do I use the .gb file?

you can use any Game Boy, Game Boy colour or Game Boy advance emulator to execute the .gb file.  
I use [Emulicious](https://emulicious.net/downloads/) to test and play the ROM, it uses [Java](https://www.java.com/en/download/)

# Controls

D-pad up/down - increase/decrease selected field or change the sign or mathematical operation  
D-pad right/left - move cursor  
  
Start - clears selected number  
Select - load stored value into selected field  
  
a - starts calculation  
b - store the result for later use  

