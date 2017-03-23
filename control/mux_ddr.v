`timescale 1ps/1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/09 22:59:24
// Design Name: 
// Module Name: wino_PE_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module muxddr #(
	parameter SINGLE_LEN  = 20,
	parameter DDR_DATA_LEN = 64*8,
	parameter DDR_ADDR_LEN = 32
  )(
	input   wire                      clk,
	input   wire                      rst_n,
	input   wire [1:0]                switch,
	
	// output interface to ddr face
	output reg [DDR_ADDR_LEN - 1:0]   ddr_st_addr_out,
	output reg [SINGLE_LEN - 1:0]     ddr_len,
	output reg                        ddr_conf,
	
	
	input   wire                      ddr_fifo_empty,
	output reg                        ddr_fifo_req,
	input   wire [DDR_DATA_LEN - 1:0] ddr_fifo_data,
	
	// 3 different input channel
	input   wire [DDR_ADDR_LEN - 1:0] ddr_st_addr_out_bias,
	input   wire [SINGLE_LEN - 1:0]   ddr_len_bias,
	input   wire                      ddr_conf_bias,
	output  wire                      ddr_fifo_empty_bias,
	input   wire                      ddr_fifo_req_bias,
	output  wire [DDR_DATA_LEN - 1:0]     ddr_fifo_data_bias,
	
	input   wire [DDR_ADDR_LEN - 1:0] ddr_st_addr_out_weights,
	input   wire [SINGLE_LEN - 1:0]   ddr_len_weights,
	input   wire                      ddr_conf_weights,
	output  wire                      ddr_fifo_empty_weights,
	input   wire                      ddr_fifo_req_weights,
	output  wire [DDR_DATA_LEN - 1:0]     ddr_fifo_data_weights,
	
	input   wire [DDR_ADDR_LEN - 1:0] ddr_st_addr_out_data,
	input   wire [SINGLE_LEN - 1:0]   ddr_len_data,
	input   wire                      ddr_conf_data,
	output  wire                      ddr_fifo_empty_data,
	input   wire                      ddr_fifo_req_data,
	output  wire [DDR_DATA_LEN - 1:0]     ddr_fifo_data_data
);


always @ * begin
	case (switch) 
	2'd1 :begin
		 ddr_st_addr_out <= ddr_st_addr_out_weights;
		 ddr_len <= ddr_len_weights;
		 ddr_conf <= ddr_conf_weights;
		 ddr_fifo_req <= ddr_fifo_req_weights;
	end
	2'd2 :begin
		 ddr_st_addr_out <= ddr_st_addr_out_bias;
		 ddr_len <= ddr_len_bias;
		 ddr_conf <= ddr_conf_bias;
		 ddr_fifo_req <= ddr_fifo_req_bias;
	end
	2'd3 :begin
		 ddr_st_addr_out <= ddr_st_addr_out_data;
		 ddr_len <= ddr_len_data;
		 ddr_conf <= ddr_conf_data;
		 ddr_fifo_req <= ddr_fifo_req_data;
	end
	default:  begin
		 ddr_st_addr_out <= 0;
		 ddr_len <= 0;
		 ddr_conf <= 0;
		 ddr_fifo_req <= 0;
	end
	endcase
end


assign ddr_fifo_empty_data = ddr_fifo_empty;
assign ddr_fifo_empty_weights = ddr_fifo_empty;
assign ddr_fifo_empty_bias = ddr_fifo_empty;

assign ddr_fifo_data_data = ddr_fifo_data;
assign ddr_fifo_data_weights = ddr_fifo_data;
assign ddr_fifo_data_bias = ddr_fifo_data;

  
endmodule
