# I cant do make, so I used openAI to make me one based on another makefile I found.

# Define the target names
TARGET := calc.gb
SYMFILE := calc.sym

# Define source files
ASM_FILES := main.asm calc.asm cursorLogic.asm grapicsROM.asm utility.asm ram.asm numbers.asm doubleDabble.asm store.asm

# Define object files
OBJ_FILES := $(ASM_FILES:.asm=.o)

# Define compiler and flags
ASM := rgbasm
LINK := rgblink
FIX := rgbfix
ASMFLAGS := 
FIXFLAGS := -v -p 0xff

# Define rules
all: $(TARGET)

$(TARGET): $(OBJ_FILES)
	$(LINK) -n $(SYMFILE) -o $@ $^
	$(FIX) $(FIXFLAGS) $@

%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $<


# Detect operating system (thanks chatgpt)
ifeq ($(OS),Windows_NT)
    RM = del /F /Q
else
    RM = rm -f
endif

clean:
	$(RM) $(OBJ_FILES) $(TARGET) $(SYMFILE)

.PHONY: all clean
