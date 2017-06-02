`timescale 1ps/1ps

module Winograd_PE_CORE
#(
	parameter FEATURE_SIZE = 4,
	parameter WEIGHT_SIZE =3,
  parameter RESULT_SIZE = 2,
  parameter DATA_BIT =8,
  parameter MESH_N=16,
  parameter WEIGHT_BIT = 8,
  parameter MESH_OUT_BIT =20,
  parameter OUT_BIT = 24,
  parameter BIAS_BIT = 20,
  parameter X_PE = 16
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
	
	output out_valid,
	output [OUT_BIT*RESULT_SIZE*RESULT_SIZE*X_PE-1:0] result_unpool,
	output [OUT_BIT*X_PE-1:0] result_pool
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

wire write_en = in_valid_shift[7] && tofifo_shift[7] && !PE_GEN[0].full;
wire read_en = in_valid_shift[6] && fromfifo_shift[6] && !PE_GEN[0].empty;
(*DONT_TOUCH = "yes"*)wire out_valid_in;
(*DONT_TOUCH = "yes"*)wire pool_valid_in;



genvar i,j,k;
generate
    for (i = 0; i < X_PE; i = i+1) begin: PE_GEN
	(*DONT_TOUCH = "yes"*)wire [OUT_BIT*RESULT_SIZE*RESULT_SIZE - 1:0] before_pool;
	(*DONT_TOUCH = "yes"*)wire [OUT_BIT*RESULT_SIZE*RESULT_SIZE - 1:0] inter_data;
	(*DONT_TOUCH = "yes"*)wire full;
	(*DONT_TOUCH = "yes"*)wire empty;
       if(i == 0) begin 
        (*DONT_TOUCH = "yes"*)
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
            .weight(weight[i*WEIGHT_BIT*MESH_N*WEIGHT_SIZE*WEIGHT_SIZE +: WEIGHT_BIT*MESH_N*WEIGHT_SIZE*WEIGHT_SIZE]),
            .inter_data(fromfifo_shift[6] ? inter_data : 0),
			.bias(bias[i*BIAS_BIT +: BIAS_BIT]),
			.bias_valid(bias_valid),
            .result(before_pool),
			.out_valid(out_valid_in)
        );
		
		(*DONT_TOUCH = "yes"*)Pool_block
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
			.out_valid(pool_valid_in),
			.in_data(before_pool),
			.out_data_pool(result_pool[i*OUT_BIT +: OUT_BIT]),
			.out_data_unpool(result_unpool[i*OUT_BIT*RESULT_SIZE*RESULT_SIZE +: OUT_BIT*RESULT_SIZE*RESULT_SIZE])
		);
		
		(*DONT_TOUCH = "yes"*)xip_fifo_96_1k interfifo(
		  .clk(clk),      
		  .srst(!rst_n),  
		  .din(before_pool),     
		  .wr_en(write_en), 
		  .rd_en(read_en), 
		  .dout(inter_data),   
		  .full(full),   
		  .empty(empty)  
		);
    end
    else begin
                (*DONT_TOUCH = "yes"*)
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
            //            .rst_n(rst_n),
                    .feature(feature),
                    .weight(weight[i*WEIGHT_BIT*MESH_N*WEIGHT_SIZE*WEIGHT_SIZE +: WEIGHT_BIT*MESH_N*WEIGHT_SIZE*WEIGHT_SIZE]),
                    .inter_data(fromfifo_shift[6] ? inter_data : 0),
                    .bias(bias[i*BIAS_BIT +: BIAS_BIT]),
                    .bias_valid(bias_valid),
                    .result(before_pool)
//                    .out_valid(out_valid_in)
                );
                
                (*DONT_TOUCH = "yes"*)Pool_block
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
//                    .out_valid(pool_valid_in),
                    .in_data(before_pool),
                    .out_data_pool(result_pool[i*OUT_BIT +: OUT_BIT]),
                    .out_data_unpool(result_unpool[i*OUT_BIT*RESULT_SIZE*RESULT_SIZE +: OUT_BIT*RESULT_SIZE*RESULT_SIZE])
                );
                
                (*DONT_TOUCH = "yes"*)xip_fifo_96_1k interfifo(
                  .clk(clk),      
                  .srst(!rst_n),  
                  .din(before_pool),     
                  .wr_en(write_en), 
                  .rd_en(read_en), 
                  .dout(inter_data),   
                  .full(full),   
                  .empty(empty)  
                );
            end
    
    end
endgenerate

assign out_valid = pool_valid_in;

endmodule
