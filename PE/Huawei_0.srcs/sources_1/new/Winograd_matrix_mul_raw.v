`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/09 10:40:24
// Design Name: 
// Module Name: Winograd_matrix_mul_raw
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


module Winograd_matrix_mul_raw_8to9
#(
  parameter IN_BIT = 8,
  parameter OUT_BIT = IN_BIT+1
  
)
(
	input clk,
  input [IN_BIT*4-1:0]data,
  output [OUT_BIT*4-1:0]result
);
  //B=[ 1, 0, 0, 0; B'=[ 1, 0,-1, 0;
  //    0, 1,-1, 1;      0, 1, 1, 0;
  //   -1, 1, 1, 0;      0,-1, 1, 0;
  //    0, 0, 0,-1]      0, 1, 0,-1]
  wire signed [IN_BIT-1:0] data_wire_array [4-1:0];
  reg signed [OUT_BIT-1:0] result_wire_array [4-1:0];

  always @(posedge clk)
  	begin
    	result_wire_array[0] <= data_wire_array[0] - data_wire_array[2];
    	result_wire_array[1] <= data_wire_array[1] + data_wire_array[2];
    	result_wire_array[2] <= data_wire_array[2] - data_wire_array[1];
    	result_wire_array[3] <= data_wire_array[1] - data_wire_array[3];
    end
  
  generate
    genvar i;
    for(i=0;i<4;i=i+1)
    begin:data_wire
      assign data_wire_array[i]=data[IN_BIT*(i+1)-1:IN_BIT*i];
    end
    for(i=0;i<4;i=i+1)
    begin:result_wire
      assign result[OUT_BIT*(i+1)-1:OUT_BIT*i]=result_wire_array[i];
    end
  endgenerate
  
  //assign result_wire_array[0]=data_wire_array[0]-data_wire_array[2];
  //assign result_wire_array[1]=data_wire_array[1]+data_wire_array[2];
  //assign result_wire_array[2]=data_wire_array[2]-data_wire_array[1];
  //assign result_wire_array[3]=data_wire_array[1]-data_wire_array[3];


endmodule
