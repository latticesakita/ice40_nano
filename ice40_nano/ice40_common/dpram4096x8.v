module dpram4096x8 (
	input wr_clk_i,
	input rd_clk_i,
	input wr_clk_en_i,
	input rd_en_i    ,
	input rd_clk_en_i,
	input wr_en_i    ,
	input [7:0] wr_data_i  ,
	input [11:0] wr_addr_i  ,
	input [11:0] rd_addr_i  ,
	output [7:0] rd_data_o  
);

wire wr_en_0 = wr_en_i & (~wr_addr_i[11]);
wire wr_en_1 = wr_en_i & ( wr_addr_i[11]);
wire [7:0] rd_data_0;
wire [7:0] rd_data_1;
reg rd_addr_i_11_d;
assign rd_data_o = rd_addr_i_11_d ? rd_data_1 : rd_data_0;

always @(posedge rd_clk_i) begin
	rd_addr_i_11_d <= rd_addr_i[11];
end

sub_dpram2048x8 u_ram2048x8_0 (
	.wr_clk_i   (wr_clk_i),
	.rd_clk_i   (rd_clk_i),
	.wr_clk_en_i(wr_clk_en_i),
	.rd_en_i    (rd_en_i),
	.rd_clk_en_i(rd_clk_en_i),
	.wr_en_i    (wr_en_0),
	.wr_data_i  (wr_data_i),
	.wr_addr_i  (wr_addr_i[10:0]),
	.rd_addr_i  (rd_addr_i[10:0]),
	.rd_data_o  (rd_data_0)
    );
sub_dpram2048x8 u_ram2048x8_1 (
	.wr_clk_i   (wr_clk_i),
	.rd_clk_i   (rd_clk_i),
	.wr_clk_en_i(wr_clk_en_i),
	.rd_en_i    (rd_en_i),
	.rd_clk_en_i(rd_clk_en_i),
	.wr_en_i    (wr_en_1),
	.wr_data_i  (wr_data_i),
	.wr_addr_i  (wr_addr_i[10:0]),
	.rd_addr_i  (rd_addr_i[10:0]),
	.rd_data_o  (rd_data_1)
    );

endmodule

module sub_dpram2048x8 (
	input wr_clk_i,
	input rd_clk_i,
	input wr_clk_en_i,
	input rd_en_i    ,
	input rd_clk_en_i,
	input wr_en_i    ,
	input [7:0] wr_data_i  ,
	input [10:0] wr_addr_i  ,
	input [10:0] rd_addr_i  ,
	output [7:0] rd_data_o  
);

PDP4K #(
	.DATA_WIDTH_W	( "2" ),
	.DATA_WIDTH_R	( "2" )
) 	dpram_0 (
		.ADW	(wr_addr_i),
		.ADR	(rd_addr_i),
		.CKW	(wr_clk_i),
		.CKR	(rd_clk_i),
		.CEW	(wr_clk_en_i),
		.CER	(rd_clk_en_i),
		.RE	(rd_en_i),
		.WE	(wr_en_i),
		.MASK_N	(0),
		.DI	(wr_data_i[ 1 : 0 ]),
		.DO	(rd_data_o[ 1 : 0 ])
);
PDP4K #(
	.DATA_WIDTH_W	( "2" ),
	.DATA_WIDTH_R	( "2" )
) 	dpram_1 (
		.ADW	(wr_addr_i),
		.ADR	(rd_addr_i),
		.CKW	(wr_clk_i),
		.CKR	(rd_clk_i),
		.CEW	(wr_clk_en_i),
		.CER	(rd_clk_en_i),
		.RE	(rd_en_i),
		.WE	(wr_en_i),
		.MASK_N	(0),
		.DI	(wr_data_i[ 3 : 2 ]),
		.DO	(rd_data_o[ 3 : 2 ])
);
PDP4K #(
	.DATA_WIDTH_W	( "2" ),
	.DATA_WIDTH_R	( "2" )
) 	dpram_2 (
		.ADW	(wr_addr_i),
		.ADR	(rd_addr_i),
		.CKW	(wr_clk_i),
		.CKR	(rd_clk_i),
		.CEW	(wr_clk_en_i),
		.CER	(rd_clk_en_i),
		.RE	(rd_en_i),
		.WE	(wr_en_i),
		.MASK_N	(0),
		.DI	(wr_data_i[ 5 : 4 ]),
		.DO	(rd_data_o[ 5 : 4 ])
);
PDP4K #(
	.DATA_WIDTH_W	( "2" ),
	.DATA_WIDTH_R	( "2" )
) 	dpram_3 (
		.ADW	(wr_addr_i),
		.ADR	(rd_addr_i),
		.CKW	(wr_clk_i),
		.CKR	(rd_clk_i),
		.CEW	(wr_clk_en_i),
		.CER	(rd_clk_en_i),
		.RE	(rd_en_i),
		.WE	(wr_en_i),
		.MASK_N	(0),
		.DI	(wr_data_i[ 7 : 6 ]),
		.DO	(rd_data_o[ 7 : 6 ])
);
endmodule


