`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/15 21:24:00
// Design Name: 
// Module Name: DSP_add_sub_mult
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


module DSP_add_sub_mult
#(
	parameter AB_BIT = 9,
	parameter C_BIT = 12
)
(
	input clk,
	input rst,
	input add_n,
	input signed [AB_BIT-1:0] A,
	input signed [AB_BIT-1:0] B,
	input signed [C_BIT-1:0] C,
	output signed [AB_BIT+1+C_BIT-1:0] P
);
    
	reg signed [AB_BIT:0]   add_reg;
  reg signed  [AB_BIT+1+C_BIT-1:0] P_reg;
    
  always @(posedge clk)
  	begin
  		if(add_n)
			begin
				add_reg <= A - B;
			end
			else
			begin
				add_reg <= A + B;
			end
      end
  
  always @(posedge clk)
	begin
			P_reg   <= add_reg * C;
	end
  
  
  assign P = P_reg;

    
endmodule
