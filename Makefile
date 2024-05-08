# I cant do make, so I used openAI to make me one based on another makefile I found.

# Define the target names
TARGET := calc.gb
SYMFILE := calc.sym

# Define source files
ASM_FILES := calc.asm cursorLogic.asm grapicsROM.asm utility.asm ram.asm

# Define object files
OBJ_FILES := $(ASM_FILES:.asm=.o)

# Define compiler and flags
ASM := rgbasm
LINK := rgblink
FIX := rgbfix
ASMFLAGS := -L
FIXFLAGS := -v -p 0xff

# Define rules
all: $(TARGET)

$(TARGET): $(OBJ_FILES)
	$(LINK) -n $(SYMFILE) -o $@ $^
	$(FIX) $(FIXFLAGS) $@

%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

clean:
	rm -f $(OBJ_FILES) $(TARGET) $(SYMFILE)

.PHONY: all clean
