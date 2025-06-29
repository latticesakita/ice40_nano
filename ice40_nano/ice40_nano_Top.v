module ice40_nano_Top (
	input rstn_i,
	input rxd_i,
	output txd_o,
	output[7:0] led_o
);

wire sys_clk;

HSOSC #(.CLKHF_DIV ("0b10")) osc0(.CLKHFEN (1'b1), .CLKHFPU(1'b1), .CLKHF(sys_clk));



ice40_nano ice40_nano_inst (
	.clk_i(sys_clk), 
	.rstn_i(rstn_i), 
	.uart_rxd_00_i(rxd_i),
	.uart_txd_00_o(txd_o),
	.gpio_00_i(),
	.gpio_en_00_o(),
	.gpio_00_o(led_o)
	);

endmodule
