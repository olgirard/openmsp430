#include "hardware.h"

int main(void) {

    WDTCTL = WDTPW | WDTHOLD;          // Disable watchdog timer

    P3DIR  = 0x0f;
    P4DIR  = 0x00;

    while(1){
	P3OUT = P4IN;
    }

    return 0;
}

