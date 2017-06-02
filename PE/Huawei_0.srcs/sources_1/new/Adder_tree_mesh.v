`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/16 10:16:24
// Design Name: 
// Module Name: Adder_tree_mesh
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


module Adder_tree_mesh
#(
  parameter IN_BIT = 20,
  parameter IN_NUM =16,
  parameter MESH_SIZE=4,
  parameter BIAS_BIT =20,
  parameter OUT_BIT =IN_BIT+4
)
(
	input clk,
	input rst_n,
	input [BIAS_BIT-1:0] bias,
	input [IN_BIT*IN_NUM*MESH_SIZE*MESH_SIZE-1:0] input_data,
	input [OUT_BIT*MESH_SIZE*MESH_SIZE-1:0] inter_data,
	output out_valid,
	output [OUT_BIT*MESH_SIZE*MESH_SIZE-1:0] output_data
);

	
	generate
	genvar i,j;
		for(i=0;i<MESH_SIZE*MESH_SIZE;i=i+1)
		begin:adder_mesh
			wire [IN_BIT*IN_NUM-1:0] adder_input;
			wire [OUT_BIT-1:0] adder_inter;
			wire [OUT_BIT-1:0] adder_output;
			for(j=0;j<IN_NUM;j=j+1)
			begin:adder_wire
				assign adder_input[IN_BIT*(j+1)-1:IN_BIT*j]=input_data[IN_BIT*(i+j*MESH_SIZE*MESH_SIZE+1)-1:IN_BIT*(i+j*MESH_SIZE*MESH_SIZE)];
			end
			assign adder_inter=inter_data[OUT_BIT*(i+1)-1:OUT_BIT*i];
			assign output_data[OUT_BIT*(i+1)-1:OUT_BIT*i]=adder_output;
			(*dont_touch = "yes"*) Adder_tree_3_input
			#(
				.IN_BIT(IN_BIT),
				.IN_NUM(IN_NUM),
				.BIAS_BIT(BIAS_BIT),
				.OUT_BIT(OUT_BIT)
			)
			adder
			(
				.clk(clk),
				.rst_n(rst_n),
				.bias(bias),
				.input_data(adder_input),
				.inter_data(adder_inter),
				.output_data(adder_output)
			);
		end
  endgenerate
endmodule
