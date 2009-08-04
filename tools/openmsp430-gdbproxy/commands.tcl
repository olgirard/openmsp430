#!/usr/bin/wish
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
# File Name: commands.tcl
# 
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#
#------------------------------------------------------------------------------
# $Rev$
# $LastChangedBy$
# $LastChangedDate$
#------------------------------------------------------------------------------

global mem_breakpoint

###############################################################################
#                                                                             #
#                              RSP COMMAND PARSER                             #
#                                                                             #
###############################################################################

proc rspParse {sock rsp_cmd} {

    set rsp_answer ""
    set cmd_tail [string range $rsp_cmd 1 [string length $rsp_cmd]]

    switch -exact -- [string index $rsp_cmd 0] {
	"!"     {set rsp_answer "OK"}
	"?"     {set rsp_answer [rsp_stop_reply $sock "?"]}
	"A"     {}
	"b"     {}
	"c"     {set rsp_answer [rsp_c $sock $cmd_tail]}
	"C"     {set rsp_answer [rsp_c $sock $cmd_tail]}
	"D"     {}
	"F"     {}
	"g"     {set rsp_answer [rsp_g]}
	"G"     {set rsp_answer [rsp_G $cmd_tail]}
	"H"     {set rsp_answer ""}
	"i"     {}
	"I"     {}
	"k"     {set rsp_answer [rsp_k $cmd_tail]}
	"m"     {set rsp_answer [rsp_m $cmd_tail]}
	"M"     {set rsp_answer [rsp_M $cmd_tail]}
	"p"     {}
	"P"     {}
	"q"     {set rsp_answer [rsp_q $sock $cmd_tail]}
	"Q"     {}
	"R"     {}
	"s"     {set rsp_answer [rsp_s $sock $cmd_tail]}
	"S"     {set rsp_answer [rsp_s $sock $cmd_tail]}
	"t"     {}
	"T"     {}
	"v"     {}
	"X"     {}
	"z"     {set rsp_answer [rsp_z $sock $cmd_tail]}
	"Z"     {set rsp_answer [rsp_Z $sock $cmd_tail]}
	default {}
    }


    return $rsp_answer
}


###############################################################################
#                                                                             #
#                                   RSP COMMANDS                              #
#                                                                             #
###############################################################################

#-----------------------------------------------------------------------------#
# Read CPU registers                                                          #
#-----------------------------------------------------------------------------#
proc rsp_g {} {
    
    # Read register value
    set reg_val [ReadRegAll]

    # Format answer
    set rsp_answer ""
    for {set i 0} {$i < [llength $reg_val]} {incr i} {

	regexp {0x(..)(..)} [lindex $reg_val $i] match msb lsb
	append rsp_answer "$lsb$msb"
    }

    return $rsp_answer
}

#-----------------------------------------------------------------------------#
# Write CPU registers                                                         #
#-----------------------------------------------------------------------------#
proc rsp_G {cmd} {
    
    # Format register value
    set num_reg [expr [string length $cmd]/4]

    set reg_val ""
    for {set i 0} {$i < $num_reg} {incr i} {

	set lsb "[string index $cmd [expr $i*4+0]][string index $cmd [expr $i*4+1]]"
	set msb "[string index $cmd [expr $i*4+2]][string index $cmd [expr $i*4+3]]"
	lappend reg_val "0x$msb$lsb"
    }

    # Write registers
    WriteRegAll $reg_val

    return "OK"
}

#-----------------------------------------------------------------------------#
# Kill request.                                                               #
#-----------------------------------------------------------------------------#
proc rsp_k {cmd} {
    
    # Reset & Stop CPU
    ExecutePOR_Halt
 
    return "-1"
}

#-----------------------------------------------------------------------------#
# Write length bytes of memory.                                               #
#-----------------------------------------------------------------------------#
proc rsp_M {cmd} {
    
    global mem_breakpoint
    
    # Parse command
    regexp {(.*),(.*):(.*)} $cmd match addr length data
    set addr   [format %04x "0x$addr"]
    set length [format %d   "0x$length"]
    
    # Format data
    set mem_val ""
    for {set i 0} {$i<$length} {incr i} {
	lappend mem_val "0x[string range $data [expr $i*2] [expr $i*2+1]]"
    }

    # Write memory
    WriteMemQuick8  "0x$addr" $mem_val

    # Eventually re-set the software breakpoints in case they have been overwritten
    set addr_start [format %d "0x$addr"]
    foreach {brk_addr brk_val} [array get mem_breakpoint] {
	set brk_addr_dec    [format %d "0x$brk_addr"]
	set brk_addr_offset [expr $brk_addr_dec-$addr_start]
	if {(0<=$brk_addr_offset) && ($brk_addr_offset<=$length)} {
	    set mem_breakpoint($brk_addr) [lindex $mem_val $brk_addr_offset]
	    WriteMem 0 "0x$brk_addr" 0x4343
	}
    }

    return "OK"
}


#-----------------------------------------------------------------------------#
# Read length bytes from memory.                                              #
#-----------------------------------------------------------------------------#
proc rsp_m {cmd} {
    
    global mem_breakpoint

    # Parse command
    regexp {(.*),(.*)} $cmd match addr length
    set addr   [format %04x "0x$addr"]
    set length [format %d   "0x$length"]

    # Read memory
    set data [ReadMemQuick8  "0x$addr" $length]

    # Eventually replace read data by the original software breakpoint value
    set addr_start [format %d "0x$addr"]
    foreach {brk_addr brk_val} [array get mem_breakpoint] {
	set brk_addr_dec    [format %d "0x$brk_addr"]
	set brk_addr_offset [expr $brk_addr_dec-$addr_start]
	if {(0<=$brk_addr_offset) && ($brk_addr_offset<=$length)} {
	    set data [lreplace $data $brk_addr_offset $brk_addr_offset "0x$mem_breakpoint($brk_addr)"]
	}
    }

    # Format data
    regsub -all {0x} $data {} data
    regsub -all { }  $data {} data

    return $data
}


#-----------------------------------------------------------------------------#
# Insert breakpoint.                                                          #
#-----------------------------------------------------------------------------#
proc rsp_Z {sock cmd} {

    global mem_breakpoint

    # Parse command
    regexp {(.),(.*),(.*)} $cmd match type addr length
    set addr   [format %04x "0x$addr"]

    switch -exact -- $type {
	"0"     {# Memory breakpoint
 	         set mem_breakpoint($addr) [ReadMem 0 "0x$addr"]
	         WriteMem 0 "0x$addr" 0x4343
	         return "OK"
                }

	"1"     {# Hardware breakpoint
	         if {[SetHWBreak 1 [format "0x%04x" 0x$addr] 1 0]} {
		     return "OK"
		 }
	         return ""
                }

	"2"     {# Write watchpoint
	         if {[SetHWBreak 0 [format "0x%04x" 0x$addr] 0 1]} {
		     return "OK"
		 }
	         return ""
                }

	"3"     {# Read watchpoint
	         if {[SetHWBreak 0 [format "0x%04x" 0x$addr] 1 0]} {
		     return "OK"
		 }
	         return ""
                }

	"4"     {# Access watchpoint
	         if {[SetHWBreak 0 [format "0x%04x" 0x$addr] 1 1]} {
		     return "OK"
		 }
	         return ""
                }

	default {return ""}
    }
}

#-----------------------------------------------------------------------------#
# Remove breakpoint.                                                          #
#-----------------------------------------------------------------------------#
proc rsp_z {sock cmd} {

    global mem_breakpoint

    # Parse command
    regexp {(.),(.*),(.*)} $cmd match type addr length
    set addr   [format %04x "0x$addr"]

    switch -exact -- $type {
	"0"     {# Memory breakpoint
	         WriteMem 0 "0x$addr" $mem_breakpoint($addr)
	         unset mem_breakpoint($addr)
	         return "OK"
                }

	"1"     {# Hardware breakpoint
	         if {[ClearHWBreak 1 [format "0x%04x" 0x$addr]]} {
		     return "OK"
		 }
	         return ""
                }

	"2"     {# Write watchpoint
	         if {[ClearHWBreak 0 [format "0x%04x" 0x$addr]]} {
		     return "OK"
		 }
	         return ""
                }

	"3"     {# Read watchpoint
	         if {[ClearHWBreak 0 [format "0x%04x" 0x$addr]]} {
		     return "OK"
		 }
	         return ""
                }

	"4"     {# Access watchpoint
	         if {[ClearHWBreak 0 [format "0x%04x" 0x$addr]]} {
		     return "OK"
		 }
	         return ""
                }

	default {return ""}
    }
}

#-----------------------------------------------------------------------------#
# Continue.                                                                   #
#-----------------------------------------------------------------------------#
proc rsp_c {sock cmd} {
    
    # Set address if required
    if {$cmd!=""} {
	set cmd [format %04x "0x$cmd"]
	SetPC "0x$cmd"
    }

    # Clear status
    ClrStatus

    # Continue
    ReleaseCPU


    return [rsp_stop_reply $sock "c"]
}

#-----------------------------------------------------------------------------#
# Step.                                                                       #
#-----------------------------------------------------------------------------#
proc rsp_s {sock cmd} {
    
    # Set address if required
    if {$cmd!=""} {
	set cmd [format %04x "0x$cmd"]
	SetPC "0x$cmd"
    }

    # Clear status
    ClrStatus

    # Incremental step
    StepCPU

    return [rsp_stop_reply $sock "s"]
}


#-----------------------------------------------------------------------------#
# The `C', `c', `S', `s', `vCont', `vAttach', `vRun', `vStopped', and `?'     #
# packets can receive any of the below as a reply. Except for `?' and         #
# `vStopped', that reply is only returned when the target halts.              #
#-----------------------------------------------------------------------------#
proc rsp_stop_reply {sock cmd} {

    # Wait until halted
    while {![IsHalted]} {

	# Wait a few milliseconds to prevent the gui from freezing
	after 100 {set end 1}
	vwait end

	# Check if we are interrupted by GDB
	fconfigure $sock -blocking 0
	set break_char [read -nonewline $sock]
	fconfigure $sock -blocking 1
	binary scan $break_char H* break_char
	if {$break_char=="03"} {
	    putsVerbose "--> BREAK"
	    HaltCPU
	}
    }

    # Read some important registers
    set pc [ReadReg 0]
    regexp {0x(..)(..)} $pc match pc_hi pc_lo
    set r4 [ReadReg 4]
    regexp {0x(..)(..)} $r4 match r4_hi r4_lo

#    return "S05"
    return "T0500:$pc_lo$pc_hi;04:$r4_lo$r4_hi;"
}


#-----------------------------------------------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#
proc rsp_q {sock cmd} {
    
       switch -regexp -- $cmd {

	"C"       {set rsp_answer ""}
	"Offsets" {set rsp_answer "Text=0;Data=0;Bss=0"}
	"Rcmd,.+" {set rsp_answer [rsp_qRcmd $sock $cmd]}
	default   {set rsp_answer ""}
    }
    return $rsp_answer
}

#-----------------------------------------------------------------------------#
# qRcmd,command'                                                              #
#    command (hex encoded) is passed to the local interpreter for execution.  #
#    Invalid commands should be reported using the output string. Before the  #
#    final result packet, the target may also respond with a number of        #
#    intermediate `Ooutput' console output packets. Implementors should note  #
#    that providing access to a stubs's interpreter may have security         #
#    implications.                                                            #
#-----------------------------------------------------------------------------#
proc rsp_qRcmd {sock cmd} {

    regsub {^Rcmd,} $cmd {} cmd
    set cmd [binary format H* $cmd];  # Convert hex to ascii

    switch -exact -- $cmd {
	"erase all" {;# Convert ascii to hex
	             binary scan "Erasing target program memory..." H* text1
	             binary scan " Erased OK\n"                     H* text2
	             ;# Execute erase command
	             sendRSPpacket $sock "O$text1"
	             EraseROM
	             sendRSPpacket $sock "O$text2"
	             set rsp_answer "OK"
                    }
	default     {set rsp_answer "OK"}
    }

    return $rsp_answer

}
