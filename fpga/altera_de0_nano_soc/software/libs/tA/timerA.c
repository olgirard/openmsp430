#include "timerA.h"

/**
Wait function
*/
void wait_time(unsigned int time_cnt) {

  // Start and re-initialize TimerA
  TACTL = TASSEL0 | TACLR | MC_2;

  // Wait until time is over
  while(TAR < time_cnt);

}
