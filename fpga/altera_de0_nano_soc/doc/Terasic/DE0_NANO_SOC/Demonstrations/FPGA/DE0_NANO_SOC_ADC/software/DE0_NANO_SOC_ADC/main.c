#include <stdio.h>
#include <io.h>
#include <unistd.h>

#include "system.h"

void main(void){
	int ch = 0;
	const int nReadNum = 10; // max 1024
	int i, Value, nIndex=0;

	printf("ADC Demo\r\n");
	while(1){
		ch = IORD(SW_BASE, 0x00) & 0x07;

		printf("======================= %d, ch=%d\r\n", nIndex++, ch);
		// set measure number for ADC convert
		IOWR(ADC_LTC2308_BASE, 0x01, nReadNum);


		// start measure
		IOWR(ADC_LTC2308_BASE, 0x00, (ch << 1) | 0x00);
		IOWR(ADC_LTC2308_BASE, 0x00, (ch << 1) | 0x01);
		IOWR(ADC_LTC2308_BASE, 0x00, (ch << 1) | 0x00);
		usleep(1);

		// wait measure done
		while ((IORD(ADC_LTC2308_BASE,0x00) & 0x01) == 0x00);

		// read adc value
		for(i=0;i<nReadNum;i++){
			Value = IORD(ADC_LTC2308_BASE, 0x01);
			printf("CH%d=%.3fV (0x%04x)\r\n", ch, (float)Value/1000.0, Value);
		}

		usleep(200*1000);
	} // while
}
