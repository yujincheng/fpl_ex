`timescale 1ps/1ps

module BP_WRITE_CONTROL #(	
	parameter X_MAC = 4,
	parameter X_PE = 16,
	parameter X_MESH = 16,
	parameter DDR_ADDR_LEN = 32,
	parameter ADDR_LEN = 16,
	parameter DATA_LEN = 32,
	parameter MUXCONTROL = 4,
	parameter SINGLE_LEN = 24,
	parameter BUFFER_NUM = 64
)(
	input wire clk,
	input wire rst_n,
	input wire conf,

	//input wire [SINGLE_LEN - 1:0] data_num, // 需要一次读这么多个weights，weights=1代表所有wb中地址增加4个。在DDR中是连续 9*X_PE*X_MESH byte数
	input wire [SINGLE_LEN - 1:0] data_ddr_byte, // X_PE*X_MESH*weights
	
	input wire [DDR_ADDR_LEN - 1:0] ddr_st_addr,
	input wire [ADDR_LEN - 1:0] BP_st_addr,
	input wire [2 - 1:0] BP_st_num,
	input wire [SINGLE_LEN - 1:0] Line_width,
	
	output reg [DDR_ADDR_LEN - 1:0] ddr_st_addr_out,
	output reg [SINGLE_LEN - 1:0] ddr_len,
	output reg ddr_conf,
	
	
	output wire ddr_write_empty,
	input wire ddr_write_req,
	output wire [DATA_LEN*16 - 1:0] ddr_write_data_out, //16 here is 512/DATA_LEN
	
	
	output wire [ADDR_LEN*BUFFER_NUM - 1:0] BP_addr_out,
	input wire [DATA_LEN*BUFFER_NUM - 1:0]  BP_data_in, //8 here is 512/DATA_LEN
	
	output wire idle
);


wire [DATA_LEN*16 - 1:0] ddr_write_data_mac[X_MAC - 1:0];

reg working;
reg working_r1;
reg[1:0] BP_num_reg;
reg[1:0] BP_num_reg_r1;
reg [SINGLE_LEN - 1:0] Line_width_reg;
reg[1:0] count_line;
reg [SINGLE_LEN - 1:0] count_in_line;
reg [DATA_LEN*16 - 1:0] ddr_write_data; // 16 here is 512/DATA_LEN
 reg [ADDR_LEN - 1:0] BP_addr_reg;
 wire ddr_fifo_near_full;
reg ddr_fifo_en;
reg ddr_fifo_en_r1;
reg ddr_fifo_en_r2;

assign idle = (!working && !working_r1);



genvar m,n,l;
generate
for (m=0;m<X_MESH;m = m+1) begin:singletomul1 
       for (n =0;n<X_MAC;n=n+1) begin:singletomul2
            assign BP_addr_out[n*ADDR_LEN+m*ADDR_LEN*X_MAC +: ADDR_LEN] = BP_addr_reg;
			assign ddr_write_data_mac[n][m*DATA_LEN +: DATA_LEN] = BP_data_in[n*DATA_LEN+m*DATA_LEN*X_MAC +: DATA_LEN];
       end
end
endgenerate

always @ * begin
	case (BP_num_reg_r1)
		2'd0: ddr_write_data = ddr_write_data_mac[0];
		2'd1: ddr_write_data = ddr_write_data_mac[1];
		2'd2: ddr_write_data = ddr_write_data_mac[2];
		2'd3: ddr_write_data = ddr_write_data_mac[3];
		default: ddr_write_data = ddr_write_data_mac[0];
	endcase
end
 
 
always @ (posedge clk) begin
	working_r1 <= working;
	BP_num_reg_r1 <= BP_num_reg;
	ddr_fifo_en_r1 <= ddr_fifo_en;
	ddr_fifo_en_r2 <= ddr_fifo_en_r1;
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
	else if (working) begin
		ddr_conf <= 0;
	end
end


always @ (posedge clk) begin
	if(!rst_n) begin
		ddr_fifo_en <= 0;
		BP_addr_reg <= 0;
		working <= 0;
		count_line <= 0;
		Line_width_reg <= 0;
		count_in_line <= 0;
		BP_num_reg <= 0;
	end
	else if (conf) begin
		working <= 1;
		BP_addr_reg <= BP_st_addr;
		count_line <= 0;
		Line_width_reg <= Line_width;
		count_in_line <= 0;
		BP_num_reg <= BP_st_num;
		ddr_fifo_en <= 1;
	end
	else if (working) begin
		if(!ddr_fifo_near_full) begin
			if(ddr_fifo_en) begin
				if(count_in_line == Line_width_reg-1 && count_line==1) begin
					working <= 0;
					count_in_line <= 0;
					BP_addr_reg <= 0;
					count_line <= 0;	
					ddr_fifo_en <= 0;
				end				
				else if(count_in_line == Line_width_reg-1 && count_line==0) begin
					count_in_line <= 0;
					count_line <= 1;
					BP_num_reg <= BP_num_reg + 1;
					BP_addr_reg <= BP_st_addr;
					ddr_fifo_en <= 1;
				end
				else if(count_in_line < Line_width_reg-1) begin
					BP_addr_reg <=  BP_addr_reg + 1;
					count_in_line <= count_in_line + 1;
					ddr_fifo_en <= 1;
				end
			end
		end
		else begin
			ddr_fifo_en <= 0;
		end
	end
	else begin
		ddr_fifo_en <= 0;
	end
end

   xip_fifo_64_64 x6464(
	  .clk(clk),
	  .srst(~rst_n),
	  .din(ddr_write_data),
	  .wr_en(ddr_fifo_en_r1),
	  .rd_en(ddr_write_req),
	  .dout(ddr_write_data_out),
	  .full(ddr_fifo_near_full),
	  .empty(ddr_write_empty)
	 );


endmodule

