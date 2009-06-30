##############################################################################
#                                                                            #
#                            CLOCK DEFINITION                                #
#                                                                            #
##############################################################################

#set CLOCK_PERIOD 50.0; #  20 MHz
#set CLOCK_PERIOD 40.0; #  25 MHz
#set CLOCK_PERIOD 30.0; #  33 MHz
#set CLOCK_PERIOD 25.0; #  40 MHz
set CLOCK_PERIOD 20.0; #  50 MHz
#set CLOCK_PERIOD 15.0; #  66 MHz
#set CLOCK_PERIOD 10.0; # 100 MHz
#set CLOCK_PERIOD  8.0; # 125 MHz


create_clock -name     "clock"                                \
             -period   "$CLOCK_PERIOD"                        \
             -waveform "[expr $CLOCK_PERIOD/2] $CLOCK_PERIOD" \
            [get_ports clock]


##############################################################################
#                                                                            #
#                          CREATE PATH GROUPS                                #
#                                                                            #
##############################################################################

group_path -name REGOUT      -to   [all_outputs] 
group_path -name REGIN       -from [remove_from_collection [all_inputs] [get_ports clock]]
group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] [get_ports clock]] -to [all_outputs]


##############################################################################
#                                                                            #
#                          BOUNDARY TIMINGS                                  #
#                                                                            #
##############################################################################
# NOTE: There are some path through between RAM and ROM signals.
#       If required you might want to relax the constrains a bit.

#===============#
# INPUT PORTS   #
#===============#

set IRQ_DLY          [expr ($CLOCK_PERIOD/100) * 30]
set NMI_DLY          [expr ($CLOCK_PERIOD/100) * 10]

set PER_DOUT_DLY     [expr ($CLOCK_PERIOD/100) * 20]
set RAM_DOUT_DLY     [expr ($CLOCK_PERIOD/100) * 20]
set ROM_DOUT_DLY     [expr ($CLOCK_PERIOD/100) * 20]

set RESET_N_DLY      [expr ($CLOCK_PERIOD/100) * 75]


set_input_delay $IRQ_DLY       -max -clock "clock"             [get_ports irq]
set_input_delay 0              -min -clock "clock"             [get_ports irq]

set_input_delay $NMI_DLY       -max -clock "clock"             [get_ports nmi]
set_input_delay 0              -min -clock "clock"             [get_ports nmi]

set_input_delay $PER_DOUT_DLY  -max -clock "clock"             [get_ports per_dout]
set_input_delay 0              -min -clock "clock"             [get_ports per_dout]

set_input_delay $RAM_DOUT_DLY  -max -clock "clock"             [get_ports ram_dout]
set_input_delay 0              -min -clock "clock"             [get_ports ram_dout]

set_input_delay $ROM_DOUT_DLY  -max -clock "clock"             [get_ports rom_dout]
set_input_delay 0              -min -clock "clock"             [get_ports rom_dout]

set_input_delay $RESET_N_DLY   -max -clock "clock" -clock_fall [get_ports reset_n]
set_input_delay 0              -min -clock "clock" -clock_fall [get_ports reset_n]


#===============#
# OUTPUT PORTS  #
#===============#

set PER_ADDR_DLY     [expr ($CLOCK_PERIOD/100) * 25]
set PER_DIN_DLY      [expr ($CLOCK_PERIOD/100) * 25]
set PER_WEN_DLY      [expr ($CLOCK_PERIOD/100) * 25]
set PER_8B_CEN_DLY   [expr ($CLOCK_PERIOD/100) * 25]
set PER_16B_CEN_DLY  [expr ($CLOCK_PERIOD/100) * 25]

set RAM_ADDR_DLY     [expr ($CLOCK_PERIOD/100) * 20]
set RAM_CEN_DLY      [expr ($CLOCK_PERIOD/100) * 20]
set RAM_DIN_DLY      [expr ($CLOCK_PERIOD/100) * 20]
set RAM_WEN_DLY      [expr ($CLOCK_PERIOD/100) * 20]

set ROM_ADDR_DLY     [expr ($CLOCK_PERIOD/100) * 20]
set ROM_CEN_DLY      [expr ($CLOCK_PERIOD/100) * 20]

set MRST_DLY         [expr ($CLOCK_PERIOD/100) * 75]


set_output_delay $PER_ADDR_DLY     -add_delay -max -clock "clock"             [get_ports per_addr]
set_output_delay 0                            -min -clock "clock"             [get_ports per_addr]

set_output_delay $PER_DIN_DLY      -add_delay -max -clock "clock"             [get_ports per_din]
set_output_delay 0                            -min -clock "clock"             [get_ports per_din]

set_output_delay $PER_WEN_DLY      -add_delay -max -clock "clock"             [get_ports per_wen]
set_output_delay 0                            -min -clock "clock"             [get_ports per_wen]

set_output_delay $PER_8B_CEN_DLY   -add_delay -max -clock "clock"             [get_ports per_8b_cen]
set_output_delay 0                            -min -clock "clock"             [get_ports per_8b_cen]

set_output_delay $PER_16B_CEN_DLY  -add_delay -max -clock "clock"             [get_ports per_16b_cen]
set_output_delay 0                            -min -clock "clock"             [get_ports per_16b_cen]

set_output_delay $RAM_ADDR_DLY     -add_delay -max -clock "clock"             [get_ports ram_addr]
set_output_delay 0                            -min -clock "clock"             [get_ports ram_addr]

set_output_delay $RAM_CEN_DLY      -add_delay -max -clock "clock"             [get_ports ram_cen]
set_output_delay 0                            -min -clock "clock"             [get_ports ram_cen]

set_output_delay $RAM_DIN_DLY      -add_delay -max -clock "clock"             [get_ports ram_din]
set_output_delay 0                            -min -clock "clock"             [get_ports ram_din]

set_output_delay $RAM_WEN_DLY      -add_delay -max -clock "clock"             [get_ports ram_wen]
set_output_delay 0                            -min -clock "clock"             [get_ports ram_wen]

set_output_delay $ROM_ADDR_DLY     -add_delay -max -clock "clock"             [get_ports rom_addr]
set_output_delay 0                            -min -clock "clock"             [get_ports rom_addr]

set_output_delay $ROM_CEN_DLY      -add_delay -max -clock "clock"             [get_ports rom_cen]
set_output_delay 0                            -min -clock "clock"             [get_ports rom_cen]

set_output_delay $MRST_DLY         -add_delay -max -clock "clock" -clock_fall [get_ports mrst]
set_output_delay 0                            -min -clock "clock" -clock_fall [get_ports mrst]


#========================#
# FEEDTHROUGH EXCEPTIONS #
#========================#

#set_max_delay [expr 2.0 + $RAM_DOUT_DLY + $RAM_ADDR_DLY] \
#              -from       [get_ports ram_dout]            \
#              -to         [get_ports ram_addr]            \
#              -group_path FEEDTHROUGH

