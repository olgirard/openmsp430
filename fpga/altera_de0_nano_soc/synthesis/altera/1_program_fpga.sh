#!/bin/bash

###############################################################################
#                            Parameter Check                                  #
###############################################################################
EXPECTED_ARGS=1
if [ $# -ne $EXPECTED_ARGS ]; then
    echo ""
    echo "ERROR          : wrong number of arguments"
    echo "USAGE          : ./1_program_fpga.sh <bitstream name>"
    echo "EXAMPLE        : ./1_program_fpga.sh    leds"
    echo ""
    echo "AVAILABLE BITSTREAMS:"
    for fullfile in ./bitstreams/*.sof ; do
        filename=$(basename "$fullfile")
        filename="${filename%.*}"
        echo "                  - $filename"
    done
    echo ""
  exit 1
fi

###############################################################################
#                     Check if the required files exist                       #
###############################################################################
soffile=./bitstreams/$1.sof;

if [ ! -e $soffile ]; then
    echo ""
    echo "ERROR: Specified SOF file doesn't exist: $soffile"
    echo ""
    exit 1
fi

###############################################################################
#                             Program FPGA                                    #
###############################################################################
echo " -----------------------------------------------"
echo "|  PROGRAM FPGA: $soffile"
echo " -----------------------------------------------"
echo ""

quartus_pgm --mode=jtag -o p\;$soffile\@2
