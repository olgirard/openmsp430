##############################################################################
#                                                                            #
#                               READ DESING RTL                              #
#                                                                            #
##############################################################################

set DESIGN_NAME      "openMSP430"
set RTL_SOURCE_FILES {../../rtl/verilog/openMSP430.inc
                      ../../rtl/verilog/openMSP430.v
                      ../../rtl/verilog/cpu_frontend.v
                      ../../rtl/verilog/cpu_execution_unit.v
                      ../../rtl/verilog/cpu_register_file.v
                      ../../rtl/verilog/cpu_alu.v
                      ../../rtl/verilog/mem_backbone.v
                      ../../rtl/verilog/sfr.v
                      ../../rtl/verilog/watchdog.v
}

set_svf ./results/$DESIGN_NAME.svf
define_design_lib WORK -path ./WORK
analyze -format verilog $RTL_SOURCE_FILES

elaborate $DESIGN_NAME
link


# Check design structure after reading verilog
current_design $DESIGN_NAME
redirect ./results/report.check {check_design}
