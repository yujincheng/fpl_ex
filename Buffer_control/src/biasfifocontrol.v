`timescale 1ps/1ps
module Bias_FIFO_CONTROL#(
	parameter X_PE = 16,
	parameter DDR_ADDR_LEN = 32,
	parameter ADDR_LEN = 16,
	parameter DATA_LEN = 64,
	parameter MUXCONTROL = 4,
	parameter RAM_DEPTH = 2**ADDR_LEN,
	parameter SINGLE_LEN = 24,
	parameter BUFFER_NUM = 8*X_PE/(DATA_LEN)
)(
	input wire clk,
	input wire rst_n,
	input wire conf,
	
	input wire [SINGLE_LEN - 1:0] bias_num, // ��Ҫһ�ζ���ô���bias��bias=1��������bb�е�ַ����1������DDR�������� X_PE byte��
	input wire [SINGLE_LEN - 1:0] bias_ddr_byte, // X_PE*bias
	
	input wire [DDR_ADDR_LEN - 1:0] ddr_st_addr,
	input wire [ADDR_LEN - 1:0] bb_st_addr,
	
	output reg [DDR_ADDR_LEN - 1:0] ddr_st_addr_out,
	output reg [SINGLE_LEN - 1:0] ddr_len,
	output reg ddr_conf,
	
	
	input wire ddr_fifo_empty,
	output reg ddr_fifo_req,
	input wire [DATA_LEN*BUFFER_NUM - 1:0] ddr_fifo_data,
	
	
	output reg [ADDR_LEN - 1:0] bb_addr,
	output reg [DATA_LEN*BUFFER_NUM - 1:0] bb_data,
	output reg [BUFFER_NUM - 1:0] bb_wea,
	
	output wire idle

);

reg [ADDR_LEN - 1:0] bb_st_addr_reg;
reg [ADDR_LEN - 1:0] bb_addr_reg;
reg [clogb2(BUFFER_NUM) - 1:0] count_buffer;
reg [SINGLE_LEN - 1:0] count_addr;
reg cto1;
reg [SINGLE_LEN - 1:0] bias_num_reg;
reg working;

assign idle = !working;

always @ (posedge clk) begin
	bb_addr <= bb_addr_reg;
	
end


always @ (posedge clk) begin
	if(!rst_n) begin
		ddr_conf <= 0;
		ddr_len <= 0;
		ddr_st_addr_out <= 0;
	end
	else if (conf) begin
		ddr_st_addr_out <= ddr_st_addr;
		ddr_len <= bias_ddr_byte;
		ddr_conf <= 1;
		
	end
	else if (working) begin
		ddr_conf <= 0;
	end

end


always @ (posedge clk) begin
	if(!rst_n) begin
		bb_addr_reg <= 0;
		count_addr <= 0;
		bb_data <= 0;
		ddr_fifo_req <= 0;
		cto1 <= 0;
		working <= 0;
		bb_wea <= 0;
	end
	else if (conf) begin
		working <= 1;
		bb_st_addr_reg <= bb_st_addr;
		bb_addr_reg <= bb_st_addr;
		count_addr <= 0;
		bias_num_reg <= bias_num;
		ddr_fifo_req <= 0;
		bb_data <= 0;
		bb_wea <= 0;
	end
	else if (working) begin
		if(!ddr_fifo_empty) begin
			ddr_fifo_req <= 1;
			if(ddr_fifo_req) begin
				bb_data <= ddr_fifo_data;
				bb_addr_reg <= bb_addr_reg + 1;
				bb_wea <= 8'hff;
				if(count_addr < bias_num_reg-1) begin
					count_addr <= count_addr + 1;
				end
				else begin
					count_addr <= 0;
					working <= 0;
				end
			end
		end
		else begin
			ddr_fifo_req <= 0;
			bb_wea <= 0;
		end
	end
	else begin
		ddr_fifo_req <= 0;
		bb_wea <= 0;
	end
end


  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
				
endmodule