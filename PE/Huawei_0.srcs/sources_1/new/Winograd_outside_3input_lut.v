`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/13 11:10:38
// Design Name: 
// Module Name: Winograd_outside_3input_lut
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


module Winograd_outside_3input_lut
#(
	parameter MESH_X=2,
	parameter MESH_Y=4,
  parameter IN_BIT = 21,
  parameter MID_BIT = IN_BIT+2,
  parameter OUT_BIT = 20,
  parameter TEMP_NUM = 8
)
(
	input clk,
	input rst_n,
  input [IN_BIT*MESH_Y*MESH_Y-1:0]data,
  output [OUT_BIT*MESH_X*MESH_X-1:0]result
);
	//A=[ 1, 0; A'=[ 1, 1, 1, 0;
  //    1, 1;      0, 1,-1,-1]
  //    1,-1;
  //    0,-1]

  wire signed [IN_BIT-1:0] data_wire_array [0:MESH_Y*MESH_Y-1];
 
  (*dont_touch = "yes"*)reg signed [MID_BIT-1:0] temp_sum[0:TEMP_NUM-1];
  (*dont_touch = "yes"*)reg signed [OUT_BIT-1:0] result_reg[0:MESH_X*MESH_X-1];
  
    genvar i;
	generate
	for(i=0;i<MESH_Y*MESH_Y;i=i+1)
	begin:data_array
		assign data_wire_array[i]=data[IN_BIT*(i+1)-1:IN_BIT*i];
	end
	for(i=0;i<MESH_X*MESH_X;i=i+1)
	begin:result_array
		assign result[OUT_BIT*(i+1)-1:OUT_BIT*i]=result_reg[i];
	end
		
	endgenerate
	  
  always @(posedge clk) begin
      if (!rst_n) begin
              temp_sum[0] <= 0;
              temp_sum[1] <= 0;
              temp_sum[2] <= 0;
              temp_sum[3] <= 0;
              temp_sum[4] <= 0;
              temp_sum[5] <= 0;
              temp_sum[6] <= 0;
              temp_sum[7] <= 0;
        end
        else begin
            temp_sum[0]<=data_wire_array[0*MESH_Y+1]+data_wire_array[2*MESH_Y+1]+data_wire_array[1*MESH_Y+1];
            temp_sum[1]<=data_wire_array[1*MESH_Y+1]-data_wire_array[2*MESH_Y+1]-data_wire_array[3*MESH_Y+1];
            temp_sum[2]<=data_wire_array[1*MESH_Y+2]+data_wire_array[0*MESH_Y+2]+data_wire_array[2*MESH_Y+2];
            temp_sum[3]<=data_wire_array[1*MESH_Y+2]-data_wire_array[2*MESH_Y+2]-data_wire_array[3*MESH_Y+2];
            temp_sum[4]<=data_wire_array[0*MESH_Y+0]+data_wire_array[1*MESH_Y+0]+data_wire_array[2*MESH_Y+0];
            temp_sum[5]<=data_wire_array[0*MESH_Y+3]+data_wire_array[1*MESH_Y+3]+data_wire_array[2*MESH_Y+3];
            temp_sum[6]<=data_wire_array[1*MESH_Y+0]-data_wire_array[2*MESH_Y+0]-data_wire_array[3*MESH_Y+0];
            temp_sum[7]<=data_wire_array[1*MESH_Y+3]-data_wire_array[2*MESH_Y+3]-data_wire_array[3*MESH_Y+3];
        
        end
   end
  	
  (*dont_touch = "yes"*)wire signed [MID_BIT+1:0] temp_sum_wire [0:3];
  assign temp_sum_wire[0]=temp_sum[0]+temp_sum[4]+temp_sum[2];
  assign temp_sum_wire[1]=temp_sum[0]-temp_sum[5]-temp_sum[2];
  assign temp_sum_wire[2]=temp_sum[1]+temp_sum[6]+temp_sum[3];
  assign temp_sum_wire[3]=temp_sum[1]-temp_sum[7]-temp_sum[3];
  
  
  always @(posedge clk)	begin
      if (!rst_n) begin
          	result_reg[0]<= 0;
          	result_reg[1]<= 0;
          	result_reg[2]<= 0;
          	result_reg[3]<= 0;
      end
      else begin
           	result_reg[0]<=temp_sum_wire[0][OUT_BIT+1:2];
              result_reg[1]<=temp_sum_wire[1][OUT_BIT+1:2];
              result_reg[2]<=temp_sum_wire[2][OUT_BIT+1:2];
              result_reg[3]<=temp_sum_wire[3][OUT_BIT+1:2];     
      end
  end
  

endmodule

