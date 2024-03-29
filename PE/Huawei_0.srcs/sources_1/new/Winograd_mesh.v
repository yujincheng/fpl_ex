`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/09 15:18:20
// Design Name: 
// Module Name: Winograd_mesh
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


module Winograd_mesh
#(
	parameter FEATURE_SIZE = 4,
	parameter RESULT_SIZE = 2,
	parameter DATA_BIT =8,
	parameter WEIGHT_BIT = 8,
	parameter WEIGHT_SIZE  = 3,
	
	parameter WEIGHT_RESULT_BIT=WEIGHT_BIT+4,
	parameter FEATURE_RESULT_BIT=DATA_BIT+1,
	parameter ELEMENT_RESULT_BIT=FEATURE_RESULT_BIT+WEIGHT_RESULT_BIT,
	parameter RESULT_BIT = 20
)
(
	input clk,
	input rst_n,
	input [WEIGHT_BIT*WEIGHT_SIZE*WEIGHT_SIZE-1:0] weight,
	output [RESULT_BIT*RESULT_SIZE*RESULT_SIZE-1:0] result,
	input [FEATURE_RESULT_BIT*FEATURE_SIZE*FEATURE_SIZE-1:0] feature_result
);
  wire [WEIGHT_RESULT_BIT*FEATURE_SIZE*FEATURE_SIZE-1:0] weight_result;
  Winograd_feature_weight_mult
	#(
		.WEIGHT_BIT(WEIGHT_BIT)
	)
	weight_mult
	(
		.clk(clk),
		.rst_n(rst_n),
		.weight(weight),
		.result(weight_result)
	);


	
	
	
	wire [ELEMENT_RESULT_BIT*FEATURE_SIZE*FEATURE_SIZE-1:0] element_result;
	Element_multiply
	#(
	  .MESH_X(FEATURE_SIZE),
		.MESH_Y(FEATURE_SIZE),
		.IN_BIT_0(FEATURE_RESULT_BIT),
		.IN_BIT_1(WEIGHT_RESULT_BIT)
	)
	elt_mult
	(
		.clk(clk),
		.rst_n(rst_n),
		.in_data_0(feature_result),
		.in_data_1(weight_result),
	  .out_data(element_result)
	 );
	 
	 
	Winograd_outside_3input_lut
	#(
		.MESH_X(RESULT_SIZE),
		.MESH_Y(FEATURE_SIZE),
		.IN_BIT(ELEMENT_RESULT_BIT)
	)
	result_matrix_mult
	(
		.clk(clk),
		.rst_n(rst_n),
	  .data(element_result),
		.result(result)
	); 
endmodule
