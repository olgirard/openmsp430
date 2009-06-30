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

