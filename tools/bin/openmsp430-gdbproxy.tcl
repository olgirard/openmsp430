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
#------------------------------------------------------------------------------

global serial_baudrate
global serial_device
global serial_status
global hw_break
global clients
global server
global verbose
global shell

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
    puts "INFO: Sucessfully connected with the openMSP430 target."
    set sizes [GetCPU_ID_SIZE]
    puts "INFO: ROM Size - [lindex $sizes 0] B"
    puts "INFO: RAM Size - [lindex $sizes 1] B"
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

# Create the Main Menu budget
frame  .menu
pack   .menu   -side top -padx 10 -pady 10 -fill x

# Create the Serial port Menu budget
frame  .serial
pack   .serial -side top -padx 10 -pady 10 -fill x

# Create the Server Menu budget
frame  .server
pack   .server -side top -padx 10 -pady 10 -fill x


####################################
#  CREATE THE REST                 #
####################################

# Exit button
button .menu.exit -text "Exit" -command {stopServer; exit 0}
pack   .menu.exit -side left


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
label  .serial.l3      -text "Disconnected" -anchor w -fg Red
pack   .serial.l3      -side left -padx 10


# Server Port field
frame  .server.port
pack   .server.port    -side top -fill x
label  .server.port.l1 -text "Proxy Server Port:" -anchor w
pack   .server.port.l1 -side left
entry  .server.port.p  -textvariable server(port) -relief sunken
pack   .server.port.p  -side left -padx 5
label  .server.port.l2 -text "Not running" -anchor w -fg Red
pack   .server.port.l2 -side left -padx 10
button .server.port.start -text "Start Proxy Server" -command {startServerGUI}
pack   .server.port.start -side right


# Create the text widget to log received messages
frame  .server.t
pack   .server.t     -side top -padx 10 -pady 10 -fill x
set server(log) [text   .server.t.log -width 80 -height 10 -borderwidth 2  \
                          -setgrid true -yscrollcommand {.server.t.scroll set}]
pack   .server.t.log -side left  -fill both -expand true
scrollbar .server.t.scroll -command {.server.t.log yview}
pack   .server.t.scroll -side right -fill both -expand true


# Log commands
frame  .server.cmd
pack   .server.cmd   -side top -fill x
button .server.cmd.clear -text "Clear log" -command {$server(log) delete 1.0 end}
pack   .server.cmd.clear -side left -padx 10
checkbutton .server.cmd.verbose -text "Verbose" -variable verbose
pack   .server.cmd.verbose -side right -padx 10
