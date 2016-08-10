#include "demo.h"
#include "timerA.h"
#include "gfx_controller.h"

//---------------------------------------------------//
// STRUCTURE AND DATA TABLE
//---------------------------------------------------//

typedef struct {
        uint16_t color;
        uint8_t  index;
        uint8_t  palette;
        uint8_t  line_nr_start;
} grad_color;

//                                             FIRST   LAST    END     INCR
static unsigned int color_table[4][10][4] = {{{0x0001, 0x001F, 0x001F, 0x0001} ,
                                              {0x003F, 0x03FF, 0x03FF, 0x0020} ,
                                              {0x041F, 0x07DF, 0x07FF, 0x0020} ,
                                              {0x07FE, 0x07E0, 0x07E0, 0xFFFF} ,
                                              {0x0FE0, 0xFFE0, 0xFFE0, 0x0800} ,
                                              {0xFFE1, 0xFFFF, 0xFFFF, 0x0001} ,
                                              {0xFFDF, 0xFC1F, 0xFC1F, 0xFFE0} ,
                                              {0xFBFF, 0xF83F, 0xF81F, 0xFFE0} ,
                                              {0xF81E, 0xF800, 0xF800, 0xFFFF} ,
                                              {0xF000, 0x0000, 0x0000, 0xF800}},
//                                             FIRST   LAST    END     INCR
                                             {{0x0001, 0x001F, 0x001F, 0x0001} ,
                                              {0x081F, 0xF81F, 0xF81F, 0x0800} ,
                                              {0xF81E, 0xF800, 0xF800, 0xFFFF} ,
                                              {0xF820, 0xFBE0, 0xFBE0, 0x0020} ,
                                              {0xFC00, 0xFFC0, 0xFFE0, 0x0020} ,
                                              {0xFFE1, 0xFFFF, 0xFFFF, 0x0001} ,
                                              {0xF7FF, 0x07FF, 0x07FF, 0xF800} ,
                                              {0x07FE, 0x07E0, 0x07E0, 0xFFFF} ,
                                              {0x07C0, 0x0400, 0x0400, 0xFFE0} ,
                                              {0x03E0, 0x0020, 0x0000, 0xFFE0}},
//                                             FIRST   LAST    END     INCR
                                             {{0x0800, 0xF800, 0xF800, 0x0800} ,
                                              {0xF801, 0xF81F, 0xF81F, 0x0001} ,
                                              {0xF01F, 0x001F, 0x001F, 0xF800} ,
                                              {0x003F, 0x03FF, 0x03FF, 0x0020} ,
                                              {0x041F, 0x07DF, 0x07FF, 0x0020} ,
                                              {0x0FFF, 0xFFFF, 0xFFFF, 0x0800} ,
                                              {0xFFFE, 0xFFE0, 0xFFE0, 0xFFFF} ,
                                              {0xF7E0, 0x07E0, 0x07E0, 0xF800} ,
                                              {0x07C0, 0x0400, 0x0400, 0xFFE0} ,
                                              {0x03E0, 0x0020, 0x0000, 0xFFE0}},
//                                             FIRST   LAST    END     INCR
                                             {{0x0800, 0xF800, 0xF800, 0x0800} ,
                                              {0xF820, 0xFBE0, 0xFBE0, 0x0020} ,
                                              {0xFC00, 0xFFC0, 0xFFE0, 0x0020} ,
                                              {0xF7E0, 0x07E0, 0x07E0, 0xF800} ,
                                              {0x07E1, 0x07FF, 0x07FF, 0x0001} ,
                                              {0x0FFF, 0xFFFF, 0xFFFF, 0x0800} ,
                                              {0xFFDF, 0xFC1F, 0xFC1F, 0xFFE0} ,
                                              {0xFBFF, 0xF83F, 0xF81F, 0xFFE0} ,
                                              {0xF01F, 0x001F, 0x001F, 0xF800} ,
                                              {0x001E, 0x0000, 0x0000, 0xFFFF}}};

//---------------------------------------------------//
// BASIC FUNCTIONS
//---------------------------------------------------//

void draw_block(uint32_t addr, uint16_t width, uint16_t length, uint16_t color, uint16_t swap_configuration, uint16_t use_gpu) {

  unsigned int line, column;

  if (use_gpu) { // Hardware FILL

    gpu_fill (addr, width, length, color, swap_configuration);

  } else {       // Software FILL
    VID_RAM0_CFG   = VID_RAM_WIN_MODE | VID_RAM_MSK_MODE | swap_configuration;
    VID_RAM0_WIDTH = width;
    VID_RAM0_ADDR  = addr;

    for( line = 0; line < length; line = line + 1 ) {
      for( column = 0; column < width; column = column + 1 ) {
        VID_RAM0_DATA = color;
      }
    }
  }
}


grad_color increment_gradient(grad_color mycolor) {

  if (mycolor.color==color_table[mycolor.palette][mycolor.index][1]) {
    if (mycolor.index==9) {
      mycolor.index = 0;
      if (mycolor.palette==3) {
        mycolor.palette = 0;
      } else {
        mycolor.palette++;
      }
    } else {
      mycolor.index++;
    }
    mycolor.color         = color_table[mycolor.palette][mycolor.index][0]-color_table[mycolor.palette][mycolor.index][3];
    mycolor.line_nr_start = 31;
  } else {
    mycolor.color         = mycolor.color+color_table[mycolor.palette][mycolor.index][3];
    mycolor.line_nr_start--;
  }
  return mycolor;
}


grad_color draw_gradient(grad_color mycolor, uint16_t width, int length, int incr_index) {

  unsigned int column;
  unsigned int nr_lines;

  nr_lines = length;

  // Fill the color gradient segment
  while (nr_lines!=0) {
    mycolor.color = mycolor.color+color_table[mycolor.palette][mycolor.index][3];
    for( column = 0; column < width; column = column + 1 ) {
      VID_RAM0_DATA = mycolor.color;
    }
    nr_lines--;
  };

  // Re-init values if we move to the next index
  if (incr_index) {
    mycolor.color = color_table[mycolor.palette][mycolor.index][2];
    if (mycolor.index==9) {mycolor.index = 0;}
    else                  {mycolor.index++;  }
  }

  return mycolor;
}

//---------------------------------------------------//
// 16BPP DEMO
//---------------------------------------------------//

void demo_16bpp(void) {

  unsigned int  loop;
  unsigned int  width;
  unsigned int  gpu_pxop;
  grad_color    omsp_color;
  unsigned int  m_color;
  unsigned int  s_color;
  unsigned int  p_color;
  grad_color    ogfx_color;
  unsigned int  g_color;
  unsigned int  f_color;
  unsigned int  x_color;
  unsigned int  use_gpu     =  0;

  const uint16_t offset_x   = 35;
  const uint16_t offset_y   = 95;
  const uint16_t char_width =  7;

  // Screen introduction
  gpu_fill (PIX_ADDR(0,                                    0                    ), 320,          240,          0x0000, DST_SWAP_NONE); // Background

  gpu_fill (PIX_ADDR(offset_x+0*6*char_width+2*char_width, offset_y+0*char_width), 1*char_width, 6*char_width, 0x001F, DST_SWAP_NONE); // 1
  gpu_fill (PIX_ADDR(offset_x+0*6*char_width+1*char_width, offset_y+1*char_width), 1*char_width, 1*char_width, 0x001F, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+0*6*char_width+1*char_width, offset_y+6*char_width), 3*char_width, 1*char_width, 0x001F, DST_SWAP_NONE);

  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+2*char_width, offset_y+0*char_width), 2*char_width, 1*char_width, 0x001F, DST_SWAP_NONE); // 6
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+1*char_width, offset_y+1*char_width), 1*char_width, 1*char_width, 0x001F, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+0*char_width, offset_y+2*char_width), 1*char_width, 4*char_width, 0x001F, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+1*char_width, offset_y+3*char_width), 3*char_width, 1*char_width, 0x001F, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+1*char_width, offset_y+6*char_width), 3*char_width, 1*char_width, 0x001F, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+1*6*char_width+4*char_width, offset_y+4*char_width), 1*char_width, 2*char_width, 0x001F, DST_SWAP_NONE);

  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+0*char_width, offset_y+0*char_width), 1*char_width, 6*char_width, 0x001F, DST_SWAP_NONE); // b
  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+1*char_width, offset_y+6*char_width), 3*char_width, 1*char_width, 0x001F, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+1*char_width, offset_y+4*char_width), 1*char_width, 1*char_width, 0x001F, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+2*char_width, offset_y+3*char_width), 2*char_width, 1*char_width, 0x001F, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+3*6*char_width+4*char_width, offset_y+4*char_width), 1*char_width, 2*char_width, 0x001F, DST_SWAP_NONE);

  gpu_fill (PIX_ADDR(offset_x+4*6*char_width+0*char_width, offset_y+2*char_width), 1*char_width, 5*char_width, 0x001F, DST_SWAP_NONE); // p
  gpu_fill (PIX_ADDR(offset_x+4*6*char_width+1*char_width, offset_y+2*char_width), 3*char_width, 1*char_width, 0x001F, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+4*6*char_width+1*char_width, offset_y+4*char_width), 3*char_width, 1*char_width, 0x001F, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+4*6*char_width+4*char_width, offset_y+3*char_width), 1*char_width, 1*char_width, 0x001F, DST_SWAP_NONE);

  gpu_fill (PIX_ADDR(offset_x+5*6*char_width+0*char_width, offset_y+2*char_width), 1*char_width, 5*char_width, 0x001F, DST_SWAP_NONE); // p
  gpu_fill (PIX_ADDR(offset_x+5*6*char_width+1*char_width, offset_y+2*char_width), 3*char_width, 1*char_width, 0x001F, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+5*6*char_width+1*char_width, offset_y+4*char_width), 3*char_width, 1*char_width, 0x001F, DST_SWAP_NONE);
  gpu_fill (PIX_ADDR(offset_x+5*6*char_width+4*char_width, offset_y+3*char_width), 1*char_width, 1*char_width, 0x001F, DST_SWAP_NONE);

  ta_wait_no_lpm(WT_500MS);
  ta_wait_no_lpm(WT_500MS);
  ta_wait_no_lpm(WT_500MS);
  ta_wait_no_lpm(WT_500MS);

  gpu_fill (PIX_ADDR(0,                                    0                    ), 320,          240,          0x0000, DST_SWAP_NONE); // Background

  loop = 0;
  while (loop <4) {

    // Wait for on-going GPU operation to be done before moving on
    gpu_wait_done();

    // Select rotation & GPU use
    switch(loop & 0x0003) {
    case 0 : DISPLAY_CFG = DST_SWAP_CL;      use_gpu = 0;
             break;
    case 1 : DISPLAY_CFG = DST_SWAP_CL;      use_gpu = 1;
             break;
    case 2 : DISPLAY_CFG = DST_SWAP_X_Y_CL;  use_gpu = 0;
             break;
    default: DISPLAY_CFG = DST_SWAP_X_Y_CL;  use_gpu = 1;
             break;
    }
    loop++;
    move_to_next_mode = 0;

    // Initialize colors
    omsp_color.color           = 0x0000;
    omsp_color.index           = 0;
    omsp_color.palette         = 0;
    omsp_color.line_nr_start   = 31;

    ogfx_color.color           = 0x0000;
    ogfx_color.index           = 0;
    ogfx_color.palette         = 2;
    ogfx_color.line_nr_start   = 31;

    // Play the demo
    while (!move_to_next_mode) {

      //-----------------------------------------
      // DRAW 'RGB' FLAG
      //-----------------------------------------
      // Note that the drawing is done using the window mode

      VID_RAM0_WIDTH = 5;
      draw_block      (PIX_ADDR( 0, 0), 5, 15, 0xF800, DST_SWAP_NONE, use_gpu);
      draw_block      (PIX_ADDR( 5, 0), 5, 15, 0x07E0, DST_SWAP_NONE, use_gpu);
      draw_block      (PIX_ADDR(10, 0), 5, 15, 0x001F, DST_SWAP_NONE, use_gpu);

      //-----------------------------------------
      // Draw 'O' of Omsp
      //-----------------------------------------

      // Set width and increment color
      width   = 15;
      omsp_color = increment_gradient(omsp_color);
      ogfx_color = increment_gradient(ogfx_color);

      VID_RAM0_WIDTH = width;

      // Top bar
      VID_RAM0_CFG   = VID_RAM_WIN_MODE | DST_SWAP_Y_CL;
      VID_RAM0_ADDR  = PIX_ADDR(31, 118);

      omsp_color     = draw_gradient(omsp_color,        width, omsp_color.line_nr_start   , 1);
      omsp_color     = draw_gradient(omsp_color,        width, 31                         , 1);
      omsp_color     = draw_gradient(omsp_color,        width, 31-omsp_color.line_nr_start, 0);
      draw_block      (PIX_ADDR(31+2*31, 118),          width, width, omsp_color.color, DST_SWAP_Y_CL, use_gpu);

      // Right bar
      VID_RAM0_CFG   = VID_RAM_WIN_MODE | DST_SWAP_NONE;
      VID_RAM0_ADDR  = PIX_ADDR(31+2*31, 118+1);

      omsp_color     = draw_gradient(omsp_color,        width, omsp_color.line_nr_start   , 1);
      omsp_color     = draw_gradient(omsp_color,        width, 31                         , 1);
      omsp_color     = draw_gradient(omsp_color,        width, 31                         , 1);
      omsp_color     = draw_gradient(omsp_color,        width, 31-omsp_color.line_nr_start, 0);
      draw_block      (PIX_ADDR(31+2*31, 118+3*31+1),   width, width, omsp_color.color, DST_SWAP_NONE, use_gpu);

      // Bottom bar
      VID_RAM0_CFG   = VID_RAM_WIN_MODE | DST_SWAP_X_CL;
      VID_RAM0_ADDR  = PIX_ADDR(31+2*31-1, 118+3*31+1);

      omsp_color     = draw_gradient(omsp_color,        width, omsp_color.line_nr_start   , 1);
      omsp_color     = draw_gradient(omsp_color,        width, 31                         , 1);
      omsp_color     = draw_gradient(omsp_color,        width, 31-omsp_color.line_nr_start, 0);
      draw_block      (PIX_ADDR(31-1, 118+3*31+1),      width, width, omsp_color.color, DST_SWAP_X_CL, use_gpu);

      // Left bar
      VID_RAM0_CFG   = VID_RAM_WIN_MODE | DST_SWAP_X_Y;
      VID_RAM0_ADDR  = PIX_ADDR(31-1, 118+3*31);

      omsp_color     = draw_gradient(omsp_color,        width, omsp_color.line_nr_start   , 1);
      omsp_color     = draw_gradient(omsp_color,        width, 31                         , 1);
      omsp_color     = draw_gradient(omsp_color,        width, 31                         , 1);
      omsp_color     = draw_gradient(omsp_color,        width, 31-omsp_color.line_nr_start, 0);
      draw_block      (PIX_ADDR(31-1, 118),             width, width, omsp_color.color, DST_SWAP_X_Y, use_gpu);

      //-----------------------------------------
      // Draw 'MSP'
      //-----------------------------------------
      VID_RAM0_WIDTH = 8;

      // Probe the colors for the 'M', 'S' and 'P'
      gpu_wait_done();
      VID_RAM0_ADDR  = PIX_ADDR(31+2*31, 118+3*31+2);
      __nop();
      __nop();
      m_color        = VID_RAM0_DATA;
      VID_RAM0_ADDR  = PIX_ADDR(31+2*31, 118+3*31+2-20);
      __nop();
      s_color        = VID_RAM0_DATA;
      VID_RAM0_ADDR  = PIX_ADDR(31+2*31, 118+3*31+2-40);
      __nop();
      p_color        = VID_RAM0_DATA;

      // 'M'
      draw_block      (PIX_ADDR(130    , 169    ), 8, 56, m_color, DST_SWAP_NONE, use_gpu);
      draw_block      (PIX_ADDR(130+  8, 169+  8), 8,  8, m_color, DST_SWAP_NONE, use_gpu);
      draw_block      (PIX_ADDR(130+2*8, 169+2*8), 8, 16, m_color, DST_SWAP_NONE, use_gpu);
      draw_block      (PIX_ADDR(130+3*8, 169+  8), 8,  8, m_color, DST_SWAP_NONE, use_gpu);
      draw_block      (PIX_ADDR(130+4*8, 169    ), 8, 56, m_color, DST_SWAP_NONE, use_gpu);

      // 'S'
      draw_block      (PIX_ADDR(180    , 169+  8), 8, 16, s_color, DST_SWAP_NONE, use_gpu);
      draw_block      (PIX_ADDR(180+4*8, 169+4*8), 8, 16, s_color, DST_SWAP_NONE, use_gpu);
      draw_block      (PIX_ADDR(180+  8, 169    ), 8, 32, s_color, DST_SWAP_CL  , use_gpu);
      draw_block      (PIX_ADDR(180+  8, 169+3*8), 8, 24, s_color, DST_SWAP_CL	, use_gpu);
      draw_block      (PIX_ADDR(180    , 169+6*8), 8, 32, s_color, DST_SWAP_CL	, use_gpu);

      // 'P'
      draw_block      (PIX_ADDR(230    , 169    ), 8, 56, p_color, DST_SWAP_NONE, use_gpu);
      draw_block      (PIX_ADDR(230+4*8, 169+  8), 8, 16, p_color, DST_SWAP_NONE, use_gpu);
      draw_block      (PIX_ADDR(230+  8, 169    ), 8, 24, p_color, DST_SWAP_CL  , use_gpu);
      draw_block      (PIX_ADDR(230+  8, 169+3*8), 8, 24, p_color, DST_SWAP_CL  , use_gpu);

      //-----------------------------------------
      // Draw 'O' of Ogfx
      //-----------------------------------------
      width = 15;

      gpu_pxop		 = GPU_PXOP_1;

      VID_RAM0_WIDTH	 = width;

      // Top bar
      if (use_gpu==0) {    // Software update
	VID_RAM0_CFG	 = VID_RAM_WIN_MODE | DST_SWAP_X_Y_CL;
	VID_RAM0_ADDR	 = PIX_ADDR(289, 30);
	ogfx_color	 = draw_gradient(ogfx_color,	      width, ogfx_color.line_nr_start	, 1);
	ogfx_color	 = draw_gradient(ogfx_color,	      width, 31				, 1);
	ogfx_color	 = draw_gradient(ogfx_color,	      width, 31-ogfx_color.line_nr_start, 0);
      } else {		   // Hardware update
	gpu_copy	  (PIX_ADDR(1*31, 118), PIX_ADDR(289   , 30), width, 31, gpu_pxop | SRC_SWAP_Y_CL | DST_SWAP_X_Y_CL);
	gpu_copy	  (PIX_ADDR(2*31, 118), PIX_ADDR(289-31, 30), width, 31, gpu_pxop | SRC_SWAP_Y_CL | DST_SWAP_X_Y_CL);
	gpu_wait_done();
	VID_RAM0_ADDR	 = PIX_ADDR(289-2*31+1, 30);
	ogfx_color.color = VID_RAM0_DATA;
      }
      draw_block	  (PIX_ADDR(289-2*31, 30),	      width, width, ogfx_color.color, DST_SWAP_X_Y_CL, use_gpu);

      // Left bar
      if (use_gpu==0) {    // Software update
	VID_RAM0_CFG	 = VID_RAM_WIN_MODE | DST_SWAP_X;
	VID_RAM0_ADDR	 = PIX_ADDR(289-2*31, 31);
	ogfx_color	 = draw_gradient(ogfx_color,	      width, ogfx_color.line_nr_start	, 1);
	ogfx_color	 = draw_gradient(ogfx_color,	      width, 31				, 1);
	ogfx_color	 = draw_gradient(ogfx_color,	      width, 31				, 1);
	ogfx_color	 = draw_gradient(ogfx_color,	      width, 31-ogfx_color.line_nr_start, 0);
      } else {		   // Hardware update
	gpu_copy	  (PIX_ADDR(30+2*31+1, 118+1+0*31), PIX_ADDR(289-2*31, 30+1+0*31), width, 31, gpu_pxop | SRC_SWAP_NONE | DST_SWAP_X);
	gpu_copy	  (PIX_ADDR(30+2*31+1, 118+1+1*31), PIX_ADDR(289-2*31, 30+1+1*31), width, 31, gpu_pxop | SRC_SWAP_NONE | DST_SWAP_X);
	gpu_copy	  (PIX_ADDR(30+2*31+1, 118+1+2*31), PIX_ADDR(289-2*31, 30+1+2*31), width, 31, gpu_pxop | SRC_SWAP_NONE | DST_SWAP_X);
	gpu_wait_done();
	VID_RAM0_ADDR	 = PIX_ADDR(289-2*31, 30+3*31);
	ogfx_color.color = VID_RAM0_DATA;
      }
      draw_block	  (PIX_ADDR(289-2*31, 30+1+3*31),    width, width, ogfx_color.color, DST_SWAP_X, use_gpu);

      // Bottom bar
      if (use_gpu==0) {    // Software update
	VID_RAM0_CFG	 = VID_RAM_WIN_MODE | DST_SWAP_CL;
	VID_RAM0_ADDR	 = PIX_ADDR(290-2*31, 30+1+3*31);
	ogfx_color	 = draw_gradient(ogfx_color,	      width, ogfx_color.line_nr_start	, 1);
	ogfx_color	 = draw_gradient(ogfx_color,	      width, 31				, 1);
	ogfx_color	 = draw_gradient(ogfx_color,	      width, 31-ogfx_color.line_nr_start, 0);
      } else {		   // Hardware update
	gpu_copy	  (PIX_ADDR(30+2*31   , 118+3*31+1), PIX_ADDR(290-2*31, 30+1+3*31), width, 31, gpu_pxop | SRC_SWAP_X_CL | DST_SWAP_CL);
	gpu_copy	  (PIX_ADDR(30+2*31-31, 118+3*31+1), PIX_ADDR(290-1*31, 30+1+3*31), width, 31, gpu_pxop | SRC_SWAP_X_CL | DST_SWAP_CL);
	gpu_wait_done();
	VID_RAM0_ADDR	 = PIX_ADDR(290-1, 30+1+3*31);
	ogfx_color.color = VID_RAM0_DATA;
      }
      draw_block	  (PIX_ADDR(290, 30+3*31+1),	      width, width, ogfx_color.color, DST_SWAP_CL, use_gpu);

      // Right bar
      if (use_gpu==0) {    // Software update
	VID_RAM0_CFG	 = VID_RAM_WIN_MODE | DST_SWAP_Y;
	VID_RAM0_ADDR	 = PIX_ADDR(290, 30+3*31);
	ogfx_color	 = draw_gradient(ogfx_color,	      width, ogfx_color.line_nr_start	, 1);
	ogfx_color	 = draw_gradient(ogfx_color,	      width, 31				, 1);
	ogfx_color	 = draw_gradient(ogfx_color,	      width, 31				, 1);
	ogfx_color	 = draw_gradient(ogfx_color,	      width, 31-ogfx_color.line_nr_start, 0);
      } else {		   // Hardware update
	gpu_copy	  (PIX_ADDR(30, 118+3*31), PIX_ADDR(290, 30+3*31), width, 31, gpu_pxop | SRC_SWAP_X_Y | DST_SWAP_Y);
	gpu_copy	  (PIX_ADDR(30, 118+2*31), PIX_ADDR(290, 30+2*31), width, 31, gpu_pxop | SRC_SWAP_X_Y | DST_SWAP_Y);
	gpu_copy	  (PIX_ADDR(30, 118+1*31), PIX_ADDR(290, 30+1*31), width, 31, gpu_pxop | SRC_SWAP_X_Y | DST_SWAP_Y);
	gpu_wait_done();
	VID_RAM0_ADDR	 = PIX_ADDR(290, 30+1);
	ogfx_color.color = VID_RAM0_DATA;
      }
      draw_block	  (PIX_ADDR(290, 30), width, width, ogfx_color.color, DST_SWAP_Y, use_gpu);

      //-----------------------------------------
      // Draw 'GFX'
      //-----------------------------------------
      VID_RAM0_WIDTH   = 8;

      // Probe the colors for the 'G', 'F' and 'X'
      gpu_wait_done();
      VID_RAM0_ADDR    = PIX_ADDR(289-2*31   , 30-1);
      __nop();
      __nop();
      g_color	       = VID_RAM0_DATA;
      VID_RAM0_ADDR    = PIX_ADDR(289-2*31+20, 30-1);
      __nop();
      f_color	       = VID_RAM0_DATA;
      VID_RAM0_ADDR    = PIX_ADDR(289-2*31+40, 30-1);
      __nop();
      x_color	       = VID_RAM0_DATA;

      // 'G'
      draw_block   (PIX_ADDR(150    , 15    ), 8, 32, g_color, DST_SWAP_NONE, use_gpu);
      draw_block   (PIX_ADDR(150    , 15+5*8), 8,  8, g_color, DST_SWAP_NONE, use_gpu);
      draw_block   (PIX_ADDR(150+4*8, 15+  8), 8, 40, g_color, DST_SWAP_NONE, use_gpu);
      draw_block   (PIX_ADDR(150+  8, 15    ), 8, 24, g_color, DST_SWAP_CL  , use_gpu);
      draw_block   (PIX_ADDR(150+  8, 15+3*8), 8, 16, g_color, DST_SWAP_CL  , use_gpu);
      draw_block   (PIX_ADDR(150+  8, 15+6*8), 8, 24, g_color, DST_SWAP_CL  , use_gpu);

      // 'F'
      draw_block   (PIX_ADDR(100+4*8, 15    ), 8, 56, f_color, DST_SWAP_NONE, use_gpu);
      draw_block   (PIX_ADDR(100+  8, 15+3*8), 8, 24, f_color, DST_SWAP_CL  , use_gpu);
      draw_block   (PIX_ADDR(100    , 15+6*8), 8, 32, f_color, DST_SWAP_CL  , use_gpu);

      // 'X'
      draw_block   (PIX_ADDR(50	    , 15    ), 8, 16, x_color, DST_SWAP_NONE, use_gpu);
      draw_block   (PIX_ADDR(50+4*8 , 15    ), 8, 16, x_color, DST_SWAP_NONE, use_gpu);
      draw_block   (PIX_ADDR(50	    , 15+5*8), 8, 16, x_color, DST_SWAP_NONE, use_gpu);
      draw_block   (PIX_ADDR(50+4*8 , 15+5*8), 8, 16, x_color, DST_SWAP_NONE, use_gpu);
      draw_block   (PIX_ADDR(50+  8 , 15+2*8), 8,  8, x_color, DST_SWAP_NONE, use_gpu);
      draw_block   (PIX_ADDR(50+3*8 , 15+2*8), 8,  8, x_color, DST_SWAP_NONE, use_gpu);
      draw_block   (PIX_ADDR(50+2*8 , 15+3*8), 8,  8, x_color, DST_SWAP_NONE, use_gpu);
      draw_block   (PIX_ADDR(50+  8 , 15+4*8), 8,  8, x_color, DST_SWAP_NONE, use_gpu);
      draw_block   (PIX_ADDR(50+3*8 , 15+4*8), 8,  8, x_color, DST_SWAP_NONE, use_gpu);
    }
  }
}
