#!/bin/bash
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
# File Name: rtlsim.sh
# 
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#             - Mihai M.,	   mmihai@delajii.net
#
#------------------------------------------------------------------------------
# $Rev$
# $LastChangedBy$
# $LastChangedDate$
#------------------------------------------------------------------------------

###############################################################################
#                            Parameter Check                                  #
###############################################################################
EXPECTED_ARGS=3
if [ $# -ne $EXPECTED_ARGS ]; then
  echo "ERROR    : wrong number of arguments"
  echo "USAGE    : rtlsim.sh <verilog stimulus file> <memory file> <submit file>"
  echo "Example  : rtlsim.sh ./stimulus.v            pmem.mem      ../src/submit.f"
  echo "MYVLOG env keeps simulator name iverilog/cver/verilog/ncverilog/vsim/vcs"
  exit 1
fi


###############################################################################
#                     Check if the required files exist                       #
###############################################################################

if [ ! -e $1 ]; then
    echo "Verilog stimulus file $1 doesn't exist"
    exit 1
fi
if [ ! -e $2 ]; then
    echo "Memory file $2 doesn't exist"
    exit 1
fi
if [ ! -e $3 ]; then
    echo "Verilog submit file $3 doesn't exist"
    exit 1
fi


###############################################################################
#                         Start verilog simulation                            #
###############################################################################

if [ "${MYVLOG:-iverilog}" = iverilog ]; then

    rm -rf simv
    
    NODUMP=${OMSP_NODUMP-0}
    if [ $NODUMP -eq 1 ]
      then
        iverilog -o simv -c $3 -D NODUMP
      else
        iverilog -o simv -c $3
    fi
    
    ./simv
else

    NODUMP=${OMSP_NODUMP-0}
    if [ $NODUMP -eq 1 ] ; then
       vargs="+define+NODUMP"
    else
       vargs=""
    fi

   case $MYVLOG in 
    cver* ) 
       vargs="$vargs +define+VXL" ;;
    verilog* )
       vargs="$vargs +define+VXL" ;;
    ncverilog* )
       rm -rf INCA_libs
       vargs="$vargs +access+r +define+TRN_FILE" ;;
    vcs* )
       rm -rf csrc simv*
       vargs="$vargs -R -debug_pp +vcs+lic+wait +v2k +define+VPD_FILE" ;;
    vsim )
       # Modelsim
       if [ -d work ]; then  vdel -all; fi
       vlib work
       exec vlog +acc=prn -f $3 $vargs -R -c -do "run -all"
   esac
   
   echo "Running: $MYVLOG -f $3 $vargs"
   exec $MYVLOG -f $3 $vargs
fi
