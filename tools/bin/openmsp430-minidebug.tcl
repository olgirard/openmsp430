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
global omsp_info
global cpu_status
global reg
global mem
global mem_sizes
global sr
global codeSelect
global binFileType
global brkpt
global color

# Color definitions
set color(PC)             "\#c1ffc1"
set color(Brk0_active)    "\#ba55d3"
set color(Brk0_disabled)  "\#dda0dd"
set color(Brk1_active)    "\#ff7256"
set color(Brk1_disabled)  "\#ffc1c1"
set color(Brk2_active)    "\#ffff30"
set color(Brk2_disabled)  "\#ffffe0"

# Initializations
set codeSelect    2
set serial_status 0
set cpu_status    1
for {set i 0} {$i<3} {incr i} {
    set brkpt(addr_$i)  0x0000
    set brkpt(data_$i)  0x0000
    set brkpt(en_$i)    0
}
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
    global brkpt
    global mem_sizes
    global color
    global omsp_info

    set serial_status [GetDevice]

    if {$serial_status} {
	set mem_sizes [GetCPU_ID_SIZE]

	if {[lindex $mem_sizes 0]==-1 | [lindex $mem_sizes 1]==-1} {
	    .ctrl.connect.info.l1.con     configure -text "Connection problem" -fg red

	} else {

	    # Disable connection section
	    .ctrl.connect.serial.p1       configure -state disabled	
	    .ctrl.connect.serial.p2       configure -state disabled
	    .ctrl.connect.serial.connect  configure -state disabled
	    if {$omsp_info(alias)==""} {
		.ctrl.connect.info.l1.con configure -text "Connected" -fg "\#00ae00"
	    } else {
		.ctrl.connect.info.l1.con configure -text "Connected to $omsp_info(alias)" -fg "\#00ae00"
	    }
	    .ctrl.connect.info.l1.more    configure -state normal

	    # Activate ELF file section
	    .ctrl.load.ft.l               configure -state normal
	    .ctrl.load.ft.file            configure -state normal
	    .ctrl.load.ft.browse          configure -state normal
	    .ctrl.load.fb.read            configure -state normal
	    .ctrl.load.fb.l               configure -state normal

	    # Activate CPU control section
	    .ctrl.cpu.cpu.l1              configure -state normal
	    .ctrl.cpu.cpu.reset           configure -state normal
	    .ctrl.cpu.cpu.run             configure -state normal
	    .ctrl.cpu.cpu.l2              configure -state normal
	    .ctrl.cpu.cpu.l3              configure -state normal
	    if {[IsHalted]} {
		.ctrl.cpu.cpu.step        configure -state normal
		.ctrl.cpu.cpu.run         configure -text "Run"
		.ctrl.cpu.cpu.l3          configure -text "Stopped" -fg "\#cdad00"
		set cpu_status 0
	    } else {
		.ctrl.cpu.cpu.step        configure -state disabled
		.ctrl.cpu.cpu.run         configure -text "Stop"
		.ctrl.cpu.cpu.l3          configure -text "Running" -fg "\#00ae00"
		set cpu_status 1
	    }

	    # Activate CPU Breakpoints section
     	    .ctrl.cpu.brkpt.l1                configure -state normal
	    for {set i 0} {$i<3} {incr i} {
		set brkpt(addr_$i)  [format "0x%04x" [expr 0x10000-[lindex $mem_sizes 0]]]
		.ctrl.cpu.brkpt.addr$i        configure -state normal
		.ctrl.cpu.brkpt.addr$i        configure -bg $color(Brk$i\_disabled)
		.ctrl.cpu.brkpt.addr$i        configure -readonlybackground $color(Brk$i\_active)
		.ctrl.cpu.brkpt.chk$i         configure -state normal
	    }

	    # Activate CPU status register section
	    .ctrl.cpu.reg_stat.l1             configure -state normal
	    .ctrl.cpu.reg_stat.v              configure -state normal
	    .ctrl.cpu.reg_stat.scg1           configure -state normal
	    .ctrl.cpu.reg_stat.oscoff         configure -state normal
	    .ctrl.cpu.reg_stat.cpuoff         configure -state normal
	    .ctrl.cpu.reg_stat.gie            configure -state normal
	    .ctrl.cpu.reg_stat.n              configure -state normal
	    .ctrl.cpu.reg_stat.z              configure -state normal
	    .ctrl.cpu.reg_stat.c              configure -state normal

	    # Activate CPU registers and memory section
	    .ctrl.cpu.reg_mem.reg.title.e     configure -state normal
	    .ctrl.cpu.reg_mem.mem.title.l     configure -state normal
	    .ctrl.cpu.reg_mem.mem.title.e     configure -state normal
	    .ctrl.cpu.reg_mem.reg.refresh     configure -state normal
	    .ctrl.cpu.reg_mem.mem.refresh     configure -state normal
	    for {set i 0} {$i<16} {incr i} {
		.ctrl.cpu.reg_mem.reg.f$i.l$i        configure -state normal
		.ctrl.cpu.reg_mem.reg.f$i.e$i        configure -state normal
		.ctrl.cpu.reg_mem.mem.f$i.addr_e$i   configure -state normal
		.ctrl.cpu.reg_mem.mem.f$i.data_e$i   configure -state normal
	    }
	    .ctrl.cpu.reg_mem.reg.f0.e0              configure -bg $color(PC)
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
	.ctrl.connect.info.l1.con         configure -text "Connection problem" -fg red
    }
}

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

proc highlightLine { line tagNameNew tagNameOld type } { 
    .code.text tag remove $tagNameOld 1.0     end
    .code.text tag remove $tagNameNew 1.0     end

    switch -exact -- $type {
	"0"     {.code.text tag add    $tagNameNew $line.0 $line.4}
	"1"     {.code.text tag add    $tagNameNew $line.2 $line.4}
	"2"     {.code.text tag add    $tagNameNew $line.3 $line.4}
	default {.code.text tag add    $tagNameNew $line.4 [expr $line+1].0}
    }
}

proc highlightCode   { } {
    global codeSelect
    global reg
    global brkpt
    global color

    if {$codeSelect!=1} {
	
	# Update PC
	regsub {0x} $reg(0) {} pc_val
	set code_match [.code.text search "$pc_val:" 1.0 end]
	set code_line 1
	regexp {(\d+).(\d+)} $code_match whole_match code_line code_column
	highlightLine $code_line highlightPC highlightPC 3
	.code.text see    $code_line.0

	# Some pre-processing
	set brkType(0) 0
	if {$brkpt(addr_0)==$brkpt(addr_1)} {
	    set brkType(1) 1
	} else {
	    set brkType(1) 0
	}
	if {$brkType(1)==1} {
	    if {$brkpt(addr_1)==$brkpt(addr_2)} {
		set brkType(2) 2
	    } else {
		set brkType(2) 0
	    }
	} else {
	    if {$brkpt(addr_0)==$brkpt(addr_2)} {
		set brkType(2) 1
	    } else {
		if {$brkpt(addr_1)==$brkpt(addr_2)} {
		    set brkType(2) 1
		} else {
		    set brkType(2) 0
		}
	    }
	}

	# Update Breakpoints if required
	for {set i 0} {$i<3} {incr i} {
	    regsub {0x} $brkpt(addr_$i) {} brkpt_val
	    set code_match [.code.text search "$brkpt_val:" 1.0 end]
	    set code_line 1
	    regexp {(\d+).(\d+)} $code_match whole_match code_line code_column
	    if {$brkpt(en_$i)==1} {
		highlightLine $code_line "highlightBRK${i}_ACT" "highlightBRK${i}_DIS" $brkType($i)
	    } else {
		highlightLine $code_line "highlightBRK${i}_DIS" "highlightBRK${i}_ACT" $brkType($i)
	    }
	}

     }
}

proc updateCodeView { bin_file_name } {
    global codeSelect
    global reg
    global binFileType
    global brkpt

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
	clearBreakpoints
	for {set i 0} {$i<3} {incr i} {
	    set brkpt(en_$i) 0
	    updateBreakpoint $i
	}

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
    highlightCode
    .code.text configure -state disabled
    return 1
}

proc loadProgram {bin_file_name} {
    global cpu_status
    global reg
    global mem
    global mem_sizes
    global binFileType
    global brkpt

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
    if {[lindex $mem_sizes 0] != [expr $hex_size/2]} {
	.ctrl.load.fb.l configure -text "ERROR: ELF program size ([expr $hex_size/2] B) is different than the available program memory ([lindex $mem_sizes 0] B)" -fg red
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
    .ctrl.load.fb.l configure -text "Load..." -fg "\#cdad00"
    update
    WriteMemQuick $StartAddr $DataArray

    # Check Data
    .ctrl.load.fb.l configure -text "Verify..." -fg "\#cdad00"
    update
    if {[VerifyMem $StartAddr $DataArray 1]} {
	.ctrl.load.fb.l configure -text "Done" -fg "\#00ae00"
    } else {
	.ctrl.load.fb.l configure -text "ERROR" -fg red
    }
    update

    # Re-initialize breakpoints
    for {set i 0} {$i<3} {incr i} {
	.ctrl.cpu.brkpt.addr$i  configure -state normal
	set brkpt(en_$i)    0
    }

    # Reset & Stop CPU
    ExecutePOR_Halt
    .ctrl.cpu.cpu.step  configure -state normal
    .ctrl.cpu.cpu.run   configure -text "Run"
    .ctrl.cpu.cpu.l3    configure -text "Stopped" -fg "\#cdad00"
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
	.ctrl.cpu.cpu.step  configure -state normal
	.ctrl.cpu.cpu.run   configure -text "Run"
	.ctrl.cpu.cpu.l3    configure -text "Stopped" -fg "\#cdad00"
	set cpu_status 0
    } else {
	clearBreakpoints
	StepCPU
	setBreakpoints
	ReleaseCPU
	.ctrl.cpu.cpu.step  configure -state disabled
	.ctrl.cpu.cpu.run   configure -text "Stop"
	.ctrl.cpu.cpu.l3    configure -text "Running" -fg "\#00ae00"
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
	clearBreakpoints
	StepCPU
	setBreakpoints
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
    highlightCode
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

proc updateBreakpoint {brkpt_num} {
    global brkpt
    global mem_sizes

    # Set the breakpoint
    if {$brkpt(en_$brkpt_num)==1} {
	    
	# Make sure the specified address is an opcode
	regsub {0x} $brkpt(addr_$brkpt_num) {} brkpt_val
	set code_match [.code.text search "$brkpt_val:" 1.0 end]
	if {![string length $code_match]} {
	    .ctrl.cpu.brkpt.addr$brkpt_num    configure -state normal
	    set brkpt(en_$brkpt_num) 0

	} else {
	    set brkpt(data_$brkpt_num) [ReadMem 0 $brkpt(addr_$brkpt_num)]
	    
	    # Only set a breakpoint if there is not already one there :-P
	    if {$brkpt(data_$brkpt_num)=="0x4343"} {
		.ctrl.cpu.brkpt.addr$brkpt_num    configure -state normal
		set brkpt(en_$brkpt_num) 0
	    } else {
		.ctrl.cpu.brkpt.addr$brkpt_num    configure -state readonly
		WriteMem 0 $brkpt(addr_$brkpt_num) 0x4343
	    }
	}

    # Clear the breakpoint
    } else {
	.ctrl.cpu.brkpt.addr$brkpt_num    configure -state normal
	WriteMem 0 $brkpt(addr_$brkpt_num) $brkpt(data_$brkpt_num)
    }

    highlightCode
}

proc clearBreakpoints {} {
    global brkpt
    global mem_sizes

    for {set i 0} {$i<3} {incr i} {
	if {$brkpt(en_$i)==1} {
	    WriteMem 0 $brkpt(addr_$i) $brkpt(data_$i)
	}
    }
}

proc setBreakpoints {} {
    global brkpt
    global mem_sizes

    for {set i 0} {$i<3} {incr i} {
	if {$brkpt(en_$i)==1} {
	    set brkpt(data_$i) [ReadMem 0 $brkpt(addr_$i)]
	    WriteMem 0 $brkpt(addr_$i) 0x4343
	}
    }
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

# Create the CPU Control field
frame  .ctrl
pack   .ctrl              -side left   -padx {5 0}   -pady 10      -fill both

# Create the Code text field
frame  .code
pack   .code              -side right  -padx 5       -pady 10      -fill both -expand true
frame  .code.rb
pack   .code.rb           -side bottom -padx 10      -pady 10      -fill both

# Create the connection frame
frame  .ctrl.connect        -bd 2 -relief ridge    ;# solid
pack   .ctrl.connect        -side top  -padx 10      -pady 0  -fill x

# Create the Serial Menu
frame  .ctrl.connect.serial
pack   .ctrl.connect.serial -side top  -padx 10      -pady {10 0}  -fill x

# Create the memory size
frame  .ctrl.connect.info
pack   .ctrl.connect.info   -side top  -padx 10      -pady {10 10} -fill x

# Create the Load executable field
frame  .ctrl.load         -bd 2 -relief ridge    ;# solid
pack   .ctrl.load         -side top    -padx 10      -pady {10 10} -fill x

# Create the cpu field
frame  .ctrl.cpu          -bd 2 -relief ridge    ;# solid
pack   .ctrl.cpu          -side top    -padx 10      -pady {0 10} -fill x

# Create the cpu control field
frame  .ctrl.cpu.cpu
pack   .ctrl.cpu.cpu      -side top    -padx 10      -pady {20 10} -fill x

# Create the breakpoint control field
frame  .ctrl.cpu.brkpt
pack   .ctrl.cpu.brkpt        -side top    -padx 10      -pady {10 20} -fill x

# Create the cpu status field
frame  .ctrl.cpu.reg_stat
pack   .ctrl.cpu.reg_stat     -side top    -padx 10      -pady {10 10} -fill x

# Create the cpu registers/memory fields
frame  .ctrl.cpu.reg_mem
pack   .ctrl.cpu.reg_mem      -side top    -padx 10      -pady {5 10}  -fill x
frame  .ctrl.cpu.reg_mem.reg
pack   .ctrl.cpu.reg_mem.reg  -side left   -padx {10 30}               -fill x
frame  .ctrl.cpu.reg_mem.mem
pack   .ctrl.cpu.reg_mem.mem  -side left   -padx {30 10}               -fill x

# Create the TCL script field
frame  .ctrl.tclscript        -bd 2 -relief ridge    ;# solid
pack   .ctrl.tclscript        -side top    -padx 10      -pady {0 20} -fill x


####################################
#  CREATE THE CPU CONTROL SECTION  #
####################################

# Exit button
button .menu.exit      -text "Exit" -command {exit 0}
pack   .menu.exit      -side left

# openMSP430 label
label  .menu.omsp      -text "openMSP430 mini debugger" -anchor center -fg "\#6a5acd" -font {-weight bold -size 16}
pack   .menu.omsp      -side right -padx 20 

# Serial Port fields
label    .ctrl.connect.serial.l1    -text "Serial Port:"  -anchor w
pack     .ctrl.connect.serial.l1    -side left
set serial_device      [lindex [dbg_list_uart] end]
combobox .ctrl.connect.serial.p1    -textvariable serial_device -editable true
eval     .ctrl.connect.serial.p1    list insert end [dbg_list_uart]
pack     .ctrl.connect.serial.p1    -side left -padx 5

label    .ctrl.connect.serial.l2    -text "  Baudrate:" -anchor w
pack     .ctrl.connect.serial.l2    -side left
set serial_baudrate    115200
combobox .ctrl.connect.serial.p2    -textvariable serial_baudrate -editable true
eval     .ctrl.connect.serial.p2    list insert end [list     9600    19200   38400  57600 115200 \
                                                    230400   460800  500000 576000 921600 \
                                                    1000000 1152000 2000000]
pack     .ctrl.connect.serial.p2    -side left -padx 5

button   .ctrl.connect.serial.connect -text "Connect" -width 9 -command {connect_openMSP430}
pack     .ctrl.connect.serial.connect -side right -padx 5

# CPU status & info
frame  .ctrl.connect.info.l1
pack   .ctrl.connect.info.l1      -side top    -padx 0      -pady {0 0} -fill x

label  .ctrl.connect.info.l1.cpu  -text "CPU Info:"       -anchor w
pack   .ctrl.connect.info.l1.cpu  -side left -padx "0 10"
label  .ctrl.connect.info.l1.con  -text "Disconnected"    -anchor w -fg Red
pack   .ctrl.connect.info.l1.con  -side left
button .ctrl.connect.info.l1.more -text "More..."         -width 9 -command {displayMore} -state disabled
pack   .ctrl.connect.info.l1.more -side right -padx 5


# Load ELF file fields
frame  .ctrl.load.ft
pack   .ctrl.load.ft        -side top -fill x -padx "10 0" -pady "10 0"
label  .ctrl.load.ft.l      -text "ELF file:"  -state disabled
pack   .ctrl.load.ft.l      -side left -padx "0 10"
entry  .ctrl.load.ft.file   -width 58 -relief sunken -textvariable bin_file_name -state disabled
pack   .ctrl.load.ft.file   -side left -padx 10
button .ctrl.load.ft.browse -text "Browse" -width 9 -state disabled -command {set bin_file_name [tk_getOpenFile -filetypes {{{ELF/Intel-Hex Files} {.elf .ihex .hex}} {{All Files} *}}]}
pack   .ctrl.load.ft.browse -side right -padx {5 15}
frame  .ctrl.load.fb
pack   .ctrl.load.fb        -side top -fill x -padx "10 0" -pady "5 10"
button .ctrl.load.fb.read   -text "Load ELF File !" -state disabled -command {loadProgram $bin_file_name}
pack   .ctrl.load.fb.read   -side left -padx 5 -fill x
label  .ctrl.load.fb.l      -text "Not loaded" -anchor w -fg Red  -state disabled
pack   .ctrl.load.fb.l      -side left

# CPU Control
label  .ctrl.cpu.cpu.l1     -text "CPU Control:" -anchor w  -state disabled
pack   .ctrl.cpu.cpu.l1     -side left
button .ctrl.cpu.cpu.reset  -text "Reset" -state disabled -command {resetCPU}
pack   .ctrl.cpu.cpu.reset  -side left -padx 5 -fill x
button .ctrl.cpu.cpu.run    -text "Stop"  -state disabled -command {runCPU}
pack   .ctrl.cpu.cpu.run    -side left -padx 5 -fill x
button .ctrl.cpu.cpu.step   -text "Step"  -state disabled -command {singleStepCPU}
pack   .ctrl.cpu.cpu.step   -side left -padx 5 -fill x
label  .ctrl.cpu.cpu.l2     -text "CPU Status:" -anchor w  -state disabled
pack   .ctrl.cpu.cpu.l2     -side left -padx "40 0"
label  .ctrl.cpu.cpu.l3     -text "--" -anchor w  -state disabled
pack   .ctrl.cpu.cpu.l3     -side left

# Breakpoints
label       .ctrl.cpu.brkpt.l1       -text "CPU Breakpoints:"    -anchor w  -state disabled
pack        .ctrl.cpu.brkpt.l1       -side left
entry       .ctrl.cpu.brkpt.addr0    -textvariable brkpt(addr_0) -relief sunken -state disabled  -width 10
pack        .ctrl.cpu.brkpt.addr0    -side left -padx "20 0"
bind        .ctrl.cpu.brkpt.addr0    <Return> "highlightCode"
checkbutton .ctrl.cpu.brkpt.chk0     -variable brkpt(en_0)       -state disabled -command "updateBreakpoint 0" -text "Enable"
pack        .ctrl.cpu.brkpt.chk0     -side left -padx "0"
entry       .ctrl.cpu.brkpt.addr1    -textvariable brkpt(addr_1) -relief sunken -state disabled  -width 10
pack        .ctrl.cpu.brkpt.addr1    -side left -padx "20 0"
bind        .ctrl.cpu.brkpt.addr1    <Return> "highlightCode"
checkbutton .ctrl.cpu.brkpt.chk1     -variable brkpt(en_1)       -state disabled -command "updateBreakpoint 1" -text "Enable"
pack        .ctrl.cpu.brkpt.chk1     -side left -padx "0"
entry       .ctrl.cpu.brkpt.addr2    -textvariable brkpt(addr_2) -relief sunken -state disabled  -width 10
pack        .ctrl.cpu.brkpt.addr2    -side left -padx "20 0"
bind        .ctrl.cpu.brkpt.addr2    <Return> "highlightCode"
checkbutton .ctrl.cpu.brkpt.chk2     -variable brkpt(en_2)       -state disabled -command "updateBreakpoint 2" -text "Enable"
pack        .ctrl.cpu.brkpt.chk2     -side left -padx "0"


# CPU Status register
label       .ctrl.cpu.reg_stat.l1     -text "Status register (r2/sr):" -anchor w -state disabled
pack        .ctrl.cpu.reg_stat.l1     -side left
checkbutton .ctrl.cpu.reg_stat.v      -variable sr(v)      -state disabled -command "statRegUpdate" -text "V"
pack        .ctrl.cpu.reg_stat.v      -side left -padx "0"
checkbutton .ctrl.cpu.reg_stat.scg1   -variable sr(scg1)   -state disabled -command "statRegUpdate" -text "SCG1"
pack        .ctrl.cpu.reg_stat.scg1   -side left -padx "0"
checkbutton .ctrl.cpu.reg_stat.oscoff -variable sr(oscoff) -state disabled -command "statRegUpdate" -text "OSCOFF"
pack        .ctrl.cpu.reg_stat.oscoff -side left -padx "0"
checkbutton .ctrl.cpu.reg_stat.cpuoff -variable sr(cpuoff) -state disabled -command "statRegUpdate" -text "CPUOFF"
pack        .ctrl.cpu.reg_stat.cpuoff -side left -padx "0"
checkbutton .ctrl.cpu.reg_stat.gie    -variable sr(gie)    -state disabled -command "statRegUpdate" -text "GIE"
pack        .ctrl.cpu.reg_stat.gie    -side left -padx "0"
checkbutton .ctrl.cpu.reg_stat.n      -variable sr(n)      -state disabled -command "statRegUpdate" -text "N"
pack        .ctrl.cpu.reg_stat.n      -side left -padx "0"
checkbutton .ctrl.cpu.reg_stat.z      -variable sr(z)      -state disabled -command "statRegUpdate" -text "Z"
pack        .ctrl.cpu.reg_stat.z      -side left -padx "0"
checkbutton .ctrl.cpu.reg_stat.c      -variable sr(c)      -state disabled -command "statRegUpdate" -text "C"
pack        .ctrl.cpu.reg_stat.c      -side left -padx "0"

# CPU Registers
frame  .ctrl.cpu.reg_mem.reg.title
pack   .ctrl.cpu.reg_mem.reg.title           -side top
label  .ctrl.cpu.reg_mem.reg.title.l         -text " " -width 8 -anchor w
pack   .ctrl.cpu.reg_mem.reg.title.l         -side left
label  .ctrl.cpu.reg_mem.reg.title.e         -text "Registers" -anchor w  -state disabled
pack   .ctrl.cpu.reg_mem.reg.title.e         -side left
for {set i 0} {$i<16} {incr i} {
    switch $i {
	{0}     {set reg_label "r0 (pc):"}
	{1}     {set reg_label "r1 (sp):"}
	{2}     {set reg_label "r2 (sr):"}
	default {set reg_label "r$i:"}
    }
    frame  .ctrl.cpu.reg_mem.reg.f$i
    pack   .ctrl.cpu.reg_mem.reg.f$i           -side top
    label  .ctrl.cpu.reg_mem.reg.f$i.l$i       -text $reg_label -width 8 -anchor w  -state disabled
    pack   .ctrl.cpu.reg_mem.reg.f$i.l$i       -side left
    entry  .ctrl.cpu.reg_mem.reg.f$i.e$i       -textvariable reg($i) -relief sunken -state disabled
    pack   .ctrl.cpu.reg_mem.reg.f$i.e$i       -side left
    bind   .ctrl.cpu.reg_mem.reg.f$i.e$i       <Return> "write2Reg $i"
}
button .ctrl.cpu.reg_mem.reg.refresh           -text "Refresh Registers"  -state disabled -command {refreshReg}
pack   .ctrl.cpu.reg_mem.reg.refresh           -side top -padx 5 -pady 10 -fill x -expand true


# CPU Memory
frame  .ctrl.cpu.reg_mem.mem.title
pack   .ctrl.cpu.reg_mem.mem.title             -side top
label  .ctrl.cpu.reg_mem.mem.title.l           -text "      Address      " -anchor w -width 20  -state disabled
pack   .ctrl.cpu.reg_mem.mem.title.l           -side left -fill x -expand true
label  .ctrl.cpu.reg_mem.mem.title.e           -text "        Data       " -anchor w -width 20  -state disabled
pack   .ctrl.cpu.reg_mem.mem.title.e           -side left -fill x -expand true
for {set i 0} {$i<16} {incr i} {
    frame  .ctrl.cpu.reg_mem.mem.f$i
    pack   .ctrl.cpu.reg_mem.mem.f$i           -side top

    entry  .ctrl.cpu.reg_mem.mem.f$i.addr_e$i  -textvariable mem(address_$i) -relief sunken -state disabled  -width 20
    pack   .ctrl.cpu.reg_mem.mem.f$i.addr_e$i  -side left
    bind   .ctrl.cpu.reg_mem.mem.f$i.addr_e$i  <Return> "refreshMem"
    entry  .ctrl.cpu.reg_mem.mem.f$i.data_e$i  -textvariable mem(data_$i)    -relief sunken -state disabled  -width 20
    pack   .ctrl.cpu.reg_mem.mem.f$i.data_e$i  -side left
    bind   .ctrl.cpu.reg_mem.mem.f$i.data_e$i  <Return> "write2Mem $i"
}
button .ctrl.cpu.reg_mem.mem.refresh -text "Refresh Memory"     -state disabled -command {refreshMem}
pack   .ctrl.cpu.reg_mem.mem.refresh -side top -padx 5 -pady 10 -fill x -expand true


# Load TCL script fields
frame  .ctrl.tclscript.ft
pack   .ctrl.tclscript.ft        -side top -padx {10 10} -pady {10 5} -fill x
label  .ctrl.tclscript.ft.l      -text "TCL script:" -state disabled
pack   .ctrl.tclscript.ft.l      -side left -padx "0 10"
entry  .ctrl.tclscript.ft.file   -width 58 -relief sunken -textvariable tcl_file_name -state disabled
pack   .ctrl.tclscript.ft.file   -side left -padx 10
button .ctrl.tclscript.ft.browse -text "Browse" -width 9 -state disabled -command {set tcl_file_name [tk_getOpenFile -filetypes {{{TCL Files} {.tcl}} {{All Files} *}}]}
pack   .ctrl.tclscript.ft.browse -side right -padx 5 
frame  .ctrl.tclscript.fb
pack   .ctrl.tclscript.fb        -side top -fill x
button .ctrl.tclscript.fb.read   -text "Source TCL script !" -state disabled -command {if {[file exists $tcl_file_name]} {source $tcl_file_name}}
pack   .ctrl.tclscript.fb.read   -side left -padx 15 -pady {0 10} -fill x


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

.code.text tag config highlightPC       -background $color(PC)
.code.text tag config highlightBRK0_ACT -background $color(Brk0_active)
.code.text tag config highlightBRK0_DIS -background $color(Brk0_disabled)
.code.text tag config highlightBRK1_ACT -background $color(Brk1_active)
.code.text tag config highlightBRK1_DIS -background $color(Brk1_disabled)
.code.text tag config highlightBRK2_ACT -background $color(Brk2_active)
.code.text tag config highlightBRK2_DIS -background $color(Brk2_disabled)


#######################################
#  PERIODICALLY CHECK THE CPU STATUS  #
#######################################

while 1 {

    # Wait 1 second
    set ::refresh_flag 0
    after 1000 set ::refresh_flag 1
    vwait refresh_flag

    # Check CPU status
    if {$serial_status} {
	if {$cpu_status} {
	    if {[IsHalted]} {
		.ctrl.cpu.cpu.step  configure -state normal
		.ctrl.cpu.cpu.run   configure -text "Run"
		.ctrl.cpu.cpu.l3    configure -text "Stopped" -fg "\#cdad00"
		set cpu_status 0
		refreshReg
		refreshMem
	    }
	}
    }
}

