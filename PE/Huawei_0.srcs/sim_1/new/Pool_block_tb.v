`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/20 13:57:18
// Design Name: 
// Module Name: Pool_block_tb
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


module Pool_block_tb
#(
  parameter IN_BIT = 24,
  parameter IN_SIZE = 2,
  parameter OUT_BIT = IN_BIT,
  parameter OUT_SIZE =1
)
(
);
	reg clk=0;
	reg op=0;
	always #10 clk=~clk;
	reg in_valid=0;
	wire out_valid;
	wire [IN_BIT*IN_SIZE*IN_SIZE-1:0] in_data;
	reg signed [IN_BIT-1:0] in_data_reg_array [0:IN_SIZE*IN_SIZE-1];
	
	generate
	genvar i;
		for(i=0;i<IN_SIZE*IN_SIZE;i=i+1)
		begin:in_wire
			assign in_data[IN_BIT*(i+1)-1:IN_BIT*i]=in_data_reg_array[i];
		end
	endgenerate
	
	always@(posedge clk)
	begin
		in_data_reg_array[0]<=$random;
		in_data_reg_array[1]<=$random;
		in_data_reg_array[2]<=$random;
		in_data_reg_array[3]<=$random;
	end
	
	
	initial
	begin
		@(posedge clk);
		@(posedge clk);
		in_valid<=1;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		op<=1;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		in_valid<=0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		in_valid<=1;
	end
	wire [OUT_BIT*OUT_SIZE*OUT_SIZE-1:0] out_data_pool;
	wire [OUT_BIT*IN_SIZE*IN_SIZE-1:0] out_data_unpool;
	Pool_block
	#(
		.IN_BIT(IN_BIT),
		.IN_SIZE(IN_SIZE),
		.OUT_SIZE(OUT_SIZE)
	)
	pool_block
	(
		.clk(clk),
		.op(op),
		.in_valid(in_valid),
		.out_valid(out_valid),
		.in_data(in_data),
		.out_data_pool(out_data_pool),
		.out_data_unpool(out_data_unpool)
	);
    
endmodule
