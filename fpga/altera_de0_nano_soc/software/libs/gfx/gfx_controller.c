#include "gfx_controller.h"
#include "timerA.h"

//----------------------------------------------------------
// Initialize Graphic controller
//----------------------------------------------------------
void init_gfx_ctrl (uint16_t gfx_mode, uint16_t refresh_rate) {

  // Local variable definition
  uint16_t kb_idx, b_idx;

  // Initialize frame buffer
#ifndef VERILOG_SIMULATION
  VID_RAM0_ADDR  = PIX_ADDR(0, 0);
  for( kb_idx = 0; kb_idx < FRAME_MEMORY_KB_SIZE/2; kb_idx = kb_idx + 1 ) {
    for( b_idx = 0; b_idx < 1024; b_idx = b_idx + 1 ) {
      VID_RAM0_DATA = 0x0000;
    }
  }
#endif
  VID_RAM0_ADDR     = PIX_ADDR(0, 0);

  // Configure Video mode
  GFX_CTRL          = gfx_mode | GFX_REFR_START_IRQ_DIS | GFX_REFR_DONE_IRQ_DIS | GFX_GPU_EN;

  // Configure Refresh Rate
  LT24_REFRESH_SYNC = LT24_REFR_SYNC | 0x0000;
  LT24_REFRESH      = refresh_rate;

  // Global configuration registers
  DISPLAY_WIDTH     = SCREEN_WIDTH;
  DISPLAY_HEIGHT    = SCREEN_HEIGHT;
  DISPLAY_SIZE      = (uint32_t)SCREEN_WIDTH * (uint32_t)SCREEN_HEIGHT;

#ifdef LT24_ROTATE
  DISPLAY_CFG       = DISPLAY_NO_X_SWAP | DISPLAY_NO_Y_SWAP | DISPLAY_NO_CL_SWAP;
#else
  DISPLAY_CFG       = DISPLAY_NO_X_SWAP | DISPLAY_NO_Y_SWAP | DISPLAY_CL_SWAP;
#endif

  // Initialize LT24 module
  init_lt24 (LT24_CLK_DIV2);

}

//----------------------------------------------------------
// Start Graphic controller
//----------------------------------------------------------
void start_gfx_ctrl (void) {

  start_lt24();

  LT24_REFRESH  = LT24_REFRESH | LT24_REFR_START;

}

//----------------------------------------------------------
// Initialize LT24 controller
//----------------------------------------------------------
void init_lt24 (uint16_t lt24_clk_div) {

  // Enable LCD, generate a reset and set LCD clock
  LT24_CFG       = 0x0000;
  ta_wait_no_lpm(WT_1MS);
  LT24_CFG       = LT24_ON | lt24_clk_div | LT24_RESET;
  ta_wait_no_lpm(WT_1MS);
  LT24_CFG       = LT24_ON | lt24_clk_div;
  ta_wait_no_lpm(WT_500MS+WT_20MS);

  // Set color mode to 16bits/pixel
  LT24_CMD       = 0x003A | LT24_CMD_HAS_PARAM;
  LT24_CMD_PARAM = 0x0055;
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  LT24_CMD       = 0x0000;

  // Define image rotation on the display
  // (MADCTL command: see pages 127 and 209 of the ILI9341 spec)
#ifdef LT24_ROTATE
  LT24_CMD       = 0x0036 | LT24_CMD_HAS_PARAM;
  LT24_CMD_PARAM = 0x0028;
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  LT24_CMD       = 0x0000;
#else
  LT24_CMD       = 0x0036 | LT24_CMD_HAS_PARAM;
  LT24_CMD_PARAM = 0x0008;
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  LT24_CMD       = 0x0000;
#endif

  // Send CASET
  LT24_CMD       = 0x002A | LT24_CMD_HAS_PARAM;
  LT24_CMD_PARAM = ( 0              & 0xFF00)>>8;   // CASET_SC[15:8]
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  LT24_CMD_PARAM = ( 0              & 0x00FF);      // CASET_SC[7:0]
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
#ifdef LT24_ROTATE
  LT24_CMD_PARAM = ( SCREEN_WIDTH   & 0xFF00)>>8;   // CASET_EC[15:8]
#else
  LT24_CMD_PARAM = ( SCREEN_HEIGHT  & 0xFF00)>>8;   // CASET_EC[15:8]
#endif
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
#ifdef LT24_ROTATE
  LT24_CMD_PARAM = ( SCREEN_WIDTH  & 0x00FF);      // CASET_EC[7:0]
#else
  LT24_CMD_PARAM = ( SCREEN_HEIGHT   & 0x00FF);      // CASET_EC[7:0]
#endif
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  LT24_CMD       = 0x0000;

  // Send PASET
  LT24_CMD       = 0x002B | LT24_CMD_HAS_PARAM;
  LT24_CMD_PARAM = ( 0              & 0xFF00)>>8;  // PASET_SC[15:8]
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  LT24_CMD_PARAM = ( 0              & 0x00FF);     // PASET_SC[7:0]
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
#ifdef LT24_ROTATE
  LT24_CMD_PARAM = ( SCREEN_HEIGHT  & 0xFF00)>>8;  // PASET_EC[15:8]
#else
  LT24_CMD_PARAM = ( SCREEN_WIDTH  & 0xFF00)>>8;  // PASET_EC[15:8]
#endif
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
#ifdef LT24_ROTATE
  LT24_CMD_PARAM = ( SCREEN_HEIGHT  & 0x00FF);     // PASET_EC[7:0]
#else
  LT24_CMD_PARAM = ( SCREEN_WIDTH   & 0x00FF);     // PASET_EC[7:0]
#endif
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  LT24_CMD       = 0x0000;

  // Initialize the LT24 display memory
#ifndef VERILOG_SIMULATION
  LT24_CMD_DFILL = 0x0000;
  while((LT24_STATUS & LT24_STATUS_DFILL_BUSY)!=0);
#endif

  // Display on
  LT24_CMD       = 0x0035 | LT24_CMD_NO_PARAM;
  LT24_CMD_PARAM = 0x0000;

  return;
}

//----------------------------------------------------------
// Start LT24 controller
//----------------------------------------------------------
void start_lt24(void) {

  // Display on
  LT24_CMD       = 0x0029 | LT24_CMD_NO_PARAM;
  LT24_CMD_PARAM = 0x0000;
  ta_wait_no_lpm(WT_10MS);

  // Go out of SLEEP
  LT24_CMD       = 0x0011 | LT24_CMD_NO_PARAM;
  LT24_CMD_PARAM = 0x0000;
  ta_wait_no_lpm(WT_100MS);

  return;
}

//----------------------------------------------------------
// Wait for the refresh to be done
//----------------------------------------------------------
void sync_screen_refresh_done(void) {

  // Clear IRQ flag
  GFX_IRQ |= GFX_IRQ_REFRESH_DONE;

  // Wait for flag to be set
  while((GFX_IRQ & GFX_IRQ_REFRESH_DONE)==0);

  return;
}

//----------------------------------------------------------
// Wait for the refresh to start
//----------------------------------------------------------
void sync_screen_refresh_start(void) {

  // Clear IRQ flag
  GFX_IRQ |= GFX_IRQ_REFRESH_START;

  // Wait for flag to be set
  while((GFX_IRQ & GFX_IRQ_REFRESH_START)==0);

  return;
}

//==========================================================
// GPU FUNCTIONS
//==========================================================

void gpu_fill (uint32_t addr, uint16_t width, uint16_t length, uint16_t color, uint16_t configuration) {

  while((GPU_STAT & GPU_STAT_FIFO_CNT_EMPTY)<7);
  GPU_CMD   = GPU_REC_WIDTH  | width;
  GPU_CMD   = GPU_REC_HEIGHT | length;
  GPU_CMD   = GPU_DST_PX_ADDR; GPU_CMD32 = addr;
  GPU_CMD   = GPU_EXEC_FILL  | configuration ;
  GPU_CMD   = color;
}


void gpu_copy (uint32_t src_addr, uint32_t dst_addr, uint16_t width, uint16_t length, uint16_t configuration) {

  while((GPU_STAT & GPU_STAT_FIFO_CNT_EMPTY)<9);
  GPU_CMD  = GPU_REC_WIDTH  | width;
  GPU_CMD  = GPU_REC_HEIGHT | length;
  GPU_CMD  = GPU_DST_PX_ADDR; GPU_CMD32 = dst_addr;
  GPU_CMD  = GPU_SRC_PX_ADDR; GPU_CMD32 = src_addr;
  GPU_CMD  = GPU_EXEC_COPY  | configuration ;
}


void gpu_copy_transparent (uint32_t src_addr, uint32_t dst_addr, uint16_t width, uint16_t length, uint16_t trans_color, uint16_t configuration) {

  while((GPU_STAT & GPU_STAT_FIFO_CNT_EMPTY)<9);
  GPU_CMD  = GPU_REC_WIDTH  | width;
  GPU_CMD  = GPU_REC_HEIGHT | length;
  GPU_CMD  = GPU_SET_TRANS;   GPU_CMD   = trans_color;
  GPU_CMD  = GPU_DST_PX_ADDR; GPU_CMD32 = dst_addr;
  GPU_CMD  = GPU_SRC_PX_ADDR; GPU_CMD32 = src_addr;
  GPU_CMD  = GPU_EXEC_COPY_TRANS  | configuration ;
}

inline void gpu_wait_done (void) {
    while((GPU_STAT & GPU_STAT_BUSY)!=0);
}
