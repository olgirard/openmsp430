#ifndef SWUART_H
#define SWUART_H

void tty_putc(char);             //send one character over timer_a uart
int  ccr0();
//extern char rxdata;
#endif //SWUART_H
