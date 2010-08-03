#!/bin/bash
###############################################################################
#                                                                             #
#                       Xilinx RAM update script for LINUX                    #
#                                                                             #
###############################################################################

###############################################################################
#                            Parameter Check                                  #
###############################################################################
EXPECTED_ARGS=1
if [ $# -ne $EXPECTED_ARGS ]; then
    echo "ERROR    : wrong number of arguments"
    echo "USAGE    : load_rom <test name>"
    echo "Example  : load_rom leds"
    echo "Available tests:"
    ls ../../software/
  exit 1
fi

###############################################################################
#                     Check if the required files exist                       #
###############################################################################
softdir=../../software/$1;
elffile=../../software/$1/$1.elf;

if [ ! -e $softdir ]; then
    echo "Software directory doesn't exist: $softdir"
    exit 1
fi

###############################################################################
#                           Update FPGA Bitstream                             #
###############################################################################


rm -f ./WORK/$1.elf
rm -f ./WORK/$1.bit

cp -f $elffile ./WORK/

cd ./WORK
data2mem -bm ../memory.bmm -bd $1.elf -bt openMSP430_fpga.bit -o b $1.bit
cd ../
