
`timescale 1 ns / 100 ps

module tb;

// GSR GSR_INST (.GSR_N(1'b1));
// PUR PUR_INST (.PUR(1'b1));

parameter FREQ = 12.0;
parameter PERIOD = 1000.0 / FREQ;

reg rstn;
reg clk;

initial begin
	rstn <= 0;
	#100 rstn <= 1;
end
initial begin
	clk = 1'b0;
	forever #(PERIOD/2) clk = ~clk;
end

wire uart_rx;
wire uart_tx;
wire [15:0] led;
wire [1:0] scl_io;
wire [1:0] sda_io;
wire       scl_i3c_io;
wire       sda_i3c_io;
wire spi_cs  ;
wire spi_clk ;
wire spi_mosi;
wire spi_miso;

pullup(uart_rx);
pullup(scl_io[0]);
pullup(scl_io[1]);
pullup(scl_i3c_io);
pullup(sda_io[0]);
pullup(sda_io[1]);
pullup(sda_i3c_io);
pullup(led[0]);
pullup(led[1]);
pullup(led[2]);
pullup(led[3]);
pullup(led[4]);
pullup(led[5]);
pullup(led[6]);
pullup(led[7]);
pullup(led[8]);
pullup(led[9]);
pullup(led[10]);
pullup(led[11]);
pullup(led[12]);
pullup(led[13]);
pullup(led[14]);
pullup(led[15]);
pullup(spi_miso);
pullup(spi_mosi);

ice40_nano_Top dut (
	//.rstn_i	(rstn),
	.rxd_i	(uart_rx),
	//.clk12m	(clk),
	.txd_o	(uart_tx),
	.led_o	(led[7:0]),
	.spi_cs  	(spi_cs  ),
	.spi_clk 	(spi_clk ), 
	.spi_miso	(spi_miso),
	.spi_mosi	(spi_mosi) 
);
// SPI Flash 
spi_flash spi_flash_i (
	.clk		(spi_clk),
	.cs		(spi_cs),
	.miso		(spi_miso),
	.mosi		(spi_mosi)
);

endmodule

