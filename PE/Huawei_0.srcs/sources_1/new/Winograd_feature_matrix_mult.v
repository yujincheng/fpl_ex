`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/13 12:13:31
// Design Name: 
// Module Name: Winograd_feature_matrix_mult
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


module Winograd_feature_matrix_mult
#(
	parameter MESH_X =4,
	parameter MESH_Y =4,
  parameter IN_BIT = 8,
  parameter OUT_BIT = IN_BIT+1
)
(
	input clk,
//	input rst_n,
  input [IN_BIT*MESH_Y*MESH_Y-1:0]data,
  output [OUT_BIT*MESH_X*MESH_X-1:0]result
);
  //resut=B'*data*B
  //B=[ 1, 0, 0, 0; B'=[ 1, 0,-1, 0;
  //    0, 1,-1, 1;      0, 1, 1, 0;
  //   -1, 1, 1, 0;      0,-1, 1, 0;
  //    0, 0, 0,-1]      0, 1, 0,-1]
  
  wire [IN_BIT*MESH_Y-1:0] data_wire_array [MESH_Y-1:0];
  wire [OUT_BIT*MESH_X-1:0] result_wire_array [MESH_X-1:0];

  generate
    genvar i;
    for(i=0;i<MESH_Y;i=i+1)
    begin:data_wire
      assign data_wire_array[i]=data[IN_BIT*MESH_Y*(i+1)-1:IN_BIT*MESH_Y*i];
    end
   
    for(i=0;i<MESH_X;i=i+1)
    begin:result_wire
      assign result[OUT_BIT*MESH_X*(i+1)-1:OUT_BIT*MESH_X*i]=result_wire_array[i];
    end
    for(i=0;i<MESH_Y;i=i+1)
    begin:mul_raw
    
    
    	Winograd_matrix_mul_raw_8to9
    	#(
	      .IN_BIT(IN_BIT),
	      .OUT_BIT(OUT_BIT)
  	  )
	      wino_mul_raw
	    (
	    	.clk(clk),
//	    	.rst_n(rst_n),
	      .data(data_wire_array[i]),
	      .result(result_wire_array[i])
	    );
    end    
  endgenerate

endmodule
