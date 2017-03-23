`timescale 1ns / 1ps
module instfifo#(
	parameter X_PE = 16,
	parameter X_MAC = 4,
	parameter X_MESH = 16,
	parameter ADDR_LEN_W = 9,
	parameter ADDR_LEN_D = 9,
	parameter INST_LEN = 128,
	parameter COM_DATALEN = 24
)(
	input   wire clk,
	input   wire rst_n,
	output	wire [INST_LEN - 1:0]	instruct,
									//  ilc_st_addr 35:0 
									//	ilc_ispad 36:36
									//	ilc_linelen 45:37
									//	bsr_iszero 49:46
									//	bsr_buffermux 57:50
									//	PEC_fromfifo 58:58
									//	PEC_tofifo 59:59
									//	is_w2c_back 60:60
									//  w2c_st_addr 96:61
									//  w2c_linelen 105:97
									//	w2c_pooled  106:106
									//  pooled_type 107:107
									//  wb_st_rd_addr 116:108
									//  w2c_shift_len 119:116
									//	w2c_valid_mac 121:120
									
	output wire inst_empty,
	input wire inst_req
);

reg [ADDR_LEN_W - 1:0]      	wb_st_rd_addr ;
reg [3:0]                   	bsr_iszero    ;
reg [7:0]                   	bsr_buffermux ;
reg								PEC_fromfifo  ;
reg								PEC_tofifo    ;
reg 							ilc_ispad     ;
reg [ADDR_LEN_D*X_MAC - 1:0] 	ilc_st_addr   ;
reg [9 : 0]						ilc_linelen   ;
reg [9 : 0]						w2c_linelen   ;
reg [ADDR_LEN_D*X_MAC - 1:0]	w2c_st_addr   ;
reg 							w2c_pooled    ;
reg 							pooled_type   ;
reg	[3:0]						w2c_shift_len ;
reg [1:0]						w2c_valid_mac ;
reg 							is_w2c_back   ;


assign instruct[116:108]  =  wb_st_rd_addr ;
assign instruct[49:46]    =  bsr_iszero    ;
assign instruct[57:50]    =  bsr_buffermux ;
assign instruct[58]       =  PEC_fromfifo  ;
assign instruct[59]       =  PEC_tofifo    ;
assign instruct[36]       =  ilc_ispad     ;
assign instruct[35:0]     =  ilc_st_addr   ;
assign instruct[45:37]    =  ilc_linelen   ;
assign instruct[107]      =  pooled_type   ;
assign instruct[96:61]    =  w2c_st_addr   ;
assign instruct[105:97]   =  w2c_linelen   ;
assign instruct[106]      =  w2c_pooled    ;
assign instruct[120:117]  =  w2c_shift_len ;
assign instruct[122:121]  =  w2c_valid_mac ;
assign instruct[60]  =  is_w2c_back ;


always @( posedge clk) begin
	if(!rst_n) begin
		wb_st_rd_addr <= 0;
		bsr_iszero    <= 0;
		bsr_buffermux <= {2'd3,2'd2,2'd1,2'd0};
		PEC_fromfifo  <= 0;
		PEC_tofifo    <= 1;
		ilc_ispad     <= 0;
		ilc_st_addr   <= 0;
		ilc_linelen   <= 64;
		w2c_linelen   <= 0;
		w2c_st_addr   <= 0;
		w2c_pooled    <= 0;
		pooled_type   <= 0;
		w2c_shift_len <= 0;
		w2c_valid_mac <= 0;
		is_w2c_back   <= 0;
	end
	else if(inst_req) begin
		wb_st_rd_addr <= 0;
		bsr_iszero    <= 0;
		bsr_buffermux <= {2'd3,2'd2,2'd1,2'd0};
		PEC_fromfifo  <= 1;
		PEC_tofifo    <= 1;
		ilc_ispad     <= 0;
		ilc_st_addr   <= 0;
		ilc_linelen   <= 64;
		w2c_linelen   <= 0;
		w2c_st_addr   <= 0;
		w2c_pooled    <= 0;
		pooled_type   <= 0;
		w2c_shift_len <= 0;
		w2c_valid_mac <= 0;
		is_w2c_back   <= 0;
	end
end

endmodule