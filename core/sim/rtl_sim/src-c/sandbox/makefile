# makfile configuration
NAME            = sandbox
OBJECTS         = main.o copydata.o

CFLAGS          =  -O2 -Wall -g -mcpu=msp430 -mhwmult=none

#switch the compiler (for the internal make rules)
CC              = msp430-elf-gcc


.PHONY: all FORCE clean download download-jtag download-bsl dist

#all should be the first target. it's built when make is runwithout args
all: ${NAME}.elf ${NAME}.a43 ${NAME}.lst

#confgigure the next line if you want to use the serial download
download: download-uart
#download: download-jtag
#download: download-bsl

#additional rules for files
${NAME}.elf: ${OBJECTS}
	${CC} -mcpu=msp430 -T linker.x -o $@ ${OBJECTS}

${NAME}.a43: ${NAME}.elf
	msp430-elf-objcopy -O ihex $^ $@

${NAME}.lst: ${NAME}.elf
	msp430-elf-objdump -dSt $^ >$@

download-uart: all
	openmsp430-loader.tcl -device /dev/ttyUSB0 -baudrate 115200 ${NAME}.elf

clean:
	rm -f ${NAME} ${NAME}.a43 ${NAME}.lst ${NAME}.elf *.o

#backup archive
dist:
	tar czf dist.tgz *.c *.h *.txt makefile

#dummy target as dependecy if something has to be build everytime
FORCE:

#project dependencies
main.o: main.c
copydata.o: copydata.c
