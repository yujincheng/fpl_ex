`timescale 1ns / 1ps
module weightfifo_file#(
	parameter DATA_LEN = 64,
	parameter FILE_NAME = "D://study//boshi1//nics//huawei_cnn//validate_data//sim_data//weight_test.txt",
	parameter DATA_DEEPTH = 2,
	parameter RAM_DEPTH = 10000
)(
	input   wire clk,
	input   wire rst_n,
	output	wire [DATA_LEN - 1:0]	weights,
	output wire weight_empty,
	input wire weight_req
);


reg [DATA_LEN-1:0] weight_reg[RAM_DEPTH - 1:0];

generate
if (FILE_NAME != "") begin: use_init_file
  initial
	$readmemh(FILE_NAME, weight_reg, 0, DATA_DEEPTH-1);
end else begin: init_bram_to_zero
  integer ram_index;
  initial
	for (ram_index = 0; ram_index < RAM_DEPTH ; ram_index = ram_index + 1)
	  weight_reg[ram_index] = {DATA_LEN{1'b0}};
end
endgenerate
	
reg [clogb2(RAM_DEPTH-1)-1:0] index;
assign weights = weight_reg[index];
assign weight_empty = (index >= DATA_DEEPTH);

always@(posedge clk) begin
	if(!rst_n) begin
		index <= 0;
	end
	else if(!weight_empty && weight_req) begin
		index <= index+1;
	end
end

  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
endmodule