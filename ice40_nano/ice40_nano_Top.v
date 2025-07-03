module ice40_nano_Top (
	input rxd_i,
	output txd_o,
	inout [7:0] led_o
);

reg [3:0] r_rst_cnt;
wire oclk;
wire clk_soc;
wire resetn;
wire resetn_soc;
wire gpll_lock;

assign resetn = r_rst_cnt[3];
assign resetn_soc = gpll_lock;

always @(posedge oclk) begin
	if(!resetn) begin
		r_rst_cnt <= r_rst_cnt + 1;
	end
end

HSOSC #(.CLKHF_DIV ("0b10")) osc0(.CLKHFEN (1'b1), .CLKHFPU(1'b1), .CLKHF(oclk));

gpll gpll_i (
        .rst_n_i	(resetn), 
        .lock_o		(gpll_lock), 
        .outcore_o	(), 
        .outglobal_o	(clk_soc)
);

ice40_nano ice40_nano_inst (
	.clk_i(clk_soc), 
	.rstn_i(resetn_soc), 
	.uart_rxd_00_i(rxd_i),
	.uart_txd_00_o(txd_o),
	.gpio0_io(led_o)
	);

endmodule
