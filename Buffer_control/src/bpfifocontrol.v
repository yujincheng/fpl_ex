`timescale 1ps/1ps

module BP_FIFO_CONTROL #(	
	parameter X_MAC = 4,
	parameter X_PE = 16,
	parameter X_MESH = 16,
	parameter DDR_ADDR_LEN = 32,
        parameter DDR_DATA_LEN = 256,
	parameter ADDR_LEN = 16,
	parameter DATA_LEN = 32,
	parameter MUXCONTROL = 4,
	parameter SINGLE_LEN = 24,
	parameter BUFFER_NUM = X_MAC*X_MESH
)(
	input wire clk,
	input wire rst_n,
	input wire conf,

	//input wire [SINGLE_LEN - 1:0] data_num, // ��Ҫһ�ζ���ô���weights��weights=1��������wb�е�ַ����4������DDR�������� 9*X_PE*X_MESH byte��
	input wire [SINGLE_LEN - 1:0] data_ddr_byte, // X_PE*X_MESH*weights
	
	input wire [DDR_ADDR_LEN - 1:0] ddr_st_addr,
	input wire [ADDR_LEN - 1:0] BP_st_addr,
	input wire [2 - 1:0] BP_st_num,
	input wire [SINGLE_LEN - 1:0] Line_width,
	
	output reg [DDR_ADDR_LEN - 1:0] ddr_st_addr_out,
	output reg [SINGLE_LEN - 1:0] ddr_len,
	output reg ddr_conf,
	
	
	input wire ddr_fifo_empty,
	output reg ddr_fifo_req,
	input wire [DDR_DATA_LEN - 1:0] ddr_fifo_data, //8 here is 256/DATA_LEN
	
	output wire [ADDR_LEN*BUFFER_NUM - 1:0] BP_addr_out,
	output wire [DATA_LEN*BUFFER_NUM - 1:0]  BP_data_out, //8 here is 256/DATA_LEN
	output reg [BUFFER_NUM - 1:0] BP_wea,
	
	output wire idle
);



reg working_read;
reg working_read_r1;
reg[1:0] BP_num_reg;
reg [SINGLE_LEN - 1:0] Line_width_reg;
reg[1:0] count_line;
reg [SINGLE_LEN - 1:0] count_in_line;
 reg [ADDR_LEN - 1:0] BP_addr_reg;
 reg [ADDR_LEN - 1:0] BP_addr; 
reg [DDR_DATA_LEN - 1:0] BP_data; // 8 here is 256/DATA_LEN


 genvar m,n;
generate
for (m=0;m<X_MESH;m = m+1) begin:singletomul1 
       for (n =0;n<X_MAC;n=n+1) begin:singletomul2
            assign BP_addr_out[n*ADDR_LEN+m*ADDR_LEN*X_MAC +: ADDR_LEN] = BP_addr;
			assign BP_data_out[n*DATA_LEN+m*DATA_LEN*X_MAC +: DATA_LEN] = BP_data[m*DATA_LEN +: DATA_LEN];
       end
end
endgenerate


assign idle = (!working_read && !working_read_r1);
always @ (posedge clk) begin
	BP_addr <= BP_addr_reg;
	working_read_r1 <= working_read;
end 

always @ (posedge clk) begin
	if(!rst_n) begin
		ddr_conf <= 0;
		ddr_len <= 0;
		ddr_st_addr_out <= 0;
	end
	else if (conf) begin
		ddr_st_addr_out <= ddr_st_addr;
		ddr_len <= data_ddr_byte;
		ddr_conf <= 1;
	end
	else if (working_read) begin
		ddr_conf <= 0;
	end
end


always @ (posedge clk) begin
	if(!rst_n) begin
		BP_data <= 0;
		ddr_fifo_req <= 0;
		BP_addr_reg <= 0;
		working_read <= 0;
		count_line <= 0;
		Line_width_reg <= 0;
		count_in_line <= 0;
		BP_num_reg <= 0;
	end
	else if (conf) begin
		working_read <= 1;
		BP_addr_reg <= BP_st_addr;
		count_line <= 0;
		Line_width_reg <= Line_width;
		count_in_line <= 0;
		BP_num_reg <= BP_st_num;
	end
	else if (working_read) begin
		if(!ddr_fifo_empty) begin
			ddr_fifo_req <= 1;
			if(ddr_fifo_req) begin
				BP_data <= ddr_fifo_data;
				if(count_in_line == Line_width_reg-1 && count_line==1) begin
					working_read <= 0;
					count_in_line <= 0;
					BP_addr_reg <= 0;
					count_line <= 0;						
				end				
				else if(count_in_line == Line_width_reg-1 && count_line==0) begin
					count_in_line <= 0;
					count_line <= 1;
					BP_num_reg <= BP_num_reg + 1;
					BP_addr_reg <= BP_st_addr;
				end
				else if(count_in_line < Line_width_reg-1) begin
					BP_addr_reg <=  BP_addr_reg + 1;
					count_in_line <= count_in_line + 1;
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

integer i,j;
always @ (posedge clk) begin
	if(!rst_n) begin
		BP_wea <= 0;
	end
	else if(working_read) begin
		if(!ddr_fifo_empty && ddr_fifo_req) begin
			for (i = 0;i < X_MAC;i = i + 1) begin
				for (j = 0;j < X_MESH;j = j + 1) begin					
					if( i == BP_num_reg) begin
						BP_wea[i+X_MAC*j] <= 1;
					end
					else begin
						BP_wea[i+X_MAC*j] <= 0;
					end
				end
			end
		end
		else begin
			BP_wea <= 0;
		end
	end
	else begin
		BP_wea <= 0;
	end
end


endmodule

