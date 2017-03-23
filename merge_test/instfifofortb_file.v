`timescale 1ns / 1ps
module instfifo_file#(
	parameter X_PE = 16,
	parameter X_MAC = 4,
	parameter X_MESH = 16,
	parameter ADDR_LEN_W = 9,
	parameter ADDR_LEN_D = 9,
	parameter INST_LEN = 160,
	parameter FILE_NAME = "D://tsinghua//boshi1//nics//huawei_cnn//validate_data//sim_data//inst.txt",
	parameter INST_DEEPTH = 2,
	parameter RAM_DEPTH = 10000,
	parameter COM_DATALEN = 24
)(
	input   wire clk,
	input   wire rst_n,
	output	wire [INST_LEN - 1:0]	instruct,
										//  ilc_st_addr 35:0 
										//	ilc_ispad 36:36
										//	ilc_linelen 45:37
										//	bsr_iszero 49:46
										//	bsr_buffermux 57:50
										//	ilc_fromfifo 58:58
										//	ilc_tofifo 59:59
										//	is_w2c_back 60:60
										//  w2c_st_addr 96:61
	                                    //  w2c_linelen 105:97
	                                    //	w2c_pooled  106:106
	                                    //  pooled_type 107:107
										//  wb_st_rd_addr 116:108
										//  w2c_shift_len 121:117
										//	w2c_valid_mac 123:122
										//  is_bb_        124:124
										//  bias_addr     131:125
										//  bias_shift    136:132
									
	output wire inst_empty,
	input wire inst_req
);


reg [INST_LEN-1:0] inst_reg[RAM_DEPTH - 1:0];

generate
if (FILE_NAME != "") begin: use_init_file
  initial
	$readmemh(FILE_NAME, inst_reg, 0, INST_DEEPTH-1);
end else begin: init_bram_to_zero
  integer ram_index;
  initial
	for (ram_index = 0; ram_index < RAM_DEPTH ; ram_index = ram_index + 1)
	  inst_reg[ram_index] = {INST_LEN{1'b0}};
end
endgenerate
	
reg [clogb2(RAM_DEPTH-1)-1:0] index;
assign instruct = inst_reg[index];
assign inst_empty = (index >= INST_DEEPTH);

always@(posedge clk) begin
	if(!rst_n) begin
		index <= 0;
	end
	else if(!inst_empty && inst_req) begin
		index <= index+1;
	end
end

  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
endmodule