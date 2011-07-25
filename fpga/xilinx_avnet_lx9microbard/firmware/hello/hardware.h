#ifndef MAIN_H
#define MAIN_H

#define __msp430_have_port3
#define __MSP430_HAS_PORT3__
#define __msp430_have_port4
#define __MSP430_HAS_PORT4__

#include <io.h>
#include <signal.h>
#include <iomacros.h>

#ifndef P3DIR
#define P3IN_                 0x0018    /* Port 3 Input */
const_sfrb(P3IN, P3IN_);
#define P3OUT_                0x0019    /* Port 3 Output */
sfrb(P3OUT, P3OUT_);
#define P3DIR_                0x001A    /* Port 3 Direction */
sfrb(P3DIR, P3DIR_);
#define P3SEL_                0x001B    /* Port 3 Selection */
sfrb(P3SEL, P3SEL_);
#endif

#ifndef P4DIR
#define P4IN_                 0x001C    /* Port 4 Input */
const_sfrb(P4IN, P4IN_);
#define P4OUT_                0x001D    /* Port 4 Output */
sfrb(P4OUT, P4OUT_);
#define P4DIR_                0x001E    /* Port 4 Direction */
sfrb(P4DIR, P4DIR_);
#define P4SEL_                0x001F    /* Port 4 Selection */
sfrb(P4SEL, P4SEL_);
#endif

#endif // MAIN_H
