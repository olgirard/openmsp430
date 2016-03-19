#include "omsp_system.h"
#include "timerA.h"

//---------------------------------------------------//
//    TA_WAIT_NO_LPM                                 //
// ( the function implements a wait by continously ) //
// ( polling the TAR register                      ) //
//                                                   //
//---------------------------------------------------//
void ta_wait_no_lpm(unsigned int time_cnt) {

  // Start and re-initialize TimerA
  TACTL = TASSEL0 | TACLR | MC_2;

  // Wait until time is over
  while(TAR < time_cnt);

}

//--------------------------------------------------//
//    WAIT FUNCTION                                 //
// ( the function brings the core to LPM0 state )   //
// ( the timerA IRQ will exit the LPM0 state    )   //
//                                                  //
//--------------------------------------------------//
void ta_wait(unsigned int time_cnt) {

  // Set time limit for IRQ generation
  TACCR0 = time_cnt;

  // Start and re-initialize TimerA
  TACTL  = TASSEL0 | TACLR | MC_1 | TAIE;

  // Go to Low-Power-Mode 0
  LPM0;

}

//--------------------------------------------------//
//    TIMER A INTERRUPT                             //
//--------------------------------------------------//
wakeup interrupt (TIMERA1_VECTOR) INT_timerA1(void) {

  // Clear the receive pending flag & stop timer A
  TACTL = TAIFG;

  // Exit the low power mode
  LPM0_EXIT;
}
