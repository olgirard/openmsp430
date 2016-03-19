/*===========================================================================*/
/* Copyright (C) 2001 Authors                                                */
/*                                                                           */
/* This source file may be used and distributed without restriction provided */
/* that this copyright statement is not removed from the file and that any   */
/* derivative work contains the original copyright notice and the associated */
/* disclaimer.                                                               */
/*                                                                           */
/* This source file is free software; you can redistribute it and/or modify  */
/* it under the terms of the GNU Lesser General Public License as published  */
/* by the Free Software Foundation; either version 2.1 of the License, or    */
/* (at your option) any later version.                                       */
/*                                                                           */
/* This source is distributed in the hope that it will be useful, but WITHOUT*/
/* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or     */
/* FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public       */
/* License for more details.                                                 */
/*                                                                           */
/* You should have received a copy of the GNU Lesser General Public License  */
/* along with this source; if not, write to the Free Software Foundation,    */
/* Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA        */
/*                                                                           */
/*===========================================================================*/
/*                          OMSP_SYSTEM HEADER FILE                          */
/*---------------------------------------------------------------------------*/
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 19 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2009-08-04 23:47:15 +0200 (Tue, 04 Aug 2009) $          */
/*===========================================================================*/

#include <in430.h>

//=============================================================================
// STATUS REGISTER BITS
//=============================================================================

// Flags
#define C             (0x0001)
#define Z             (0x0002)
#define N             (0x0004)
#define V             (0x0100)
#define GIE           (0x0008)
#define CPUOFF        (0x0010)
#define OSCOFF        (0x0020)
#define SCG0          (0x0040)
#define SCG1          (0x0080)

// Low Power Modes coded with Bits 4-7 in SR
#define LPM0_bits     (CPUOFF)
#define LPM1_bits     (SCG0+CPUOFF)
#define LPM2_bits     (SCG1+CPUOFF)
#define LPM3_bits     (SCG1+SCG0+CPUOFF)
#define LPM4_bits     (SCG1+SCG0+OSCOFF+CPUOFF)

#define LPM0          _BIS_SR(LPM0_bits)       // Enter Low Power Mode 0
#define LPM0_EXIT     _BIC_SR_IRQ(LPM0_bits)   // Exit  Low Power Mode 0
#define LPM1          _BIS_SR(LPM1_bits)       // Enter Low Power Mode 1
#define LPM1_EXIT     _BIC_SR_IRQ(LPM1_bits)   // Exit  Low Power Mode 1
#define LPM2          _BIS_SR(LPM2_bits)       // Enter Low Power Mode 2
#define LPM2_EXIT     _BIC_SR_IRQ(LPM2_bits)   // Exit  Low Power Mode 2
#define LPM3          _BIS_SR(LPM3_bits)       // Enter Low Power Mode 3
#define LPM3_EXIT     _BIC_SR_IRQ(LPM3_bits)   // Exit  Low Power Mode 3
#define LPM4          _BIS_SR(LPM4_bits)       // Enter Low Power Mode 4
#define LPM4_EXIT     _BIC_SR_IRQ(LPM4_bits)   // Exit  Low Power Mode 4


//=============================================================================
// PERIPHERALS REGISTER DEFINITIONS
//=============================================================================

//----------------------------------------------------------
// SPECIAL FUNCTION REGISTERS
//----------------------------------------------------------
#define  IE1_set_wdtie()   __asm__ __volatile__ ("bis.b #0x01, &0x0000")
//#define  IE1         (*(volatile unsigned char *) 0x0000)
#define  IFG1        (*(volatile unsigned char *) 0x0002)

#define  CPU_ID_LO   (*(volatile unsigned int  *) 0x0004)
#define  CPU_ID_HI   (*(volatile unsigned int  *) 0x0006)
#define  CPU_NR      (*(volatile unsigned int  *) 0x0008)


//----------------------------------------------------------
// KEY / SW / LEDs
//----------------------------------------------------------
#define  LED_CTRL        (*(volatile unsigned char *) 0x0090)
#define  KEY_SW_VAL      (*(volatile unsigned char *) 0x0091)
#define  KEY_SW_IRQ_EN   (*(volatile unsigned char *) 0x0092)
#define  KEY_SW_IRQ_EDGE (*(volatile unsigned char *) 0x0093)
#define  KEY_SW_IRQ_VAL  (*(volatile unsigned char *) 0x0094)


//----------------------------------------------------------
// BASIC CLOCK MODULE
//----------------------------------------------------------
#define  DCOCTL      (*(volatile unsigned char *) 0x0056)
#define  BCSCTL1     (*(volatile unsigned char *) 0x0057)
#define  BCSCTL2     (*(volatile unsigned char *) 0x0058)


//----------------------------------------------------------
// WATCHDOG TIMER
//----------------------------------------------------------

// Addresses
#define  WDTCTL      (*(volatile unsigned int  *) 0x0120)

// Bit masks
#define  WDTIS0      (0x0001)
#define  WDTIS1      (0x0002)
#define  WDTSSEL     (0x0004)
#define  WDTCNTCL    (0x0008)
#define  WDTTMSEL    (0x0010)
#define  WDTNMI      (0x0020)
#define  WDTNMIES    (0x0040)
#define  WDTHOLD     (0x0080)
#define  WDTPW       (0x5A00)


//----------------------------------------------------------
// HARDWARE MULTIPLIER
//----------------------------------------------------------
#define  OP1_MPY     (*(volatile unsigned int  *) 0x0130)
#define  OP1_MPYS    (*(volatile unsigned int  *) 0x0132)
#define  OP1_MAC     (*(volatile unsigned int  *) 0x0134)
#define  OP1_MACS    (*(volatile unsigned int  *) 0x0136)
#define  OP2         (*(volatile unsigned int  *) 0x0138)

#define  RESLO       (*(volatile unsigned int  *) 0x013A)
#define  RESHI       (*(volatile unsigned int  *) 0x013C)
#define  SUMEXT      (*(volatile unsigned int  *) 0x013E)


//=============================================================================
// INTERRUPT VECTORS
//=============================================================================
#define interrupt(x) void __attribute__((interrupt (x)))
#define wakeup  __attribute__((wakeup))
#define eint()  __eint()
#define dint()  __dint()

// Vector definition for RedHat/TI toolchain
#ifdef PFX_MSP430_ELF
   #define RESET_VECTOR        ("reset")   // Vector 15  (0xFFFE) - Reset              -  [Highest Priority]
   #define NMI_VECTOR          (15)        // Vector 14  (0xFFFC) - Non-maskable       -
   #define UNUSED_13_VECTOR    (14)        // Vector 13  (0xFFFA) -                    -
   #define UNUSED_12_VECTOR    (13)        // Vector 12  (0xFFF8) -                    -
   #define UNUSED_11_VECTOR    (12)        // Vector 11  (0xFFF6) -                    -
   #define WDT_VECTOR          (11)        // Vector 10  (0xFFF4) - Watchdog Timer     -
   #define TIMERA0_VECTOR      (10)        // Vector  9  (0xFFF2) - Timer A CC0        -
   #define TIMERA1_VECTOR      (9)         // Vector  8  (0xFFF0) - Timer A CC1-2, TA  -
   #define UNUSED_07_VECTOR    (8)         // Vector  7  (0xFFEE) -                    -
   #define UNUSED_06_VECTOR    (7)         // Vector  6  (0xFFEC) -                    -
   #define UNUSED_05_VECTOR    (6)         // Vector  5  (0xFFEA) -                    -
   #define UNUSED_04_VECTOR    (5)         // Vector  4  (0xFFE8) -                    -
   #define UNUSED_03_VECTOR    (4)         // Vector  3  (0xFFE6) -                    -
   #define PORT1_VECTOR        (3)         // Vector  2  (0xFFE4) - Port 1             -
   #define UNUSED_01_VECTOR    (2)         // Vector  1  (0xFFE2) -                    -
   #define UNUSED_00_VECTOR    (1)         // Vector  0  (0xFFE0) -                    -  [Lowest Priority]

// Vector definition for MSPGCC toolchain
#else
   #define RESET_VECTOR        (0x001E)    // Vector 15  (0xFFFE) - Reset              -  [Highest Priority]
   #define NMI_VECTOR          (0x001C)    // Vector 14  (0xFFFC) - Non-maskable       -
   #define UNUSED_13_VECTOR    (0x001A)    // Vector 13  (0xFFFA) -                    -
   #define UNUSED_12_VECTOR    (0x0018)    // Vector 12  (0xFFF8) -                    -
   #define UNUSED_11_VECTOR    (0x0016)    // Vector 11  (0xFFF6) -                    -
   #define WDT_VECTOR          (0x0014)    // Vector 10  (0xFFF4) - Watchdog Timer     -
   #define TIMERA0_VECTOR      (0x0012)    // Vector  9  (0xFFF2) - Timer A CC0        -
   #define TIMERA1_VECTOR      (0x0010)    // Vector  8  (0xFFF0) - Timer A CC1-2, TA  -
   #define UNUSED_07_VECTOR    (0x000E)    // Vector  7  (0xFFEE) -                    -
   #define UNUSED_06_VECTOR    (0x000C)    // Vector  6  (0xFFEC) -                    -
   #define UNUSED_05_VECTOR    (0x000A)    // Vector  5  (0xFFEA) -                    -
   #define UNUSED_04_VECTOR    (0x0008)    // Vector  4  (0xFFE8) -                    -
   #define UNUSED_03_VECTOR    (0x0006)    // Vector  3  (0xFFE6) -                    -
   #define PORT1_VECTOR        (0x0004)    // Vector  2  (0xFFE4) - Port 1             -
   #define UNUSED_01_VECTOR    (0x0002)    // Vector  1  (0xFFE2) -                    -
   #define UNUSED_00_VECTOR    (0x0000)    // Vector  0  (0xFFE0) -                    -  [Lowest Priority]
#endif
