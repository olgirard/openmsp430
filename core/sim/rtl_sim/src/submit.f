//=============================================================================
// Module specific modules
//=============================================================================

+incdir+../../../rtl/verilog/
../../../rtl/verilog/openMSP430.inc
../../../rtl/verilog/openMSP430.v
../../../rtl/verilog/frontend.v
../../../rtl/verilog/execution_unit.v
../../../rtl/verilog/register_file.v
../../../rtl/verilog/alu.v
../../../rtl/verilog/mem_backbone.v
../../../rtl/verilog/clock_module.v
../../../rtl/verilog/sfr.v
../../../rtl/verilog/dbg.v
../../../rtl/verilog/dbg_hwbrk.v
../../../rtl/verilog/dbg_uart.v
../../../rtl/verilog/watchdog.v
../../../rtl/verilog/periph/gpio.v
../../../rtl/verilog/periph/timerA.v
../../../rtl/verilog/periph/template_periph_8b.v
../../../rtl/verilog/periph/template_periph_16b.v


//=============================================================================
// Testbench related
//=============================================================================

+incdir+../../../bench/verilog/
../../../bench/verilog/tb_openMSP430.v
../../../bench/verilog/ram.v
../../../bench/verilog/msp_debug.v
