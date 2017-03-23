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
	
	input wire [SINGLE_LEN - 1:0] bias_num, // 需要一次读这么多个bias，bias=9代表所有bb中地址增加1个。在DDR中是连续 X_PE byte数
	input wire [SINGLE_LEN - 1:0] bias_ddr_byte, // X_PE*bias
	
	input wire [DDR_ADDR_LEN - 1:0] ddr_st_addr,
	input wire [ADDR_LEN - 1:0] bb_st_addr,
	
	output reg [DDR_ADDR_LEN - 1:0] ddr_st_addr_out,
	output reg [SINGLE_LEN - 1:0] ddr_len,
	output reg ddr_conf,
	
	
	input wire ddr_fifo_empty,
	output reg ddr_fifo_req,
	input wire [DATA_LEN - 1:0] ddr_fifo_data,
	
	
	output reg [ADDR_LEN - 1:0] bb_addr,
	output reg [DATA_LEN - 1:0] bb_data,
	output reg [BUFFER_NUM - 1:0] bb_wea,
	
	output wire idle

);

assign idle = !working;

reg working;
always @ (posedge clk) begin
	if(!rst_n) begin
		ddr_conf <= 0;
		ddr_len <= 0;
		ddr_st_addr_out <= 0;
		working <= 0;
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

reg [ADDR_LEN - 1:0] bb_st_addr_reg;
reg [ADDR_LEN - 1:0] bb_addr_reg;
reg [clogb2(BUFFER_NUM) - 1:0] count_buffer;
reg [SINGLE_LEN - 1:0] count_addr;
reg cto1;
reg [SINGLE_LEN - 1:0] bias_num_reg;

always@ (posedge clk) begin
	if(!rst_n) begin
		bb_addr <= 0;
	end
	else bb_addr <= bb_addr_reg;
end


always @ (posedge clk) begin
	if(!rst_n) begin
		bb_addr_reg <= 0;
		count_addr <= 0;
		count_buffer <= 0;
		bb_data <= 0;
		ddr_fifo_req <= 0;
		cto1 <= 0;
	end
	else if (conf) begin
		working <= 1;
		bb_st_addr_reg <= bb_st_addr;
		bb_addr_reg <= bb_st_addr;
		count_addr <= 0;
		bias_num_reg <= bias_num;
		count_buffer <= 0;
		ddr_fifo_req <= 0;
		bb_data <= 0;
		cto1 <= 0;
	end
	else if (working) begin
		if(!ddr_fifo_empty) begin
			ddr_fifo_req <= 1;
			bb_data <= ddr_fifo_data;
			if(cto1 == 0) begin
				bb_addr_reg <= bb_st_addr_reg;
				cto1 <= cto1 + 1;
			end
			else if(count_buffer == (BUFFER_NUM-1) && count_addr == (bias_num_reg-1) ) begin
				working <= 0;
				count_addr <= 0;
				count_buffer <= 0;
				bb_addr_reg <= 0;
			end
			else if(count_addr == (bias_num_reg-1)) begin
				count_addr <= 0;
				count_buffer <= count_buffer + 1;
				bb_addr_reg <= bb_st_addr_reg;
			end
			else begin
				count_addr <= count_addr + 1;
				bb_addr_reg <= bb_addr_reg + 1;
			end
		end
		else begin
			ddr_fifo_req <= 0;
		end
	end
	else begin
		ddr_fifo_req <= 0;
	end
end


integer i,j,k;
always @ (posedge clk) begin
	if(!rst_n) begin
		bb_wea <= 0;
	end
	else if(working) begin
		if(cto1 == 0) begin
			bb_wea <= 0;
		end
		else if(!ddr_fifo_empty) begin
			for (i = 0;i < BUFFER_NUM;i = i + 1) begin
				if( i == count_buffer) begin
					bb_wea[i] <= 1;
				end
				else begin
					bb_wea[i] <= 0;
				end
			end
		end
		else begin
			bb_wea <= 0;
		end
	end
	else begin
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