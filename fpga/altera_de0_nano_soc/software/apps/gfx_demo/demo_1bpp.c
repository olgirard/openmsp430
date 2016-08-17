#include "demo.h"
#include "timerA.h"
#include "gfx_controller.h"

//---------------------------------------------------//
// 8BPP DEMO
//---------------------------------------------------//
void demo_1bpp(void) {

  unsigned int  line, column;
  unsigned int  color        = 0;
  unsigned int  use_gpu      = 1;
  unsigned int  wait_sel     = 0;
  unsigned int  x_coord      = 0;
  unsigned int  y_coord      = 0;
  unsigned int  loop;

  const uint16_t offset_x    = 35;
  const uint16_t offset_y    = 95;
  const uint16_t char_width  =  7;

  // Screen introduction
  gpu_fill (PIX_ADDR(0,                                    0                    ), 320,          480,          0x0000, DST_SWAP_NONE); // Background

  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+2*char_width, offset_y+0*char_width), 1*char_width, 6*char_width, 0x0001, DST_SWAP_NONE); // 1
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+1*char_width, offset_y+1*char_width), 1*char_width, 1*char_width, 0x0001, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+1*char_width, offset_y+6*char_width), 3*char_width, 1*char_width, 0x0001, DST_SWAP_NONE);

  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+0*char_width, offset_y+0*char_width), 1*char_width, 6*char_width, 0x0001, DST_SWAP_NONE); // b
  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+1*char_width, offset_y+6*char_width), 3*char_width, 1*char_width, 0x0001, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+1*char_width, offset_y+4*char_width), 1*char_width, 1*char_width, 0x0001, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+2*char_width, offset_y+3*char_width), 2*char_width, 1*char_width, 0x0001, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+4*char_width, offset_y+4*char_width), 1*char_width, 2*char_width, 0x0001, DST_SWAP_NONE);

  gpu_fill (PIX_ADDR(offset_x+4*6*char_width+0*char_width, offset_y+2*char_width), 1*char_width, 5*char_width, 0x0001, DST_SWAP_NONE); // p
  gpu_fill (PIX_ADDR(offset_x+4*6*char_width+1*char_width, offset_y+2*char_width), 3*char_width, 1*char_width, 0x0001, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+4*6*char_width+1*char_width, offset_y+4*char_width), 3*char_width, 1*char_width, 0x0001, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+4*6*char_width+4*char_width, offset_y+3*char_width), 1*char_width, 1*char_width, 0x0001, DST_SWAP_NONE);

  gpu_fill (PIX_ADDR(offset_x+5*6*char_width+0*char_width, offset_y+2*char_width), 1*char_width, 5*char_width, 0x0001, DST_SWAP_NONE); // p
  gpu_fill (PIX_ADDR(offset_x+5*6*char_width+1*char_width, offset_y+2*char_width), 3*char_width, 1*char_width, 0x0001, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+5*6*char_width+1*char_width, offset_y+4*char_width), 3*char_width, 1*char_width, 0x0001, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+5*6*char_width+4*char_width, offset_y+3*char_width), 1*char_width, 1*char_width, 0x0001, DST_SWAP_NONE);

  ta_wait_no_lpm(WT_500MS);
  ta_wait_no_lpm(WT_500MS);
  ta_wait_no_lpm(WT_500MS);
  ta_wait_no_lpm(WT_500MS);

  // Clear background
  gpu_fill (PIX_ADDR(0,                                    0                    ), 320,          240,          0x0000, DST_SWAP_NONE);

  // Wait for on-going GPU operation to be done before moving on
  gpu_wait_done();

  // Fill the screen with all possible colors
  color     = 0x0006;
  x_coord   = 0;
  y_coord   = 0;
  for( line = 0; line <2; line = line + 1 ) {
    for( column = 0; column < 2; column = column + 1 ) {

      draw_block(PIX_ADDR(x_coord, y_coord), 158, 118, color, DST_SWAP_NONE, 0);
      color   /= 2;
      x_coord += 162;
    }
    y_coord += 122;
    x_coord  =  0;
  }
  ta_wait_no_lpm(WT_500MS);
  ta_wait_no_lpm(WT_500MS);

  // Loop the demo
  loop  = 0;
  color = 0x0000;
  while (loop <4) {

    // Select rotation & GPU use
    switch(loop) {
    case 0 : DISPLAY_CFG = DST_SWAP_CL;	 wait_sel = 3;
	     break;
    case 1 : DISPLAY_CFG = DST_SWAP_CL;	 wait_sel = 2;
	     break;
    case 2 : DISPLAY_CFG = DST_SWAP_CL;	 wait_sel = 1;
	     break;
    default: DISPLAY_CFG = DST_SWAP_CL;	 wait_sel = 0;
	     break;
    }
    loop++;
    move_to_next_mode = 0;

    // Move the starting point of the buffer refresh
    DISPLAY_REFR_CNT =	0;
    while (!move_to_next_mode | (color!=0x0000)) {

      if (color==0x0000) {
	color = 0x4821;
	//  1000  0100  0010  0001  0000  0000  0000  0000  0000  0000  0000  0000  0000  0000  0000  0000  0000  0000  1000
	//  0000  0000  0000  0000  0001  0000  0000  0000  0000  0000  0000  1000  0100  0010  0000  0000  0000  1000  0000
	//  0000  0000  0000  0000  0000  0001  0000  0000  0000  0000  1000  0000  0000  0000  0010  0100  1000  0000  0000
	//  0000  0000  0000  0000  0000  0000  0001  0010  0100  1000  0000  0000  0000  0000  0000  0000  0000  0000  0000
      }

      // Fill the screen with random colors
      x_coord	   = 0;
      y_coord	   = 0;
      for( line = 0; line <2; line = line + 1 ) {
	for( column = 0; column < 2; column = column + 1 ) {

	  // Draw the box
	  draw_block(PIX_ADDR(x_coord, y_coord), 158, 118, color, DST_SWAP_NONE, use_gpu);
	  color   /= 2;
	  x_coord += 162;
	}
	y_coord += 122;
	x_coord	 =  0;
      }

      // Wait according to config
      switch(wait_sel) {
      case 0 : while(DISPLAY_REFR_CNT!=0); DISPLAY_REFR_CNT = 3;
	       break;
      case 1 : while(DISPLAY_REFR_CNT!=0); DISPLAY_REFR_CNT = 6;
	       break;
      case 2 : while(DISPLAY_REFR_CNT!=0); DISPLAY_REFR_CNT = 9;
	       break;
      default: while(DISPLAY_REFR_CNT!=0); DISPLAY_REFR_CNT = 15;
	       break;
      }
    }
  }
};
