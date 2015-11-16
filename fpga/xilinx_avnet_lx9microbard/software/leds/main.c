#include "hardware.h"

/**
Delay function.
*/
void delay(unsigned int c, unsigned int d) {
  volatile int i, j;
  for (i = 0; i<=c; i++) {
    for (j = 0; j<d; j++) {
      __nop();
      __nop();
    }
  }
}

#define DELAY_TIME 0x000f, 0xffff
//#define DELAY_TIME 0x0000, 0x003f

/**
Main function with some blinking leds
*/
int main(void) {

    WDTCTL = WDTPW | WDTHOLD;          // Disable watchdog timer

    P1OUT  = 0x00;                     // Port data output
    P2OUT  = 0x00;

    P1DIR  = 0x00;                     // Port direction register
    P2DIR  = 0xff;

    P1IES  = 0x00;                     // Port interrupt enable (0=dis 1=enabled)
    P2IES  = 0x00;
    P1IE   = 0x00;                     // Port interrupt Edge Select (0=pos 1=neg)
    P2IE   = 0x00;

    if (CPU_NR==0x0100) {
      delay(DELAY_TIME);
    }

    while (1) {                        // Main loop, never ends...

      P2OUT = 0x00;
      delay(DELAY_TIME);

      P2OUT = 0x01;
      delay(DELAY_TIME);

      P2OUT = 0x02;
      delay(DELAY_TIME);

      P2OUT = 0x03;
      delay(DELAY_TIME);

      P2OUT = 0x02;
      delay(DELAY_TIME);

      P2OUT = 0x01;
      delay(DELAY_TIME);
    }
}
