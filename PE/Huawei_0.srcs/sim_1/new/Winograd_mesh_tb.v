`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/09 15:42:49
// Design Name: 
// Module Name: Winograd_mesh_tb
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


module Winograd_mesh_tb #(
	parameter FEATURE_SIZE = 4,
	parameter RESULT_SIZE = 2,
	parameter DATA_BIT =8,
	parameter WEIGHT_BIT = 12,
	parameter BIAS_BIT = 20,
	parameter RESULT_BIT = 26
)
(
);
	
	
	reg [WEIGHT_BIT-1:0] weight_reg_array [0:FEATURE_SIZE*FEATURE_SIZE-1];
	reg [DATA_BIT-1:0] data_reg_array [0:FEATURE_SIZE*FEATURE_SIZE-1];
	reg [RESULT_BIT-1:0] result_tb_reg_array [0:RESULT_SIZE*RESULT_SIZE-1];
	reg [BIAS_BIT-1:0] bias_tb_reg;
	wire[WEIGHT_BIT*FEATURE_SIZE*FEATURE_SIZE-1:0] weight_wire;
	wire[DATA_BIT*FEATURE_SIZE*FEATURE_SIZE-1:0] data_wire;
	wire[RESULT_BIT*RESULT_SIZE*RESULT_SIZE-1:0] result_wire;
	wire[RESULT_BIT-1:0] result_wire_array[0:RESULT_SIZE*RESULT_SIZE-1];
	
	initial
	begin
		$readmemh ("D:/jiantao/Winograd/weight.txt",weight_reg_array);
	  $readmemh ("D:/jiantao/Winograd/feature.txt",data_reg_array);
	  $readmemh ("D:/jiantao/Winograd/result.txt",result_tb_reg_array);
	end
	
	generate
	genvar x,y;
	for(x=0;x<FEATURE_SIZE*FEATURE_SIZE;x=x+1)
	begin:feature
			assign weight_wire[WEIGHT_BIT*(x+1)-1:WEIGHT_BIT*x]=weight_reg_array[x];
			assign data_wire[DATA_BIT*(x+1)-1:DATA_BIT*x]=data_reg_array[x];
	end
	for(x=0;x<RESULT_SIZE*RESULT_SIZE;x=x+1)
	begin:result
			assign result_wire_array[x]=result_wire[RESULT_BIT*(x+1)-1:RESULT_BIT*x];
	end
	endgenerate
	
	
	Winograd_mesh
	#(
		.FEATURE_SIZE(FEATURE_SIZE),
		.RESULT_SIZE(RESULT_SIZE),
		.DATA_BIT(DATA_BIT),
		.WEIGHT_BIT(WEIGHT_BIT)
	)
	wino_mesh
	(
		.feature(data_wire),
		.weight(weight_wire),
		.result(result_wire)
	);
	
endmodule
