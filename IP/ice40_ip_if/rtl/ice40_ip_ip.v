// support only single write, single read
// HSIZE is for write operation is not supported
// HSIZE is only for read operation

module ice40_ip_if (
    input         clk,
    input         resetn,
    output        int_o,

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

    output [7:0]	ip_addr_o,
    output [7:0]	ip_wdata_o,
    input [7:0]		ip_rdata_i,
    output		ip_we_o,
    output		ip_stb_o,
    input [1:0]		ip_int_i,
    input		ip_ack_i

);

reg [7:0] r_rdata;
reg       r_we;
reg       r_hready;
reg       r_stb;
wire      ahb_access;

assign HREADYOUT = r_hready;
assign HRDATA    = {24'b0, r_rdata[7:0]};
assign HRESP     = 1'b0;
assign ahb_access = HSEL && HTRANS[1];

assign ip_addr_o   = HADDR[9:2];
assign ip_wdata_o  = HWDATA[7:0];
assign ip_we_o     = HWRITE;
assign ip_stb_o    = r_stb;
assign int_o       = |ip_int_i;

always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_hready <= 1'b1;
		r_rdata  <= 8'h00;
		r_stb    <= 1'b0;
	end
	else if(ahb_access) begin
		r_hready <= 1'b0;
		r_rdata  <= 8'h00;
		r_stb    <= 1'b1;
	end
	else if((r_hready==1'b0)&&(ip_ack_i==1'b1)) begin
		r_hready <= 1'b1;
		r_rdata  <= ip_rdata_i[7:0];
		r_stb    <= 1'b0;
	end
end


endmodule
