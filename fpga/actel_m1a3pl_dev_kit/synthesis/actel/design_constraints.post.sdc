# Design Constraints

create_clock -name oscclk  -period 20.0 -waveform [list 0.0 10.0]  oscclk
create_clock -name dco_clk -period 62.5 -waveform [list 0.0 31.25] pll_0:GLA

set_false_path -from {pbrst_n}
set_false_path -from {porst_n}
