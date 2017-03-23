`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/09 14:37:10
// Design Name: 
// Module Name: wino_outside_mat_mul_tb
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


module wino_outside_mat_mul_tb#(
	parameter MESH_X =2,
	parameter MESH_Y =4,
	parameter IN_BIT = 22,
	parameter MID_BIT = 24,
  parameter OUT_BIT = 26
)
();

reg clk=0;
reg rst_n=1;
reg ena;
reg signed [OUT_BIT-1:0] data_out_tb_array[0:MESH_X-1][0:MESH_X-1];
reg signed [MID_BIT-1:0] mid_data_out_array[0:MESH_Y-1][0:MESH_X-1];
reg signed [IN_BIT-1:0] data_in_array[0:MESH_Y-1][0:MESH_Y-1];

reg signed [2-1:0] A_matrix[0:MESH_Y-1][0:MESH_X-1];
    
wire [OUT_BIT*MESH_X*MESH_X-1:0]data_out;
wire [OUT_BIT-1:0]data_out_array[0:MESH_X-1][0:MESH_X-1];
wire [IN_BIT*MESH_Y*MESH_Y-1:0] data_in;

integer iter,x,y;

always #10 clk=~clk;

always @(posedge clk)
begin
    for(x=0;x<MESH_Y;x=x+1)
    	for(y=0;y<MESH_Y;y=y+1)
        data_in_array[y][x]=$random;
    for(x=0;x<MESH_X;x=x+1)
      for(y=0;y<MESH_Y;y=y+1)
      begin
      	mid_data_out_array[y][x]=0;
      	for(iter=0;iter<MESH_Y;iter=iter+1)
      	  mid_data_out_array[y][x]=mid_data_out_array[y][x]+data_in_array[y][iter]*A_matrix[iter][x];
      end
    for(x=0;x<MESH_X;x=x+1)
      for(y=0;y<MESH_X;y=y+1)
      begin
      	data_out_tb_array[y][x]=0;
      	for(iter=0;iter<MESH_Y;iter=iter+1)
      	  data_out_tb_array[y][x]=data_out_tb_array[y][x]+A_matrix[iter][y]*mid_data_out_array[iter][x];
      end      
end

generate
    genvar xx,yy;
    for(xx=0;xx<MESH_X;xx=xx+1)
    begin:data_out_x
			for(yy=0;yy<MESH_X;yy=yy+1)
      begin:data_out_y
      	assign data_out_array[yy][xx]=data_out[OUT_BIT*(yy*MESH_X+xx+1)-1:OUT_BIT*(yy*MESH_X+xx)];
    	end
    end
    for(xx=0;xx<MESH_Y;xx=xx+1)
    begin:data_in_x
			for(yy=0;yy<MESH_Y;yy=yy+1)
      begin:data_in_y
      	assign data_in[IN_BIT*(yy*MESH_Y+xx+1)-1:IN_BIT*(yy*MESH_Y+xx)]=data_in_array[yy][xx];
    	end
    end
endgenerate



initial
begin
		A_matrix[0][0]=1;A_matrix[0][1]=0;
		A_matrix[1][0]=1;A_matrix[1][1]=1;
		A_matrix[2][0]=1;A_matrix[2][1]=-1;
		A_matrix[3][0]=0;A_matrix[3][1]=-1;
    @(posedge clk);
    rst_n=0;
    @(posedge clk);
    rst_n=1;
    ena=1;
end





Winograd_outside_3input_lut #(
	.MESH_X(MESH_X),
	.MESH_Y(MESH_Y),
  .IN_BIT(IN_BIT)
)
	mat_mul
(
	.clk(clk),
	.clk_en(ena),
	.rst_n(rst_n),
  .data(data_in),
  .result(data_out)
);

endmodule
