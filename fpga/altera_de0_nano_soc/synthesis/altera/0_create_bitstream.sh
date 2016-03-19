#!/bin/bash

# Cleanup
rm -rf ./WORK
mkdir WORK

###############################################################################
#                            Parameter Check                                  #
###############################################################################
EXPECTED_ARGS=1
if [ $# -ne $EXPECTED_ARGS ]; then
    echo ""
    echo "ERROR          : wrong number of arguments"
    echo "USAGE          : ./0_create_bitstream.sh <test name>"
    echo "EXAMPLE	 : ./0_create_bitstream.sh    leds"
    echo ""
    echo "AVAILABLE TESTS:"
    for fullfile in ../../software/apps/* ; do
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
softdir=../../software/apps/$1;
elffile=../../software/apps/$1/$1.elf;

if [ ! -e $softdir ]; then
    echo "Software directory doesn't exist: $softdir"
    exit 1
fi

###############################################################################
#                           Compile program                                   #
###############################################################################
echo " -----------------------------------------------"
echo "|  COMPILE PROGRAM: $1"
echo " -----------------------------------------------"
echo ""

cd $softdir
make clean
make
cd ../../../synthesis/altera

###############################################################################
#                           Generate MIF file                                 #
###############################################################################
echo ""
echo " -----------------------------------------------"
echo "|  GENERATE MIF FILE: $1"
echo " -----------------------------------------------"
echo ""

cd ./WORK

# Generate memory MIF file
if command -v msp430-elf-gcc >/dev/null; then
    msp430-elf-objcopy -O ihex ../$elffile ./$1.ihex
else
    msp430-objcopy     -O ihex ../$elffile ./$1.ihex
fi
../scripts/ihex2mif.tcl -ihex $1.ihex -out pmem.mif -mem_size 32768

echo "New MIF file generated:"
echo "                          ./WORK/pmem.mif"
echo ""

###############################################################################
#                           Generate bitstream                                #
###############################################################################
echo ""
echo " -----------------------------------------------"
echo "|  GENERATE NEW BITSTREAM (SOF FILE)"
echo " -----------------------------------------------"
echo ""

# FPGA flow (i.e. generate SOF file)
quartus_sh  -t ../scripts/synthesis.tcl | tee ../log/quartus_synthesis.log

cd ..
cp -f ./WORK/output_files/openMSP430_fpga.sof ./bitstreams/$1.sof

echo ""
echo "New SOF file generated:"
echo "                        ./bitstreams/$1.sof"
echo ""
