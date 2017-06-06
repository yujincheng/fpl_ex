`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/09 10:55:33
// Design Name: 
// Module Name: wino_mat_mult_raw_tb
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


module wino_mat_mult_raw_tb #(
	parameter IN_BIT = 8,
  parameter OUT_BIT = 9
)
();
    
reg clk=0;
reg rst_n=1;
reg ena=1;
reg signed [OUT_BIT-1:0] data_out_tb_array[4-1:0];
reg signed [IN_BIT-1:0] data_array[4-1:0];

reg signed [2-1:0] B_matrix[4-1:0][4-1:0];
    
wire [OUT_BIT*4-1:0]data_out;
wire [OUT_BIT-1:0]data_out_array[4-1:0];
wire [IN_BIT*4-1:0] data_in;

integer iter,x;

always #10 clk=~clk;

always @(posedge clk)
begin
    for(iter=0;iter<4;iter=iter+1)
        data_array[iter]=$random;
    for(iter=0;iter<4;iter=iter+1)
    begin
      data_out_tb_array[iter]=0;
    	for(x=0;x<4;x=x+1)
    	 	data_out_tb_array[iter]=data_out_tb_array[iter]+data_array[x]*B_matrix[x][iter];
    end
end


genvar i;
generate
    for(i=0;i<4;i=i+1)
    begin:inter_
        assign data_out_array[i]=data_out[(i+1)*OUT_BIT-1:i*OUT_BIT];
    end
    for(i=0;i<4;i=i+1)
    begin:in_data_
        assign data_in[(1+i)*IN_BIT-1:i*IN_BIT]=data_array[i];
    end        
endgenerate



initial
begin
		B_matrix[0][0]=1;B_matrix[0][1]=0;B_matrix[0][2]=0;B_matrix[0][3]=0;
		B_matrix[1][0]=0;B_matrix[1][1]=1;B_matrix[1][2]=-1;B_matrix[1][3]=1;
		B_matrix[2][0]=-1;B_matrix[2][1]=1;B_matrix[2][2]=1;B_matrix[2][3]=0;
		B_matrix[3][0]=0;B_matrix[3][1]=0;B_matrix[3][2]=0;B_matrix[3][3]=-1;
    @(posedge clk);
    rst_n=0;
    @(posedge clk);
    rst_n=1;
    ena=1;
end
Winograd_matrix_mul_raw_8to9
#(
  .IN_BIT(IN_BIT),
  .OUT_BIT(OUT_BIT)
)
  mul_raw
(
	.clk(clk),
	.clk_en(ena),
	.rst_n(rst_n),
  .data(data_in),
  .result(data_out)
);

endmodule
