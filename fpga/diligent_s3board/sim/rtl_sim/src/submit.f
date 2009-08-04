//=============================================================================
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
//-----------------------------------------------------------------------------
// 
// File Name: submit.f
// 
// Author(s):
//             - Olivier Girard,    olgirard@gmail.com
//
//-----------------------------------------------------------------------------
// $Rev$
// $LastChangedBy$
// $LastChangedDate$
//=============================================================================

//=============================================================================
// Xilinx library
//=============================================================================
+libext+.v

-y /opt/Xilinx/10.1/ISE/verilog/src/unisims/
-y /opt/Xilinx/10.1/ISE/verilog/src/simprims/
-y /opt/Xilinx/10.1/ISE/verilog/src/XilinxCoreLib/


//=============================================================================
// FPGA Specific modules
//=============================================================================

+incdir+../../../rtl/verilog/
../../../rtl/verilog/openMSP430.inc
../../../rtl/verilog/openMSP430_fpga.v
../../../rtl/verilog/io_mux.v
../../../rtl/verilog/driver_7segment.v
../../../rtl/verilog/coregen/ram_8x512_hi.v
../../../rtl/verilog/coregen/ram_8x512_lo.v
../../../rtl/verilog/coregen/rom_8x2k_hi.v
../../../rtl/verilog/coregen/rom_8x2k_lo.v


//=============================================================================
// openMSP430
//=============================================================================

../../../../../core/rtl/verilog/openMSP430.v
../../../../../core/rtl/verilog/frontend.v
../../../../../core/rtl/verilog/execution_unit.v
../../../../../core/rtl/verilog/register_file.v
../../../../../core/rtl/verilog/alu.v
../../../../../core/rtl/verilog/mem_backbone.v
../../../../../core/rtl/verilog/clock_module.v
../../../../../core/rtl/verilog/sfr.v
../../../../../core/rtl/verilog/dbg.v
../../../../../core/rtl/verilog/dbg_hwbrk.v
../../../../../core/rtl/verilog/dbg_uart.v
../../../../../core/rtl/verilog/watchdog.v
../../../../../core/rtl/verilog/periph/gpio.v
../../../../../core/rtl/verilog/periph/timerA.v


//=============================================================================
// Testbench related
//=============================================================================

+incdir+../../../bench/verilog/
../../../bench/verilog/tb_openMSP430_fpga.v
../../../bench/verilog/msp_debug.v
../../../bench/verilog/glbl.v

