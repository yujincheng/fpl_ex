`timescale 1ps/1ps
module Weight_FIFO_CONTROL#(
	parameter X_PE = 16,
	parameter X_MESH = 16,
	parameter DDR_ADDR_LEN = 32,
	parameter ADDR_LEN = 16,
	parameter DATA_LEN = 64,
	parameter MUXCONTROL = 4,
	parameter SINGLE_LEN = 24,
	parameter BUFFER_NUM = 8*X_PE*X_MESH/(DATA_LEN)
)(
	input wire clk,
	input wire rst_n,
	input wire conf,
	
	input wire [SINGLE_LEN - 1:0] weight_num, // ��Ҫһ�ζ���ô���weights��weights=1��������wb�е�ַ����4������DDR�������� 9*X_PE*X_MESH byte��
	input wire [SINGLE_LEN - 1:0] weight_ddr_byte, // X_PE*X_MESH*weights
	
	input wire [DDR_ADDR_LEN - 1:0] ddr_st_addr,
	input wire [ADDR_LEN - 1:0] wb_st_addr,
	
	output reg [DDR_ADDR_LEN - 1:0] ddr_st_addr_out,
	output reg [SINGLE_LEN - 1:0] ddr_len,
	output reg ddr_conf,
	
	
	input wire ddr_fifo_empty,
	output reg ddr_fifo_req,
	input wire [DATA_LEN* 8 - 1:0] ddr_fifo_data, //8 here is 512/DATA_LEN
	
	
	output reg [ADDR_LEN - 1:0] wb_addr,
	output reg [DATA_LEN* 8 - 1:0] wb_data, //8 here is 512/DATA_LEN
	output reg [BUFFER_NUM - 1:0] wb_wea,
	
	output wire idle

);
reg [ADDR_LEN - 1:0] wb_st_addr_reg;
reg [ADDR_LEN - 1:0] wb_addr_reg;
reg [clogb2(BUFFER_NUM) - 1:0] count_buffer;
reg [clogb2(BUFFER_NUM) - 1:0] count_buffer_next;
reg [SINGLE_LEN - 1:0] count_addr;
reg [4 - 1:0] cto9;
reg [SINGLE_LEN - 1:0] weight_num_reg;

reg working;

assign idle = !working;

always @ (posedge clk) begin
	if(!rst_n) begin
		ddr_conf <= 0;
		ddr_len <= 0;
		ddr_st_addr_out <= 0;
	end
	else if (conf) begin
		ddr_st_addr_out <= ddr_st_addr;
		ddr_len <= weight_ddr_byte;
		ddr_conf <= 1;
		
	end
	else if (working) begin
		ddr_conf <= 0;
	end

end


always@ * begin
	wb_addr <= wb_addr_reg;
end


always @ (posedge clk) begin
	if(!rst_n) begin
		wb_addr_reg <= 0;
		count_addr <= 0;
		count_buffer <= 0;
		count_buffer_next <= 0;
		wb_data <= 0;
		ddr_fifo_req <= 0;
		working <= 0;
		cto9 <= 0;
	end
	else if (conf) begin
		working <= 1;
		wb_st_addr_reg <= wb_st_addr;
		wb_addr_reg <= wb_st_addr;
		count_addr <= 0;
		weight_num_reg <= weight_num;
		count_buffer <= 0;
		count_buffer_next <= 0;
		ddr_fifo_req <= 0;
		wb_data <= 0;
		cto9 <= 0;
	end
	else if (working) begin
		if(!ddr_fifo_empty) begin
			ddr_fifo_req <= 1;
			if(ddr_fifo_req) begin
				wb_data <= ddr_fifo_data;
				if(cto9 == 0) begin
					wb_addr_reg <= wb_st_addr_reg;
					cto9 <= cto9 + 1;
				end
				else if(count_buffer == (BUFFER_NUM/8-1) && count_addr == (weight_num_reg-1) && cto9 == 8) begin //8 here is 512/DATA_LEN
					working <= 0;
					cto9 <= 0;
					count_addr <= 0;
					count_buffer <= 0;
					wb_addr_reg <= 0;
				end
				else if(count_addr == (weight_num_reg-1) && cto9 == 9) begin
					count_addr <= 0;
					count_buffer <= count_buffer + 1;
					cto9 <= 1;
					wb_addr_reg <= wb_st_addr_reg;
				end
				else if(count_addr == (weight_num_reg-1) && cto9 == 8) begin
					wb_addr_reg <= wb_addr_reg + 1;
					cto9 <= cto9 + 1;
					count_buffer_next <= count_buffer_next + 1;
				end
				else if(cto9 == 9) begin
					count_addr <= count_addr + 1;
					wb_addr_reg <= wb_addr_reg + 1;
					cto9 <= 1;
				end
				else if(cto9 > 0) begin
					wb_addr_reg <= wb_addr_reg + 1;
					cto9 <= cto9 + 1;
				end
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
		wb_wea <= 0;
	end
	else if(working) begin
		if(!ddr_fifo_empty && ddr_fifo_req) begin
			for (i = 0;i < BUFFER_NUM;i = i + 1) begin
				if( i >= 8*count_buffer_next && i <  8*(count_buffer_next+1)) begin //8 here is 512/DATA_LEN
					wb_wea[i] <= 1;
				end
				else begin
					wb_wea[i] <= 0;
				end
			end
		end
		else begin
			wb_wea <= 0;
		end
	end
	else begin
		wb_wea <= 0;
	end
end
  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
				
endmodule