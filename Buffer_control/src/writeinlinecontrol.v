`timescale 1ps/1ps
module writeinlinecontrol#(
parameter X_MAC = 4,
parameter X_MESH = 16,
parameter ADDR_LEN = 13,
parameter DATA_LEN = 32,
parameter COM_DATALEN = 24,
parameter MUXCONTROL = 4,
parameter MAX_LINE_LEN = 10,
parameter RAM_DEPTH = 2**ADDR_LEN,
parameter BUFFER_NUM = X_MAC*X_MESH,
parameter DATAWIDTH = BUFFER_NUM*DATA_LEN,
parameter ADDRWIDTH = BUFFER_NUM*ADDR_LEN
)(
input wire[ADDR_LEN*X_MAC - 1:0] st_addr,
input wire [MAX_LINE_LEN - 1:0] linelen,
input wire [1:0] valid_mac,

output wire [ADDRWIDTH-1:0] addra,
output wire [DATAWIDTH-1:0] data_a,
output wire [BUFFER_NUM - 1:0] wea,
output wire ready,

input wire [4*COM_DATALEN*X_MESH - 1:0]  in_data,
input wire [3:0] shift_len,

input wire valid,

input rst_n,
input clk

);

wire [8 - 1:0] in_data_split[X_MESH-1:0][2-1:0][2-1:0];

wire [COM_DATALEN - 1:0] in_data_split_before_shift[X_MESH-1:0][2-1:0][2-1:0];
wire [ADDR_LEN-1:0] addra_show[X_MESH-1:0][X_MAC-1:0];
reg wea_show[X_MESH-1:0][X_MAC-1:0];

reg out_valid_1;//
reg  [MUXCONTROL - 1:0] control;
reg working;
reg [MAX_LINE_LEN - 1:0] linelen_left;
reg [DATA_LEN-1:0] data_a_show[X_MESH-1:0][X_MAC-1:0];

localparam ST_IDLE = 0;
localparam ST_EN = 1;
localparam ST_ODD = 2;


reg [ADDR_LEN - 1:0]  st_addr_show[X_MAC-1:0];

genvar i,j,k;
generate
for (i=0;i<X_MESH;i = i+1) begin:ass   
       for (j =0;j<X_MAC;j=j+1) begin:assh
            assign addra[j*ADDR_LEN+i*ADDR_LEN*X_MAC +: ADDR_LEN] = addra_show[i][j];
			assign addra_show[i][j] = st_addr_show[j];
			assign data_a[j*DATA_LEN+i*DATA_LEN*X_MAC +: DATA_LEN] = data_a_show[i][j];
			assign wea[j+i*X_MAC] = wea_show[i][j];
       end
end
for (i=0;i<X_MESH;i = i+1) begin:ass2   
       for (j =0;j<2;j =j+1) begin:assh
		for (k =0;k<2;k = k+1) begin:assh3
            assign in_data_split_before_shift[i][j][k] = in_data[k*COM_DATALEN + j*COM_DATALEN*2 +i*COM_DATALEN*4 +: COM_DATALEN];			
            assign in_data_split[i][j][k] = (in_data_split_before_shift[i][j][k] >> shift_len);
		end
       end
end
endgenerate


always @ (posedge clk) begin: aclk
integer i;
integer j;	
	if (!rst_n) begin
		working <= 0;
		control <= ST_IDLE;
	end
	else begin: ere
		if(valid) begin
			for (j =0;j<X_MAC;j=j+1) begin:assh
				st_addr_show[j] <= st_addr[j*ADDR_LEN +: ADDR_LEN];
			end
			working <= 1;
			linelen_left <= linelen - 2;
			if(linelen > 2) begin
				control <= ST_ODD;
			end
			else begin
				control <= ST_EN;
			end
		end
		else if (working)begin
			case(control)
			ST_IDLE: control <=  control;
			ST_ODD: begin
				control <= ST_EN;
			end
			ST_EN: begin
				if(linelen_left > 2) begin
					control <= ST_ODD;
				end
				else if(linelen_left > 0) begin
					control <= ST_EN;
				end
				else begin
					control <= ST_IDLE;
				end
				for (j =0;j<X_MAC;j=j+1) begin:assj
					st_addr_show[j] <=st_addr_show[j] + 1;
				end
			end
			endcase
			
			if (linelen_left >= 2) linelen_left <= linelen_left - 2;
			else if (linelen_left == 1) begin
				linelen_left <= 0;
			end
			else working <= 0;
		end
	end
end



generate
for (i=0;i<X_MESH;i = i+1) begin:assi
	for (j = 0;j< 4;j = j+1) begin:asso
		always @ (posedge clk) begin
			if (valid_mac == j && working)begin
				data_a_show[i][j] <= {data_a_show[i][j][0 +: 16],in_data_split[i][0][0],in_data_split[i][0][1]};
			end
			else if(valid_mac == (j == 3)? 0 : (j+1) && working) begin
				data_a_show[i][j] <= {data_a_show[i][j][0 +: 16],in_data_split[i][1][0],in_data_split[i][1][1]};
			end
		end
		always @ (posedge clk) begin
			if (valid_mac == j && control == ST_EN && working) begin
				wea_show[i][j] <= 1;
			end
			else if(valid_mac == (j == 3)? 0 : (j+1) && control == ST_EN && working) begin
				wea_show[i][j] <= 1;
			end
			else begin
				wea_show[i][j] <= 0;
			end
		end
	end
end
endgenerate


assign ready = working & (linelen_left > 0);

endmodule