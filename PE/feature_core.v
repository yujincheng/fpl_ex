`timescale 1ps/1ps

module feature_mesh#(
	parameter FEATURE_SIZE = 4,
    parameter RESULT_SIZE = 2,
    parameter DATA_BIT =8,
    parameter MESH_N = 8,
    parameter FEATURE_RESULT_BIT=DATA_BIT+1
)(

	input clk,
	input rst_n,
	input [MESH_N* DATA_BIT*FEATURE_SIZE*FEATURE_SIZE -1:0] feature,
	output [MESH_N*FEATURE_RESULT_BIT*FEATURE_SIZE*FEATURE_SIZE-1:0] feature_result
);

genvar i;
generate
    for(i=0;i<MESH_N;i=i+1) begin: Feater_gen
	Winograd_feature_matrix_mult
	#(
		.MESH_X(FEATURE_SIZE),
		.MESH_Y(FEATURE_SIZE),
  	.IN_BIT(DATA_BIT)
	)
	feature_matrix_mult
	(
		.clk(clk),
		.rst_n(rst_n),
	  .data(feature[DATA_BIT*FEATURE_SIZE*FEATURE_SIZE*(i+1)-1:DATA_BIT*FEATURE_SIZE*FEATURE_SIZE*i]),
	  .result(feature_result[FEATURE_RESULT_BIT*FEATURE_SIZE*FEATURE_SIZE*(i+1)-1:FEATURE_RESULT_BIT*FEATURE_SIZE*FEATURE_SIZE*i])
	);
    end
endgenerate

endmodule
