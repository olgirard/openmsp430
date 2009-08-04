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
// $Rev$
// $LastChangedBy$
// $LastChangedDate$
//----------------------------------------------------------------------------

//=============================================================================
// FPGA Specific modules
//=============================================================================

`include "../../../rtl/verilog/openMSP430.inc"
`include "../../../rtl/verilog/openMSP430_fpga.v"
`include "../../../rtl/verilog/io_mux.v"
`include "../../../rtl/verilog/driver_7segment.v"
`include "../../../rtl/verilog/coregen/ram_8x512_hi.v"
`include "../../../rtl/verilog/coregen/ram_8x512_lo.v"
`include "../../../rtl/verilog/coregen/rom_8x2k_hi.v"
`include "../../../rtl/verilog/coregen/rom_8x2k_lo.v"


//=============================================================================
// openMSP430
//=============================================================================

`include "../../../../../core/rtl/verilog/openMSP430.v"
`include "../../../../../core/rtl/verilog/frontend.v"
`include "../../../../../core/rtl/verilog/execution_unit.v"
`include "../../../../../core/rtl/verilog/register_file.v"
`include "../../../../../core/rtl/verilog/alu.v"
`include "../../../../../core/rtl/verilog/mem_backbone.v"
`include "../../../../../core/rtl/verilog/clock_module.v"
`include "../../../../../core/rtl/verilog/dbg.v"
`include "../../../../../core/rtl/verilog/dbg_hwbrk.v"
`include "../../../../../core/rtl/verilog/dbg_uart.v"
`include "../../../../../core/rtl/verilog/sfr.v"
`include "../../../../../core/rtl/verilog/watchdog.v"
`include "../../../../../core/rtl/verilog/periph/gpio.v"
`include "../../../../../core/rtl/verilog/periph/timerA.v"
