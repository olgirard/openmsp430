#include "omsp_system.h"
#include "timerA.h"
#include "gfx_controller.h"
#include "palette_64k.h"

int display_f_16bpp(void);
int display_8bpp(void);

/**
Main
*/
int main(void) {

  unsigned int idx1;

  WDTCTL = WDTPW | WDTHOLD;   // Disable watchdog timer

  //init_gfx_ctrl(GFX_8_BPP, LT24_REFR_MANUAL); // Initialize Graphic controller
  init_gfx_ctrl(GFX_16_BPP, LT24_REFR_MANUAL); // Initialize Graphic controller
  //init_gfx_ctrl(GFX_16_BPP, LT24_REFR_24MS); // Initialize Graphic controller

  // Initialize palette
  LUT_RAM_ADDR    = 0x0000;
  for( idx1 = 0; idx1 < 256; idx1 = idx1 + 1 ) {
    LUT_RAM_DATA  = palette_64k[idx1];
  }

  // LUT Configuration
  LUT_CFG         = SW_LUT_DISABLE      |
                    SW_LUT_BANK0_SELECT |
                    HW_LUT_PALETTE_0_LO;

  // Initialize Frame pointers
  FRAME0_PTR_HI   = 0x0000;
  FRAME0_PTR_LO   = 0x0000;

  FRAME1_PTR_HI   = 0x0000;
  FRAME1_PTR_LO   = 0x0000;

  FRAME_SELECT    = REFRESH_FRAME0_SELECT  |
                    VID_RAM0_FRAME0_SELECT |
                    VID_RAM1_FRAME0_SELECT;

  start_gfx_ctrl();            // Start Graphic controller

  LT24_REFRESH_SYNC = LT24_REFR_SYNC | 0x0000;

  display_f_16bpp();
  //display_8bpp();

  while(1);
}

int display_8bpp(void) {

  unsigned int  line, column;
  unsigned int  color_idx    = 0;
  unsigned int  color_toggle = 0;
  unsigned int  color        = 0;

  // Write some stuff to the user memory
  while (1) {

    // Initialize pointer
    VID_RAM0_ADDR_HI = 0x0000;
    VID_RAM0_ADDR_LO = 0x0000;

    // Fill the screen
    color_idx    = 0x0000;
    color        = 0x0000;
    color_toggle = color_toggle ^ 1;

    for( line = 0; line < SCREEN_HEIGHT; line = line + 1 ) {
      for( column = 0; column < SCREEN_WIDTH/2; column = column + 1 ) {
	VID_RAM0_DATA	 = color;
      }
      color_idx++;
      color = (color_idx<<8)+color_idx;
    }

    // Manual refresh
    LT24_REFRESH      = LT24_REFRESH   | LT24_REFR_START;
    GFX_IRQ = GFX_IRQ_REFRESH_DONE;
    while((GFX_IRQ & GFX_IRQ_REFRESH_DONE)==0);

    ta_wait_no_lpm(WT_20MS);
  }
  return 0;
};

int display_f_16bpp(void) {

  unsigned int idx1;
  unsigned int line, column;
  unsigned int lfsr = 0xACE1;
  unsigned int lfsr_lsb;
  unsigned int data;

  // Write some stuff to the user memory
  while (1) {

    // Simple LFSR to pseudo randomize the color
    lfsr_lsb = lfsr & 1;		 /* Get LSB (i.e., the output bit). */
    lfsr     >>= 1;			 /* Shift register */
    lfsr     ^= (-lfsr_lsb) & 0xB400u;	 /* If the output bit is 1, apply toggle mask.
					  * The value has 1 at bits corresponding
					  * to taps, 0 elsewhere. */

    // Initialize pointer
    VID_RAM0_ADDR_HI = 0x0000;
    VID_RAM0_ADDR_LO = 0x0000;

    // Fill the screen
    for( line = 0; line < SCREEN_HEIGHT; line = line + 1 ) {
      for( column = 0; column < SCREEN_WIDTH; column = column + 1 ) {
	VID_RAM0_DATA	 = lfsr;
      }
    }

    // Draw an 'RGB' flag
    VID_RAM0_ADDR_HI = 0x0000;
    idx1             = 0x0000;
    for( line = 0; line < 25; line = line + 1 ) {
      VID_RAM0_ADDR_LO = idx1 + 0;
      for( column = 0; column < 25; column = column + 1 ) {
     	VID_RAM0_DATA	 = 0xF800;
      }
      idx1             = idx1 + 320;
    }
    VID_RAM0_ADDR_HI = 0x0000;
    idx1             = 0x0019;
    for( line = 0; line < 25; line = line + 1 ) {
      VID_RAM0_ADDR_LO = idx1 + 0;
      for( column = 0; column < 25; column = column + 1 ) {
     	VID_RAM0_DATA	 = 0x07E0;
      }
      idx1             = idx1 + 320;
    }
    VID_RAM0_ADDR_HI = 0x0000;
    idx1             = 0x0032;
    for( line = 0; line < 25; line = line + 1 ) {
      VID_RAM0_ADDR_LO = idx1 + 0;
      for( column = 0; column < 25; column = column + 1 ) {
     	VID_RAM0_DATA	 = 0x001F;
      }
      idx1             = idx1 + 320;
    }

    // Draw an 'F' with inverted color
    data = lfsr ^ 0xFFFF;

    VID_RAM0_ADDR_HI = 0x0000;
    idx1             = 0x3E80;

    for( line = 0; line < 20; line = line + 1 ) {
      VID_RAM0_ADDR_LO = idx1 + 50;
      idx1             = idx1 + 320;
      for( column = 0; column < 100; column = column + 1 ) {
     	VID_RAM0_DATA	 = data;
      }
    }

    for( line = 0; line < 100; line = line + 1 ) {
      VID_RAM0_ADDR_LO = idx1 + 50;
      idx1             = idx1 + 320;
      for( column = 0; column < 20; column = column + 1 ) {
     	VID_RAM0_DATA	 = data;
      }
    }

    idx1             = 0x7D00;
    for( line = 0; line < 20; line = line + 1 ) {
      VID_RAM0_ADDR_LO = idx1 + 50;
      idx1             = idx1 + 320;
      for( column = 0; column < 90; column = column + 1 ) {
     	VID_RAM0_DATA	 = data;
      }
    }

    // Manual refresh
    LT24_REFRESH      = LT24_REFRESH   | LT24_REFR_START;
    GFX_IRQ = GFX_IRQ_REFRESH_DONE;
    while((GFX_IRQ & GFX_IRQ_REFRESH_DONE)==0);

  }
  return 0;
}
