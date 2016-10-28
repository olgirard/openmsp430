#include "omsp_system.h"
#include "timerA.h"
#include "gfx_controller.h"
#include "demo.h"

//---------------------------------------------------//
// Watchdog interrupt                                //
// Change Video Mode every 327ms * 15 = 4.2seconds   //
//---------------------------------------------------//
volatile unsigned char wdt_irq_cnt;
volatile unsigned char move_to_next_mode;

wakeup interrupt (WDT_VECTOR) INT_watchdog(void) {

  if (wdt_irq_cnt<100) {
    wdt_irq_cnt++;
  } else {
    wdt_irq_cnt       = 0;
    move_to_next_mode = 1;
  }
}

//---------------------------------------------------//
// Graphic mode initialization                       //
//---------------------------------------------------//
void gfx_mode_init(uint16_t gfx_mode, uint16_t refresh_rate) {

  //unsigned int idx;

  // Initialize Graphic controller
  init_gfx_ctrl(gfx_mode, refresh_rate);

  // Initialize palette
  //LUT_RAM_ADDR    = 0x0000;
  //for( idx = 0; idx < 256; idx = idx + 1 ) {
  //  LUT_RAM_DATA  = palette_64k[idx];
  //}

  // LUT Configuration
  LUT_CFG      = HW_LUT_BG_BLACK     |
                 HW_LUT_FG_WHITE     |
                 HW_LUT_PALETTE_0_HI |
                 SW_LUT_BANK0_SELECT |
                 SW_LUT_DISABLE;

  // Initialize Frame pointers
  FRAME0_PTR   = PIX_ADDR(0, 0);
  FRAME1_PTR   = PIX_ADDR(0, 0);

  FRAME_SELECT = REFRESH_FRAME0_SELECT  |
                 VID_RAM0_FRAME0_SELECT |
                 VID_RAM1_FRAME0_SELECT;

  // Start Graphic controller
  start_gfx_ctrl();
}

//---------------------------------------------------//
// Main                                              //
//---------------------------------------------------//
int main(void) {

  // Init global variables
  wdt_irq_cnt       = 0;
  move_to_next_mode = 0;

  // Configure watchdog timer to generate an IRQ every 327ms
  WDTCTL = WDTPW | WDTSSEL | WDTCNTCL | WDTTMSEL | WDTIS0;  // Select ACLK | Clear timer | Enable interval timer mode | div32768
  IE1_set_wdtie();
  eint();

  while (1) {

    gfx_mode_init(GFX_16_BPP, LT24_REFR_62_FPS);
    demo_16bpp();
    move_to_next_mode = 0;

    gfx_mode_init(GFX_8_BPP,  LT24_REFR_1000_FPS);
    demo_8bpp();
    move_to_next_mode = 0;

    gfx_mode_init(GFX_4_BPP,  LT24_REFR_1000_FPS);
    demo_4bpp();
    move_to_next_mode = 0;

    gfx_mode_init(GFX_2_BPP,  LT24_REFR_1000_FPS);
    demo_2bpp();
    move_to_next_mode = 0;

    gfx_mode_init(GFX_1_BPP,  LT24_REFR_1000_FPS);
    demo_1bpp();
    move_to_next_mode = 0;
  };

  return 0;
}
