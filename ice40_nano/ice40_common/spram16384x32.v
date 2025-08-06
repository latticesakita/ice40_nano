// instatiate SP256K

module spram16384x32 (
	input clk_i,
	input [13:0] addr_i  ,
	input wr_en_i    ,
	input [31:0] wr_data_i  ,
	output [31:0] rd_data_o  
);

SP256K u_spram16k_16_0 (
  .AD       (addr_i		),  // I
  .DI       (wr_data_i[15:0]	),  // I
  .MASKWE   (4'b1111		),  // I
  .WE       (wr_en_i		),  // I
  .CS       (1'b1		),  // I
  .CK       (clk_i		),  // I
  .STDBY    (1'b0		),  // I
  .SLEEP    (1'b0		),  // I
  .PWROFF_N (1'b1		),  // I
  .DO       (rd_data_o[15:0]	)   // O
);
SP256K u_spram16k_16_1 (
  .AD       (addr_i		),  // I
  .DI       (wr_data_i[31:16]	),  // I
  .MASKWE   (4'b1111		),  // I
  .WE       (wr_en_i		),  // I
  .CS       (1'b1		),  // I
  .CK       (clk_i		),  // I
  .STDBY    (1'b0		),  // I
  .SLEEP    (1'b0		),  // I
  .PWROFF_N (1'b1		),  // I
  .DO       (rd_data_o[31:16]	)   // O
);

endmodule
// vim:foldmethod=marker: 
