`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/09 15:17:39
// Design Name: 
// Module Name: Winograd_PE
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


module Winograd_PE
#(
	parameter FEATURE_SIZE = 4,
	parameter WEIGHT_SIZE =3,
  parameter RESULT_SIZE = 2,
  parameter DATA_BIT =8,
  parameter MESH_N=16,
  parameter WEIGHT_BIT = 12,
  parameter BIAS_BIT = 20,
  parameter MESH_OUT_BIT =20,
  parameter OUT_BIT = 24
)
(
	input clk,
	input rst_n,
	input in_valid,
	input acum,
	input bias_valid,
	input [DATA_BIT*MESH_N*FEATURE_SIZE*FEATURE_SIZE-1:0]feature,
	input [WEIGHT_BIT*MESH_N*WEIGHT_SIZE*WEIGHT_SIZE-1:0]weight,
	input [OUT_BIT*RESULT_SIZE*RESULT_SIZE-1:0]inter_data,
	input [BIAS_BIT-1:0] bias,
	output out_valid,
	output [OUT_BIT*RESULT_SIZE*RESULT_SIZE-1:0] result
);
  
  reg[7:0] in_valid_reg;
  reg[BIAS_BIT-1:0] bias_reg[4:0];
  
  
  always @(posedge clk)
  begin
  	bias_reg[0]<=(bias_valid?bias:{BIAS_BIT{1'b0}});
  	bias_reg[1]<=bias_reg[0];
  	bias_reg[2]<=bias_reg[1];
  	bias_reg[3]<=bias_reg[2];
  	bias_reg[4]<=bias_reg[3];
 		in_valid_reg<={in_valid_reg[6:0],in_valid};
  end
  
  
    assign out_valid = in_valid_reg[7];
  
  wire [MESH_OUT_BIT*MESH_N*RESULT_SIZE*RESULT_SIZE-1:0] adder_tree_in;
	generate
		genvar i;
		for(i=0;i<MESH_N;i=i+1)
			begin:mesh_list
			(*dont_touch = "yes"*)Winograd_mesh#(
	    	.FEATURE_SIZE(FEATURE_SIZE),
	    	.RESULT_SIZE(RESULT_SIZE),
	    	.DATA_BIT(DATA_BIT),
	  	  .WEIGHT_BIT(WEIGHT_BIT)
	  	)	
	  	mesh
	  	(
		  	.clk(clk),
		  	.rst_n(rst_n),
		    .feature(feature[DATA_BIT*FEATURE_SIZE*FEATURE_SIZE*(i+1)-1:DATA_BIT*FEATURE_SIZE*FEATURE_SIZE*i]),
		    .weight(weight[WEIGHT_BIT*WEIGHT_SIZE*WEIGHT_SIZE*(i+1)-1:WEIGHT_BIT*WEIGHT_SIZE*WEIGHT_SIZE*i]),
		    .result(adder_tree_in[MESH_OUT_BIT*RESULT_SIZE*RESULT_SIZE*(i+1)-1:MESH_OUT_BIT*RESULT_SIZE*RESULT_SIZE*i])
			);
		end
  endgenerate
  
   
  (*dont_touch = "yes"*)Adder_tree_mesh
  #(
  	.IN_BIT(MESH_OUT_BIT),
  	.MESH_SIZE(RESULT_SIZE),
  	.BIAS_BIT(BIAS_BIT),
  	.IN_NUM(MESH_N)
  )
  adder_mesh
  (
  	.clk(clk), 
  	.rst_n(rst_n),
	  .bias(bias_reg[4]),
	  .input_data(adder_tree_in),
	  .inter_data(inter_data),
	  .output_data(result)
  );
    
endmodule
