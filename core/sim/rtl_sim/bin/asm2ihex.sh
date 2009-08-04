#!/bin/sh
#------------------------------------------------------------------------------
# Copyright (C) 2001 Authors
#
# This source file may be used and distributed without restriction provided
# that this copyright statement is not removed from the file and that any
# derivative work contains the original copyright notice and the associated
# disclaimer.
#
# This source file is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.
#
# This source is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
# License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this source; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
#------------------------------------------------------------------------------
# 
# File Name: asm2ihex.sh
# 
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#
#------------------------------------------------------------------------------
# $Rev$
# $LastChangedBy$
# $LastChangedDate$
#------------------------------------------------------------------------------

###############################################################################
#                            Parameter Check                                  #
###############################################################################
EXPECTED_ARGS=5
if [ $# -ne $EXPECTED_ARGS ]; then
  echo "ERROR    : wrong number of arguments"
  echo "USAGE    : asm2ihex.sh <test name> <test assembler file> <definition file>   <rom size> <ram size>"
  echo "Example  : asm2ihex.sh c-jump_jge  ../src/c-jump_jge.s43 ../bin/template.def 2048       128"
  exit 1
fi


###############################################################################
#               Check if definition & assembler files exist                   #
###############################################################################

if [ ! -e $2 ]; then
    echo "Assembler file doesn't exist: $2"
    exit 1
fi
if [ ! -e $3 ]; then
    echo "Linker definition file template doesn't exist: $3"
    exit 1
fi


###############################################################################
#               Generate the linker definition file                           #
###############################################################################

RAM_SIZE=$5
ROM_SIZE=$4
ROM_BASE=$((0x10000-$ROM_SIZE))

cp  $3  ./rom.def
sed -i "s/ROM_BASE/$ROM_BASE/g" rom.def
sed -i "s/ROM_SIZE/$ROM_SIZE/g" rom.def
sed -i "s/RAM_SIZE/$RAM_SIZE/g" rom.def


###############################################################################
#                  Compile, link & generate IHEX file                         #
###############################################################################
msp430-as      -alsm         $2     -o $1.o     > $1.l43
msp430-objdump -xdsStr       $1.o              >> $1.l43
msp430-ld      -T ./rom.def  $1.o   -o $1.elf
msp430-objcopy -O ihex       $1.elf    $1.ihex
