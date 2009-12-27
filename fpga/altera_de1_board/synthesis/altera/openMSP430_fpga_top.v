//----------------------------------------------------------------------------
// Copyright (C) 2001 Authors
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//----------------------------------------------------------------------------
//
// *File Name: openMSP430_fpga_top.v
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 23 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2009-08-30 18:39:26 +0200 (Sun, 30 Aug 2009) $
//----------------------------------------------------------------------------

//=============================================================================
// FPGA Specific modules
//=============================================================================

`include "../../../rtl/verilog/openMSP430_fpga.v"
`include "../../../rtl/verilog/io_mux.v"
`include "../../../rtl/verilog/driver_7segment.v"
`include "../../../rtl/verilog/ram16x512.v"    // altera DE1 specific modules
`include "../../../rtl/verilog/rom16x2048.v"   //
`include "../../../rtl/verilog/ext_de1_sram.v" //


//=============================================================================
// openMSP430
//=============================================================================

`include "../../../rtl/verilog/openmsp430/openMSP430.v"
`include "../../../rtl/verilog/openmsp430/frontend.v"
`include "../../../rtl/verilog/openmsp430/execution_unit.v"
`include "../../../rtl/verilog/openmsp430/register_file.v"
`include "../../../rtl/verilog/openmsp430/alu.v"
`include "../../../rtl/verilog/openmsp430/mem_backbone.v"
`include "../../../rtl/verilog/openmsp430/clock_module.v"
`include "../../../rtl/verilog/openmsp430/dbg.v"
`include "../../../rtl/verilog/openmsp430/dbg_hwbrk.v"
`include "../../../rtl/verilog/openmsp430/dbg_uart.v"
`include "../../../rtl/verilog/openmsp430/sfr.v"
`include "../../../rtl/verilog/openmsp430/watchdog.v"
`include "../../../rtl/verilog/openmsp430/periph/gpio.v"
`include "../../../rtl/verilog/openmsp430/periph/timerA.v"

