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
