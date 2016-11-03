#ifndef GFX_CONTROLLER_H
#define GFX_CONTROLLER_H

#include "timerA.h"
#include <in430.h>
#include <stdint.h>

//----------------------------------------------------------
// GLOBAL CONFIGURATION
//----------------------------------------------------------

#ifdef VERILOG_SIMULATION
  #define SCREEN_WIDTH         5
  #define SCREEN_HEIGHT        3
#else
  #define SCREEN_WIDTH         320
  #define SCREEN_HEIGHT        240
#endif

#define   FRAME_MEMORY_KB_SIZE 75*2

//#define LT24_ROTATE

//----------------------------------------------------------
// UTILITY MACROS
//----------------------------------------------------------

// Convert pixel coordinates into memory address
#define PIX_ADDR(X, Y) ((((uint32_t)(Y)) * ((uint32_t)(SCREEN_WIDTH))) + ((uint32_t)(X)))


//----------------------------------------------------------
// FUNCTIONS
//----------------------------------------------------------

// Initialization functions
void init_gfx_ctrl (uint16_t gfx_mode, uint16_t refresh_rate);
void start_gfx_ctrl(void);

// LT24 specific functions
void init_lt24(uint16_t lt24_clk_div);
void start_lt24(void);

// GPU Functions
void gpu_fill (uint32_t addr, uint16_t width, uint16_t length, uint16_t color, uint16_t configuration);
void gpu_copy (uint32_t src_addr, uint32_t dst_addr, uint16_t width, uint16_t length, uint16_t configuration);
void gpu_copy_transparent (uint32_t src_addr, uint32_t dst_addr, uint16_t width, uint16_t length, uint16_t trans_color, uint16_t configuration);
inline void gpu_wait_done (void);

// Other Functions
void sync_screen_refresh_done(void);
void sync_screen_refresh_start(void);


//----------------------------------------------------------
// GRAPHIC CONTROLLER REGISTERS
//----------------------------------------------------------
#define  GFX_CTRL          (*(volatile uint16_t  *) 0x0200)
#define  GFX_STATUS        (*(volatile uint16_t  *) 0x0208)
#define  GFX_IRQ           (*(volatile uint16_t  *) 0x020A)

#define  DISPLAY_WIDTH     (*(volatile uint16_t  *) 0x0210)
#define  DISPLAY_HEIGHT    (*(volatile uint16_t  *) 0x0212)
#define  DISPLAY_SIZE      (*(volatile uint32_t  *) 0x0214)
#define  DISPLAY_CFG       (*(volatile uint16_t  *) 0x0218)
#define  DISPLAY_REFR_CNT  (*(volatile uint16_t  *) 0x021A)

#define  LT24_CFG          (*(volatile uint16_t  *) 0x0220)
#define  LT24_REFRESH      (*(volatile uint16_t  *) 0x0222)
#define  LT24_REFRESH_SYNC (*(volatile uint16_t  *) 0x0224)
#define  LT24_CMD          (*(volatile uint16_t  *) 0x0226)
#define  LT24_CMD_PARAM    (*(volatile uint16_t  *) 0x0228)
#define  LT24_CMD_DFILL    (*(volatile uint16_t  *) 0x022A)
#define  LT24_STATUS       (*(volatile uint16_t  *) 0x022C)

#define  LUT_CFG           (*(volatile uint16_t  *) 0x0230)
#define  LUT_RAM_ADDR      (*(volatile uint16_t  *) 0x0232)
#define  LUT_RAM_DATA      (*(volatile uint16_t  *) 0x0234)

#define  FRAME_SELECT      (*(volatile uint16_t  *) 0x023E)
#define  FRAME0_PTR        (*(volatile uint32_t  *) 0x0240)
#define  FRAME1_PTR        (*(volatile uint32_t  *) 0x0244)
#define  FRAME2_PTR        (*(volatile uint32_t  *) 0x0248)
#define  FRAME3_PTR        (*(volatile uint32_t  *) 0x024C)

#define  VID_RAM0_CFG      (*(volatile uint16_t  *) 0x0250)
#define  VID_RAM0_WIDTH    (*(volatile uint16_t  *) 0x0252)
#define  VID_RAM0_ADDR     (*(volatile uint32_t  *) 0x0254)
#define  VID_RAM0_DATA     (*(volatile uint16_t  *) 0x0258)

#define  VID_RAM1_CFG      (*(volatile uint16_t  *) 0x0260)
#define  VID_RAM1_WIDTH    (*(volatile uint16_t  *) 0x0262)
#define  VID_RAM1_ADDR     (*(volatile uint32_t  *) 0x0264)
#define  VID_RAM1_DATA     (*(volatile uint16_t  *) 0x0268)

#define  GPU_CMD           (*(volatile uint16_t  *) 0x0270)
#define  GPU_CMD32         (*(volatile uint32_t  *) 0x0270)
#define  GPU_STAT          (*(volatile uint16_t  *) 0x0274)


//----------------------------------------------------------
// GRAPHIC CONTROLLER REGISTER FIELD MAPPING
//----------------------------------------------------------

// GFX_CTRL Register
#define  GFX_REFR_DONE_IRQ_EN      0x0001
#define  GFX_REFR_DONE_IRQ_DIS     0x0000
#define  GFX_REFR_START_IRQ_EN     0x0002
#define  GFX_REFR_START_IRQ_DIS    0x0000
#define  GFX_REFR_CNT_DONE_IRQ_EN  0x0004
#define  GFX_REFR_CNT_DONE_IRQ_DIS 0x0000
#define  GFX_GPU_FIFO_DONE_IRQ_EN  0x0010
#define  GFX_GPU_FIFO_DONE_IRQ_DIS 0x0000
#define  GFX_GPU_FIFO_OVFL_IRQ_EN  0x0020
#define  GFX_GPU_FIFO_OVFL_IRQ_DIS 0x0000
#define  GFX_GPU_CMD_DONE_IRQ_EN   0x0040
#define  GFX_GPU_CMD_DONE_IRQ_DIS  0x0000
#define  GFX_GPU_CMD_ERROR_IRQ_EN  0x0080
#define  GFX_GPU_CMD_ERROR_IRQ_DIS 0x0000
#define  GFX_16_BPP                0x0400
#define  GFX_8_BPP                 0x0300
#define  GFX_4_BPP                 0x0200
#define  GFX_2_BPP                 0x0100
#define  GFX_1_BPP                 0x0000
#define  GFX_GPU_EN                0x1000
#define  GFX_GPU_DIS               0x0000

// GFX_STATUS Register
#define  STATUS_REFRESH_BUSY       0x0001
#define  STATUS_GPU_FIFO           0x0010
#define  STATUS_GPU_BUSY           0x0040

// GFX_IRQ Register
#define  GFX_IRQ_REFRESH_DONE      0x0001
#define  GFX_IRQ_REFRESH_START     0x0002
#define  GFX_IRQ_REFRESH_CNT_DONE  0x0004
#define  GFX_IRQ_GPU_FIFO_DONE     0x0010
#define  GFX_IRQ_GPU_FIFO_OVFL     0x0020
#define  GFX_IRQ_GPU_CMD_DONE      0x0040
#define  GFX_IRQ_GPU_CMD_ERROR     0x0080

// DISPLAY_CFG Register
#define  DISPLAY_CL_SWAP           0x0001
#define  DISPLAY_Y_SWAP            0x0002
#define  DISPLAY_X_SWAP            0x0004
#define  DISPLAY_NO_CL_SWAP        0x0000
#define  DISPLAY_NO_Y_SWAP         0x0000
#define  DISPLAY_NO_X_SWAP         0x0000

// LT24_CFG Register
#define  LT24_ON                   0x0001
#define  LT24_RESET                0x0002
#define  LT24_CLK_DIV1             0x0000
#define  LT24_CLK_DIV2             0x0010
#define  LT24_CLK_DIV3             0x0020
#define  LT24_CLK_DIV4             0x0030
#define  LT24_CLK_DIV5             0x0040
#define  LT24_CLK_DIV6             0x0050
#define  LT24_CLK_DIV7             0x0060
#define  LT24_CLK_DIV8             0x0070
#define  LT24_CLK_MASK             0x0070

// LT24_REFRESH Register
#define  LT24_REFR_START           0x0001
#define  LT24_REFR_MANUAL          0x0000
#define  LT24_REFR_21_FPS          (((48000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_24_FPS          (((40000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_31_FPS          (((32000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_42_FPS          (((24000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_62_FPS          (((16000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_125_FPS         ((( 8000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_250_FPS         ((( 4000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_500_FPS         ((( 2000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_1000_FPS        ((( 1000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_MASK            0xFFF0

// LT24_REFRESH_SYNC Register
#define  LT24_REFR_SYNC            0x8000
#define  LT24_REFR_NO_SYNC         0x0000

// LT24_CMD Register
#define  LT24_CMD_MSK              0x00FF
#define  LT24_CMD_HAS_PARAM        0x0100
#define  LT24_CMD_NO_PARAM         0x0000

// LT24_STATUS Register
#define  LT24_STATUS_FSM_BUSY      0x0001
#define  LT24_STATUS_WAIT_PARAM    0x0002
#define  LT24_STATUS_REFRESH_BUSY  0x0004
#define  LT24_STATUS_REFRESH_WAIT  0x0008
#define  LT24_STATUS_DFILL_BUSY    0x0010

// LUT_CFG Register
#define  SW_LUT_DISABLE            0x0000
#define  SW_LUT_ENABLE             0x0001
#define  SW_LUT_RAM_RMW_MODE       0x0002
#define  SW_LUT_RAM_NO_RMW_MODE    0x0000
#define  SW_LUT_BANK0_SELECT       0x0000
#define  SW_LUT_BANK1_SELECT       0x0004
#define  HW_LUT_PALETTE_0_HI       0x0000
#define  HW_LUT_PALETTE_0_LO       0x0010
#define  HW_LUT_PALETTE_1_HI       0x0020
#define  HW_LUT_PALETTE_1_LO       0x0030
#define  HW_LUT_PALETTE_2_HI       0x0040
#define  HW_LUT_PALETTE_2_LO       0x0050
#define  HW_LUT_PALETTE_MSK        0x0070
#define  HW_LUT_BGCOLOR_MSK        0x0F00
#define  HW_LUT_FGCOLOR_MSK        0xF000

#define  HW_LUT_BG_BLACK           0x0000
#define  HW_LUT_BG_BLUE            0x0100
#define  HW_LUT_BG_GREEN           0x0200
#define  HW_LUT_BG_CYAN            0x0300
#define  HW_LUT_BG_RED             0x0400
#define  HW_LUT_BG_MAGENTA         0x0500
#define  HW_LUT_BG_BROWN           0x0600
#define  HW_LUT_BG_LIGHT_GRAY      0x0700
#define  HW_LUT_BG_GRAY            0x0800
#define  HW_LUT_BG_LIGHT_BLUE      0x0900
#define  HW_LUT_BG_LIGHT_GREEN     0x0A00
#define  HW_LUT_BG_LIGHT_CYAN      0x0B00
#define  HW_LUT_BG_LIGHT_RED       0x0C00
#define  HW_LUT_BG_LIGHT_MAGENTA   0x0D00
#define  HW_LUT_BG_YELLOW          0x0E00
#define  HW_LUT_BG_WHITE           0x0F00

#define  HW_LUT_FG_BLACK           0x0000
#define  HW_LUT_FG_BLUE            0x1000
#define  HW_LUT_FG_GREEN           0x2000
#define  HW_LUT_FG_CYAN            0x3000
#define  HW_LUT_FG_RED             0x4000
#define  HW_LUT_FG_MAGENTA         0x5000
#define  HW_LUT_FG_BROWN           0x6000
#define  HW_LUT_FG_LIGHT_GRAY      0x7000
#define  HW_LUT_FG_GRAY            0x8000
#define  HW_LUT_FG_LIGHT_BLUE      0x9000
#define  HW_LUT_FG_LIGHT_GREEN     0xA000
#define  HW_LUT_FG_LIGHT_CYAN      0xB000
#define  HW_LUT_FG_LIGHT_RED       0xC000
#define  HW_LUT_FG_LIGHT_MAGENTA   0xD000
#define  HW_LUT_FG_YELLOW          0xE000
#define  HW_LUT_FG_WHITE           0xF000

// FRAME_SELECT Register
#define  REFRESH_FRAME0_SELECT     0x0000
#define  REFRESH_FRAME1_SELECT     0x0001
#define  REFRESH_FRAME2_SELECT     0x0002
#define  REFRESH_FRAME3_SELECT     0x0003
#define  REFRESH_FRAME_MASK        0x0003

#define  VID_RAM0_FRAME0_SELECT    0x0000
#define  VID_RAM0_FRAME1_SELECT    0x0100
#define  VID_RAM0_FRAME2_SELECT    0x0200
#define  VID_RAM0_FRAME3_SELECT    0x0300
#define  VID_RAM0_FRAME_MASK       0x0300

#define  VID_RAM1_FRAME0_SELECT    0x0000
#define  VID_RAM1_FRAME1_SELECT    0x1000
#define  VID_RAM1_FRAME2_SELECT    0x2000
#define  VID_RAM1_FRAME3_SELECT    0x3000
#define  VID_RAM1_FRAME_MASK       0x3000

// VID_RAMx_CFG Register
#define  VID_RAM_RMW_MODE          0x0010
#define  VID_RAM_MSK_MODE          0x0020
#define  VID_RAM_WIN_MODE          0x0040
#define  VID_RAM_NO_RMW_MODE       0x0000
#define  VID_RAM_NO_MSK_MODE       0x0000
#define  VID_RAM_NO_WIN_MODE       0x0000
#define  VID_RAM_WIN_CL_SWAP       0x0001
#define  VID_RAM_WIN_Y_SWAP        0x0002
#define  VID_RAM_WIN_X_SWAP        0x0004
#define  VID_RAM_WIN_NO_CL_SWAP    0x0000
#define  VID_RAM_WIN_NO_Y_SWAP     0x0000
#define  VID_RAM_WIN_NO_X_SWAP     0x0000

// GPU_STAT Register
#define  GPU_STAT_FIFO_CNT_EMPTY   0x000F
#define  GPU_STAT_FIFO_CNT         0x00F0
#define  GPU_STAT_FIFO_EMPTY       0x0100
#define  GPU_STAT_FIFO_FULL        0x0200
#define  GPU_STAT_DMA_BUSY         0x1000
#define  GPU_STAT_BUSY             0x8000

//----------------------------------------------------------
// GPU COMMANDS
//----------------------------------------------------------

// GPU COMMAND
#define  GPU_EXEC_FILL             0x0000
#define  GPU_EXEC_COPY             0x4000
#define  GPU_EXEC_COPY_TRANS       0x8000
#define  GPU_REC_WIDTH             0xC000
#define  GPU_REC_HEIGHT            0xD000
#define  GPU_SRC_PX_ADDR           0xF800
#define  GPU_DST_PX_ADDR           0xF801
#define  GPU_OF0_ADDR              0xF810
#define  GPU_OF1_ADDR              0xF811
#define  GPU_OF2_ADDR              0xF812
#define  GPU_OF3_ADDR              0xF813
#define  GPU_SET_FILL              0xF420
#define  GPU_SET_TRANS             0xF421

// ADDRESS SOURCE SELECTION
#define  GPU_SRC_OF0               0x0000
#define  GPU_SRC_OF1               0x1000
#define  GPU_SRC_OF2               0x2000
#define  GPU_SRC_OF3               0x3000
#define  GPU_DST_OF0               0x0000
#define  GPU_DST_OF1               0x0008
#define  GPU_DST_OF2               0x0010
#define  GPU_DST_OF3               0x0018

// DMA CONFIGURATION
#define  GPU_DST_CL_SWP            0x0001
#define  GPU_DST_Y_SWP             0x0002
#define  GPU_DST_X_SWP             0x0004
#define  GPU_SRC_CL_SWP            0x0200
#define  GPU_SRC_Y_SWP             0x0400
#define  GPU_SRC_X_SWP             0x0800
#define  GPU_DST_NO_CL_SWP         0x0000
#define  GPU_DST_NO_Y_SWP          0x0000
#define  GPU_DST_NO_X_SWP          0x0000
#define  GPU_SRC_NO_CL_SWP         0x0000
#define  GPU_SRC_NO_Y_SWP          0x0000
#define  GPU_SRC_NO_X_SWP          0x0000

#define  DST_SWAP_NONE             0x0000
#define  DST_SWAP_CL               0x0001
#define  DST_SWAP_Y                0x0002
#define  DST_SWAP_Y_CL             0x0003
#define  DST_SWAP_X                0x0004
#define  DST_SWAP_X_CL             0x0005
#define  DST_SWAP_X_Y              0x0006
#define  DST_SWAP_X_Y_CL           0x0007
#define  DST_SWAP_MSK              0xFFF8

#define  SRC_SWAP_NONE             0x0000
#define  SRC_SWAP_CL               0x0200
#define  SRC_SWAP_Y                0x0400
#define  SRC_SWAP_Y_CL             0x0600
#define  SRC_SWAP_X                0x0800
#define  SRC_SWAP_X_CL             0x0A00
#define  SRC_SWAP_X_Y              0x0C00
#define  SRC_SWAP_X_Y_CL           0x0E00
#define  SRC_SWAP_MSK              0xF1FF

// PIXEL OPERATION
#define  GPU_PXOP_0                0x0000  // S
#define  GPU_PXOP_1                0x0020  // not S
#define  GPU_PXOP_2                0x0040  // not D
#define  GPU_PXOP_3                0x0060  // S and D
#define  GPU_PXOP_4                0x0080  // S or  D
#define  GPU_PXOP_5                0x00A0  // S xor D
#define  GPU_PXOP_6                0x00C0  // not (S and D)
#define  GPU_PXOP_7                0x00E0  // not (S or  D)
#define  GPU_PXOP_8                0x0100  // not (S xor D)
#define  GPU_PXOP_9                0x0120  // (not S) and      D
#define  GPU_PXOP_A                0x0140  //      S  and (not D)
#define  GPU_PXOP_B                0x0160  // (not S) or       D
#define  GPU_PXOP_C                0x0180  //      S  or  (not D)
#define  GPU_PXOP_D                0x01A0  // Fill 0            if S not transparent (only COPY_TRANSPARENT command)
#define  GPU_PXOP_E                0x01C0  // Fill 1            if S not transparent (only COPY_TRANSPARENT command)
#define  GPU_PXOP_F                0x01E0  // Fill 'fill_color' if S not transparent (only COPY_TRANSPARENT command)


#endif
