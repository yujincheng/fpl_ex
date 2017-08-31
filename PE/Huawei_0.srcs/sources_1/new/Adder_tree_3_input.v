`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/15 23:36:26
// Design Name: 
// Module Name: Adder_tree_3_inputm
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


module Adder_tree_3_input
#(
  parameter IN_BIT = 20,
  parameter IN_NUM =16,
  parameter BIAS_BIT =20,
  parameter OUT_BIT =IN_BIT+4
)
(
  input clk,
  input rst_n,
  input [IN_BIT*IN_NUM-1:0] input_data,
  input [BIAS_BIT-1:0] bias,
  input [OUT_BIT-1:0] inter_data,
  output [OUT_BIT-1:0] output_data

);

  
  wire signed [IN_BIT-1:0] in_data [0:IN_NUM-1];
  genvar i;
  generate
  for(i=0;i<IN_NUM;i=i+1)
  begin:in_wires
    assign in_data[i]=input_data[IN_BIT*(i+1)-1:IN_BIT*i];
  end
  endgenerate
  wire signed [OUT_BIT-1:0] inter;
  wire signed [BIAS_BIT-1:0] bias_wire;
  assign inter=inter_data;
  assign bias_wire=bias;
  
   (*dont_touch = "yes"*)reg signed [IN_BIT+1 :0] lvl1_reg [0:5];
   (*dont_touch = "yes"*)reg signed [OUT_BIT-1:0] lvl2_reg [0:1];
   (*dont_touch = "yes"*)reg signed [OUT_BIT-1:0] output_reg;
  
  always @(posedge clk) begin
      if(!rst_n)begin
                 lvl1_reg[0] <= 0;
                 lvl1_reg[1] <= 0;
                 lvl1_reg[2] <= 0;
                 lvl1_reg[3] <= 0;
                 lvl1_reg[4] <= 0;
                 lvl1_reg[5] <= 0;          
      end      
      else begin          
          lvl1_reg[0]<=in_data[0]+in_data[1];
          lvl1_reg[1]<=in_data[3]+in_data[2];
          lvl1_reg[2]<=in_data[4]+in_data[5];
          lvl1_reg[3]<=in_data[6] ;
          lvl1_reg[4]<=in_data[7] ;
          lvl1_reg[5]<= bias_wire ;          
      end
    end
  
  
  always @(posedge clk)begin
          if(!rst_n)begin
          lvl2_reg[0]<=0;
          lvl2_reg[1]<=0;
        end
        else begin
          lvl2_reg[0]<=lvl1_reg[0]+lvl1_reg[1]+lvl1_reg[2];
           lvl2_reg[1]<=lvl1_reg[3]+lvl1_reg[4]+lvl1_reg[5];        
        end
   end
  
  always @(posedge clk) begin
  if (!rst_n) begin
      output_reg<=0;
    end
    else begin
      output_reg<=lvl2_reg[0]+lvl2_reg[1]+inter_data;  
    end
  end
  
  assign output_data=output_reg;
  
  
endmodule
