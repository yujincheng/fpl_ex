`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/09 13:26:59
// Design Name: 
// Module Name: Element_multiply
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


module Element_multiply
#(
	parameter MESH_X = 4,
	parameter MESH_Y = 4,
	parameter IN_BIT_0 = 9,
	parameter IN_BIT_1 = 12,
	parameter OUT_BIT = IN_BIT_0+IN_BIT_1
)
(
	input clk,
	input rst_n,
	input [IN_BIT_0*MESH_X*MESH_Y-1:0] in_data_0,
	input [IN_BIT_1*MESH_X*MESH_Y-1:0] in_data_1,
	output [OUT_BIT*MESH_X*MESH_Y-1:0] out_data
 );
 	wire signed [IN_BIT_0-1:0] in_data_0_wire [0:MESH_X*MESH_Y-1];
 	wire signed [IN_BIT_1-1:0] in_data_1_wire [0:MESH_X*MESH_Y-1];
 	wire signed [OUT_BIT-1:0] out_data_wire [0:MESH_X*MESH_Y-1];
 	
	generate
		genvar x,y;
		for(x=0;x<MESH_X*MESH_Y;x=x+1)
		begin:wires
			assign in_data_0_wire[x]=in_data_0[IN_BIT_0*(x+1)-1:IN_BIT_0*x];
			assign in_data_1_wire[x]=in_data_1[IN_BIT_1*(x+1)-1:IN_BIT_1*x];
			assign out_data[OUT_BIT*(x+1)-1:OUT_BIT*x]=out_data_wire[x];
		end
		for(x=0;x<MESH_X;x=x+1)
		begin:mul_x
			DSP_add_sub_mult mult_0
			(	.clk(clk),.add_n(1'b1),
				.A(in_data_0_wire[x+0*MESH_Y]),.B(in_data_0_wire[x+2*MESH_Y]),.C(in_data_1_wire[x+0*MESH_Y]),.P(out_data_wire[x+0*MESH_Y]));
			DSP_add_sub_mult mult_1
			(	.clk(clk),.add_n(1'b0),
				.A(in_data_0_wire[x+1*MESH_Y]),.B(in_data_0_wire[x+2*MESH_Y]),.C(in_data_1_wire[x+1*MESH_Y]),.P(out_data_wire[x+1*MESH_Y]));
			DSP_add_sub_mult mult_2
			(	.clk(clk),.add_n(1'b1),
				.A(in_data_0_wire[x+2*MESH_Y]),.B(in_data_0_wire[x+1*MESH_Y]),.C(in_data_1_wire[x+2*MESH_Y]),.P(out_data_wire[x+2*MESH_Y]));
			DSP_add_sub_mult mult_3
			(	.clk(clk),.add_n(1'b1),
				.A(in_data_0_wire[x+1*MESH_Y]),.B(in_data_0_wire[x+3*MESH_Y]),.C(in_data_1_wire[x+3*MESH_Y]),.P(out_data_wire[x+3*MESH_Y]));
		end		
 endgenerate
 
 
endmodule
