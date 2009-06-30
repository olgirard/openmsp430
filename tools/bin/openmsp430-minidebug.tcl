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
# File Name: minidebug.tcl
# 
#------------------------------------------------------------------------------

###############################################################################
#                                                                             #
#                            GLOBAL VARIABLES                                 #
#                                                                             #
###############################################################################

global serial_baudrate
global serial_device
global serial_status
global cpu_status
global reg
global mem

# Initializations
set serial_status 0
set cpu_status    1
for {set i 0} {$i<16} {incr i} {
    set reg($i)         0x0000
    set mem(address_$i) [format "0x%04x" [expr 0x0200+$i*2]]
    set mem(data_$i)    0x0000
}

###############################################################################
#                                                                             #
#                            SOURCE LIBRARIES                                 #
#                                                                             #
###############################################################################

# Get library path
set current_file [info script]
if {[file type $current_file]=="link"} {
    set current_file [file readlink $current_file]
}
set lib_path [file dirname $current_file]/../lib/tcl-lib

# Source library
source $lib_path/dbg_functions.tcl
source $lib_path/combobox.tcl
package require combobox 2.3
catch {namespace import combobox::*}


###############################################################################
#                                                                             #
#                                    FUNCTIONS                                #
#                                                                             #
###############################################################################

proc connect_openMSP430 {} {
    global serial_status
    global reg
    global mem

    set serial_status [GetDevice]

    if {$serial_status} {
	set sizes [GetCPU_ID_SIZE]

	.serial.p1               configure -state disabled	
	.serial.p2               configure -state disabled
	.serial.connect          configure -state disabled
	.serial.l3               configure -text "Connected" -fg green
	.load.ft.file            configure -state normal
	.load.ft.browse          configure -state normal
	.load.fb.read            configure -state normal
	.cpu.reset               configure -state normal
	.cpu.run                 configure -state normal
	.cpu.l7                  configure -text [lindex $sizes 0]
	.cpu.l5                  configure -text [lindex $sizes 1]
	.reg_mem.reg.cmd.refresh configure -state normal
	.reg_mem.mem.cmd.refresh configure -state normal
	for {set i 0} {$i<16} {incr i} {
	    .reg_mem.reg.entries.e$i   configure -state normal
	    .reg_mem.mem.address.e$i   configure -state normal
	    .reg_mem.mem.data.e$i      configure -state normal
	}
	refreshReg
	refreshMem

    } else {
	.serial.l3      configure -text "Connection problem" -fg red
    }
}

proc disconnect_openMSP430 {} {
    global serial_status

    if {$serial_status} {
	ReleaseDevice 0xfffe
    }
}

proc loadProgram {elf_file_name} {
    global cpu_status
    global reg
    global mem

    # Create and read binary executable file
    #----------------------------------------

    # Generate binary file
    set bin_file "[clock clicks].bin"
    catch {exec msp430-objcopy -O binary $elf_file_name $bin_file}

    # Read file
    set fp [open $bin_file r]
    fconfigure $fp -translation binary
    binary scan [read $fp] H* hex_data yop
    close $fp

    # Cleanup
    file delete $bin_file

    # Get program size
    set hex_size  [string length $hex_data]
    set byte_size [expr $hex_size/2]
    set word_size [expr $byte_size/2]

    # Format data
    for {set i 0} {$i < $hex_size} {set i [expr $i+4]} {
	set hex_msb "[string index $hex_data [expr $i+2]][string index $hex_data [expr $i+3]]"
	set hex_lsb "[string index $hex_data [expr $i+0]][string index $hex_data [expr $i+1]]"
	lappend DataArray "0x$hex_msb$hex_lsb"
    }

    # Load program to openmsp430 target
    #-----------------------------------

    # Reset & Stop CPU
    ExecutePOR_Halt

    # Load ROM
    set StartAddr [format "0x%04x" [expr 0x10000-$byte_size]]
    .load.fb.l configure -text "Load..." -fg yellow
    update
    WriteMemQuick $StartAddr $DataArray

    # Check Data
    .load.fb.l configure -text "Verify..." -fg yellow
    update
    if {[VerifyMem $StartAddr $DataArray]} {
	.load.fb.l configure -text "Done" -fg green
    } else {
	.load.fb.l configure -text "ERROR" -fg red
    }
    update

    # Release device if it was not previously stopped
    if {$cpu_status} {
	ReleaseCPU
    }
    refreshReg
    refreshMem
}

proc runCPU {} {
    global cpu_status
    global reg
    global mem

    if {$cpu_status} {
	HaltCPU
	.cpu.run   configure -text "Run"
	.cpu.l3    configure -text "Stopped" -fg yellow
	set cpu_status 0
    } else {
	ReleaseCPU
	.cpu.run   configure -text "Stop"
	.cpu.l3    configure -text "Running" -fg green
	set cpu_status 1
    }
    refreshReg
    refreshMem
}

proc resetCPU {} {
    global cpu_status
    global reg
    global mem

    if {$cpu_status} {
	ExecutePOR
    } else {
	ExecutePOR_Halt
    }
    refreshReg
    refreshMem
}

proc refreshReg {} {
    global reg
    global mem

    set new_vals [ReadRegAll]
    for {set i 0} {$i<16} {incr i} {
	set reg($i) [lindex $new_vals $i]
    }
}

proc write2Reg {reg_num} {
    global reg
    global mem

    WriteReg $reg_num $reg($reg_num)
    refreshReg
    refreshMem
}

proc refreshMem {} {
    global reg
    global mem

    for {set i 0} {$i<16} {incr i} {
	# Check if address lay in 16 or 8 bit space
	if {[expr $mem(address_$i)]>=[expr 0x100]} {
	    set Format 0
	} else {
	    set Format 1
	}

	# Read data
	set mem(data_$i) [ReadMem $Format $mem(address_$i)]
    }
}

proc write2Mem {mem_num} {
    global reg
    global mem

    # Check if address lay in 16 or 8 bit space
    if {[expr $mem(address_$mem_num)]>=[expr 0x100]} {
	set Format 0
    } else {
	set Format 1
    }

    WriteMem $Format $mem(address_$mem_num) $mem(data_$mem_num)
    refreshReg
    refreshMem
}

###############################################################################
#                                                                             #
#                           CREATE GRAPHICAL INTERFACE                        #
#                                                                             #
###############################################################################

####################################
#   CREATE & PLACE MAIN WIDGETS    #
####################################

wm title    . "openMSP430 mini debuger"
wm iconname . "openMSP430 mini debuger"

# Create the Main Menu budget
frame  .menu
pack   .menu    -side top -padx 10 -pady 10 -fill x

# Create the Serial Menu budget
frame  .serial
pack   .serial  -side top -padx 10 -pady 10 -fill x

# Create the Load executable field
frame  .load
pack   .load    -side top -padx 10 -pady 10 -fill x

# Create the cpu control field
frame  .cpu
pack   .cpu     -side top -padx 10 -pady 10 -fill x

# Create the cpu registers/memory fields
frame  .reg_mem
pack   .reg_mem -side top -padx 10 -pady 10 -fill x
frame  .reg_mem.reg
pack   .reg_mem.reg           -side left -fill x
frame  .reg_mem.mem
pack   .reg_mem.mem           -side left -fill x


####################################
#  CREATE THE REST                 #
####################################

# Exit button
button .menu.exit      -text "Exit" -command {disconnect_openMSP430; exit 0}
pack   .menu.exit      -side left


# Serial Port fields
label  .serial.l1      -text "Serial Port:"  -anchor w
pack   .serial.l1      -side left
set serial_device      [lindex [dbg_list_uart] end]
combobox .serial.p1    -textvariable serial_device -editable true
eval     .serial.p1    list insert end [dbg_list_uart]
pack   .serial.p1      -side left -padx 5

label  .serial.l2      -text "  Baudrate:" -anchor w
pack   .serial.l2      -side left
set serial_baudrate    115200
combobox .serial.p2    -textvariable serial_baudrate -editable true
eval     .serial.p2    list insert end [list    9600   19200  38400  57600 115200 \
                                              230400  460800 500000 576000 921600 \
                                             1000000 1152000]
pack   .serial.p2      -side left -padx 5

button .serial.connect -text "Connect" -command {connect_openMSP430}
pack   .serial.connect -side left -padx 10
label  .serial.l3      -text "Disconnected" -anchor w -fg Red
pack   .serial.l3      -side left


# Load ELF file fields
frame  .load.ft
pack   .load.ft        -side top -fill x
label  .load.ft.l      -text "ELF file:"
pack   .load.ft.l      -side left -padx 5
entry  .load.ft.file   -width 58 -relief sunken -textvariable elf_file_name -state disabled
pack   .load.ft.file   -side left -padx 5
button .load.ft.browse -text "Browse" -state disabled -command {set elf_file_name [tk_getOpenFile]}
pack   .load.ft.browse -side left -padx 5 
frame  .load.fb
pack   .load.fb        -side top -fill x
button .load.fb.read   -text "Load ELF File !" -state disabled -command {loadProgram $elf_file_name}
pack   .load.fb.read   -side left -padx 5 -fill x
label  .load.fb.l      -text "Not loaded" -anchor w -fg Red
pack   .load.fb.l      -side left


# CPU Control
label  .cpu.l1         -text "Control CPU:" -anchor w
pack   .cpu.l1         -side left
button .cpu.reset      -text "Reset" -state disabled -command {resetCPU}
pack   .cpu.reset      -side left -padx 5 -fill x
button .cpu.run        -text "Stop"  -state disabled -command {runCPU}
pack   .cpu.run        -side left -padx 5 -fill x
label  .cpu.l2         -text "CPU Status:" -anchor w
pack   .cpu.l2         -side left
label  .cpu.l3         -text "Running" -anchor w -fg green
pack   .cpu.l3         -side left

label  .cpu.l4         -text "B)"        -anchor w
pack   .cpu.l4         -side right
label  .cpu.l5         -text "--"        -anchor w
pack   .cpu.l5         -side right
label  .cpu.l6         -text "B; RAM size:" -anchor w
pack   .cpu.l6         -side right
label  .cpu.l7         -text "--"        -anchor w
pack   .cpu.l7         -side right
label  .cpu.l8         -text "(ROM size:" -anchor w
pack   .cpu.l8         -side right


# CPU Registers
frame  .reg_mem.reg.labels
pack   .reg_mem.reg.labels     -side left -fill x
frame  .reg_mem.reg.entries
pack   .reg_mem.reg.entries    -side left -fill x
for {set i 0} {$i<16} {incr i} {
    switch $i {
	{0}     {set reg_label "r0 (pc):"}
	{1}     {set reg_label "r1 (sp):"}
	{2}     {set reg_label "r2 (sr):"}
	default {set reg_label "r$i:"}
    }
    label  .reg_mem.reg.labels.l$i    -text $reg_label -anchor w
    pack   .reg_mem.reg.labels.l$i    -side top -padx 5 -pady 1
    entry  .reg_mem.reg.entries.e$i   -textvariable reg($i) -relief sunken -state disabled
    pack   .reg_mem.reg.entries.e$i   -side top
    bind   .reg_mem.reg.entries.e$i   <Return> "write2Reg $i"
}
frame  .reg_mem.reg.cmd
pack   .reg_mem.reg.cmd               -side left -fill x
button .reg_mem.reg.cmd.refresh       -text "Refresh\nRegisters"  -state disabled -command {refreshReg}
pack   .reg_mem.reg.cmd.refresh       -side top -padx 5 -fill x

# CPU Memory
frame  .reg_mem.mem.cmd
pack   .reg_mem.mem.cmd               -side left -fill x
button .reg_mem.mem.cmd.refresh       -text "Refresh\nMemory"  -state disabled -command {refreshMem}
pack   .reg_mem.mem.cmd.refresh       -side top -padx 5 -fill x
frame  .reg_mem.mem.address
pack   .reg_mem.mem.address           -side left -fill x
frame  .reg_mem.mem.data
pack   .reg_mem.mem.data              -side left -fill x
label  .reg_mem.mem.address.l         -text "Address" -anchor w
pack   .reg_mem.mem.address.l         -side top -padx 5
label  .reg_mem.mem.data.l            -text "Data"   -anchor w
pack   .reg_mem.mem.data.l            -side top -padx 5

for {set i 0} {$i<16} {incr i} {
    entry  .reg_mem.mem.address.e$i    -textvariable mem(address_$i) -relief sunken -state disabled
    pack   .reg_mem.mem.address.e$i    -side top
    bind   .reg_mem.mem.address.e$i    <Return> "refreshMem"
    entry  .reg_mem.mem.data.e$i       -textvariable mem(data_$i) -relief sunken -state disabled
    pack   .reg_mem.mem.data.e$i       -side top
    bind   .reg_mem.mem.data.e$i       <Return> "write2Mem $i"
}