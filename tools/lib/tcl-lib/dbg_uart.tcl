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
# File Name:   dbg_uart.tcl
#
# Description: Some UART utility functions for the openMSP430 serial debug
#             interface:
#
#               - dbg_uart_connect    (Device,       Baudrate)
#               - dbg_uart_tx         (Data)
#               - dbg_uart_rx         (Format,       Length)
#               - dbg_uart_rd         (RegisterName)
#               - dbg_uart_wr         (RegisterName, Data)
#               - dbg_uart_format_cmd (RegisterName, Action)
#               - dbg_list_uart       ()
# 
#------------------------------------------------------------------------------

global serial

#=============================================================================#
# dbg_uart_connect (Device, Baudrate)                                         #
#-----------------------------------------------------------------------------#
# Description: Open the UART connection with the openMSP430 serial debug      #
#              interface. It also sends the synchronisation frame if required.#
# Arguments  : Device   - Serial port device (i.e. /dev/ttyS0 or COM2:)       #
#              Baudrate - UART communication speed.                           #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc dbg_uart_connect {Device Baudrate} {
    
    global serial

    if {$serial==""} {
	# Open device for reading and writing
	if {[catch {open $Device RDWR} serial]} {
	    set serial ""
	    return 0
	}
 
	# Setup the baud rate
	fconfigure $serial -mode "$Baudrate,n,8,1"
    
	# Block on read, don't buffer output
	fconfigure $serial -blocking 1 -buffering none -translation binary -timeout 1000
    }

    # Send synchronisation frame
    dbg_uart_tx {0x80}

    # Send dummy frame in case the debug interface is already synchronized
    dbg_uart_tx {0xC0}
    dbg_uart_tx {0x00}

    return 1
}


#=============================================================================#
# dbg_uart_tx (Data)                                                          #
#-----------------------------------------------------------------------------#
# Description: Transmit data over the serial debug interface.                 #
# Arguments  : Data - Data byte list to be sent.                              #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc dbg_uart_tx {Data} {

    global serial

    foreach char [split $Data] {
	# Check data format
	if {![regsub {0x} $char {} char]} {
	    set char [format %x $char]
	}
	# Send data
	puts -nonewline $::serial [binary format H* $char]
    }
    flush $serial

    return 1
}


#=============================================================================#
# dbg_uart_rx (Format, Length)                                                #
#-----------------------------------------------------------------------------#
# Description: Receive data from the serial debug interface.                  #
# Arguments  : Format - 0 format as 16 bit word, 1 format as 8 bit word.      #
#              Length - Number of byte to be received.                        #
# Result     : List of received values, in hexadecimal.                       #
#=============================================================================#
proc dbg_uart_rx {Format Length} {

    global serial

    set rx_data [read $::serial $Length]

    set hex_data ""
    foreach char [split $rx_data {}] {
	binary scan $char H* hex_char
	lappend hex_data $hex_char
    }

    # Format data
    if {$Format==0} {
	set num_byte 2
    } else {
	set num_byte 1
    }
    set formated_data ""
    for {set i 0} {$i<[expr $Length/$num_byte]} {incr i} {

	set data ""
	for {set j $num_byte} {$j>0} {set j [expr $j-1]} {
	    append data [lindex $hex_data [expr ($i*$num_byte)+$j-1]]
	}
	lappend formated_data "0x$data"
    }

    return $formated_data
}


#=============================================================================#
# dbg_uart_rd (RegisterName)                                                  #
#-----------------------------------------------------------------------------#
# Description: Read the specified debug register.                             #
# Arguments  : RegisterName - Name of the register to be read.                #
# Result     : Register content, in hexadecimal.                              #
#=============================================================================#
proc dbg_uart_rd {RegisterName} {

    global serial

    # Send command frame
    set cmd [dbg_uart_format_cmd $RegisterName RD]
    dbg_uart_tx $cmd

    # Compute size of data to be received
    if [string eq [expr 0x40 & $cmd] 64] {
	set format 1
	set length 1
    } else {
	set format 0
	set length 2
    }

    # Receive data
    set rx_data [dbg_uart_rx $format $length]

    return $rx_data
}

#=============================================================================#
# dbg_uart_wr (RegisterName, Data)                                            #
#-----------------------------------------------------------------------------#
# Description: Write to the specified debug register.                         #
# Arguments  : RegisterName - Name of the register to be written.             #
#              Data         - Data to be written.                             #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc dbg_uart_wr {RegisterName Data} {

    global serial

    # Send command frame
    set cmd [dbg_uart_format_cmd $RegisterName WR]
    dbg_uart_tx $cmd

    # Format input data
    if {![regexp {0x} $Data match]} {
	set Data [format "0x%x" $Data]
    }
    set hex_val [format %04x $Data]
    regexp {(..)(..)} $hex_val match hex_msb hex_lsb

    # Compute size of data to be sent
    if [string eq [expr 0x40 & $cmd] 64] {
	set size 1
    } else {
	set size 2
    }

    # Send data
    dbg_uart_tx "0x$hex_lsb"
    if {$size==2} {
	dbg_uart_tx "0x$hex_msb"
    }

    return 1
}

#=============================================================================#
# dbg_uart_format_cmd (RegisterName, Action)                                  #
#-----------------------------------------------------------------------------#
# Description: Get the correcponding UART command to a given debug register   #
#              access.                                                        #
# Arguments  : RegisterName - Name of the register to be accessed.            #
#              Action       - RD for read / WR for write.                     #
# Result     : Command to be sent via UART.                                   #
#=============================================================================#
proc dbg_uart_format_cmd {RegisterName Action} {

    switch -exact $Action {
	RD         {set rd_wr "0x00"}
	WR         {set rd_wr "0x080"}
	default    {set rd_wr "0x00"}
    }

    switch -exact $RegisterName {
	CPU_ID_LO  {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x00]]}
	CPU_ID_HI  {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x01]]}
	CPU_CTL    {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x02]]}
	CPU_STAT   {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x03]]}
	MEM_CTL    {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x04]]}
	MEM_ADDR   {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x05]]}
	MEM_DATA   {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x06]]}
	MEM_CNT    {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x07]]}
	BRK0_CTL   {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x08]]}
	BRK0_STAT  {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x09]]}
	BRK0_ADDR0 {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x0A]]}
	BRK0_ADDR1 {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x0B]]}
	BRK1_CTL   {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x0C]]}
	BRK1_STAT  {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x0D]]}
	BRK1_ADDR0 {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x0E]]}
	BRK1_ADDR1 {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x0F]]}
	BRK2_CTL   {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x10]]}
	BRK2_STAT  {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x11]]}
	BRK2_ADDR0 {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x12]]}
	BRK2_ADDR1 {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x13]]}
	BRK3_CTL   {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x14]]}
	BRK3_STAT  {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x15]]}
	BRK3_ADDR0 {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x16]]}
	BRK3_ADDR1 {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x17]]}
	default    {set uart_cmd  "0x00"}
    }

    return $uart_cmd
}


#=============================================================================#
# dbg_list_uart ()                                                            #
#-----------------------------------------------------------------------------#
# Description: Return the available serial ports (works on both linux and     #
#              windows.                                                       #
# Arguments  : None.                                                          #
# Result     : List of the available serial ports.                            #
#=============================================================================#
proc dbg_list_uart {} {

    set serial_ports ""

    switch $::tcl_platform(os) {
	{Linux}      {
	              set dmesg        ""
     	              catch {exec dmesg} dmesg
	              while {[regexp {ttyS\d+?} $dmesg match]} {
			  regsub $match $dmesg {} dmesg
			  if { [lsearch -exact $serial_ports "/dev/$match"] == -1 } {
			      lappend serial_ports "/dev/$match"
			  }
		      }
	              while {[regexp {ttyUSB\d+?} $dmesg match]} {
			  regsub $match $dmesg {} dmesg
			  if { [lsearch -exact $serial_ports "/dev/$match"] == -1 } {
			      lappend serial_ports "/dev/$match"
			  }
		      }
                      if {![llength $serial_ports]} {
			  set serial_ports [list /dev/ttyS0 /dev/ttyS1 /dev/ttyS2 /dev/ttyS3]
		      }
	}
	{Windows NT} {
	              package require registry
                      set serial_base "HKEY_LOCAL_MACHINE\\HARDWARE\\DEVICEMAP\\SERIALCOMM"
                      set values [registry values $serial_base]
	              foreach valueName $values {
			  lappend serial_ports "[registry get $serial_base $valueName]:"
		      }
	}
	default      {set serial_ports ""}
    }

    return $serial_ports
}


###############################################################################
#                         INITIALIZE VARIABLES                                #
###############################################################################
if {![info exist serial]} {
    set serial ""
}