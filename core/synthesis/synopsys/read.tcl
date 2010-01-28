##############################################################################
#                                                                            #
#                               READ DESING RTL                              #
#                                                                            #
##############################################################################

set DESIGN_NAME      "openMSP430"
set RTL_SOURCE_FILES {../../rtl/verilog/openMSP430.v
                      ../../rtl/verilog/omsp_frontend.v
                      ../../rtl/verilog/omsp_execution_unit.v
                      ../../rtl/verilog/omsp_register_file.v
                      ../../rtl/verilog/omsp_alu.v
                      ../../rtl/verilog/omsp_sfr.v
                      ../../rtl/verilog/omsp_clock_module.v
                      ../../rtl/verilog/omsp_mem_backbone.v
                      ../../rtl/verilog/omsp_watchdog.v
                      ../../rtl/verilog/omsp_dbg.v
                      ../../rtl/verilog/omsp_dbg_uart.v
                      ../../rtl/verilog/omsp_dbg_hwbrk.v
}


set_svf ./results/$DESIGN_NAME.svf
define_design_lib WORK -path ./WORK
analyze -format verilog $RTL_SOURCE_FILES

elaborate $DESIGN_NAME
link


# Check design structure after reading verilog
current_design $DESIGN_NAME
redirect ./results/report.check {check_design}
