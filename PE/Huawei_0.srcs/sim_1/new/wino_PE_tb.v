`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/09 22:59:24
// Design Name: 
// Module Name: wino_PE_tb
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


module wino_PE_tb#(
	parameter FEATURE_SIZE = 4,
	parameter RESULT_SIZE = 2,
	parameter DATA_BIT =8,
	parameter MESH_N=16,
	parameter WEIGHT_BIT = 8,
	parameter WEIGHT_SIZE =3, 
	parameter MESH_OUT_BIT = 20,
	parameter BIAS_BIT =20,
	parameter RESULT_BIT =24
  )
  (
  );
  reg clk=0;
  always #10 clk=~clk;
  reg rst_n=0;
  reg ce=0;
  reg acum=0;
  reg bias_valid=0;
  
  reg [WEIGHT_BIT-1:0] weight_reg_array [0:MESH_N*WEIGHT_SIZE*WEIGHT_SIZE-1];
  reg [DATA_BIT-1:0] data_reg_array [0:MESH_N*FEATURE_SIZE*FEATURE_SIZE-1];
  reg [RESULT_BIT-1:0] result_tb_reg_array [0:RESULT_SIZE*RESULT_SIZE-1];
  reg [BIAS_BIT-1:0] bias_tb_reg;
  
  
  wire[WEIGHT_BIT*MESH_N*WEIGHT_SIZE*WEIGHT_SIZE-1:0] weight_wire;
  wire[DATA_BIT*MESH_N*FEATURE_SIZE*FEATURE_SIZE-1:0] data_wire;
  wire[RESULT_BIT*RESULT_SIZE*RESULT_SIZE-1:0] result_wire;
  wire[RESULT_BIT-1:0] result_wire_array[0:RESULT_SIZE*RESULT_SIZE-1];
    
    
    
    
    
    initial
    begin
    	$readmemh ("D:/jiantao/Winograd/weight_ori.txt",weight_reg_array);
      $readmemh ("D:/jiantao/Winograd/feature.txt",data_reg_array);
      $readmemh ("D:/jiantao/Winograd/result.txt",result_tb_reg_array);
      bias_tb_reg<=$random;
      @(posedge clk)
      rst_n<=1;
      @(posedge clk)
      bias_valid<=1;
      ce<=1;
      @(posedge clk)
      bias_valid<=0;
      ce<=0;
      @(posedge clk)
      @(posedge clk)
      @(posedge clk)
      @(posedge clk)
      @(posedge clk)
      @(posedge clk)
      @(posedge clk)
      @(posedge clk)
      @(posedge clk)
      @(posedge clk)
      @(posedge clk)
      @(posedge clk)
      @(posedge clk)
      rst_n<=0;
      @(posedge clk)
      rst_n<=1;
      @(posedge clk)
      ce<=1;
      @(posedge clk)
      acum<=1;
      @(posedge clk)
      ce<=0;
      acum<=0;
    end
    
    generate
    genvar x,y;
    for(x=0;x<MESH_N*FEATURE_SIZE*FEATURE_SIZE;x=x+1)
    begin:feature
    		
    		assign data_wire[DATA_BIT*(x+1)-1:DATA_BIT*x]=data_reg_array[x];
    end
    for(x=0;x<MESH_N*WEIGHT_SIZE*WEIGHT_SIZE;x=x+1)
    begin:weight
    	assign weight_wire[WEIGHT_BIT*(x+1)-1:WEIGHT_BIT*x]=weight_reg_array[x];
    end
    for(x=0;x<RESULT_SIZE*RESULT_SIZE;x=x+1)
    begin:result
    		assign result_wire_array[x]=result_wire[RESULT_BIT*(x+1)-1:RESULT_BIT*x];
    end
    endgenerate
    
    wire data_valid;
    
	Winograd_PE
    #(
    	.FEATURE_SIZE(FEATURE_SIZE),
    	.WEIGHT_SIZE(WEIGHT_SIZE),
      .RESULT_SIZE(RESULT_SIZE),
      .DATA_BIT(DATA_BIT),
      .MESH_N(MESH_N),
      .WEIGHT_BIT(WEIGHT_BIT),
      .MESH_OUT_BIT(MESH_OUT_BIT),
      .OUT_BIT(RESULT_BIT)
    )
    PE
    (
    	.clk(clk),
    	.in_valid(ce),
    	.acum(acum),
    	.rst_n(rst_n),
    	.out_valid(data_valid),
    	.feature(data_wire),
    	.bias(bias_tb_reg),
    	.bias_valid(bias_valid),
    	.weight(weight_wire),
    	.inter_data(result_wire),
    	.result(result_wire)
    );
    
endmodule
