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
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#
#------------------------------------------------------------------------------
# $Rev$
# $LastChangedBy$
# $LastChangedDate$
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
global sr
global codeSelect
global binFileType

# Initializations
set codeSelect    2
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

	if {[lindex $sizes 0]==-1 | [lindex $sizes 1]==-1} {
	    .ctrl.mem_sz.l3               configure -text "Connection problem" -fg red

	} else {

	    # Disable connection section
	    .ctrl.serial.p1               configure -state disabled	
	    .ctrl.serial.p2               configure -state disabled
	    .ctrl.serial.connect          configure -state disabled
	    .ctrl.mem_sz.l3               configure -text "Connected" -fg green
	    .ctrl.mem_sz.l8               configure -text [lindex $sizes 1]
	    .ctrl.mem_sz.l5               configure -text [lindex $sizes 0]

	    # Activate ELF file section
	    .ctrl.load.ft.l               configure -state normal
	    .ctrl.load.ft.file            configure -state normal
	    .ctrl.load.ft.browse          configure -state normal
	    .ctrl.load.fb.read            configure -state normal
	    .ctrl.load.fb.l               configure -state normal

	    # Activate CPU control section
	    .ctrl.cpu.l1                  configure -state normal
	    .ctrl.cpu.reset               configure -state normal
	    .ctrl.cpu.run                 configure -state normal
	    .ctrl.cpu.l2                  configure -state normal
	    .ctrl.cpu.l3                  configure -state normal
	    if {[IsHalted]} {
		.ctrl.cpu.step  configure -state normal
		.ctrl.cpu.run   configure -text "Run"
		.ctrl.cpu.l3    configure -text "Stopped" -fg yellow
		set cpu_status 0
	    } else {
		.ctrl.cpu.step  configure -state disabled
		.ctrl.cpu.run   configure -text "Stop"
		.ctrl.cpu.l3    configure -text "Running" -fg green
		set cpu_status 1
	    }

	    # Activate CPU status register section
	    .ctrl.reg_stat.l1             configure -state normal
	    .ctrl.reg_stat.v              configure -state normal
	    .ctrl.reg_stat.scg1           configure -state normal
	    .ctrl.reg_stat.oscoff         configure -state normal
	    .ctrl.reg_stat.cpuoff         configure -state normal
	    .ctrl.reg_stat.gie            configure -state normal
	    .ctrl.reg_stat.n              configure -state normal
	    .ctrl.reg_stat.z              configure -state normal
	    .ctrl.reg_stat.c              configure -state normal

	    # Activate CPU registers and memory section
	    .ctrl.reg_mem.reg.title.e     configure -state normal
	    .ctrl.reg_mem.mem.title.l     configure -state normal
	    .ctrl.reg_mem.mem.title.e     configure -state normal
	    .ctrl.reg_mem.reg.refresh     configure -state normal
	    .ctrl.reg_mem.mem.refresh     configure -state normal
	    for {set i 0} {$i<16} {incr i} {
		.ctrl.reg_mem.reg.f$i.l$i        configure -state normal
		.ctrl.reg_mem.reg.f$i.e$i        configure -state normal
		.ctrl.reg_mem.mem.f$i.addr_e$i   configure -state normal
		.ctrl.reg_mem.mem.f$i.data_e$i   configure -state normal
	    }
	    refreshReg
	    refreshMem

	    # Activate Load TCL script section
	    .ctrl.tclscript.ft.l          configure -state normal
	    .ctrl.tclscript.ft.file       configure -state normal
	    .ctrl.tclscript.ft.browse     configure -state normal
	    .ctrl.tclscript.fb.read       configure -state normal
	    
	    # Activate the code debugger section
	    .code.rb.txt                  configure -state normal
	    .code.rb.none                 configure -state normal
	    .code.rb.asm                  configure -state normal
	    .code.rb.mix                  configure -state normal
	}

    } else {
	.ctrl.mem_sz.l3               configure -text "Connection problem" -fg red
    }
}

proc highlightLine { line } { 
    .code.text tag remove highlight 1.0     end
    .code.text tag add    highlight $line.0 [expr $line+1].0
    .code.text see        $line.0

}

proc highlightPC   { pc_val } {
    global codeSelect

    if {$codeSelect!=1} {

	regsub {0x} $pc_val {} pc_val
	set code_match [.code.text search "$pc_val:" 1.0 end]
	set code_line 1
	regexp {(\d+).(\d+)} $code_match whole_match code_line code_column
	highlightLine $code_line
     }
}

proc updateCodeView { bin_file_name } {
    global codeSelect
    global reg
    global binFileType

    set temp_elf_file "[clock clicks].elf"
    if {[catch {exec msp430-objcopy -I $binFileType -O elf32-msp430 $bin_file_name $temp_elf_file} debug_info]} {
	.ctrl.load.fb.l configure -text "$debug_info" -fg red
	return 0
    }
    if {[string eq $binFileType "ihex"]} {
	set dumpOpt "-D"
    } else {
	set dumpOpt "-d"
    }

    if {$codeSelect==1} {
	set debug_info ""

    } elseif {$codeSelect==2} {
	if {[catch {exec msp430-objdump $dumpOpt $temp_elf_file} debug_info]} {
	    .ctrl.load.fb.l configure -text "$debug_info" -fg red
	    return 0
	}
    } elseif {$codeSelect==3} {
	if {[catch {exec msp430-objdump $dumpOpt\S $temp_elf_file} debug_info]} {
	    .ctrl.load.fb.l configure -text "$debug_info" -fg red
	    return 0
	}
    }
    file delete $temp_elf_file

    .code.text configure -state normal
    .code.text delete 1.0 end
    .code.text insert end $debug_info
    highlightPC $reg(0)
    .code.text configure -state disabled
    return 1
}

proc loadProgram {bin_file_name} {
    global cpu_status
    global reg
    global mem
    global binFileType

    # Detect the file format depending on the fil extention
    #--------------------------------------------------------
    set binFileType [file extension $bin_file_name]
    set binFileType [string tolower $binFileType]
    regsub {\.} $binFileType {} binFileType

    if {![string eq $binFileType "ihex"] & ![string eq $binFileType "hex"] & ![string eq $binFileType "elf"]} {
	.ctrl.load.fb.l configure -text "[string toupper $binFileType] file format not supported\"" -fg red
	return 0
    } 

    # Check if the file exists
    #----------------------------------------
    if {![file exists $bin_file_name]} {
	.ctrl.load.fb.l configure -text "[string toupper $binFileType] file doesn't exists: \"$bin_file_name\"" -fg red
	return 0
    }
    if {[string eq $binFileType "hex"]} {
	set binFileType "ihex"
    }
    if {[string eq $binFileType "elf"]} {
	set binFileType "elf32-msp430"
    }


    # Create and read debug informations
    #----------------------------------------

    updateCodeView $bin_file_name

    # Create and read binary executable file
    #----------------------------------------

    # Generate binary file
    set bin_file "[clock clicks].bin"
    if {[catch {exec msp430-objcopy -I $binFileType -O binary $bin_file_name $bin_file} errMsg]} {
	.ctrl.load.fb.l configure -text "$errMsg" -fg red
	return 0
    }
 
    # Wait until bin file is present on the filesystem
    set timeout 100
    for {set i 0} {$i <= $timeout} {incr i} {
	after 500
	if {[file exists $bin_file]} {
	    break
	}
    }
    if {$i>=$timeout} {
	.ctrl.load.fb.l configure -text "Timeout: ELF to BIN file conversion problem with \"msp430-objcopy\" executable" -fg red
	return 0
    }

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

    # Make sure ELF program size is the same as the available program memory
    set sizes [GetCPU_ID_SIZE]
    if {[lindex $sizes 0] != [expr $hex_size/2]} {
	.ctrl.load.fb.l configure -text "ERROR: ELF program size ([expr $hex_size/2] B) is different than the available program memory ([lindex $sizes 0] B)" -fg red
	return 0
    }

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

    # Load Program Memory
    set StartAddr [format "0x%04x" [expr 0x10000-$byte_size]]
    .ctrl.load.fb.l configure -text "Load..." -fg yellow
    update
    WriteMemQuick $StartAddr $DataArray

    # Check Data
    .ctrl.load.fb.l configure -text "Verify..." -fg yellow
    update
    if {[VerifyMem $StartAddr $DataArray 1]} {
	.ctrl.load.fb.l configure -text "Done" -fg green
    } else {
	.ctrl.load.fb.l configure -text "ERROR" -fg red
    }
    update

    # Reset & Stop CPU
    ExecutePOR_Halt
    .ctrl.cpu.step  configure -state normal
    .ctrl.cpu.run   configure -text "Run"
    .ctrl.cpu.l3    configure -text "Stopped" -fg yellow
    set cpu_status 0
    refreshReg
    refreshMem
}

proc runCPU {} {
    global cpu_status
    global reg
    global mem

    if {$cpu_status} {
	HaltCPU
	.ctrl.cpu.step  configure -state normal
	.ctrl.cpu.run   configure -text "Run"
	.ctrl.cpu.l3    configure -text "Stopped" -fg yellow
	set cpu_status 0
    } else {
	ReleaseCPU
	.ctrl.cpu.step  configure -state disabled
	.ctrl.cpu.run   configure -text "Stop"
	.ctrl.cpu.l3    configure -text "Running" -fg green
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

proc singleStepCPU {} {
    global cpu_status
    global reg
    global mem

    if {$cpu_status==0} {
	StepCPU
    }
    refreshReg
    refreshMem
}

proc statRegUpdate {} {
    global cpu_status
    global reg
    global mem
    global sr

    set tmp_reg [expr ($sr(v)      * 0x0100) |  \
                      ($sr(scg1)   * 0x0080) |  \
                      ($sr(oscoff) * 0x0020) |  \
                      ($sr(cpuoff) * 0x0010) |  \
                      ($sr(gie)    * 0x0008) |  \
                      ($sr(n)      * 0x0004) |  \
                      ($sr(z)      * 0x0002) |  \
 		      ($sr(c)      * 0x0001)]

    set reg(2) [format "0x%04x" $tmp_reg]

    write2Reg 2
}


proc refreshReg {} {
    global reg
    global mem
    global sr

    # Read register values
    set new_vals [ReadRegAll]
    for {set i 0} {$i<16} {incr i} {
	set reg($i) [lindex $new_vals $i]
    }
    set sr(c)      [expr $reg(2) & 0x0001]
    set sr(z)      [expr $reg(2) & 0x0002]
    set sr(n)      [expr $reg(2) & 0x0004]
    set sr(gie)    [expr $reg(2) & 0x0008]
    set sr(cpuoff) [expr $reg(2) & 0x0010]
    set sr(oscoff) [expr $reg(2) & 0x0020]
    set sr(scg1)   [expr $reg(2) & 0x0080]
    set sr(v)      [expr $reg(2) & 0x0100]

    # Update highlighted line in the code view
    highlightPC $reg(0)
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

wm title    . "openMSP430 mini debugger"
wm iconname . "openMSP430 mini debugger"

# Create the Main Menu
frame  .menu
pack   .menu              -side top    -padx 10      -pady 10      -fill x

# Create the CPU Contorl field
frame  .ctrl
pack   .ctrl              -side left   -padx 10      -pady 10      -fill x

# Create the Code text field
frame  .code
pack   .code              -side right  -padx 10      -pady 10      -fill both -expand true
frame  .code.rb
pack   .code.rb           -side bottom -padx 10      -pady 10      -fill both

# Create the Serial Menu
frame  .ctrl.serial
pack   .ctrl.serial       -side top    -padx 10      -pady {10 0}  -fill x

# Create the memory size
frame  .ctrl.mem_sz
pack   .ctrl.mem_sz       -side top    -padx 10      -pady {10 20} -fill x

# Create the Load executable field
frame  .ctrl.load
pack   .ctrl.load         -side top    -padx 10      -pady {10 20} -fill x

# Create the cpu control field
frame  .ctrl.cpu
pack   .ctrl.cpu          -side top    -padx 10      -pady {10 20} -fill x

# Create the cpu status field
frame  .ctrl.reg_stat
pack   .ctrl.reg_stat     -side top    -padx 10      -pady {10 10} -fill x

# Create the cpu registers/memory fields
frame  .ctrl.reg_mem
pack   .ctrl.reg_mem      -side top    -padx 10      -pady {5 20}  -fill x
frame  .ctrl.reg_mem.reg
pack   .ctrl.reg_mem.reg  -side left   -padx {10 30}               -fill x
frame  .ctrl.reg_mem.mem
pack   .ctrl.reg_mem.mem  -side left   -padx {30 10}               -fill x

# Create the TCL script field
frame  .ctrl.tclscript
pack   .ctrl.tclscript    -side top    -padx 10      -pady {10 20} -fill x


####################################
#  CREATE THE CPU CONTROL SECTION  #
####################################

# Exit button
button .menu.exit      -text "Exit" -command {exit 0}
pack   .menu.exit      -side left


# Serial Port fields
label    .ctrl.serial.l1    -text "Serial Port:"  -anchor w
pack     .ctrl.serial.l1    -side left
set serial_device      [lindex [dbg_list_uart] end]
combobox .ctrl.serial.p1    -textvariable serial_device -editable true
eval     .ctrl.serial.p1    list insert end [dbg_list_uart]
pack     .ctrl.serial.p1    -side left -padx 5

label    .ctrl.serial.l2    -text "  Baudrate:" -anchor w
pack     .ctrl.serial.l2    -side left
set serial_baudrate    115200
combobox .ctrl.serial.p2    -textvariable serial_baudrate -editable true
eval     .ctrl.serial.p2    list insert end [list     9600    19200  38400  57600 115200 \
                                                    230400   460800 500000 576000 921600 \
                                                    1000000 1152000]
pack     .ctrl.serial.p2      -side left -padx 5

button   .ctrl.serial.connect -text "Connect" -command {connect_openMSP430}
pack     .ctrl.serial.connect -side left -padx 10

# Memory size status
label  .ctrl.mem_sz.l2    -text "CPU Info:"             -anchor w
pack   .ctrl.mem_sz.l2    -side left -padx "0 10"
label  .ctrl.mem_sz.l3    -text "Disconnected"          -anchor w -fg Red
pack   .ctrl.mem_sz.l3    -side left -padx "0 30"
label  .ctrl.mem_sz.l4    -text "Program Memory size:"  -anchor w
pack   .ctrl.mem_sz.l4    -side left
label  .ctrl.mem_sz.l5    -text "--"                    -anchor w
pack   .ctrl.mem_sz.l5    -side left
label  .ctrl.mem_sz.l6    -text "B"                     -anchor w
pack   .ctrl.mem_sz.l6    -side left -padx "0 30"
label  .ctrl.mem_sz.l7    -text "Data Memory size:"     -anchor w
pack   .ctrl.mem_sz.l7    -side left
label  .ctrl.mem_sz.l8    -text "--"                    -anchor w
pack   .ctrl.mem_sz.l8    -side left
label  .ctrl.mem_sz.l9    -text "B"                     -anchor w
pack   .ctrl.mem_sz.l9    -side left

# Load ELF file fields
frame  .ctrl.load.ft
pack   .ctrl.load.ft        -side top -fill x
label  .ctrl.load.ft.l      -text "ELF file:"  -state disabled
pack   .ctrl.load.ft.l      -side left -padx "0 10"
entry  .ctrl.load.ft.file   -width 58 -relief sunken -textvariable bin_file_name -state disabled
pack   .ctrl.load.ft.file   -side left -padx 10
button .ctrl.load.ft.browse -text "Browse" -state disabled -command {set bin_file_name [tk_getOpenFile -filetypes {{{ELF/Intel-Hex Files} {.elf .ihex .hex}} {{All Files} *}}]}
pack   .ctrl.load.ft.browse -side left -padx 5 
frame  .ctrl.load.fb
pack   .ctrl.load.fb        -side top -fill x
button .ctrl.load.fb.read   -text "Load ELF File !" -state disabled -command {loadProgram $bin_file_name}
pack   .ctrl.load.fb.read   -side left -padx 5 -fill x
label  .ctrl.load.fb.l      -text "Not loaded" -anchor w -fg Red  -state disabled
pack   .ctrl.load.fb.l      -side left

# CPU Control
label  .ctrl.cpu.l1         -text "CPU Control:" -anchor w  -state disabled
pack   .ctrl.cpu.l1         -side left
button .ctrl.cpu.reset      -text "Reset" -state disabled -command {resetCPU}
pack   .ctrl.cpu.reset      -side left -padx 5 -fill x
button .ctrl.cpu.run        -text "Stop"  -state disabled -command {runCPU}
pack   .ctrl.cpu.run        -side left -padx 5 -fill x
button .ctrl.cpu.step       -text "Step"  -state disabled -command {singleStepCPU}
pack   .ctrl.cpu.step       -side left -padx 5 -fill x
label  .ctrl.cpu.l2         -text "CPU Status:" -anchor w  -state disabled
pack   .ctrl.cpu.l2         -side left -padx "40 0"
label  .ctrl.cpu.l3         -text "--" -anchor w  -state disabled
pack   .ctrl.cpu.l3         -side left

# CPU Status register
label       .ctrl.reg_stat.l1     -text "Status register (r2/sr):" -anchor w -state disabled
pack        .ctrl.reg_stat.l1     -side left
checkbutton .ctrl.reg_stat.v      -variable sr(v)      -state disabled -command "statRegUpdate" -text "V"
pack        .ctrl.reg_stat.v      -side left -padx "0"
checkbutton .ctrl.reg_stat.scg1   -variable sr(scg1)   -state disabled -command "statRegUpdate" -text "SCG1"
pack        .ctrl.reg_stat.scg1   -side left -padx "0"
checkbutton .ctrl.reg_stat.oscoff -variable sr(oscoff) -state disabled -command "statRegUpdate" -text "OSCOFF"
pack        .ctrl.reg_stat.oscoff -side left -padx "0"
checkbutton .ctrl.reg_stat.cpuoff -variable sr(cpuoff) -state disabled -command "statRegUpdate" -text "CPUOFF"
pack        .ctrl.reg_stat.cpuoff -side left -padx "0"
checkbutton .ctrl.reg_stat.gie    -variable sr(gie)    -state disabled -command "statRegUpdate" -text "GIE"
pack        .ctrl.reg_stat.gie    -side left -padx "0"
checkbutton .ctrl.reg_stat.n      -variable sr(n)      -state disabled -command "statRegUpdate" -text "N"
pack        .ctrl.reg_stat.n      -side left -padx "0"
checkbutton .ctrl.reg_stat.z      -variable sr(z)      -state disabled -command "statRegUpdate" -text "Z"
pack        .ctrl.reg_stat.z      -side left -padx "0"
checkbutton .ctrl.reg_stat.c      -variable sr(c)      -state disabled -command "statRegUpdate" -text "C"
pack        .ctrl.reg_stat.c      -side left -padx "0"

# CPU Registers
frame  .ctrl.reg_mem.reg.title
pack   .ctrl.reg_mem.reg.title           -side top
label  .ctrl.reg_mem.reg.title.l         -text " " -width 8 -anchor w
pack   .ctrl.reg_mem.reg.title.l         -side left
label  .ctrl.reg_mem.reg.title.e         -text "Registers" -anchor w  -state disabled
pack   .ctrl.reg_mem.reg.title.e         -side left
for {set i 0} {$i<16} {incr i} {
    switch $i {
	{0}     {set reg_label "r0 (pc):"}
	{1}     {set reg_label "r1 (sp):"}
	{2}     {set reg_label "r2 (sr):"}
	default {set reg_label "r$i:"}
    }
    frame  .ctrl.reg_mem.reg.f$i
    pack   .ctrl.reg_mem.reg.f$i           -side top
    label  .ctrl.reg_mem.reg.f$i.l$i       -text $reg_label -width 8 -anchor w  -state disabled
    pack   .ctrl.reg_mem.reg.f$i.l$i       -side left
    entry  .ctrl.reg_mem.reg.f$i.e$i       -textvariable reg($i) -relief sunken -state disabled
    pack   .ctrl.reg_mem.reg.f$i.e$i       -side left
    bind   .ctrl.reg_mem.reg.f$i.e$i       <Return> "write2Reg $i"
}
button .ctrl.reg_mem.reg.refresh           -text "Refresh Registers"  -state disabled -command {refreshReg}
pack   .ctrl.reg_mem.reg.refresh           -side top -padx 5 -pady 10 -fill x -expand true


# CPU Memory
frame  .ctrl.reg_mem.mem.title
pack   .ctrl.reg_mem.mem.title             -side top
label  .ctrl.reg_mem.mem.title.l           -text "      Address      " -anchor w -width 20  -state disabled
pack   .ctrl.reg_mem.mem.title.l           -side left -fill x -expand true
label  .ctrl.reg_mem.mem.title.e           -text "        Data       " -anchor w -width 20  -state disabled
pack   .ctrl.reg_mem.mem.title.e           -side left -fill x -expand true
for {set i 0} {$i<16} {incr i} {
    frame  .ctrl.reg_mem.mem.f$i
    pack   .ctrl.reg_mem.mem.f$i           -side top

    entry  .ctrl.reg_mem.mem.f$i.addr_e$i  -textvariable mem(address_$i) -relief sunken -state disabled  -width 20
    pack   .ctrl.reg_mem.mem.f$i.addr_e$i  -side left
    bind   .ctrl.reg_mem.mem.f$i.addr_e$i  <Return> "refreshMem"
    entry  .ctrl.reg_mem.mem.f$i.data_e$i  -textvariable mem(data_$i)    -relief sunken -state disabled  -width 20
    pack   .ctrl.reg_mem.mem.f$i.data_e$i  -side left
    bind   .ctrl.reg_mem.mem.f$i.data_e$i  <Return> "write2Mem $i"
}
button .ctrl.reg_mem.mem.refresh -text "Refresh Memory"     -state disabled -command {refreshMem}
pack   .ctrl.reg_mem.mem.refresh -side top -padx 5 -pady 10 -fill x -expand true


# Load TCL script fields
frame  .ctrl.tclscript.ft
pack   .ctrl.tclscript.ft        -side top -fill x
label  .ctrl.tclscript.ft.l      -text "TCL script:" -state disabled
pack   .ctrl.tclscript.ft.l      -side left -padx "0 10"
entry  .ctrl.tclscript.ft.file   -width 58 -relief sunken -textvariable tcl_file_name -state disabled
pack   .ctrl.tclscript.ft.file   -side left -padx 10
button .ctrl.tclscript.ft.browse -text "Browse" -state disabled -command {set tcl_file_name [tk_getOpenFile -filetypes {{{TCL Files} {.tcl}} {{All Files} *}}]}
pack   .ctrl.tclscript.ft.browse -side left -padx 5 
frame  .ctrl.tclscript.fb
pack   .ctrl.tclscript.fb        -side top -fill x
button .ctrl.tclscript.fb.read   -text "Source TCL script !" -state disabled -command {if {[file exists $tcl_file_name]} {source $tcl_file_name}}
pack   .ctrl.tclscript.fb.read   -side left -padx 5 -fill x


####################################
#  CREATE THE CODE SECTION         #
####################################

label       .code.rb.txt  -text "Code View:" -anchor w     -state disabled
pack        .code.rb.txt  -side left
radiobutton .code.rb.none -value "1" -text "None"          -state disabled -variable codeSelect  -command { updateCodeView $bin_file_name }
pack        .code.rb.none -side left
radiobutton .code.rb.asm  -value "2" -text "Assembler"     -state disabled -variable codeSelect  -command { updateCodeView $bin_file_name }
pack        .code.rb.asm  -side left
radiobutton .code.rb.mix  -value "3" -text "C & Assembler" -state disabled -variable codeSelect  -command { updateCodeView $bin_file_name }
pack        .code.rb.mix  -side left


scrollbar .code.xscroll -orient horizontal -command {.code.text xview}
pack      .code.xscroll -side bottom -fill both

scrollbar .code.yscroll -orient vertical   -command {.code.text yview}
pack      .code.yscroll -side right  -fill both

text      .code.text    -width 80 -borderwidth 2  -state disabled  -wrap none -setgrid true -font TkFixedFont \
                        -xscrollcommand {.code.xscroll set} -yscrollcommand {.code.yscroll set}
pack      .code.text    -side left   -fill both -expand true

.code.text tag config highlight -background yellow
