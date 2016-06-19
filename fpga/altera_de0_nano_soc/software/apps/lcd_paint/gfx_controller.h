#ifndef GFX_CONTROLLER_H
#define GFX_CONTROLLER_H

#include "timerA.h"
#include <in430.h>
#include <stdint.h>

//----------------------------------------------------------
// GLOBAL CONFIGURATION
//----------------------------------------------------------

#define SCREEN_WIDTH         320
#define SCREEN_HEIGHT        240

#define FRAME_MEMORY_KB_SIZE 75*2

//----------------------------------------------------------
// AVAILABLE FUNCTIONS
//----------------------------------------------------------

void init_lt24(void);


//----------------------------------------------------------
// GRAPHIC CONTROLLER REGISTERS
//----------------------------------------------------------
#define  GFX_CTRL          (*(volatile unsigned int  *) 0x0200)
#define  GFX_STATUS        (*(volatile unsigned int  *) 0x0208)
#define  GFX_IRQ           (*(volatile unsigned int  *) 0x020A)

#define  DISPLAY_WIDTH     (*(volatile unsigned int  *) 0x0210)
#define  DISPLAY_HEIGHT    (*(volatile unsigned int  *) 0x0212)
#define  DISPLAY_SIZE_HI   (*(volatile unsigned int  *) 0x0214)
#define  DISPLAY_SIZE_LO   (*(volatile unsigned int  *) 0x0216)
#define  DISPLAY_CFG       (*(volatile unsigned int  *) 0x0218)

#define  LT24_CFG          (*(volatile unsigned int  *) 0x0220)
#define  LT24_REFRESH      (*(volatile unsigned int  *) 0x0222)
#define  LT24_REFRESH_SYNC (*(volatile unsigned int  *) 0x0224)
#define  LT24_CMD          (*(volatile unsigned int  *) 0x0226)
#define  LT24_CMD_PARAM    (*(volatile unsigned int  *) 0x0228)
#define  LT24_CMD_DFILL    (*(volatile unsigned int  *) 0x022A)
#define  LT24_STATUS       (*(volatile unsigned int  *) 0x022C)

#define  LUT_RAM_ADDR      (*(volatile unsigned int  *) 0x0230)
#define  LUT_RAM_DATA      (*(volatile unsigned int  *) 0x0232)

#define  FRAME_SELECT      (*(volatile unsigned int  *) 0x023E)
#define  FRAME0_PTR_HI     (*(volatile unsigned int  *) 0x0240)
#define  FRAME0_PTR_LO     (*(volatile unsigned int  *) 0x0242)
#define  FRAME1_PTR_HI     (*(volatile unsigned int  *) 0x0244)
#define  FRAME1_PTR_LO     (*(volatile unsigned int  *) 0x0246)
#define  FRAME2_PTR_HI     (*(volatile unsigned int  *) 0x0248)
#define  FRAME2_PTR_LO     (*(volatile unsigned int  *) 0x024A)
#define  FRAME3_PTR_HI     (*(volatile unsigned int  *) 0x024C)
#define  FRAME3_PTR_LO     (*(volatile unsigned int  *) 0x024E)

#define  VID_RAM0_CFG      (*(volatile unsigned int  *) 0x0250)
#define  VID_RAM0_WIDTH    (*(volatile unsigned int  *) 0x0252)
#define  VID_RAM0_ADDR_HI  (*(volatile unsigned int  *) 0x0254)
#define  VID_RAM0_ADDR_LO  (*(volatile unsigned int  *) 0x0256)
#define  VID_RAM0_DATA     (*(volatile unsigned int  *) 0x0258)

#define  VID_RAM1_CFG      (*(volatile unsigned int  *) 0x0260)
#define  VID_RAM1_WIDTH    (*(volatile unsigned int  *) 0x0262)
#define  VID_RAM1_ADDR_HI  (*(volatile unsigned int  *) 0x0264)
#define  VID_RAM1_ADDR_LO  (*(volatile unsigned int  *) 0x0266)
#define  VID_RAM1_DATA     (*(volatile unsigned int  *) 0x0268)

#define  GPU_CMD           (*(volatile unsigned int  *) 0x0270)
#define  GPU_STAT          (*(volatile unsigned int  *) 0x0272)

//----------------------------------------------------------
// GRAPHIC CONTROLLER REGISTER FIELD MAPPING
//----------------------------------------------------------

// GFX_CTRL Register
#define  GFX_REFR_DONE_IRQ_EN      0x0001
#define  GFX_REFR_DONE_IRQ_DIS     0x0000
#define  GFX_REFR_START_IRQ_EN     0x0002
#define  GFX_REFR_START_IRQ_DIS    0x0000
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

// GFX_IRQ Register
#define  GFX_IRQ_REFRESH_DONE      0x0001
#define  GFX_IRQ_REFRESH_START     0x0002
#define  GFX_IRQ_GPU_FIFO_DONE     0x0010
#define  GFX_IRQ_GPU_FIFO_OFVL     0x0020
#define  GFX_IRQ_GPU_CMD_DONE      0x0040
#define  GFX_IRQ_GPU_CMD_ERROR     0x0080

// DISPLAY_CFG Register
#define  DISPLAY_X_SWAP            0x0001
#define  DISPLAY_NO_X_SWAP         0x0000
#define  DISPLAY_Y_SWAP            0x0002
#define  DISPLAY_NO_Y_SWAP         0x0000
#define  DISPLAY_CL_SWAP           0x0004
#define  DISPLAY_NO_CL_SWAP        0x0000

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
#define  LT24_REFR_48MS            (((48000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_40MS            (((40000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_32MS            (((32000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_24MS            (((24000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_16MS            (((16000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_8MS             ((( 8000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_4MS             ((( 4000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_2MS             ((( 2000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
#define  LT24_REFR_1MS             ((( 1000000/DCO_CLK_PERIOD)>>8) & 0xFFF0)
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

// FRAME_SELECT Register
#define  REFRESH_FRAME0_SELECT     0x0000
#define  REFRESH_FRAME1_SELECT     0x0001
#define  REFRESH_FRAME2_SELECT     0x0002
#define  REFRESH_FRAME3_SELECT     0x0003

#define  REFRESH_SW_LUT_DISABLE    0x0000
#define  REFRESH_SW_LUT_ENABLE     0x0004
#define  REFRESH_SW_LUT0_SELECT    0x0000
#define  REFRESH_SW_LUT1_SELECT    0x0008

#define  VID_RAM0_FRAME0_SELECT    0x0000
#define  VID_RAM0_FRAME1_SELECT    0x0010
#define  VID_RAM0_FRAME2_SELECT    0x0020
#define  VID_RAM0_FRAME3_SELECT    0x0030

#define  VID_RAM1_FRAME0_SELECT    0x0000
#define  VID_RAM1_FRAME1_SELECT    0x0040
#define  VID_RAM1_FRAME2_SELECT    0x0080
#define  VID_RAM1_FRAME3_SELECT    0x00C0

// VID_RAMx_CFG Register
#define  VID_RAM_NO_RMW_MODE       0x0000
#define  VID_RAM_RMW_MODE          0x0001
#define  VID_RAM_NO_WIN_MODE       0x0000
#define  VID_RAM_WIN_MODE          0x0002

#define  VID_RAM_NO_WIN_X_SWAP     0x0000
#define  VID_RAM_WIN_X_SWAP        0x0010
#define  VID_RAM_NO_WIN_Y_SWAP     0x0000
#define  VID_RAM_WIN_Y_SWAP        0x0020
#define  VID_RAM_NO_WIN_CL_SWAP    0x0000
#define  VID_RAM_WIN_CL_SWAP       0x0040

// GPU_CMD Register


// GPU_STAT Register
#define  GPU_STAT_FIFO_CNT         0x000F
#define  GPU_STAT_FIFO_EMPTY       0x0010
#define  GPU_STAT_FIFO_FULL        0x0020


#endif
