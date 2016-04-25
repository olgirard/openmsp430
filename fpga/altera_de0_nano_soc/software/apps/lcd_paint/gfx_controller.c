#include "gfx_controller.h"
#include "timerA.h"

/**
Initialize LT24 controller
*/
void init_lt24(void) {

  // Enable LCD, generate a reset and set LCD clock
  LT24_CFG       = 0x0000;
  wait_time(WT_1MS);
  LT24_CFG       = LT24_ON | LT24_CLK_DIV1 | LT24_RESET;
  wait_time(WT_1MS);
  LT24_CFG       = LT24_ON | LT24_CLK_DIV1;
  wait_time(WT_500MS+WT_20MS);

  // Set color mode to 16bits/pixel
  LT24_CMD       = 0x003A | LT24_CMD_HAS_PARAM;
  LT24_CMD_PARAM = 0x0055;
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  LT24_CMD       = 0x0000;

  // Color set: define the LUT for 16-bit to 18-bit color depth conversion
  //unsigned char idx;
  //LT24_CMD         = 0x002D | LT24_CMD_HAS_PARAM;
  //for( idx = 0; idx < 128; idx = idx + 1 ) {
  //  LT24_CMD_PARAM = 0x0000;
  //  // Wait until earlier data is sent
  //  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  //}
  //LT24_CMD         = 0x0000;

  // Initialize memory
#ifdef VERILOG_SIMULATION
  #define LT24_DISPLAY_X        0       // X Coordinate
  #define LT24_DISPLAY_Y        0       // Y Coordinate
  #define LT24_DISPLAY_WIDTH    13 -1   // Display width
  #define LT24_DISPLAY_HEIGHT   10 -1   // Display height
  #define LT24_DISPLAY_SIZE_HI  0       // 76800>>16
  #define LT24_DISPLAY_SIZE_LO  130     // 76800-2^16-1
#else
  #define LT24_DISPLAY_X        0       // X Coordinate
  #define LT24_DISPLAY_Y        0       // Y Coordinate
  #define LT24_DISPLAY_WIDTH    320 -1  // Display width
  #define LT24_DISPLAY_HEIGHT   240 -1  // Display height
  #define LT24_DISPLAY_SIZE_HI  0x0001  // 76800>>16
  #define LT24_DISPLAY_SIZE_LO  0x2C00  // 76800-2^16-1
#endif

  // Global configuration registers
  DISPLAY_WIDTH   = LT24_DISPLAY_WIDTH+1;
  DISPLAY_HEIGHT  = LT24_DISPLAY_HEIGHT+1;
  DISPLAY_SIZE_HI  = LT24_DISPLAY_SIZE_HI;
  DISPLAY_SIZE_LO  = LT24_DISPLAY_SIZE_LO;

  DISPLAY_CFG = DISPLAY_NO_X_SWAP | DISPLAY_NO_Y_SWAP | DISPLAY_NO_CL_SWAP;

  // Send CASET
  LT24_CMD       = 0x002A | LT24_CMD_HAS_PARAM;
  LT24_CMD_PARAM = ( LT24_DISPLAY_X                     & 0xFF00)>>8;   // CASET_SC[15:8]
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  LT24_CMD_PARAM = ( LT24_DISPLAY_X                     & 0x00FF);      // CASET_SC[7:0]
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  LT24_CMD_PARAM = ((LT24_DISPLAY_X+LT24_DISPLAY_WIDTH) & 0xFF00)>>8;   // CASET_EC[15:8]
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  LT24_CMD_PARAM = ((LT24_DISPLAY_X+LT24_DISPLAY_WIDTH) & 0x00FF);      // CASET_EC[7:0]
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  LT24_CMD       = 0x0000;

  // Send PASET
  LT24_CMD       = 0x002B | LT24_CMD_HAS_PARAM;
  LT24_CMD_PARAM = ( LT24_DISPLAY_Y                      & 0xFF00)>>8;  // PASET_SC[15:8]
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  LT24_CMD_PARAM = ( LT24_DISPLAY_Y                      & 0x00FF);     // PASET_SC[7:0]
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  LT24_CMD_PARAM = ((LT24_DISPLAY_Y+LT24_DISPLAY_HEIGHT) & 0xFF00)>>8;  // PASET_EC[15:8]
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  LT24_CMD_PARAM = ((LT24_DISPLAY_Y+LT24_DISPLAY_HEIGHT) & 0x00FF);     // PASET_EC[7:0]
  while((LT24_STATUS & LT24_STATUS_WAIT_PARAM)==0);
  LT24_CMD       = 0x0000;

  // Initialize the LT24 display memory
//  LT24_CMD_DFILL = 0x1234;
//  while((LT24_STATUS & LT24_STATUS_DFILL_BUSY)!=0);

  // Display on
  LT24_CMD       = 0x0029 | LT24_CMD_NO_PARAM;
  LT24_CMD_PARAM = 0x0000;
  wait_time(WT_10MS);

  // Go out of SLEEP
  LT24_CMD       = 0x0011 | LT24_CMD_NO_PARAM;
  LT24_CMD_PARAM = 0x0000;
  wait_time(WT_100MS);

  return;
}
