#!/usr/bin/tclsh
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
# File Name: openmsp430-gdbproxy.tcl
# 
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#
#------------------------------------------------------------------------------
# $Rev$
# $LastChangedBy$
# $LastChangedDate$
#------------------------------------------------------------------------------

global serial_baudrate
global serial_device
global serial_status
global hw_break
global clients
global server
global verbose
global shell
global omsp_info

# Initializations
set serial_status 0


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

# Source remaining files
source [file dirname $current_file]/../openmsp430-gdbproxy/server.tcl
source [file dirname $current_file]/../openmsp430-gdbproxy/commands.tcl


###############################################################################
#                                                                             #
#                            PARAMETER CHECK                                  #
#                                                                             #
###############################################################################

proc help {} {
    puts ""
    puts "USAGE   : openmsp430-gdbproxy.tcl \[-device   <communication device>\]"
    puts "                                  \[-baudrate <communication speed>\]"
    puts "                                  \[-port     <server port>\]"
    puts "                                  \[-shell]"
    puts "                                  \[-verbose\]"
    puts "                                  \[-help\]"
    puts ""
    puts "Examples: openmsp430-gdbproxy.tcl -device /dev/ttyUSB0 -baudrate  9600  -port 2000"
    puts "          openmsp430-gdbproxy.tcl -device COM2:        -baudrate 38400  -port 2000"
    puts ""
}

# Default values
set serial_device   [lindex [dbg_list_uart] end]
set serial_baudrate 115200
set server(port)    2000
set shell           0
set verbose         0

# Parse arguments
for {set i 0} {$i < $argc} {incr i} {
    switch -exact -- [lindex $argv $i] {
	-device   {set serial_device   [lindex $argv [expr $i+1]]; incr i}
	-baudrate {set serial_baudrate [lindex $argv [expr $i+1]]; incr i}
	-port     {set server(port)    [lindex $argv [expr $i+1]]; incr i}
	-shell    {set shell   1}
	-verbose  {set verbose 1}
	-h        {help; exit 0}
	-help     {help; exit 0}
	default   {}
    }
}

# Source additional library for graphical interface
if {!$shell} {
    source $lib_path/combobox.tcl
    package require combobox 2.3
    catch {namespace import combobox::*}
}

# Small functions to display messages
proc putsLog {string {nonewline 0}} {
    global server
    global shell
    if {$shell} {
	if {$nonewline} {
	    puts -nonewline $string
	} else {
	    puts $string
	}
    } else {
	if {$nonewline} {
	    $server(log) insert end "$string"
	} else {
	    $server(log) insert end "$string\n"
	}
	$server(log) see end
    }
}
proc putsVerbose {string} {
    global verbose
    if {$verbose} {
	putsLog "$string"
    }
}

###############################################################################
#                               SHELL MODE                                    #
###############################################################################
if {$shell} {

    # Connect to device
    if {![GetDevice]} {
	puts "ERROR: Could not open $serial_device"
	puts "INFO:  Available serial ports are:"
	foreach port [dbg_list_uart] {
	    puts "INFO:                               -  $port"
	}
	exit 1
    }

    # Display info
    if {$omsp_info(alias)==""} {
	puts "INFO: Sucessfully connected with the openMSP430 target."
    } else {
	puts "INFO: Sucessfully connected with the openMSP430 target ($omsp_info(alias))."
    }
    set sizes [GetCPU_ID_SIZE]
    if {$omsp_info(asic)} {
	puts "INFO: CPU Version              - $omsp_info(cpu_ver) / ASIC"
    } else {
	puts "INFO: CPU Version              - $omsp_info(cpu_ver) / FPGA"
    }
    puts "INFO: User Version             - $omsp_info(user_ver)"
    if {$omsp_info(cpu_ver)==1} {
	puts "INFO: Hardware Multiplier      - --"
    } elseif {$omsp_info(mpy)} {
	puts "INFO: Hardware Multiplier      - Yes"
    } else {
	puts "INFO: Hardware Multiplier      - No"
    }
    puts "INFO: Program Memory Size      - $omsp_info(pmem_size) B"
    puts "INFO: Data Memory Size         - $omsp_info(dmem_size) B"
    puts "INFO: Peripheral Address Space - $omsp_info(per_size) B"
    puts "INFO: $hw_break(num) Hardware Brea/Watch-point unit(s) detected"
    puts ""

    # Reset & Stop CPU
    ExecutePOR_Halt

    # Start server for GDB
    if {![startServer]} {
	exit 1
    }

    vwait forever
}


###############################################################################
#                                 GUI MODE                                    #
###############################################################################

####################################
#   CREATE & PLACE MAIN WIDGETS    #
####################################

wm title    . "openMSP430 GDB Proxy"
wm iconname . "openMSP430 GDB Proxy"

# Create the Main Menu frame
frame  .menu
pack   .menu   -side top -padx 10 -pady 10 -fill x

# Create the Connection frame
frame  .connect -bd 2 -relief ridge    ;# solid
pack   .connect -side top -padx 10 -pady {5 0} -fill x

# Create the Info frame
frame  .info    -bd 2 -relief ridge    ;# solid
pack   .info    -side top -padx 10 -pady {10 0} -fill x

# Create the Server frame
frame  .server -bd 2 -relief ridge    ;# solid
pack   .server -side top -padx 10 -pady {10 0} -fill x

# Create the TCL script field
frame  .tclscript -bd 2 -relief ridge    ;# solid
pack   .tclscript -side top -padx 10 -pady 10 -fill x


####################################
#  CREATE THE REST                 #
####################################

# Exit button
button .menu.exit -text "Exit" -command {stopServer; exit 0}
pack   .menu.exit -side left

# openMSP430 label
label  .menu.omsp      -text "openMSP430 GDB proxy" -anchor center -fg "\#6a5acd" -font {-weight bold -size 14}
pack   .menu.omsp      -side right -padx 20 

# Create the Configuration, Start & Info frames
frame  .connect.config
pack   .connect.config -side left   -padx 10 -pady 0 -fill x -expand true
frame  .connect.start
pack   .connect.start  -side right  -padx 10 -pady 0 -fill x -expand true

# Serial Port fields
set serial_device      [lindex [dbg_list_uart] end]
frame    .connect.config.serial_port
pack     .connect.config.serial_port     -side top   -padx 5 -pady {10 0} -fill x
label    .connect.config.serial_port.l1  -text "Serial Port:"  -anchor w
pack     .connect.config.serial_port.l1  -side left  -padx 5
combobox .connect.config.serial_port.p1  -textvariable serial_device -editable true -width 20
eval     .connect.config.serial_port.p1  list insert end [dbg_list_uart]
pack     .connect.config.serial_port.p1  -side right -padx 20

# Serial Baudrate fields
set serial_baudrate    115200
frame    .connect.config.serial_baudrate
pack     .connect.config.serial_baudrate     -side top  -padx 5 -pady {5 0} -fill x
label    .connect.config.serial_baudrate.l2  -text "  Baudrate:" -anchor w
pack     .connect.config.serial_baudrate.l2  -side left
combobox .connect.config.serial_baudrate.p2  -textvariable serial_baudrate -editable true -width 20
eval     .connect.config.serial_baudrate.p2  list insert end [list    9600   19200  38400  57600 115200 \
                                                                    230400  460800 500000 576000 921600 \
                                                                   1000000 1152000]
pack     .connect.config.serial_baudrate.p2  -side right -padx 20

# Server Port field
frame    .connect.config.server_port
pack     .connect.config.server_port    -side top   -padx 10 -pady {15 10} -fill x
label    .connect.config.server_port.l1 -text "Proxy Server Port:" -anchor w
pack     .connect.config.server_port.l1 -side left
entry    .connect.config.server_port.p  -textvariable server(port) -relief sunken -width 20
pack     .connect.config.server_port.p  -side right -padx 5 -padx 20


# Connect to CPU & start proxy server
button .connect.start.but -text "Connect to CPU\n and \nStart Proxy Server" -command {startServerGUI}
pack   .connect.start.but -side right -padx 30


# CPU Info
frame  .info.cpu
pack   .info.cpu      -side top   -padx 10 -pady {5 0} -fill x
label  .info.cpu.l    -text "CPU Info:"       -anchor w
pack   .info.cpu.l    -side left -padx {10 10}
label  .info.cpu.con  -text "Disconnected"    -anchor w -fg Red
pack   .info.cpu.con  -side left
button .info.cpu.more -text "More..."         -width 9 -command {displayMore} -state disabled
pack   .info.cpu.more -side right -padx {0 30}


# Server Info
frame  .info.server
pack   .info.server     -side top   -padx 10 -pady {0 10} -fill x
label  .info.server.l   -text "Server Info:"       -anchor w
pack   .info.server.l   -side left -padx {10 10}
label  .info.server.con -text "Not running"    -anchor w -fg Red
pack   .info.server.con -side left


# Create the text widget to log received messages
frame  .server.t
pack   .server.t     -side top -padx 10 -pady 10 -fill x
set server(log) [text   .server.t.log -width 80 -height 15 -borderwidth 2  \
                          -setgrid true -yscrollcommand {.server.t.scroll set}]
pack   .server.t.log -side left  -fill both -expand true
scrollbar .server.t.scroll -command {.server.t.log yview}
pack   .server.t.scroll -side right -fill both


# Log commands
frame  .server.cmd
pack   .server.cmd   -side top  -pady {0 10} -fill x
button .server.cmd.clear -text "Clear log" -command {$server(log) delete 1.0 end}
pack   .server.cmd.clear -side left -padx 10
checkbutton .server.cmd.verbose -text "Verbose" -variable verbose
pack   .server.cmd.verbose -side right -padx 10


# Load TCL script fields
frame  .tclscript.ft
pack   .tclscript.ft        -side top  -padx 10  -pady 10 -fill x
label  .tclscript.ft.l      -text "TCL script:" -state disabled
pack   .tclscript.ft.l      -side left -padx "0 10"
entry  .tclscript.ft.file   -width 58 -relief sunken -textvariable tcl_file_name -state disabled
pack   .tclscript.ft.file   -side left -padx 10
button .tclscript.ft.browse -text "Browse" -state disabled -command {set tcl_file_name [tk_getOpenFile -filetypes {{{TCL Files} {.tcl}} {{All Files} *}}]}
pack   .tclscript.ft.browse -side left -padx 5 
frame  .tclscript.fb
pack   .tclscript.fb        -side top -fill x
button .tclscript.fb.read   -text "Source TCL script !" -state disabled -command {if {[file exists $tcl_file_name]} {source $tcl_file_name}}
pack   .tclscript.fb.read   -side left -padx 20  -pady {0 10} -fill x

wm resizable . 0 0
