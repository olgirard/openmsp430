# Design Constraints

define_clock   {oscclk}       -name {oscclk }  -freq 50  -rise 0.0  -fall 10
define_clock   {n:pll_0.GLA}  -name {dco_clk}  -freq 16  -rise 0.0  -fall 31.25

define_input_delay   -default  15.00 -improve 0.00 -route 0.00
define_output_delay  -default   8.00 -improve 0.00 -route 0.00

define_false_path  -from {{p:pbrst_n}} 
define_false_path  -from {{p:porst_n}} 
