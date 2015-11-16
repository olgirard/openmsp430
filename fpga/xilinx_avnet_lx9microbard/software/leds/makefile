# makfile configuration
NAME            = leds
OBJECTS         = main.o

# Compiler performance option (-Os / -O2 / -O3)
PORT_CFLAGS     = -O2

# Choose GCC toolchain prefix ('msp430' for MSPGCC / 'msp430-elf' for GCC RedHat/TI)
ifndef MSPGCC_PFX
MSPGCC_PFX      = msp430-elf
endif

# disable some warnings specific to the Dhrystone code
WARNINGS        =  -Wall

# Select flags depending on selected toolchain
ifeq ($(MSPGCC_PFX),msp430-elf)
INCDIR          = -I /cad/ti/gcc/include
CFLAGS		= -D PFX_MSP430_ELF $(INCDIR) $(PORT_CFLAGS) ${WARNINGS} -g -mcpu=msp430 -mhwmult=16bit
else
CFLAGS		= -D PFX_MSP430               $(PORT_CFLAGS) ${WARNINGS} -g -mcpu=430    -mmpy=16	-mivcnt=16
endif

# Toolchain executables
CC              = ${MSPGCC_PFX}-gcc
OBJCOPY		= ${MSPGCC_PFX}-objcopy
OBJDUMP         = ${MSPGCC_PFX}-objdump
OBJSIZE         = ${MSPGCC_PFX}-size

.PHONY: all FORCE clean download dist

#all should be the first target. it's built when make is runwithout args
all: ${NAME}.elf ${NAME}.a43 ${NAME}.lst ${NAME}.size

#confgigure the next line if you want to use the serial download
download: download-uart

#additional rules for files
${NAME}.elf: ${OBJECTS}
	${CC} ${CFLAGS} -T linker.${MSPGCC_PFX}.x -o $@ ${OBJECTS}

${NAME}.a43: ${NAME}.elf
	${OBJCOPY} -O ihex $^ $@

${NAME}.lst: ${NAME}.elf
	${OBJDUMP} -dSt $^ >$@

${NAME}.size: ${NAME}.elf
	${OBJSIZE}  $^ >$@

download-uart: all
	openmsp430-loader.tcl -device /dev/ttyUSB0 -baudrate 115200 ${NAME}.elf

clean:
	rm -f ${NAME} ${NAME}.a43 ${NAME}.lst ${NAME}.elf $(NAME).size *.o

#backup archive
dist:
	tar czf dist.tgz *.c *.h *.txt makefile

#dummy target as dependecy if something has to be build everytime
FORCE:

#project dependencies
main.o: main.c hardware.h
