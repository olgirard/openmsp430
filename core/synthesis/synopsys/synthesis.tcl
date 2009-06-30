

#=============================================================================#
#                           Read technology library                           #
#=============================================================================#
source -echo -verbose ./library.tcl


#=============================================================================#
#                               Read design RTL                               #
#=============================================================================#
source -echo -verbose ./read.tcl


#=============================================================================#
#                           Set design constraints                            #
#=============================================================================#
source -echo -verbose ./constraints.tcl


#=============================================================================#
#              Set operating conditions & wire-load models                    #
#=============================================================================#

# Set operating conditions
set_operating_conditions -max $LIB_WC_OPCON -max_library $LIB_WC_NAME \
	                 -min $LIB_WC_OPCON -min_library $LIB_BC_NAME

# Set wire-load models
set_wire_load_mode top
set_wire_load_model -name $LIB_WIRE_LOAD -max -library $LIB_WC_NAME
set_wire_load_model -name $LIB_WIRE_LOAD -min -library $LIB_BC_NAME


#=============================================================================#
#                                Synthesize                                   #
#=============================================================================#

# Prevent assignment statements in the Verilog netlist.
set_fix_multiple_port_nets -all -buffer_constants

# Configure & Synthesize
current_design $DESIGN_NAME
set_max_area  0.0
set_flatten false
set_structure true -timing true -boolean false

compile -map_effort high -area_effort high
#compile_ultra -area_high_effort_script
#compile_ultra -area_high_effort_script -no_autoungroup -no_boundary_optimization


#=============================================================================#
#                            Reports generation                               #
#=============================================================================#

redirect ./results/report.timing         {check_timing}
redirect ./results/report.constraints    {report_constraints -all_violators -verbose}
redirect ./results/report.paths.max      {report_timing -path end  -delay max -max_paths 200 -nworst 2}
redirect ./results/report.full_paths.max {report_timing -path full -delay max -max_paths 5   -nworst 2}
redirect ./results/report.paths.min      {report_timing -path end  -delay min -max_paths 200 -nworst 2}
redirect ./results/report.full_paths.min {report_timing -path full -delay min -max_paths 5   -nworst 2}
redirect ./results/report.area           {report_area}
redirect ./results/report.refs           {report_reference}


#=============================================================================#
#                    Dump gate level netlist & final DDC file                 #
#=============================================================================#
current_design $DESIGN_NAME

write -hierarchy -format verilog -output "./results/$DESIGN_NAME.gate.v"
write -hierarchy -format ddc     -output "./results/$DESIGN_NAME.ddc"


quit
