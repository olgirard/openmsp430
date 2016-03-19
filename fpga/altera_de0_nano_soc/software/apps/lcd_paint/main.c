#include "omsp_system.h"
#include "timerA.h"
#include "gfx_controller.h"


#define TEST_16_BPP
//#define TEST_8_BPP
//#define TEST_4_BPP
//#define TEST_2_BPP
//#define TEST_1_BPP

/**
Main function
*/
int main(void) {

//  unsigned int idx;
//  unsigned int lfsr = 0xACE1;
//  unsigned int lfsr_lsb;
  volatile unsigned int temp1, temp2, temp3, temp4;
  unsigned int idx;

  WDTCTL = WDTPW | WDTHOLD;   // Disable watchdog timer

  init_lt24();                // Initialize LCD

#ifdef TEST_16_BPP
  GFX_CTRL = GFX_16_BPP | GFX_REFR_DONE_IRQ_DIS ; // Configure Video mode
#endif
#ifdef TEST_8_BPP
  GFX_CTRL = GFX_8_BPP  | GFX_REFR_DONE_IRQ_DIS ;
#endif
#ifdef TEST_4_BPP
  GFX_CTRL = GFX_4_BPP  | GFX_REFR_DONE_IRQ_DIS ;
#endif
#ifdef TEST_2_BPP
  GFX_CTRL = GFX_2_BPP  | GFX_REFR_DONE_IRQ_DIS ;
#endif
#ifdef TEST_1_BPP
  GFX_CTRL = GFX_1_BPP  | GFX_REFR_DONE_IRQ_DIS ;
#endif

  VID_RAM0_ADDR_HI = 0x0000;
  VID_RAM0_ADDR_LO = 0x0000;

#ifdef TEST_16_BPP
  VID_RAM0_DATA    =  0;
  VID_RAM0_DATA    =  1;
  VID_RAM0_DATA    =  2;
  VID_RAM0_DATA    =  3;
  VID_RAM0_DATA    =  4;
  VID_RAM0_DATA    =  5;
  VID_RAM0_DATA    =  6;
  VID_RAM0_DATA    =  7;
  VID_RAM0_DATA    =  8;
  VID_RAM0_DATA    =  9;
  VID_RAM0_DATA    = 10;
  VID_RAM0_DATA    = 11;
  VID_RAM0_DATA    = 12;
  VID_RAM0_DATA    = 13;
  VID_RAM0_DATA    = 14;
  VID_RAM0_DATA    = 15;
  VID_RAM0_DATA    = 16;
  VID_RAM0_DATA    = 17;
  VID_RAM0_DATA    = 18;
  VID_RAM0_DATA    = 19;
  VID_RAM0_DATA    = 20;
  VID_RAM0_DATA    = 21;
  VID_RAM0_DATA    = 22;
  VID_RAM0_DATA    = 23;
  VID_RAM0_DATA    = 24;
  VID_RAM0_DATA    = 25;
  VID_RAM0_DATA    = 26;
  VID_RAM0_DATA    = 27;
  VID_RAM0_DATA    = 28;
  VID_RAM0_DATA    = 29;
  VID_RAM0_DATA    = 30;
  VID_RAM0_DATA    = 31;
  VID_RAM0_DATA    = 32;
  VID_RAM0_DATA    = 33;
  VID_RAM0_DATA    = 34;
  VID_RAM0_DATA    = 35;
  VID_RAM0_DATA    = 36;
  VID_RAM0_DATA    = 37;
  VID_RAM0_DATA    = 38;
  VID_RAM0_DATA    = 39;
  VID_RAM0_DATA    = 40;
#endif
#ifdef TEST_8_BPP
  VID_RAM0_DATA    = ( 1 << 8) |   0;
  VID_RAM0_DATA    = ( 3 << 8) |   2;
  VID_RAM0_DATA    = ( 5 << 8) |   4;
  VID_RAM0_DATA    = ( 7 << 8) |   6;
  VID_RAM0_DATA    = ( 9 << 8) |   8;
  VID_RAM0_DATA    = (11 << 8) |  10;
  VID_RAM0_DATA    = (13 << 8) |  12;
  VID_RAM0_DATA    = (15 << 8) |  14;
  VID_RAM0_DATA    = (17 << 8) |  16;
  VID_RAM0_DATA    = (19 << 8) |  18;
  VID_RAM0_DATA    = (21 << 8) |  20;
  VID_RAM0_DATA    = (23 << 8) |  22;
  VID_RAM0_DATA    = (25 << 8) |  24;
  VID_RAM0_DATA    = (27 << 8) |  26;
  VID_RAM0_DATA    = (29 << 8) |  28;
  VID_RAM0_DATA    = (31 << 8) |  30;
  VID_RAM0_DATA    = (33 << 8) |  32;
  VID_RAM0_DATA    = (35 << 8) |  34;
  VID_RAM0_DATA    = (37 << 8) |  36;
  VID_RAM0_DATA    = (39 << 8) |  38;
  VID_RAM0_DATA    = (41 << 8) |  40;
#endif
#ifdef TEST_4_BPP
  VID_RAM0_DATA    = ( 3 << 12) | ( 2 << 8) | ( 1 << 4) |  0;
  VID_RAM0_DATA    = ( 7 << 12) | ( 6 << 8) | ( 5 << 4) |  4;
  VID_RAM0_DATA    = (11 << 12) | (10 << 8) | ( 9 << 4) |  8;
  VID_RAM0_DATA    = (15 << 12) | (14 << 8) | (13 << 4) | 12;
  VID_RAM0_DATA    = (12 << 12) | (13 << 8) | (14 << 4) | 15;
  VID_RAM0_DATA    = ( 8 << 12) | ( 9 << 8) | (10 << 4) | 11;
  VID_RAM0_DATA    = ( 4 << 12) | ( 5 << 8) | ( 6 << 4) |  7;
  VID_RAM0_DATA    = ( 0 << 12) | ( 1 << 8) | ( 2 << 4) |  3;
  VID_RAM0_DATA    = ( 2 << 12) | ( 3 << 8) | ( 0 << 4) |  1;
  VID_RAM0_DATA    = ( 5 << 12) | ( 4 << 8) | ( 7 << 4) |  6;
  VID_RAM0_DATA    = ( 9 << 12) | ( 8 << 8) | (11 << 4) | 10;
#endif
#ifdef TEST_2_BPP
  VID_RAM0_DATA    = ( 3 << 14) | ( 2 << 12) | ( 1 << 10) | ( 0 << 8) | ( 3 << 6) | ( 2 << 4) | ( 1 << 2) |  0;
  VID_RAM0_DATA    = ( 0 << 14) | ( 3 << 12) | ( 2 << 10) | ( 1 << 8) | ( 0 << 6) | ( 3 << 4) | ( 2 << 2) |  1;
  VID_RAM0_DATA    = ( 1 << 14) | ( 0 << 12) | ( 3 << 10) | ( 2 << 8) | ( 1 << 6) | ( 0 << 4) | ( 3 << 2) |  2;
  VID_RAM0_DATA    = ( 2 << 14) | ( 1 << 12) | ( 0 << 10) | ( 3 << 8) | ( 2 << 6) | ( 1 << 4) | ( 0 << 2) |  3;
  VID_RAM0_DATA    = ( 3 << 14) | ( 2 << 12) | ( 1 << 10) | ( 0 << 8) | ( 3 << 6) | ( 2 << 4) | ( 1 << 2) |  0;
  VID_RAM0_DATA    = ( 0 << 14) | ( 3 << 12) | ( 2 << 10) | ( 1 << 8) | ( 0 << 6) | ( 3 << 4) | ( 2 << 2) |  1;
#endif
#ifdef TEST_1_BPP
  VID_RAM0_DATA    = 0b1001110100110101;
  VID_RAM0_DATA    = 0b0110001011001010;
  VID_RAM0_DATA    = 0b1001110100110101;
#endif

  VID_RAM1_ADDR_HI = 0x0001;
  VID_RAM1_ADDR_LO = 0x0000;

  VID_RAM1_DATA    = 0x1111;
  VID_RAM1_DATA    = 0x2222;
  VID_RAM1_DATA    = 0x3333;
  VID_RAM1_DATA    = 0x4444;

  VID_RAM0_ADDR_LO = 0x0000;
  __nop();
  temp1           = VID_RAM0_DATA;
  temp2           = VID_RAM0_DATA;
  temp3           = VID_RAM0_DATA;
  temp4           = VID_RAM0_DATA;

  VID_RAM1_ADDR_LO = 0x2345;
  __nop();
  temp1           = VID_RAM1_DATA;
  temp2           = VID_RAM1_DATA;
  temp3           = VID_RAM1_DATA;
  temp4           = VID_RAM1_DATA;

  //
  LUT_RAM_ADDR    = 0x0234;

  LUT_RAM_DATA    = 0x5555;
  LUT_RAM_DATA    = 0x6666;
  LUT_RAM_DATA    = 0x7777;
  LUT_RAM_DATA    = 0x8888;

  LUT_RAM_ADDR    = 0x0234;
  __nop();
  temp1           = LUT_RAM_DATA;
  temp2           = LUT_RAM_DATA;
  temp3           = LUT_RAM_DATA;
  temp4           = LUT_RAM_DATA;

  // Update LUT
  LUT_RAM_ADDR = 0x0000;
  for( idx = 0; idx < 256; idx = idx + 1 ) {
    LUT_RAM_DATA    = idx<<8;
  }

  LT24_CMD      = 0x0004 | LT24_CMD_NO_PARAM;

//  FRAME0_PTR_HI   = 0x0001;
//  FRAME0_PTR_LO   = 0x2345;

  FRAME0_PTR_HI   = 0x0000;
  FRAME0_PTR_LO   = 0x0000;

  FRAME1_PTR_HI   = 0x0000;
  FRAME1_PTR_LO   = 0xfff8;

  FRAME_SELECT    = REFRESH_FRAME0_SELECT;


  LT24_REFRESH_SYNC = LT24_REFR_SYNC  | 0x0000;
  LT24_REFRESH      = LT24_REFR_START | LT24_REFR_1MS;

  return 0;
}


//  // Try to do some funky stuff
//  while(1) {
//    for( idx = 0; idx < 14; idx = idx + 1 ) {
//
//      LCD_CASET_SC    = 8*idx;             // Column Address Set (START)
//      LCD_CASET_EC    = 239-8*idx;   // Column Address Set (END)
//
//      LCD_PASET_SP    = 12*idx;            // Line Address Set (START)
//      LCD_PASET_EP    = 319-12*idx;  // Line Address Set (END)
//
//      // Simple LFSR to pseudo randomize the color
//      lfsr_lsb = lfsr & 1;                       /* Get LSB (i.e., the output bit). */
//      lfsr     >>= 1;                            /* Shift register */
//      lfsr     ^= (-lfsr_lsb) & 0xB400u;         /* If the output bit is 1, apply toggle mask.
//                                                  * The value has 1 at bits corresponding
//                                                  * to taps, 0 elsewhere. */
//      LCD_REC_DATA    = lfsr;
//
//      wait_time(WT_50MS);
//    }
//  }
