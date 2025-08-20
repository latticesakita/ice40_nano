// support only single write, single read
// HSIZE is for write operation is not supported
// HSIZE is only for read operation

module ahb_spsram_nano (
    input         HCLK,
    input         HRESETn,
    input  [31:0] HADDR,
    input  [2:0]  HBURST,
input  [1:0]  HTRANS,
input  [2:0]  HSIZE,
    input         HWRITE,
    input         HSEL,
    input         HREADY,
    input  [31:0] HWDATA,
    output [31:0] HRDATA,
    output        HREADYOUT,
    output        HRESP,

    output [31:0] sram_addr,
    output        sram_we,
    output [3:0]  sram_maskwe,
    output        sram_re,
    output [31:0] sram_din,
    input  [31:0] sram_dout,
    input         sram_write_done,
    input         sram_read_valid
);
    reg        sram_we_reg;
    reg        hreadyout_reg;
    //wire ahb_access = HSEL && HREADY && HTRANS[1];
    wire ahb_access;
assign ahb_access = HSEL && HTRANS[1];

    assign sram_addr = {2'b0,HADDR[31:2]};
    assign sram_we   = sram_we_reg;
    assign sram_re   = ahb_access & (~HWRITE);
    assign sram_din  = HWDATA;
    assign HRDATA    = sram_dout;
    assign sram_maskwe = (HSIZE[2:0] == 3'b000) ? (4'b0001 << HADDR[1:0]) :
			(HSIZE[2:0] == 3'b001) ? (4'b0011 << HADDR[1]*2) :
			4'b1111;

    assign HREADYOUT = hreadyout_reg| (sram_write_done|sram_read_valid);
    assign HRESP = 1'b0;


always @(posedge HCLK or negedge HRESETn) begin
	if (!HRESETn) begin
            sram_we_reg <= 1'b0;
	end
	else if (ahb_access) begin
            sram_we_reg <= HWRITE;
	end
	else begin
            sram_we_reg <= 1'b0;
	end
end
always @(posedge HCLK or negedge HRESETn) begin
	if (!HRESETn) begin
            hreadyout_reg <= 1'b1;
	end
	else if (ahb_access) begin
            hreadyout_reg <= 1'b0;
	end
	else if((~hreadyout_reg) && (sram_write_done|sram_read_valid) ) begin
            hreadyout_reg <= 1'b1;
	end
end

endmodule
