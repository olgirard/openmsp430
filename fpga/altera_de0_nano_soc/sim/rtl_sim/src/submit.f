//=============================================================================
// Copyright (C) 2016 Authors
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
// $Rev: 136 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2012-03-22 22:14:16 +0100 (Thu, 22 Mar 2012) $
//=============================================================================

//=============================================================================
// Testbench related
//=============================================================================

+incdir+../../../bench/verilog/
../../../bench/verilog/tb_openMSP430_fpga.v
../../../bench/verilog/msp_debug.v



//=============================================================================
// Altera library
//=============================================================================
+libext+.v

../../../bench/verilog/altsyncram.v
../../../bench/verilog/cyclonev_io.v


//=============================================================================
// FPGA Specific modules
//=============================================================================

+incdir+../../../rtl/verilog/
../../../rtl/verilog/openMSP430_fpga.v
../../../rtl/verilog/omsp_de0_nano_soc_led_key_sw.v
../../../rtl/verilog/sync_debouncer_10ms.v
../../../rtl/verilog/mega/ram_16x75k.v
../../../rtl/verilog/mega/ram_16x512.v
../../../rtl/verilog/mega/ram_16x16k.v
../../../rtl/verilog/mega/ram_16x8k.v
../../../rtl/verilog/mega/io_buf.v
../../../rtl/verilog/mega/in_buf.v

//=============================================================================
// openMSP430
//=============================================================================

+incdir+../../../rtl/verilog/openmsp430/
+incdir+../../../rtl/verilog/openmsp430/periph/

../../../rtl/verilog/openmsp430/openMSP430.v
../../../rtl/verilog/openmsp430/omsp_frontend.v
../../../rtl/verilog/openmsp430/omsp_execution_unit.v
../../../rtl/verilog/openmsp430/omsp_register_file.v
../../../rtl/verilog/openmsp430/omsp_alu.v
../../../rtl/verilog/openmsp430/omsp_sfr.v
../../../rtl/verilog/openmsp430/omsp_mem_backbone.v
../../../rtl/verilog/openmsp430/omsp_clock_module.v
../../../rtl/verilog/openmsp430/omsp_dbg.v
../../../rtl/verilog/openmsp430/omsp_dbg_hwbrk.v
../../../rtl/verilog/openmsp430/omsp_dbg_uart.v
../../../rtl/verilog/openmsp430/omsp_dbg_i2c.v
../../../rtl/verilog/openmsp430/omsp_watchdog.v
../../../rtl/verilog/openmsp430/omsp_multiplier.v
../../../rtl/verilog/openmsp430/omsp_sync_reset.v
../../../rtl/verilog/openmsp430/omsp_sync_cell.v
../../../rtl/verilog/openmsp430/omsp_scan_mux.v
../../../rtl/verilog/openmsp430/omsp_and_gate.v
../../../rtl/verilog/openmsp430/omsp_wakeup_cell.v
../../../rtl/verilog/openmsp430/omsp_clock_gate.v
../../../rtl/verilog/openmsp430/omsp_clock_mux.v

../../../rtl/verilog/openmsp430/periph/omsp_timerA.v

//=============================================================================
// openGFX430
//=============================================================================

+incdir+../../../rtl/verilog/opengfx430/

../../../rtl/verilog/opengfx430/openGFX430.v
../../../rtl/verilog/opengfx430/ogfx_reg.v
../../../rtl/verilog/opengfx430/ogfx_reg_fifo.v
../../../rtl/verilog/opengfx430/ogfx_reg_vram_if.v
../../../rtl/verilog/opengfx430/ogfx_reg_vram_addr.v
../../../rtl/verilog/opengfx430/ogfx_if_lt24.v
../../../rtl/verilog/opengfx430/ogfx_backend.v
../../../rtl/verilog/opengfx430/ogfx_backend_frame_fifo.v
../../../rtl/verilog/opengfx430/ogfx_backend_lut_fifo.v
../../../rtl/verilog/opengfx430/ogfx_gpu.v
../../../rtl/verilog/opengfx430/ogfx_gpu_reg.v
../../../rtl/verilog/opengfx430/ogfx_gpu_dma.v
../../../rtl/verilog/opengfx430/ogfx_gpu_dma_addr.v
../../../rtl/verilog/opengfx430/ogfx_ram_arbiter.v
