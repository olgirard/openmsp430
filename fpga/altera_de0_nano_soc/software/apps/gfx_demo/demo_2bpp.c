#include "demo.h"
#include "timerA.h"
#include "gfx_controller.h"

//---------------------------------------------------//
// 8BPP DEMO
//---------------------------------------------------//
void demo_2bpp(void) {

  unsigned int  line, column;
  unsigned int  color        = 0;
  unsigned int  x_coord      = 0;
  unsigned int  y_coord      = 0;
  unsigned int  palette      = 0;
  unsigned int  bg_color     = 0;

  const uint16_t offset_x    = 35;
  const uint16_t offset_y    = 95;
  const uint16_t char_width  =  7;

  // Screen introduction
  gpu_fill (PIX_ADDR(0,                                    0                    ), 320,          480,          0x0000, DST_SWAP_NONE); // Background

  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+1*char_width, offset_y+0*char_width), 3*char_width, 1*char_width, 0x0003, DST_SWAP_NONE); // 2
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+0*char_width, offset_y+1*char_width), 1*char_width, 1*char_width, 0x0003, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+4*char_width, offset_y+1*char_width), 1*char_width, 2*char_width, 0x0003, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+3*char_width, offset_y+3*char_width), 1*char_width, 1*char_width, 0x0003, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+2*char_width, offset_y+4*char_width), 1*char_width, 1*char_width, 0x0003, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+1*char_width, offset_y+5*char_width), 1*char_width, 1*char_width, 0x0003, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+0*char_width, offset_y+6*char_width), 5*char_width, 1*char_width, 0x0003, DST_SWAP_NONE);

  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+0*char_width, offset_y+0*char_width), 1*char_width, 6*char_width, 0x0003, DST_SWAP_NONE); // b
  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+1*char_width, offset_y+6*char_width), 3*char_width, 1*char_width, 0x0003, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+1*char_width, offset_y+4*char_width), 1*char_width, 1*char_width, 0x0003, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+2*char_width, offset_y+3*char_width), 2*char_width, 1*char_width, 0x0003, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+4*char_width, offset_y+4*char_width), 1*char_width, 2*char_width, 0x0003, DST_SWAP_NONE);

  gpu_fill (PIX_ADDR(offset_x+4*6*char_width+0*char_width, offset_y+2*char_width), 1*char_width, 5*char_width, 0x0003, DST_SWAP_NONE); // p
  gpu_fill (PIX_ADDR(offset_x+4*6*char_width+1*char_width, offset_y+2*char_width), 3*char_width, 1*char_width, 0x0003, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+4*6*char_width+1*char_width, offset_y+4*char_width), 3*char_width, 1*char_width, 0x0003, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+4*6*char_width+4*char_width, offset_y+3*char_width), 1*char_width, 1*char_width, 0x0003, DST_SWAP_NONE);

  gpu_fill (PIX_ADDR(offset_x+5*6*char_width+0*char_width, offset_y+2*char_width), 1*char_width, 5*char_width, 0x0003, DST_SWAP_NONE); // p
  gpu_fill (PIX_ADDR(offset_x+5*6*char_width+1*char_width, offset_y+2*char_width), 3*char_width, 1*char_width, 0x0003, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+5*6*char_width+1*char_width, offset_y+4*char_width), 3*char_width, 1*char_width, 0x0003, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+5*6*char_width+4*char_width, offset_y+3*char_width), 1*char_width, 1*char_width, 0x0003, DST_SWAP_NONE);

  ta_wait_no_lpm(WT_500MS);
  ta_wait_no_lpm(WT_500MS);
  ta_wait_no_lpm(WT_500MS);
  ta_wait_no_lpm(WT_500MS);

  // Clear background
  gpu_fill (PIX_ADDR(0,                                    0                    ), 320,          240,          0x0000, DST_SWAP_NONE);

  // Wait for on-going GPU operation to be done before moving on
  gpu_wait_done();

  // Fill the screen with all possible colors
  color     = 0x0000;
  x_coord   = 0;
  y_coord   = 0;
  for( line = 0; line <2; line = line + 1 ) {
    for( column = 0; column < 2; column = column + 1 ) {

      draw_block(PIX_ADDR(x_coord, y_coord), 158, 118, color, DST_SWAP_NONE, 0);
      if (color==3) { color= 0;}
      else          { color++; }
      x_coord += 162;
    }
    y_coord += 122;
    x_coord  =  0;
  }
  ta_wait_no_lpm(WT_500MS);
  ta_wait_no_lpm(WT_500MS);

  // For each palette, try out each background-color
  for( palette = 0; palette <6; palette = palette + 1 ) {

    LUT_CFG = (LUT_CFG & ~HW_LUT_PALETTE_MSK) | HW_LUT_BG_BLACK | (palette<<4);
    ta_wait_no_lpm(WT_500MS);
    ta_wait_no_lpm(WT_500MS);

    for( bg_color = 0; bg_color < 15; bg_color = bg_color + 1 ) {

      LUT_CFG = (LUT_CFG & ~HW_LUT_BGCOLOR_MSK) | (bg_color<<8);

      ta_wait_no_lpm(WT_500MS);
    }

    LUT_CFG = (LUT_CFG & ~HW_LUT_BGCOLOR_MSK) | HW_LUT_BG_BLACK;
    ta_wait_no_lpm(WT_500MS);
    ta_wait_no_lpm(WT_500MS);
  }

  // Re-initialize LUT configuration
  LUT_CFG = HW_LUT_BG_BLACK     |
            HW_LUT_FG_WHITE     |
            HW_LUT_PALETTE_0_HI |
            SW_LUT_BANK0_SELECT |
            SW_LUT_DISABLE;
};
