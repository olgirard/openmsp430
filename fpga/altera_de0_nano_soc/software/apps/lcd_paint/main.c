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

  //VID_RAM0_CFG     = VID_RAM_NO_RMW_MODE | VID_RAM_WIN_MODE | VID_RAM_WIN_X_SWAP | VID_RAM_WIN_Y_SWAP | VID_RAM_WIN_CL_SWAP;
  //VID_RAM0_WIDTH   = 8;
  VID_RAM0_WIDTH   = 5;
  VID_RAM0_ADDR_HI = 0x0000;
  //VID_RAM0_ADDR_LO = 27;
  VID_RAM0_ADDR_LO = 86;

#ifdef TEST_16_BPP
  __nop();
  __nop();
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
  VID_RAM0_DATA    = 41;
  VID_RAM0_DATA    = 42;
  VID_RAM0_DATA    = 43;
  VID_RAM0_DATA    = 44;
  VID_RAM0_DATA    = 45;
  VID_RAM0_DATA    = 46;
  VID_RAM0_DATA    = 47;
  VID_RAM0_DATA    = 48;
  VID_RAM0_DATA    = 49;
  VID_RAM0_DATA    = 50;
  VID_RAM0_DATA    = 51;
  VID_RAM0_DATA    = 52;
  VID_RAM0_DATA    = 53;
  VID_RAM0_DATA    = 54;
  VID_RAM0_DATA    = 55;
  VID_RAM0_DATA    = 56;
  VID_RAM0_DATA    = 57;
  VID_RAM0_DATA    = 58;
  VID_RAM0_DATA    = 59;
  VID_RAM0_DATA    = 60;
  VID_RAM0_DATA    = 61;
  VID_RAM0_DATA    = 62;
  VID_RAM0_DATA    = 63;
  VID_RAM0_DATA    = 64;
  VID_RAM0_DATA    = 65;
  VID_RAM0_DATA    = 66;
  VID_RAM0_DATA    = 67;
  VID_RAM0_DATA    = 68;
  VID_RAM0_DATA    = 69;
  VID_RAM0_DATA    = 70;
  VID_RAM0_DATA    = 71;
  VID_RAM0_DATA    = 72;
  VID_RAM0_DATA    = 73;
  VID_RAM0_DATA    = 74;
  VID_RAM0_DATA    = 75;
  VID_RAM0_DATA    = 76;
  VID_RAM0_DATA    = 77;
  VID_RAM0_DATA    = 78;
  VID_RAM0_DATA    = 79;
  VID_RAM0_DATA    = 80;
  VID_RAM0_DATA    = 81;
  VID_RAM0_DATA    = 82;
  VID_RAM0_DATA    = 83;
  VID_RAM0_DATA    = 84;
  VID_RAM0_DATA    = 85;
  VID_RAM0_DATA    = 86;
  VID_RAM0_DATA    = 87;
  VID_RAM0_DATA    = 88;
  VID_RAM0_DATA    = 89;
  VID_RAM0_DATA    = 90;
  VID_RAM0_DATA    = 91;
  VID_RAM0_DATA    = 92;
  VID_RAM0_DATA    = 93;
  VID_RAM0_DATA    = 94;
  VID_RAM0_DATA    = 95;
  VID_RAM0_DATA    = 96;
  VID_RAM0_DATA    = 97;
  VID_RAM0_DATA    = 98;
  VID_RAM0_DATA    = 99;
  VID_RAM0_DATA    = 100;
  VID_RAM0_DATA    = 101;
  VID_RAM0_DATA    = 102;
  VID_RAM0_DATA    = 103;
  VID_RAM0_DATA    = 104;
  VID_RAM0_DATA    = 105;
  VID_RAM0_DATA    = 106;
  VID_RAM0_DATA    = 107;
  VID_RAM0_DATA    = 108;
  VID_RAM0_DATA    = 109;
  VID_RAM0_DATA    = 110;
  VID_RAM0_DATA    = 111;
  VID_RAM0_DATA    = 112;
  VID_RAM0_DATA    = 113;
  VID_RAM0_DATA    = 114;
  VID_RAM0_DATA    = 115;
  VID_RAM0_DATA    = 116;
  VID_RAM0_DATA    = 117;
  VID_RAM0_DATA    = 118;
  VID_RAM0_DATA    = 119;
  VID_RAM0_DATA    = 120;
  VID_RAM0_DATA    = 121;
  VID_RAM0_DATA    = 122;
  VID_RAM0_DATA    = 123;
  VID_RAM0_DATA    = 124;
  VID_RAM0_DATA    = 125;
  VID_RAM0_DATA    = 126;
  VID_RAM0_DATA    = 127;
  VID_RAM0_DATA    = 128;
  VID_RAM0_DATA    = 129;
  VID_RAM0_DATA    = 130;
  VID_RAM0_DATA    = 131;
  VID_RAM0_DATA    = 132;
  VID_RAM0_DATA    = 133;
  VID_RAM0_DATA    = 134;
  VID_RAM0_DATA    = 135;
  VID_RAM0_DATA    = 136;
  VID_RAM0_DATA    = 137;
  VID_RAM0_DATA    = 138;
  VID_RAM0_DATA    = 139;
  VID_RAM0_DATA    = 140;
  VID_RAM0_DATA    = 141;
  VID_RAM0_DATA    = 142;
  VID_RAM0_DATA    = 143;
  VID_RAM0_DATA    = 144;
  VID_RAM0_DATA    = 145;
  VID_RAM0_DATA    = 146;
  VID_RAM0_DATA    = 147;
  VID_RAM0_DATA    = 148;
  VID_RAM0_DATA    = 149;
  VID_RAM0_DATA    = 150;
  VID_RAM0_DATA    = 151;
  VID_RAM0_DATA    = 152;
  VID_RAM0_DATA    = 153;
  VID_RAM0_DATA    = 154;
  VID_RAM0_DATA    = 155;
  VID_RAM0_DATA    = 156;
  VID_RAM0_DATA    = 157;
  VID_RAM0_DATA    = 158;
  VID_RAM0_DATA    = 159;
  VID_RAM0_DATA    = 160;
  VID_RAM0_DATA    = 161;
  VID_RAM0_DATA    = 162;
  VID_RAM0_DATA    = 163;
  VID_RAM0_DATA    = 164;
  VID_RAM0_DATA    = 165;
  VID_RAM0_DATA    = 166;
  VID_RAM0_DATA    = 167;
  VID_RAM0_DATA    = 168;
  VID_RAM0_DATA    = 169;
  VID_RAM0_DATA    = 170;
  VID_RAM0_DATA    = 171;
  VID_RAM0_DATA    = 172;
  VID_RAM0_DATA    = 173;
  VID_RAM0_DATA    = 174;
  VID_RAM0_DATA    = 175;
  VID_RAM0_DATA    = 176;
  VID_RAM0_DATA    = 177;
  VID_RAM0_DATA    = 178;
  VID_RAM0_DATA    = 179;
  VID_RAM0_DATA    = 180;
  VID_RAM0_DATA    = 181;
  VID_RAM0_DATA    = 182;
  VID_RAM0_DATA    = 183;
  VID_RAM0_DATA    = 184;
  VID_RAM0_DATA    = 185;
  VID_RAM0_DATA    = 186;
  VID_RAM0_DATA    = 187;
  VID_RAM0_DATA    = 188;
  VID_RAM0_DATA    = 189;
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

  VID_RAM0_ADDR_HI = 0x0001;
  VID_RAM0_ADDR_HI = 0x0000;
  VID_RAM0_ADDR_HI = 0x0001;
  VID_RAM0_ADDR_LO = 0x0000;
  //__nop();
  //__nop();
  //__nop();
  //__nop();
  //__nop();
  //__nop();
  temp1           = VID_RAM0_DATA;
  __nop();
  temp2           = VID_RAM0_DATA;
  temp3           = VID_RAM0_DATA;
  temp4           = VID_RAM0_DATA;

  VID_RAM1_ADDR_LO = 0x0002;
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
