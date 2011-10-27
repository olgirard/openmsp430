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
# File Name: server.tcl
# 
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#
#------------------------------------------------------------------------------
# $Rev$
# $LastChangedBy$
# $LastChangedDate$
#------------------------------------------------------------------------------

global clients
global server


###############################################################################
#                                                                             #
#                           START/STOP LOCAL SERVER                           #
#                                                                             #
###############################################################################

proc startServer { } {

    global server
    if {![info exists server(socket)]} {
	putsLog "Open socket on port $server(port) ... " 1
	if {[catch {socket -server clientAccept $server(port)} server(socket)]} {
	    putsLog "failed"
	    putsLog "ERROR: $server(socket)."
	    unset server(socket)
	    return 0
	}
	putsLog "done"
	putsLog "INFO: Waiting on TCP port $server(port)"
    } else {
	putsLog "Server is already up."
    }
    return 1
}

proc stopServer { } {
    global serial_status
    global server

    if {[info exists server(socket)]} {
	set port [lindex [fconfigure $server(socket) -sockname] 2]
	putsLog "Stop server (port $port)"
	close $server(socket)
	unset server(socket)
    }
    if {$serial_status} {
	ReleaseDevice 0xfffe
    }
}

proc clientAccept {sock addr port} {
    global clients

    putsLog "Accept client: $addr ($port)\n"

    set clients(addr,$sock) [list $addr $port]
    fconfigure $sock -buffering none
    fileevent  $sock readable [list receiveRSPpacket $sock]

    InitBreakUnits
}

proc startServerGUI { } {
    global serial_device
    global hw_break
    global omsp_info

    # Connect to device
    if {![GetDevice]} {
	.info.cpu.con   configure -text "Connection problem" -fg red
	putsLog "ERROR: Could not open \"$serial_device\""
    putsLog ""
    putsLog "         -------------------------------------------------------------"
    putsLog "       !!!! Please consider the following options:                  !!!!"
	putsLog "       !!!!                                                         !!!!"
	putsLog "       !!!!      - check the physical connection to the board.      !!!!"
	putsLog "       !!!!      - adjust the serial connection baudrate.           !!!!"
    putsLog "       !!!!      - don't forget to reset the serial debug interface !!!!"
    putsLog "       !!!!        between each attempt.                            !!!!"
    putsLog "         -------------------------------------------------------------"
    putsLog ""
	return 0
    }

    if {$omsp_info(alias)==""} {
	.info.cpu.con   configure -text "Connected" -fg "\#00ae00"
    } else {
	.info.cpu.con   configure -text "Connected to $omsp_info(alias)" -fg "\#00ae00"
    }

    # Display info
    putsLog "INFO: Sucessfully connected with the openMSP430 target."
    set sizes [GetCPU_ID_SIZE]
    if {$omsp_info(asic)} {
	putsLog "INFO: CPU Version              - $omsp_info(cpu_ver) / ASIC"
    } else {
	putsLog "INFO: CPU Version              - $omsp_info(cpu_ver) / FPGA"
    }
    putsLog "INFO: User Version             - $omsp_info(user_ver)"
    if {$omsp_info(cpu_ver)==1} {
	putsLog "INFO: Hardware Multiplier      - --"
    } elseif {$omsp_info(mpy)} {
	putsLog "INFO: Hardware Multiplier      - Yes"
    } else {
	putsLog "INFO: Hardware Multiplier      - No"
    }
    putsLog "INFO: Program Memory Size      - $omsp_info(pmem_size) B"
    putsLog "INFO: Data Memory Size         - $omsp_info(dmem_size) B"
    putsLog "INFO: Peripheral Address Space - $omsp_info(per_size) B"
    putsLog "INFO: $hw_break(num) Hardware Break/Watch-point unit(s) detected"
    putsLog ""

    # Activate Load TCL script section
    .tclscript.ft.l          configure -state normal
    .tclscript.ft.file       configure -state normal
    .tclscript.ft.browse     configure -state normal
    .tclscript.fb.read       configure -state normal

    # Activate extra cpu info button
    .info.cpu.more           configure -state normal

    # Reset & Stop CPU
    ExecutePOR_Halt

    # Start server for GDB
    if {![startServer]} {
	.info.server.con configure -text "Connection problem" -fg red
	return 0
    }
    .info.server.con     configure -text "Running" -fg "\#00ae00"

    # Disable gui entries
    .connect.config.serial_port.p1      configure -state disabled	
    .connect.config.serial_baudrate.p2  configure -state disabled
    .connect.config.server_port.p       configure -state disabled
    .connect.start.but                  configure -state disabled
}

###############################################################################
#                                                                             #
#                        RECEIVE / SEND RSP PACKETS                           #
#                                                                             #
###############################################################################

proc receiveRSPpacket {sock} {

    # Get client info
    set ip   [lindex [fconfigure $sock -peername] 0]
    set port [lindex [fconfigure $sock -peername] 2]

    # Check if a new packet arrives
    set rx_packet 0
    set rsp_cmd [getDebugChar $sock]
    set rsp_sum ""
    if {[string eq $rsp_cmd "\$"]} {
	set rx_packet 1
	set rsp_cmd ""
    } else {
	binary scan $rsp_cmd H* rsp_cmd
	if {$rsp_cmd=="03"} {
	    putsVerbose "--> BREAK"
	    HaltCPU
	}
    }
    # Receive packet
    while {$rx_packet} {
	set char [getDebugChar $sock]
	if {$char==-1} {
	    set    rx_packet 0
	} elseif {[string eq $char "\#"]} {
	    set    rx_packet 0
	    set    rsp_sum   [getDebugChar $sock]
	    append rsp_sum   [getDebugChar $sock]
 
	    # Re-calculate the checksum
	    set    tmp_sum   [RSPcheckSum  $rsp_cmd]

	    # Acknowledge and analyse the packet
	    if {[string eq $rsp_sum $tmp_sum]} {
		putDebugChar $sock "+"

		# Remove escape characters
		set rsp_cmd [removeEscapeChar $rsp_cmd]
		putsVerbose "+ w $rsp_cmd"

		# Parse packet and send back the answer
		set rsp_answer [rspParse $sock $rsp_cmd]
		if {$rsp_answer != "-1"} {
		    sendRSPpacket $sock $rsp_answer
		}
	    } else {
		putDebugChar $sock "-"
	    }
	} else {
	    append rsp_cmd $char
	}
    }
}


proc sendRSPpacket {sock rsp_cmd} {

    # Set escape characters
    set rsp_cmd [setEscapeChar $rsp_cmd]

    # Calculate checksum
    set rsp_sum [RSPcheckSum  $rsp_cmd]

    # Format the packet
    set rsp_packet "\$$rsp_cmd\#$rsp_sum"

    # Send the packet until the "+" aknowledge is received
    set send_ok 0
    while {!$send_ok} {
	putDebugChar $sock "$rsp_packet"
	set char [getDebugChar $sock]

	putsVerbose "$char r $rsp_cmd"

	if {$char==-1} {
	    set    send_ok 1
	} elseif {[string eq $char "+"]} {
	    set    send_ok 1
	}
    }
}


###############################################################################
#                                                                             #
#                   CHECKSUM / ESCAPE CHAR / RX / TX FUNCTIONS                #
#                                                                             #
###############################################################################

proc RSPcheckSum {rsp_cmd} {

    set    rsp_sum   0
    for {set i 0} {$i<[string length $rsp_cmd]} {incr i} {
	scan [string index $rsp_cmd $i] "%c" char_val
	set rsp_sum [expr $rsp_sum+$char_val]
    }
    set rsp_sum [format %02x [expr $rsp_sum%256]]

    return $rsp_sum
}

proc removeEscapeChar {rsp_cmd} {

    # Replace all '\}0x03' characters with '#'
    regsub -all "\}[binary format H* 03]" $rsp_cmd "\#" rsp_cmd

    # Replace all '\}0x04' characters with '$'
    regsub -all "\}[binary format H* 04]" $rsp_cmd "\$" rsp_cmd

    # Replace all '\}\]' characters with '\}'
    regsub -all "\}\]" $rsp_cmd "\}" rsp_cmd

    return "$rsp_cmd"
}

proc setEscapeChar {rsp_cmd} {

    # Escape all '\}' characters with '\}\]'
    regsub -all "\}" $rsp_cmd "\}\]" rsp_cmd

    # Escape all '$' characters with '\}0x04'
    regsub -all "\\$" $rsp_cmd "\}[binary format H* 04]" rsp_cmd

    # Escape all '#' characters with '\}0x03'
    regsub -all "\#" $rsp_cmd "\}[binary format H* 03]" rsp_cmd

    return "$rsp_cmd"
}


proc getDebugChar {sock} {
    global clients

    # Get client info
    set ip   [lindex [fconfigure $sock -peername] 0]
    set port [lindex [fconfigure $sock -peername] 2]

    if {[eof $sock] || [catch {set char [read $sock 1]}]} {
	# end of file or abnormal connection drop
	close $sock
	putsLog "Connection closed: $ip ($port)\n"
	unset clients(addr,$sock)
	return -1
    } else {
	return $char
    }
}


proc putDebugChar {sock char} {
    puts -nonewline $sock $char
}

###############################################################################
#                                                                             #
#                          GUI: DISPLAY EXTRA INFO                            #
#                                                                             #
###############################################################################

proc displayMore  { } {

    global omsp_info

    # Destroy windows if already existing
    if {[lsearch -exact [winfo children .] .omsp_extra_info]!=-1} {
	destroy .omsp_extra_info
    }

    # Create master window
    toplevel    .omsp_extra_info
    wm title    .omsp_extra_info "openMSP430 extra info"
    wm geometry .omsp_extra_info +380+200
    wm resizable .omsp_extra_info 0 0

    # Title
    set title "openMSP430"
    if {$omsp_info(alias)!=""} {
	set title $omsp_info(alias)
    }
    label  .omsp_extra_info.title  -text "$title"   -anchor center -fg "\#00ae00" -font {-weight bold -size 16}
    pack   .omsp_extra_info.title  -side top -padx {20 20} -pady {20 10}

    # Add extra info
    frame     .omsp_extra_info.extra
    pack      .omsp_extra_info.extra         -side top  -padx 10  -pady {10 10}
    scrollbar .omsp_extra_info.extra.yscroll -orient vertical   -command {.omsp_extra_info.extra.text yview}
    pack      .omsp_extra_info.extra.yscroll -side right -fill both
    text      .omsp_extra_info.extra.text    -wrap word -height 20 -font TkFixedFont -yscrollcommand {.omsp_extra_info.extra.yscroll set}
    pack      .omsp_extra_info.extra.text    -side right 

    # Create OK button
    button .omsp_extra_info.okay -text "OK" -font {-weight bold}  -command {destroy .omsp_extra_info}
    pack   .omsp_extra_info.okay -side bottom -expand true -fill x -padx 5 -pady {0 10}
    

    # Fill the text widget will configuration info
    .omsp_extra_info.extra.text tag configure bold -font {-family TkFixedFont -weight bold}
    .omsp_extra_info.extra.text insert end         "Configuration\n\n" bold
    .omsp_extra_info.extra.text insert end [format "CPU Version                : %5s\n" $omsp_info(cpu_ver)]
    .omsp_extra_info.extra.text insert end [format "User Version               : %5s\n" $omsp_info(user_ver)]
    if {$omsp_info(cpu_ver)==1} {
    .omsp_extra_info.extra.text insert end [format "Implementation             : %5s\n" --]
    } elseif {$omsp_info(asic)==0} {
    .omsp_extra_info.extra.text insert end [format "Implementation             : %5s\n" FPGA]
    } elseif {$omsp_info(asic)==1} {
    .omsp_extra_info.extra.text insert end [format "Implementation             : %5s\n" ASIC]
    }
    if {$omsp_info(mpy)==1} {
    .omsp_extra_info.extra.text insert end [format "Hardware Multiplier support: %5s\n" Yes]
    } elseif {$omsp_info(mpy)==0} {
    .omsp_extra_info.extra.text insert end [format "Hardware Multiplier support: %5s\n" No]
    } else {
    .omsp_extra_info.extra.text insert end [format "Hardware Multiplier support: %5s\n" --]
    }
    .omsp_extra_info.extra.text insert end [format "Program memory size        : %5s B\n" $omsp_info(pmem_size)]
    .omsp_extra_info.extra.text insert end [format "Data memory size           : %5s B\n" $omsp_info(dmem_size)]
    .omsp_extra_info.extra.text insert end [format "Peripheral address space   : %5s B\n" $omsp_info(per_size)]
    if {$omsp_info(alias)==""} {
    .omsp_extra_info.extra.text insert end [format "Alias                      : %5s\n\n\n" None]
    } else {
    .omsp_extra_info.extra.text insert end [format "Alias                      : %5s\n\n\n" $omsp_info(alias)]
    }

    .omsp_extra_info.extra.text insert end         "Extra Info\n\n" bold

    if {$omsp_info(alias)!=""} {

	set aliasEXTRA  [lsort -increasing [array names omsp_info -glob "extra,*"]]
	if {[llength $aliasEXTRA]} {

	    foreach currentEXTRA $aliasEXTRA {
		regexp {^.+,.+,(.+)$} $currentEXTRA whole_match extraATTR
		.omsp_extra_info.extra.text insert end     [format "%-15s: %s\n" $extraATTR  $omsp_info($currentEXTRA)]
	    }
	    .omsp_extra_info.extra.text insert end         "\n\n"
	}
    } else {
	.omsp_extra_info.extra.text insert end  "No alias found in 'omsp_alias.xml' file"
    }
}
