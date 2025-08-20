
// 8'b0000_0000: i2c command write/read value
// 8'b0000_0100: interrupt & status
//		  bit0: r_start_done
//		  bit1: r_byte_done
//                  bit2: r_stop_done
//                  bit3: 0
//                  bit4: ack status
// 8'b0000_1000: trigger to start processing, bit0: start, bit1: byte, bit2: stop
// 8'b0000_1100: rsvd
// 8'b0001_0000: T_HD_START_CLKS	// hold time of START condition
// 8'b0001_0100: T_LOW_CLKS		// minimum 1.3us
// 8'b0001_1000: T_HIGH_CLKS		// minimum 0.6us
// 8'b0001_1100: T_SU_START_CLKS	// setup time for repeated START condition
// 8'b0010_0000: T_SU_DATA_CLKS	// data hold time, 100ns
// 8'b0010_0100: T_HD_DATA_CLKS	// data hold time, 100ns
// 8'b0010_1000: T_SU_STOP_CLKS	// setup time for STOP condition
// 8'b0010_1100: T_BUF_CLKS		// bus free time btween STOP and START, min 1.3us

//`define REMOVE_TRI_STATE_BUFFER_I2C_CONT

`define AHBL_IF

module i2c_controller #(
	parameter NOISE_FILTER		= "EN",
	parameter CLK_FREQ_HZ		= 32'd24_000_000,
	parameter T_HD_START_CLKS	= 19, //   800 * CLK_FREQ_HZ /1000_000_000,	// hold time of START condition
	parameter T_LOW_CLKS		= 33, // 1_380 * CLK_FREQ_HZ /1000_000_000,	// minimum 1.3us
	parameter T_HIGH_CLKS		= 23, //   960 * CLK_FREQ_HZ /1000_000_000,	// minimum 0.6us
	parameter T_SU_START_CLKS	= 19, //   800 * CLK_FREQ_HZ /1000_000_000,	// setup time for repeated START condition
	parameter T_SU_STOP_CLKS	= 19, //   800 * CLK_FREQ_HZ /1000_000_000,	// setup time for STOP condition
	parameter T_BUF_CLKS		= 36, // 1_500 * CLK_FREQ_HZ /1000_000_000,	// bus free time btween STOP and START, min 1.3us
	parameter COUNTER_SIZE		= 8 // number of bits
)
(
`ifdef REMOVE_TRI_STATE_BUFFER_I2C_CONT
	input		scl_i,
	input		sda_i,
	output		scl_low_o,
	output		sda_low_o,
`else
	inout		scl_io,
	inout		sda_io,
`endif
	output		int_o,

`ifdef AHBL_IF
	input [31:0]	ahbl_haddr_i,	// AHB address
	input [ 2:0]	ahbl_hburst_i,	// unused
	output [31:0]	ahbl_hrdata_o,	// AHB read data
	input [ 2:0]	ahbl_hsize_i,	// unused
	input [ 1:0]	ahbl_htrans_i,	// AHB transfer type
	input [31:0]	ahbl_hwdata_i,	// AHB write data
	input		ahbl_hready_i,	// unused
	output		ahbl_hreadyout_o,	// AHB ready signal
	output		ahbl_hresp_o,	// unused
	input		ahbl_hsel_i,		// AHB select
	input		ahbl_hwrite_i,	// AHB write enable
`else
        input		apb_penable_i, 
        input		apb_psel_i, 
        input		apb_pwrite_i, 
        input	[31:0]	apb_paddr_i, 
        input	[31:0]	apb_pwdata_i, 
        output	[31:0]	apb_prdata_o, 
        output		apb_pslverr_o, 
        output		apb_pready_o,
`endif

	input		clk_i,
	input		resetn_i
);

assign ahbl_hresp_o = 1'b0;

// I/F independent signals
reg [31:0]	r_rdata_o;
wire [31:0]     w_wdata_i;
wire [3:0] w_addr;
wire w_re;
wire w_we;

`ifdef AHBL_IF
// AHBL I/F {{{
// AHBL
reg r_we;
assign ahbl_hresp_o = 1'b0;
assign w_addr = ahbl_haddr_i[5:2]; // same as LMMI
assign w_re = (ahbl_hsel_i && ahbl_htrans_i[1] && (!ahbl_hwrite_i));
assign w_we = r_we;
assign ahbl_hreadyout_o = 1'b1;
assign ahbl_hrdata_o = r_rdata_o;
assign w_wdata_i     = ahbl_hwdata_i;

always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_we <= 0;
	end
	else begin
		r_we <= (ahbl_hsel_i && ahbl_htrans_i[1] &&   ahbl_hwrite_i);
	end
end

// AHBL I/F }}}
`else
// APB I/F {{{
assign w_addr = apb_paddr_i[5:2];
assign w_re = (apb_psel_i && apb_penable_i && (!apb_pwrite_i));
assign w_we = (apb_psel_i && apb_penable_i && ( apb_pwrite_i));
assign apb_pready_o = 1'b1;
assign apb_prdata_o = r_rdata_o;
assign w_wdata_i = apb_pwdata_i;
// APB I/F }}}
`endif


reg	[COUNTER_SIZE-1:0]	r_t_hd_start;
reg	[COUNTER_SIZE-1:0]	r_t_low;
reg	[COUNTER_SIZE-1:0]	r_t_high;
reg	[COUNTER_SIZE-1:0]	r_t_su_start;
reg	[COUNTER_SIZE-1:0]	r_t_su_stop;
reg	[COUNTER_SIZE-1:0]	r_t_buf;
wire	[COUNTER_SIZE-1:0]	r_t_su_data;
wire	[COUNTER_SIZE-1:0]	r_t_hd_data;
assign r_t_su_data = {1'b0,r_t_low[COUNTER_SIZE-1:1]};
assign r_t_hd_data = {1'b0,r_t_low[COUNTER_SIZE-1:1]};

`ifndef REMOVE_TRI_STATE_BUFFER_I2C_CONT
	wire  	scl_i;
	wire  	sda_i;
	wire	scl_low_o;
	wire	sda_low_o;
`endif

wire	clk	=	clk_i;
wire	resetn	=	resetn_i;

reg [7:0] r_tx_dat;
reg [7:0] r_rx_dat;
reg       r_tx_ack;
reg       r_rx_ack;
reg [3:0] r_bcnt;
reg [2:0] scl_d;
reg [2:0] sda_d;
wire w_scl;
wire w_sda;
wire w_scl_rise;
wire w_scl_fall;
wire w_sda_rise;
wire w_sda_fall;
// SCL/SDA filter {{{
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		scl_d <= 3'b111;
		sda_d <= 3'b111;
	end
	else begin
		scl_d <= {scl_d[1:0],scl_i};
		sda_d <= {sda_d[1:0],sda_i};
	end
end

generate if (NOISE_FILTER == "EN") begin
reg scl_flt;
reg sda_flt;
reg scl_flt_d;
reg sda_flt_d;

assign w_scl = scl_flt;
assign w_sda = sda_flt;
assign w_scl_rise = ~scl_flt_d & scl_flt;
assign w_scl_fall =  scl_flt_d & (~scl_flt);
assign w_sda_rise = ~sda_flt_d & sda_flt;
assign w_sda_fall =  sda_flt_d & (~sda_flt);
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		scl_flt <= 1'b1;
		sda_flt <= 1'b1;
		scl_flt_d <= 1'b1;
		sda_flt_d <= 1'b1;
	end
	else begin
		scl_flt <= scl_d[2] & scl_d[1];
		//scl_flt <= scl_flt ? scl_d[2] | scl_d[1] : scl_d[2] & scl_d[1];
		sda_flt <= sda_flt ? sda_d[2] | sda_d[1] : sda_d[2] & sda_d[1];
		scl_flt_d <= scl_flt;
		sda_flt_d <= sda_flt;
	end
end
end
else begin
assign w_scl = scl_d[1];
assign w_sda = sda_d[1];
assign w_scl_rise = scl_d[2:1] == 2'b01;
assign w_scl_fall = scl_d[2:1] == 2'b10;
assign w_sda_rise = sda_d[2:1] == 2'b01;
assign w_sda_fall = sda_d[2:1] == 2'b10;
end
endgenerate
// SCL/SDA filter }}}


reg r_start_stb;
reg r_byte_stb;
reg r_stop_stb;
reg r_start_done;
reg r_byte_done;
reg r_stop_done;
reg r_start_scl_low;
reg r_start_sda_low;
reg r_byte_scl_low;
reg r_byte_sda_low;
reg r_stop_scl_low;
reg r_stop_sda_low;

assign scl_low_o = r_start_scl_low | r_byte_scl_low | r_stop_scl_low;
assign sda_low_o = r_start_sda_low | r_byte_sda_low | r_stop_sda_low;
assign int_o     = r_start_done | r_byte_done | r_stop_done;

// ********************
// I2C start {{{
// ********************
reg [COUNTER_SIZE-1:0] r_start_cnt;

always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_start_cnt <= 0;
	end
	else if(r_start_stb) begin
		r_start_cnt <= r_t_hd_start + r_t_su_start;
	end
	else if( r_start_cnt > r_t_hd_start )begin
		r_start_cnt <=(w_scl & w_sda) ? r_start_cnt -1 : r_start_cnt ;
	end
	else if( (w_sda == 1'b0) && (r_start_cnt != 0) )begin
		r_start_cnt <= r_start_cnt -1;
	end
end
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_start_done <= 1'b0;
	end
	else if(r_start_done && (r_byte_stb || r_stop_stb)) begin
		r_start_done <= 1'b0;
	end
	else if( (w_sda == 1'b0) && (r_start_cnt == 1) )begin
		r_start_done <= 1'b1;
	end
end
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_start_scl_low <= 0;
		r_start_sda_low <= 0;
	end
	else if(r_start_done && (r_byte_stb || r_stop_stb)) begin
		r_start_scl_low <= 0;
		r_start_sda_low <= 0;
	end
	else if(r_start_cnt > r_t_hd_start) begin
		r_start_scl_low <= 0;
		r_start_sda_low <= 0;
	end
	else if(r_start_cnt != 0) begin
		r_start_scl_low <= 0;
		r_start_sda_low <= 1;
	end
	else if(r_start_done) begin
		r_start_scl_low <= 1;
		r_start_sda_low <= 1;
	end
end
// I2C start }}}

// ********************
// I2C stop {{{
// ********************
reg [COUNTER_SIZE-1:0] r_stop_cnt;

always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_stop_cnt <= 0;
	end
	else if(r_stop_stb) begin
		r_stop_cnt <= r_t_su_data + r_t_su_stop + r_t_buf ;
	end
	else if(r_stop_cnt > r_t_su_stop + r_t_buf) begin
		r_stop_cnt <= r_stop_cnt -1;
	end
	else if(r_stop_cnt > r_t_buf) begin
		r_stop_cnt <= ({w_scl,w_sda} == 2'b10) ? r_stop_cnt -1 : r_stop_cnt;
	end
	else if( ({w_scl,w_sda} == 2'b11) && (r_stop_cnt != 0) )begin
		r_stop_cnt <= r_stop_cnt -1;
	end
end
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_stop_done <= 1'b0;
	end
	else if(w_re && (w_addr==4'b0001)) begin
		r_stop_done <= 1'b0;
	end
	else if( ({w_scl,w_sda} == 2'b11) && (r_stop_cnt == 1) )begin
		r_stop_done <= 1'b1;
	end
end
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_stop_scl_low <= 0;
		r_stop_sda_low <= 0;
	end
	else if(r_stop_cnt > r_t_su_stop + r_t_buf) begin
		r_stop_scl_low <= 1;
		r_stop_sda_low <= 1;
	end
	else if(r_stop_cnt > r_t_buf) begin
		r_stop_scl_low <= 0;
		r_stop_sda_low <= 1;
	end
	else begin
		r_stop_scl_low <= 0;
		r_stop_sda_low <= 0;
	end
end
// I2C Stop }}}

// I2C scl toggling {{{
reg r_byte_busy;
reg 	[COUNTER_SIZE-1:0] r_bit_time_cnt;
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_byte_busy <= 0;
	end
	else if(r_byte_stb) begin
		r_byte_busy <= 1;
	end
	else if(r_byte_busy && (r_start_stb | r_stop_stb) ) begin
		r_byte_busy <= 0;
	end
end
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_bit_time_cnt <= 0;
	end
	else if(r_byte_stb) begin
		r_bit_time_cnt <= r_t_low + r_t_high ;
	end
	else if( r_byte_busy && (r_bcnt != 9) && (r_bit_time_cnt == 1) ) begin
		r_bit_time_cnt <= r_t_low + r_t_high ;
	end
	else if( (~w_scl) && (r_bit_time_cnt>r_t_high+r_t_hd_data) ) begin
		r_bit_time_cnt <= r_bit_time_cnt - 1;
	end
	else if( ( w_scl) && (r_bit_time_cnt > r_t_hd_data) ) begin
		r_bit_time_cnt <= r_bit_time_cnt - 1;
	end
	else if( (~w_scl) && (r_bit_time_cnt != 0) ) begin
		r_bit_time_cnt <= r_bit_time_cnt - 1;
	end
end
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_byte_scl_low <= 0;
	end
	else if(r_byte_busy && (r_start_stb | r_stop_stb) ) begin
		r_byte_scl_low <= 0;
	end
	else if( r_byte_stb ) begin
		r_byte_scl_low <= 1;
	end
	else if(r_bit_time_cnt>r_t_high+r_t_hd_data) begin
		r_byte_scl_low <= 1;
	end
	else if(r_bit_time_cnt>r_t_hd_data) begin
		r_byte_scl_low <= 0;
	end
	else if(r_bit_time_cnt != 0) begin
		r_byte_scl_low <= 1;
	end
end
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_bcnt <= 0;
	end
	else if(!r_byte_busy) begin
		r_bcnt <= 0;
	end
	else if( r_byte_stb )  begin
		r_bcnt <= 0;
	end
	else if(w_scl_rise) begin
		r_bcnt <= (r_bcnt != 9) ? r_bcnt + 1 : 0;
	end
end
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_byte_done <= 0;
	end
	else if(w_re && (w_addr==4'b0001)) begin
		r_byte_done <= 0;
	end
	else if( (r_bcnt == 9) && (r_bit_time_cnt == 1) ) begin
		r_byte_done <= 1;
	end
end
// I2C scl toggling }}}

// ********************
// I2C receive byte {{{
// ********************
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_rx_dat <= 0;
		r_rx_ack <= 0;
	end
	else if(w_scl_rise) begin
		case(r_bcnt)
		4'd0: r_rx_dat[7] <= w_sda;
		4'd1: r_rx_dat[6] <= w_sda;
		4'd2: r_rx_dat[5] <= w_sda;
		4'd3: r_rx_dat[4] <= w_sda;
		4'd4: r_rx_dat[3] <= w_sda;
		4'd5: r_rx_dat[2] <= w_sda;
		4'd6: r_rx_dat[1] <= w_sda;
		4'd7: r_rx_dat[0] <= w_sda;
		4'd8: r_rx_ack    <= w_sda;
		default: {r_rx_dat,r_rx_ack} <= 0;
		endcase
	end
end
// I2C receive byte }}}

// ********************
// I2C send byte {{{
// ********************
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_byte_sda_low <= 0;
	end
	else if(r_byte_busy && (r_start_stb | r_stop_stb) ) begin
		r_byte_sda_low <= 0;
	end
	else if(r_byte_stb || (r_byte_busy && (r_bit_time_cnt==1))) begin
		case(r_bcnt)
		4'd0: r_byte_sda_low <= ~r_tx_dat[7];
		4'd1: r_byte_sda_low <= ~r_tx_dat[6];
		4'd2: r_byte_sda_low <= ~r_tx_dat[5];
		4'd3: r_byte_sda_low <= ~r_tx_dat[4];
		4'd4: r_byte_sda_low <= ~r_tx_dat[3];
		4'd5: r_byte_sda_low <= ~r_tx_dat[2];
		4'd6: r_byte_sda_low <= ~r_tx_dat[1];
		4'd7: r_byte_sda_low <= ~r_tx_dat[0];
		4'd8: r_byte_sda_low <= ~r_tx_ack;
		default: r_byte_sda_low <= 0;
		endcase
	end
end
// I2C send byte }}}

// reg access {{{
// **** READ ACCESS ****
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_rdata_o <= 32'h00;
	end
	else if(w_re) begin
		case(w_addr)
		4'b0000: r_rdata_o <= r_rx_dat;
		4'b0001: r_rdata_o <= {3'b0,r_rx_ack, 1'b0, r_stop_done,r_byte_done,r_start_done};
		4'b0100: r_rdata_o <= r_t_hd_start;
		4'b0101: r_rdata_o <= r_t_low;
		4'b0110: r_rdata_o <= r_t_high;
		4'b0111: r_rdata_o <= r_t_su_start;
		4'b1000: r_rdata_o <= r_t_su_data;
		4'b1001: r_rdata_o <= r_t_hd_data;
		4'b1010: r_rdata_o <= r_t_su_stop;
		4'b1011: r_rdata_o <= r_t_buf;
		default: r_rdata_o <= 0;
		endcase
	end
end
// **** WRITE ACCESS ****
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_tx_dat <= 8'h00;
		r_tx_ack <= 1'b0;
	end
	else if(w_we) begin
		if(w_addr == 4'b0000) begin
			r_tx_dat <= w_wdata_i[7:0];
			r_tx_ack <= w_wdata_i[8];
		end
	end
end
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_start_stb <= 0;
		r_byte_stb <= 0;
		r_stop_stb <= 0;
	end
	else if(w_we) begin
		if(w_addr == 4'b0010) begin
			{r_stop_stb,r_byte_stb,r_start_stb} <= w_wdata_i[2:0];
		end
	end
	else begin
		r_start_stb <= 0;
		r_byte_stb <= 0;
		r_stop_stb <= 0;
	end
end
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_t_hd_start <= T_HD_START_CLKS;
	end
	else if(w_we) begin
		if(w_addr == 4'b0100) begin
			r_t_hd_start <= w_wdata_i[COUNTER_SIZE-1:0];
		end
	end
end
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_t_low <= T_LOW_CLKS;
	end
	else if(w_we) begin
		if(w_addr == 4'b0101) begin
			r_t_low <= w_wdata_i[COUNTER_SIZE-1:0];
		end
	end
end
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_t_high <= T_HIGH_CLKS;
	end
	else if(w_we) begin
		if(w_addr == 4'b0110) begin
			r_t_high <= w_wdata_i[COUNTER_SIZE-1:0];
		end
	end
end
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_t_su_start <= T_SU_START_CLKS;
	end
	else if(w_we) begin
		if(w_addr == 4'b0111) begin
			r_t_su_start <= w_wdata_i[COUNTER_SIZE-1:0];
		end
	end
end
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_t_su_stop <= T_SU_STOP_CLKS;
	end
	else if(w_we) begin
		if(w_addr == 4'b1010) begin
			r_t_su_stop <= w_wdata_i[COUNTER_SIZE-1:0];
		end
	end
end
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		r_t_buf <= T_BUF_CLKS;
	end
	else if(w_we) begin
		if(w_addr == 4'b1011) begin
			r_t_buf <= w_wdata_i[COUNTER_SIZE-1:0];
		end
	end
end

// AHBL Interface }}}


`ifndef REMOVE_TRI_STATE_BUFFER_I2C_CONT
	BB_B  scl_io_i (
		.I	(1'b0),
		.O	(scl_i),
		.T_N	(scl_low_o),
		.B	(scl_io)
	);
	BB_B  sda_io_i (
		.I	(1'b0),
		.O	(sda_i),
		.T_N	(sda_low_o),
		.B	(sda_io)
	);
`endif

endmodule

// vim:foldmethod=marker:
//
