#ifndef DEMO_H
#define DEMO_H
#include "gfx_controller.h"

extern volatile unsigned char move_to_next_mode;


void demo_16bpp (void);
void demo_8bpp  (void);
void demo_4bpp  (void);
void demo_2bpp  (void);
void demo_1bpp  (void);

void draw_block(uint32_t addr, uint16_t width, uint16_t length, uint16_t color, uint16_t swap_configuration, uint16_t use_gpu);

#endif
