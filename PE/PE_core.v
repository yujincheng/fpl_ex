`timescale 1ps/1ps

module Winograd_PE_CORE
#(
	parameter FEATURE_SIZE = 4,
	parameter WEIGHT_SIZE =3,
  parameter RESULT_SIZE = 2,
  parameter DATA_BIT =8,
  parameter MESH_N=8,
  parameter WEIGHT_BIT = 8,
  parameter MESH_OUT_BIT =20,
  parameter OUT_BIT = 24,
  parameter BIAS_BIT = 20,
  parameter X_PE = 8
)
(
	input clk,
	input in_valid,
	input poolop,
	input rst_n,
	input [DATA_BIT*MESH_N*FEATURE_SIZE*FEATURE_SIZE-1:0]feature,
	input [WEIGHT_BIT*MESH_N*WEIGHT_SIZE*WEIGHT_SIZE*X_PE-1:0]weight,
	// input [OUT_BIT*RESULT_SIZE*RESULT_SIZE*X_PE-1:0]inter_data,
	
	input tofifo,
	input fromfifo,
	input [BIAS_BIT * X_PE - 1:0] bias,
	input bias_valid,
	
    output [OUT_BIT*RESULT_SIZE*RESULT_SIZE*X_PE-1:0] result_unpool,
    output [OUT_BIT*X_PE-1:0] result_pool,
	output out_valid
);

reg [10:0] in_valid_shift;
reg [10:0] tofifo_shift;
reg [10:0] fromfifo_shift;

always @ (posedge clk) begin:SFT
integer i;
integer j;
	if(!rst_n) begin
		in_valid_shift <= 0;
		tofifo_shift <= 0;
		fromfifo_shift <= 0;
	end else begin 
		in_valid_shift[0] <= in_valid;
		tofifo_shift[0] <= tofifo;
		fromfifo_shift[0] <= fromfifo;
		for (i = 1; i <= 10 ; i = i + 1) begin
			in_valid_shift[i] <= in_valid_shift[i-1];
			tofifo_shift[i] <= tofifo_shift[i-1];
			fromfifo_shift[i] <= fromfifo_shift[i-1];
		end
	end
end

wire write_en = in_valid_shift[7] && tofifo_shift[7];
wire read_en = in_valid_shift[6] && fromfifo_shift[6];
wire [X_PE-1:0] out_valid_mash;

genvar i;
generate
    for (i = 0; i < X_PE; i = i+1) begin: PE_GEN
	PE_GEN_UNIT
	pe_unit(
		.clk(clk),
        .rst_n(rst_n),
		.in_valid(in_valid),
		.poolop(poolop),
		.feature(feature),
		.weight(weight[i*WEIGHT_BIT*MESH_N*WEIGHT_SIZE*WEIGHT_SIZE +: WEIGHT_BIT*MESH_N*WEIGHT_SIZE*WEIGHT_SIZE]),
		
		.write_en(write_en),
		.read_en(read_en),
		.bias(bias[i*BIAS_BIT +: BIAS_BIT]),
		.bias_valid(bias_valid),
		
		.result_unpool(result_unpool[i*OUT_BIT*RESULT_SIZE*RESULT_SIZE +: OUT_BIT*RESULT_SIZE*RESULT_SIZE]),
		.result_pool(result_pool[i*OUT_BIT +: OUT_BIT]),
		.pool_valid(out_valid_mash[i])
		
	);
	
    end
endgenerate

assign out_valid = out_valid_mash[0];

endmodule

module PE_GEN_UNIT#(
  parameter FEATURE_SIZE = 4,
  parameter WEIGHT_SIZE =3,
  parameter RESULT_SIZE = 2,
  parameter DATA_BIT =8,
  parameter MESH_N=8,
  parameter WEIGHT_BIT = 8,
  parameter MESH_OUT_BIT =20,
  parameter OUT_BIT = 24,
  parameter BIAS_BIT = 20,
  parameter X_PE = 8
)(

	input clk,
	input rst_n,
	input in_valid,
	input poolop,
	input [DATA_BIT*MESH_N*FEATURE_SIZE*FEATURE_SIZE-1:0]		feature,
	input [WEIGHT_BIT*MESH_N*WEIGHT_SIZE*WEIGHT_SIZE-1:0]		weight,
	// input [OUT_BIT*RESULT_SIZE*RESULT_SIZE*X_PE-1:0]inter_data,
	
	input write_en,
	input read_en,
	input [BIAS_BIT - 1:0] bias,
	input bias_valid,
	
	output pool_valid,
	output [OUT_BIT*RESULT_SIZE*RESULT_SIZE-1:0] result_unpool,
	output [OUT_BIT -1 :0] result_pool
);



	wire out_valid_in;
	wire [OUT_BIT*RESULT_SIZE*RESULT_SIZE - 1:0] before_pool;
	wire [OUT_BIT*RESULT_SIZE*RESULT_SIZE - 1:0] inter_data;
	wire full;
	wire empty;
    Winograd_PE #(
		.FEATURE_SIZE(FEATURE_SIZE),
		.WEIGHT_SIZE(WEIGHT_SIZE), 
		.RESULT_SIZE(RESULT_SIZE), 
		.DATA_BIT(DATA_BIT),    
		.MESH_N(MESH_N),      
		.WEIGHT_BIT(WEIGHT_BIT),  
		.MESH_OUT_BIT(MESH_OUT_BIT),
		.OUT_BIT(OUT_BIT)       
		) WPE
        (
            .clk(clk),
            .in_valid(in_valid),
            .rst_n(rst_n),
            .feature(feature),
            .weight(weight),
            .inter_data(	read_en ? inter_data : 0),
			.bias(bias),
			.bias_valid(bias_valid),
            .result(before_pool),
			.out_valid(out_valid_in)
        );
		
		Pool_block
		#(
			.IN_BIT(24),
			.IN_SIZE(2),
			.OUT_SIZE(1)
		)
		pool_block
		(
			.clk(clk),
			.op(poolop),
			.in_valid(out_valid_in),
			.out_valid(pool_valid),
			.in_data(before_pool),
			.out_data_pool(result_pool),
			.out_data_unpool(result_unpool)
		);
		
		xip_fifo_96_1k interfifo(
		  .clk(clk),      
		  .srst(!rst_n),  
		  .din(before_pool),     
		  .wr_en(write_en), 
		  .rd_en(read_en), 
		  .dout(inter_data),   
		  .full(full),   
		  .empty(empty)  
		);
    endmodule
