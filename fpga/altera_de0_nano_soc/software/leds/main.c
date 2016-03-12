#include "omsp_system.h"
#include "timerA.h"

/*
Watchdog interrupt
Change LED blinking type every 327ms * 30 = 9.8seconds
 */
volatile unsigned int  lfsr = 0xACEB;
volatile unsigned char wdt_irq_cnt;
volatile unsigned char led_blink_type;
volatile unsigned char led_blink_type_init;

wakeup interrupt (WDT_VECTOR) INT_watchdog(void) {

  unsigned int lfsr_lsb;

  if (wdt_irq_cnt<15) {
    wdt_irq_cnt++;
  } else {
    wdt_irq_cnt=0;

    // Update lfsr to select random LED algo
    lfsr_lsb = lfsr & 1;			   /* Get LSB (i.e., the output bit). */
    lfsr     >>= 1;				   /* Shift register */
    lfsr     ^= (-lfsr_lsb) & 0xB400u;	           /* If the output bit is 1, apply toggle mask.
      					            * The value has 1 at bits corresponding
					            * to taps, 0 elsewhere. */
    led_blink_type      = (unsigned char) (lfsr & 0x0007);
    led_blink_type_init = 1;
  }
}


/**
Main function with some blinking leds
*/
int main(void) {

  unsigned char temp, temp2;
  unsigned char direction;

  // Init global variables
  wdt_irq_cnt         = 0;
  led_blink_type      = 0;
  led_blink_type_init = 1;
  direction           = 0;
  temp                = 0;

  // Configure watchdog timer to generate an IRQ every 327ms
  WDTCTL = WDTPW | WDTSSEL | WDTCNTCL | WDTTMSEL | WDTIS0;  // Select ACLK | Clear timer | Enable interval timer mode | div32768
  IE1_set_wdtie();

  eint();

  while (1) {                        // Main loop, never ends...

    switch(led_blink_type) {
    case 0 :                         // Double-counter (type1)
      if (led_blink_type_init) {
	LED_CTRL = 0x00;
	temp     = 0x00;
	led_blink_type_init=0;
      } else {
	temp     = (temp+1) & 0x0f;
	temp2    = (temp<<4) | temp;
	LED_CTRL = temp2;
      }
      ta_wait(WT_200MS);
      break;


    case 1 :                         // Double-counter (type2)
      if (led_blink_type_init) {
	LED_CTRL = 0x00;
	temp     = 0x00;
	led_blink_type_init=0;
      } else {
	temp     = (temp-1) & 0x0f;
	temp2    = (temp<<4) | temp;
	LED_CTRL = temp2;
      }
      ta_wait(WT_200MS);
      break;


    case 2 :                         // Interleaved
      if (led_blink_type_init) {
	LED_CTRL = 0x55;
	led_blink_type_init=0;
      } else {
	LED_CTRL ^= 0xFF;
      }
      ta_wait(WT_500MS);
      break;


    case 3 :                         // Blink
      if (led_blink_type_init) {
	LED_CTRL = 0x00;
	led_blink_type_init=0;
      } else {
	LED_CTRL ^= 0xFF;
      }
      ta_wait(WT_500MS);
      ta_wait(WT_200MS);
      break;


    case 4 :                         // Inverted Ping-pong
      if (led_blink_type_init) {
	LED_CTRL  = 0x3F;
	led_blink_type_init=0;
	direction = 0;
      } else {
	if (direction==0) {
	  temp     = (LED_CTRL >> 1) | 0x80;
	  if (temp==0xFC) {direction=1;}
	} else {
	  temp     = (LED_CTRL << 1) | 0x01;
	  if (temp==0x3F) {direction=0;}
	}
	LED_CTRL = temp;
      }
      ta_wait(WT_100MS);
      break;


    case 5 :                         // Ping-pong
      if (led_blink_type_init) {
	LED_CTRL  = 0x80;
	led_blink_type_init=0;
	direction = 0;
      } else {
	if (direction==0) {
	  temp     = LED_CTRL >> 1;
	  if (temp==0x01) {direction=1;}
	} else {
	  temp     = LED_CTRL << 1;
	  if (temp==0x80) {direction=0;}
	}
	LED_CTRL = temp;
      }
      ta_wait(WT_100MS);
      break;


    case 6 :                         // Inverted Shift -->
      if (led_blink_type_init) {
	LED_CTRL = 0x3f;
	led_blink_type_init=0;
      } else {
	temp     = (LED_CTRL >> 1) | 0x80;
	LED_CTRL = temp;
	if (temp==0xfe) {led_blink_type_init = 1;}
      }
      ta_wait(WT_100MS);
      break;


    default:                         // Shift -->
      if (led_blink_type_init) {
	LED_CTRL = 0x80;
	led_blink_type_init=0;
      } else {
	temp     = LED_CTRL >> 1;
	LED_CTRL = temp;
	if (temp==0x01) {led_blink_type_init = 1;}
      }
      ta_wait(WT_100MS);
    }
  }
}
