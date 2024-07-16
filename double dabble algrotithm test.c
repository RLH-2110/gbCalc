/******************************************************************************

                            Online C Compiler.
                Code, Compile, Run and Debug C program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <stdio.h>


// Constants
#define doubleDabbleSize 5
#define dd_numberIndex 3

// Memory (simulated for demonstration)
unsigned char wDoubleDabble[doubleDabbleSize];
unsigned char wResult[2];

// Function prototypes
void SetMem(unsigned char* destination, unsigned char value, unsigned short size);
void doubleDabbleShift(void);
void doubleDabbleCheck(void);


void logStatus(){
       printf("        %X %X %X %X %X   -- %x %x\n",
        wDoubleDabble[0],
        wDoubleDabble[1] & 0xf0,
        wDoubleDabble[1] & 0x0f,
        wDoubleDabble[2] & 0xf0,
        wDoubleDabble[2] & 0x0f,
        wDoubleDabble[3],
        wDoubleDabble[4]
    );
}

void logStatusR(){
       printf("RESULT: %X %X %X %X %X   -- %x %x\n",
        wDoubleDabble[0],
        wDoubleDabble[1] & 0xf0,
        wDoubleDabble[1] & 0x0f,
        wDoubleDabble[2] & 0xf0,
        wDoubleDabble[2] & 0x0f,
        wDoubleDabble[3],
        wDoubleDabble[4]
    );
}

void prepareResult(void) {
    // Clear space for Double Dabble
    SetMem(wDoubleDabble, 0, doubleDabbleSize);

    // Load the number into double dabble
    wDoubleDabble[dd_numberIndex] = wResult[1];   // Big endian
    wDoubleDabble[dd_numberIndex + 1] = wResult[0]; // Big endian

    logStatus();

    // Counter for every bit
    unsigned char c = 16;
    do {
        doubleDabbleShift();
        logStatus();
        doubleDabbleCheck();
        logStatusR();
        c--;
    } while (c > 0);
}

// Shift operation in double dabble
void doubleDabbleShift(void) {
    unsigned char carry = 0;

    for (int i = doubleDabbleSize - 1; i >= 0; i--) {
        unsigned char temp = wDoubleDabble[i];
        wDoubleDabble[i] = (temp << 1) | carry;
        carry = (temp & 0x80) >> 7;
    }
}

// Check and adjust the double dabble values
void doubleDabbleCheck(void) {
    for (int b = dd_numberIndex - 1; b >= 0; b--) {
        int index = b;

        // Check first segment
        unsigned char lowNibble = wDoubleDabble[index] & 0x0F;
        if (lowNibble >= 0x05) {
            wDoubleDabble[index] += 0x03;
        }

        // Check second segment
        unsigned char highNibble = wDoubleDabble[index] & 0xF0;
        if (highNibble >= 0x50) {
            wDoubleDabble[index] += 0x30;
        }
    }
}

// Implementation of SetMem (as described in the notes)
// Set BC bytes starting from HL to the value of D
void SetMem(unsigned char* destination, unsigned char value, unsigned short size) {
    for (unsigned short i = 0; i < size; i++) {
        destination[i] = value;
    }
}



int main()
{
    wResult[0] = 0x8d;
    wResult[1] = 0x27,
    
    logStatus();
    
    prepareResult();
    
    logStatus();
    puts("done");

    return 0;
}
