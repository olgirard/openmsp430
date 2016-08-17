#include "demo.h"
#include "timerA.h"
#include "gfx_controller.h"

//---------------------------------------------------//
// 8BPP DEMO
//---------------------------------------------------//
void demo_8bpp(void) {

  unsigned int  line, column;
  unsigned int  color        = 0;
  unsigned int  use_gpu      = 0;
  unsigned int  wait_sel     = 0;
  unsigned int  x_coord      = 0;
  unsigned int  y_coord      = 0;
  unsigned int  loop;
  volatile unsigned int  address;

  const uint16_t offset_x    = 35;
  const uint16_t offset_y    = 95;
  const uint16_t char_width  =  7;

  // Screen introduction
  gpu_fill (PIX_ADDR(0,                                    0                    ), 320,          480,          0x0000, DST_SWAP_NONE); // Background

  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+1*char_width, offset_y+0*char_width), 3*char_width, 1*char_width, 0x001C, DST_SWAP_NONE); // 8
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+1*char_width, offset_y+3*char_width), 3*char_width, 1*char_width, 0x001C, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+1*char_width, offset_y+6*char_width), 3*char_width, 1*char_width, 0x001C, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+0*char_width, offset_y+1*char_width), 1*char_width, 2*char_width, 0x001C, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+4*char_width, offset_y+1*char_width), 1*char_width, 2*char_width, 0x001C, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+0*char_width, offset_y+4*char_width), 1*char_width, 2*char_width, 0x001C, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+4*char_width, offset_y+4*char_width), 1*char_width, 2*char_width, 0x001C, DST_SWAP_NONE);

  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+0*char_width, offset_y+0*char_width), 1*char_width, 6*char_width, 0x001C, DST_SWAP_NONE); // b
  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+1*char_width, offset_y+6*char_width), 3*char_width, 1*char_width, 0x001C, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+1*char_width, offset_y+4*char_width), 1*char_width, 1*char_width, 0x001C, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+2*char_width, offset_y+3*char_width), 2*char_width, 1*char_width, 0x001C, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+4*char_width, offset_y+4*char_width), 1*char_width, 2*char_width, 0x001C, DST_SWAP_NONE);

  gpu_fill (PIX_ADDR(offset_x+4*6*char_width+0*char_width, offset_y+2*char_width), 1*char_width, 5*char_width, 0x001C, DST_SWAP_NONE); // p
  gpu_fill (PIX_ADDR(offset_x+4*6*char_width+1*char_width, offset_y+2*char_width), 3*char_width, 1*char_width, 0x001C, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+4*6*char_width+1*char_width, offset_y+4*char_width), 3*char_width, 1*char_width, 0x001C, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+4*6*char_width+4*char_width, offset_y+3*char_width), 1*char_width, 1*char_width, 0x001C, DST_SWAP_NONE);

  gpu_fill (PIX_ADDR(offset_x+5*6*char_width+0*char_width, offset_y+2*char_width), 1*char_width, 5*char_width, 0x001C, DST_SWAP_NONE); // p
  gpu_fill (PIX_ADDR(offset_x+5*6*char_width+1*char_width, offset_y+2*char_width), 3*char_width, 1*char_width, 0x001C, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+5*6*char_width+1*char_width, offset_y+4*char_width), 3*char_width, 1*char_width, 0x001C, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+5*6*char_width+4*char_width, offset_y+3*char_width), 1*char_width, 1*char_width, 0x001C, DST_SWAP_NONE);

  ta_wait_no_lpm(WT_500MS);
  ta_wait_no_lpm(WT_500MS);
  ta_wait_no_lpm(WT_500MS);
  ta_wait_no_lpm(WT_500MS);

  // Clear background
  gpu_fill (PIX_ADDR(0,                                    0                    ), 320,          240,          0x0000, DST_SWAP_NONE);

  // Wait for on-going GPU operation to be done before moving on
  gpu_wait_done();

  // Fill the screen with all possible colors
  color = 0x0000;
  for( line = 0; line <29; line = line + 1 ) {
    for( column = 0; column < 20; column = column + 1 ) {

      draw_block(PIX_ADDR(x_coord, y_coord), 13, 13, color, DST_SWAP_NONE, use_gpu);
      if (color==255) { color= 0;}
      else            { color++; }
      x_coord += 16;
    }
    y_coord += 16;
    x_coord  =  0;
  }
  ta_wait_no_lpm(WT_500MS);
  ta_wait_no_lpm(WT_500MS);

  // Use the frame pointer 1 for refresh
  FRAME1_PTR = 0x0000;
  FRAME_SELECT = (FRAME_SELECT & ~REFRESH_FRAME_MASK) | REFRESH_FRAME1_SELECT;

  // Initialize coordinates for refresh
  x_coord      = 0;
  y_coord      = 0;

  // Loop the demo
  loop = 0;
  while (loop <4) {

    // Select rotation & GPU use
    switch(loop & 0x0003) {
    case 0 : DISPLAY_CFG = DST_SWAP_CL;  wait_sel = 3;
             break;
    case 1 : DISPLAY_CFG = DST_SWAP_CL;  wait_sel = 2;
             break;
    case 2 : DISPLAY_CFG = DST_SWAP_CL;  wait_sel = 1;
             break;
    default: DISPLAY_CFG = DST_SWAP_CL;  wait_sel = 0;
             break;
    }
    loop++;
    move_to_next_mode = 0;

    // Move the starting point of the buffer refresh
    DISPLAY_REFR_CNT =  0;
    while (!move_to_next_mode) {

      FRAME1_PTR = address;

      // Compute next address
      x_coord +=1;
      y_coord +=1;
      address = PIX_ADDR(x_coord, y_coord);

      // Wait according to config
      switch(wait_sel) {
      case 0 : break;
      case 1 : while(DISPLAY_REFR_CNT!=0); DISPLAY_REFR_CNT = 1;
  	       break;
      case 2 : while(DISPLAY_REFR_CNT!=0); DISPLAY_REFR_CNT = 2;
	       break;
      default: while(DISPLAY_REFR_CNT!=0); DISPLAY_REFR_CNT = 3;
   	       break;
      }
    }
  }

  // Restore refresh configuration
  FRAME0_PTR = 0x0000;
  FRAME_SELECT = (FRAME_SELECT & ~REFRESH_FRAME_MASK) | REFRESH_FRAME0_SELECT;
};
