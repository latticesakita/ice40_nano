create_clock -name {osc0/CLKHF} -period 41.6666666666667 [get_pins osc0/CLKHF]
create_clock -name {ice40_nano_inst/pll0_inst/outglobal_o} -period 20.8333333333333 [get_pins gpll_i/lscc_pll_inst/outcore_o]
