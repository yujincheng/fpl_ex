`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/20 13:31:41
// Design Name: 
// Module Name: Pool_block
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


module Pool_block
#(
	parameter IN_BIT = 24,
	parameter IN_SIZE = 2,
	parameter OUT_BIT = IN_BIT,
	parameter OUT_SIZE =1
)
(
	input clk,
	input in_valid,
	input op,
	output out_valid,
	input [IN_BIT*IN_SIZE*IN_SIZE-1:0] in_data,
	output [OUT_BIT*OUT_SIZE*OUT_SIZE-1:0] out_data_pool,
	output [OUT_BIT*IN_SIZE*IN_SIZE-1:0] out_data_unpool
);
	reg signed [OUT_BIT-1:0] out_data_pool_reg;
	reg signed [OUT_BIT*IN_SIZE*IN_SIZE-1:0] out_data_unpool_reg;
	reg out_valid_reg;
	wire signed [IN_BIT-1:0] in_data_wire_array [0:IN_SIZE*IN_SIZE-1];
	wire signed [IN_BIT-1:0] pool_wire [0:IN_SIZE-1];
	
	assign pool_wire[0]=((in_data_wire_array[0*IN_SIZE+0]>in_data_wire_array[0*IN_SIZE+1])?in_data_wire_array[0*IN_SIZE+0]:in_data_wire_array[0*IN_SIZE+1]);
	assign pool_wire[1]=((in_data_wire_array[1*IN_SIZE+0]>in_data_wire_array[1*IN_SIZE+1])?in_data_wire_array[1*IN_SIZE+0]:in_data_wire_array[1*IN_SIZE+1]);
	
	generate
		genvar i;
		for(i=0;i<IN_SIZE*IN_SIZE;i=i+1)
		begin:in_wire
			assign in_data_wire_array[i]=in_data[IN_BIT*(i+1)-1:IN_BIT*i];
		end
	endgenerate
	
	always @(posedge clk)
	begin
		out_valid_reg<=in_valid;
		if(in_valid)
		begin
			out_data_unpool_reg<=in_data;
			out_data_pool_reg<=(op?((pool_wire[0]>pool_wire[1])?pool_wire[0]:pool_wire[1]):(in_data_wire_array[0*IN_SIZE+0]));
		end
	end
	
	assign out_valid=out_valid_reg;
	assign out_data_pool=out_data_pool_reg;
	assign out_data_unpool=out_data_unpool_reg;

endmodule
