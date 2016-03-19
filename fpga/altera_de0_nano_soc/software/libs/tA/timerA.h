#ifndef TIMERA_H
#define TIMERA_H

#include <in430.h>

//----------------------------------------------------------
// AVAILABLE FUNCTIONS
//----------------------------------------------------------

void ta_wait_no_lpm(unsigned int);
void ta_wait(unsigned int);

// Base clock period definitions (in ns)
//#define VERILOG_SIMULATION
#define DCO_CLK_PERIOD     20
#define LFXT_CLK_PERIOD 10240

// Time definitions (base clock of 10us period)
#define   WT_20US     (    20000/LFXT_CLK_PERIOD)+1
#define   WT_50US     (    50000/LFXT_CLK_PERIOD)+1
#ifdef VERILOG_SIMULATION
  #define WT_100US    WT_50US
  #define WT_200US    WT_50US
  #define WT_500US    WT_50US
  #define WT_1MS      WT_50US
  #define WT_2MS      WT_50US
  #define WT_5MS      WT_50US
  #define WT_10MS     WT_50US
  #define WT_20MS     WT_50US
  #define WT_50MS     WT_50US
  #define WT_100MS    WT_50US
  #define WT_200MS    WT_50US
  #define WT_500MS    WT_50US
#else
  #define WT_100US    (   100000/LFXT_CLK_PERIOD)+1
  #define WT_200US    (   200000/LFXT_CLK_PERIOD)+1
  #define WT_500US    (   500000/LFXT_CLK_PERIOD)+1
  #define WT_1MS      (  1000000/LFXT_CLK_PERIOD)+1
  #define WT_2MS      (  2000000/LFXT_CLK_PERIOD)+1
  #define WT_5MS      (  5000000/LFXT_CLK_PERIOD)+1
  #define WT_10MS     ( 10000000/LFXT_CLK_PERIOD)+1
  #define WT_20MS     ( 20000000/LFXT_CLK_PERIOD)+1
  #define WT_50MS     ( 50000000/LFXT_CLK_PERIOD)+1
  #define WT_100MS    (100000000/LFXT_CLK_PERIOD)+1
  #define WT_200MS    (200000000/LFXT_CLK_PERIOD)+1
  #define WT_500MS    (500000000/LFXT_CLK_PERIOD)+1
#endif


//----------------------------------------------------------
// TIMER A REGISTERS
//----------------------------------------------------------
#define  TACTL       (*(volatile unsigned int  *) 0x0160)
#define  TAR         (*(volatile unsigned int  *) 0x0170)
#define  TACCTL0     (*(volatile unsigned int  *) 0x0162)
#define  TACCR0      (*(volatile unsigned int  *) 0x0172)
#define  TACCTL1     (*(volatile unsigned int  *) 0x0164)
#define  TACCR1      (*(volatile unsigned int  *) 0x0174)
#define  TACCTL2     (*(volatile unsigned int  *) 0x0166)
#define  TACCR2      (*(volatile unsigned int  *) 0x0176)
#define  TAIV        (*(volatile unsigned int  *) 0x012E)

//--------------------------------------------------
// TIMER A REGISTER FIELD MAPPING
//--------------------------------------------------

// Alternate register names
#define CCTL0        TACCTL0
#define CCTL1        TACCTL1
#define CCR0         TACCR0
#define CCR1         TACCR1

// Bit-masks
#define TASSEL1      (0x0200)  /* Timer A clock source select 1 */
#define TASSEL0      (0x0100)  /* Timer A clock source select 0 */
#define ID1          (0x0080)  /* Timer A clock input divider 1 */
#define ID0          (0x0040)  /* Timer A clock input divider 0 */
#define MC1          (0x0020)  /* Timer A mode control 1 */
#define MC0          (0x0010)  /* Timer A mode control 0 */
#define TACLR        (0x0004)  /* Timer A counter clear */
#define TAIE         (0x0002)  /* Timer A counter interrupt enable */
#define TAIFG        (0x0001)  /* Timer A counter interrupt flag */

#define MC_0         (0x0000)  /* Timer A mode control: 0 - Stop */
#define MC_1         (0x0010)  /* Timer A mode control: 1 - Up to CCR0 */
#define MC_2         (0x0020)  /* Timer A mode control: 2 - Continous up */
#define MC_3         (0x0030)  /* Timer A mode control: 3 - Up/Down */
#define ID_0         (0x0000)  /* Timer A input divider: 0 - /1 */
#define ID_1         (0x0040)  /* Timer A input divider: 1 - /2 */
#define ID_2         (0x0080)  /* Timer A input divider: 2 - /4 */
#define ID_3         (0x00C0)  /* Timer A input divider: 3 - /8 */
#define TASSEL_0     (0x0000)  /* Timer A clock source select: 0 - TACLK */
#define TASSEL_1     (0x0100)  /* Timer A clock source select: 1 - ACLK  */
#define TASSEL_2     (0x0200)  /* Timer A clock source select: 2 - SMCLK */
#define TASSEL_3     (0x0300)  /* Timer A clock source select: 3 - INCLK */

#define CM1          (0x8000)  /* Capture mode 1 */
#define CM0          (0x4000)  /* Capture mode 0 */
#define CCIS1        (0x2000)  /* Capture input select 1 */
#define CCIS0        (0x1000)  /* Capture input select 0 */
#define SCS          (0x0800)  /* Capture sychronize */
#define SCCI         (0x0400)  /* Latched capture signal (read) */
#define CAP          (0x0100)  /* Capture mode: 1 /Compare mode : 0 */
#define OUTMOD2      (0x0080)  /* Output mode 2 */
#define OUTMOD1      (0x0040)  /* Output mode 1 */
#define OUTMOD0      (0x0020)  /* Output mode 0 */
#define CCIE         (0x0010)  /* Capture/compare interrupt enable */
#define CCI          (0x0008)  /* Capture input signal (read) */
#define OUT          (0x0004)  /* PWM Output signal if output mode 0 */
#define COV          (0x0002)  /* Capture/compare overflow flag */
#define CCIFG        (0x0001)  /* Capture/compare interrupt flag */


#endif
