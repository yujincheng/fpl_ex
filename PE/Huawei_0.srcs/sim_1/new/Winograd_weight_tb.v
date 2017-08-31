`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/16 15:33:26
// Design Name: 
// Module Name: Winograd_weight_tb
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


module Winograd_weight_tb
#(
	parameter WEIGHT_BIT = 8,
	parameter WEIGHT_SIZE =3,
	parameter RESULT_BIT = WEIGHT_BIT+4,
	parameter RESULT_SIZE = 4 
)
(

);

	reg clk=0;
	reg rst_n=0;
	reg invalid=0;
	always #10 clk=~clk;
	reg [WEIGHT_BIT-1:0]weight[0:WEIGHT_SIZE*WEIGHT_SIZE-1];
	reg [RESULT_BIT-1:0]weight_tb[0:RESULT_SIZE*RESULT_SIZE-1];
	reg [2:0] G_matrix [0:3][0:2];
	wire [RESULT_BIT*RESULT_SIZE*RESULT_SIZE-1:0]result;
	wire [WEIGHT_BIT*WEIGHT_SIZE*WEIGHT_SIZE-1:0]weight_wire;
	
	genvar i;
	generate
	for(i=0;i<WEIGHT_SIZE*WEIGHT_SIZE;i=i+1)
	begin:weight_wire_array
		assign weight_wire[WEIGHT_BIT*(i+1)-1:WEIGHT_BIT*i]=weight[i];
	end
	endgenerate
	
	initial
	begin
		$readmemh ("D:/jiantao/Winograd/weight_ori.txt",weight);
		$readmemh ("D:/jiantao/Winograd/weight.txt",weight_tb);
		@(posedge clk)
		rst_n=1;
		@(posedge clk)
		invalid=1;
	end

  Winograd_feature_weight_mult
	#(
		.WEIGHT_BIT(WEIGHT_BIT)
	)
	weight_mult
	(
		.clk(clk),
		.in_valid(invalid),
		.rst_n(rst_n),
		.weight(weight_wire),
		.result(result)
	);
endmodule
