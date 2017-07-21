`timescale 1ps/1ps
module write2control#(
parameter X_MAC = 4,
parameter X_MESH = 16,
parameter ADDR_LEN = 13,
parameter DATA_LEN = 32,
parameter COM_DATALEN = 24,
parameter MUXCONTROL = 4,
parameter RAM_DEPTH = 2**ADDR_LEN,
	parameter MAX_LINE_LEN = 10,
parameter BUFFER_NUM = X_MAC*X_MESH,
parameter DATAWIDTH = BUFFER_NUM*DATA_LEN,
parameter ADDRWIDTH = BUFFER_NUM*ADDR_LEN
)(
input wire[ADDR_LEN*X_MAC - 1:0] st_addr,
input wire [MAX_LINE_LEN - 1:0] linelen,
input wire [1:0] valid_mac,
input wire pooled,
input wire is_relu,
input wire [4:0] shift_len,


output wire [ADDRWIDTH-1:0] addra,
output wire [DATAWIDTH-1:0] data_a,
output wire [BUFFER_NUM - 1:0] wea,
output wire req,
output wire idle,
input wire indata_valid,
input wire dvalid,

input wire [4*COM_DATALEN*X_MESH - 1:0]  in_data_4,
input wire [COM_DATALEN*X_MESH - 1:0]  in_data_1,

input wire conf_input,

input rst_n,
input clk

);

 reg  [ADDR_LEN*X_MAC - 1:0] st_addr_reg;
  reg [MAX_LINE_LEN - 1:0] linelen_reg;
  reg [1:0] valid_mac_reg;
  reg pooled_reg;
reg is_relu_reg;
reg [4:0] shift_len_reg;


wire signed [8 - 1:0] in_data_4_split[X_MESH-1:0][2-1:0][2-1:0];
wire signed [8 - 1:0] in_data_1_split[X_MESH-1:0];
     
wire signed [COM_DATALEN - 1:0] in_data_4_split_before_shift[X_MESH-1:0][2-1:0][2-1:0];
wire [ADDR_LEN-1:0] addra_show[X_MESH-1:0][X_MAC-1:0];
reg wea_show[X_MESH-1:0][X_MAC-1:0];

reg out_valid_1;//
reg  [MUXCONTROL - 1:0] control;
reg working;
reg [MAX_LINE_LEN - 1:0] linelen_left;
reg [DATA_LEN-1:0] data_a_show[X_MESH-1:0][X_MAC-1:0];

reg conf_wait;

always @(posedge clk) begin
    if (!rst_n) begin
        conf_wait <= 0;
    end
    else if(conf_input) begin
        conf_wait <= 1;
    end
    else if(indata_valid & conf_wait) begin
        conf_wait <= 0;    
    end    
end

wire conf_r10 = conf_wait & indata_valid;

reg [13:0] conf_vec;
always @(posedge clk) begin:DELAY
    integer i_d;    
    for (i_d = 1;i_d <= 13;i_d = i_d + 1) begin
        conf_vec[i_d] <= conf_vec[i_d - 1];
    end
    conf_vec[0] <= conf_r10;
end

wire conf = conf_vec[11];

always @(posedge clk) begin
    if (!rst_n) begin
        linelen_reg <= 0;
        st_addr_reg <= 0;
        valid_mac_reg <= 0;
        pooled_reg <= 0;
        is_relu_reg <= 0;
        shift_len_reg <= 0;
    end
    else if (conf_input) begin
        linelen_reg <= linelen;
        st_addr_reg <= st_addr;
        pooled_reg <= pooled;
        is_relu_reg <= is_relu;
        valid_mac_reg <= valid_mac;
        shift_len_reg <= shift_len;
    end
end


localparam ST_IDLE = 0;
localparam ST_4_ENABLE = 1;
localparam ST_4_BUF1 = 2;
localparam ST_4_END1 = 3;
localparam ST_1_ENABLE = 4;
localparam ST_1_BUF1 = 5;
localparam ST_1_BUF2 = 6;
localparam ST_1_BUF3 = 7;
localparam ST_1_END1 = 8;
localparam ST_1_END2 = 9;
localparam ST_1_END3 = 10;


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
       relu_shift rs(
			.input_data(in_data_1[i*COM_DATALEN +: COM_DATALEN]),
			.output_data(in_data_1_split[i]),
			.is_relu(is_relu_reg),
			.shift_len(shift_len_reg)
		);	   
	   for (j =0;j<2;j =j+1) begin:assh
		for (k =0;k<2;k = k+1) begin:assh3
		
			relu_shift rs(
			.input_data(in_data_4_split_before_shift[i][j][k]),
			.output_data(in_data_4_split[i][j][k]),
			.is_relu(is_relu_reg),
			.shift_len(shift_len_reg)
			);
            assign in_data_4_split_before_shift[i][j][k] = (in_data_4[k*COM_DATALEN + j*COM_DATALEN*2 +i*COM_DATALEN*4 +: COM_DATALEN]);			
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
		if(conf) begin
			for (j =0;j<X_MAC;j=j+1) begin:assh
				st_addr_show[j] <= st_addr_reg[j*ADDR_LEN +: ADDR_LEN] - 1;
			end
			working <= 1;
			if(pooled_reg) begin
				control <= ST_1_BUF1;
				linelen_left <= linelen_reg - 1;
			end
			else begin
				control <= ST_4_BUF1;
				linelen_left <= linelen_reg - 2;
			end
		end
		else if (working && dvalid)begin
			case(control)
			ST_1_BUF1: begin
				if(linelen_left > 1) begin
					control <= ST_1_BUF2;
				end
				else begin
					control <= ST_1_END2;
				end
			end
			ST_1_BUF2: begin
				if(linelen_left > 1) begin
					control <= ST_1_BUF3;
				end
				else begin
					control <= ST_1_END3;
				end
			end
			ST_1_BUF3: begin
				control <= ST_1_ENABLE;
			end
			ST_1_ENABLE: begin
				if(linelen_left > 1) begin
					control <= ST_1_BUF1;
				end
				else if(linelen_left == 1) begin
					control <= ST_1_END1;
				end
				else begin
					control <= ST_IDLE;
				end
				for (j =0;j<X_MAC;j=j+1) begin:asshq
					st_addr_show[j] <= st_addr_show[j]+1;
				end
			end
			ST_1_END1:begin
				control <= ST_IDLE;
				for (j =0;j<X_MAC;j=j+1) begin:asshw
					st_addr_show[j] <= st_addr_show[j]+1;
				end
			end
			ST_1_END2:begin
				control <= ST_IDLE;
				for (j =0;j<X_MAC;j=j+1) begin:asshe
					st_addr_show[j] <= st_addr_show[j]+1;
				end
			end
			ST_1_END3:begin
				control <= ST_IDLE;
				for (j =0;j<X_MAC;j=j+1) begin:asshr
					st_addr_show[j] <= st_addr_show[j]+1;
				end
			end
			ST_4_BUF1:begin
					control <= ST_4_ENABLE;				
			end
			ST_4_ENABLE:begin
				if(linelen_left > 2) begin
					control <= ST_4_BUF1;
				end
				else if(linelen_left > 0)begin
					control <= ST_4_END1;
				end
				else begin
					control <= ST_IDLE;
				end
				for (j =0;j<X_MAC;j=j+1) begin:assht
					st_addr_show[j] <= st_addr_show[j]+1;
				end
			end
			ST_4_END1:begin
				control <= ST_IDLE;
				for (j =0;j<X_MAC;j=j+1) begin:asshy
					st_addr_show[j] <= st_addr_show[j]+1;
				end
			end
			endcase
			if(pooled_reg) begin
				if(linelen_left >= 1) linelen_left <= linelen_left - 1;
				else working <= 0;
			end
			else begin
				if (linelen_left >= 2) linelen_left <= linelen_left - 2;
				else if (linelen_left == 1) begin
					linelen_left <= 0;
				end
				else working <= 0;
			end
		end
	end
end



generate
for (i=0;i<X_MESH;i = i+1) begin:assi
	for (j = 0;j< 4;j = j+1) begin:asso
		always @ (posedge clk) begin
			case (control)
			ST_IDLE: data_a_show[i][j] <= 0;
			ST_1_BUF1: begin
				if(j == valid_mac_reg) data_a_show[i][j][0 +: 8] <= in_data_1_split[i];
			end
			ST_1_BUF2: begin
				if(j == valid_mac_reg) data_a_show[i][j][8 +: 8] <= in_data_1_split[i];
			end
			ST_1_BUF3: begin
				if(j == valid_mac_reg) data_a_show[i][j][16 +: 8] <= in_data_1_split[i];
			end
			ST_1_ENABLE: begin
				if(j == valid_mac_reg) data_a_show[i][j][24 +: 8] <= in_data_1_split[i];
			end
			ST_1_END1: begin
				if(j == valid_mac_reg) data_a_show[i][j][0 +: 8] <= in_data_1_split[i];			
			end
			ST_1_END2: begin
				if(j == valid_mac_reg) data_a_show[i][j][8 +: 8] <= in_data_1_split[i];			
			end
			ST_1_END3: begin
				if(j == valid_mac_reg) data_a_show[i][j][16 +: 8] <= in_data_1_split[i];			
			end
			ST_4_BUF1: begin
				if (valid_mac_reg < 3)begin
					if (j == valid_mac_reg) data_a_show[i][j][0 +: 16] <= {in_data_4_split[i][0][1],in_data_4_split[i][0][0]};
					else if(j == (valid_mac_reg + 1)) data_a_show[i][j][0 +: 16] <= {in_data_4_split[i][1][1],in_data_4_split[i][1][0]};
				end
				else begin
					if (j == 3) data_a_show[i][j][0 +: 16] <= {in_data_4_split[i][0][1],in_data_4_split[i][0][0]};
					else if(j == 0) data_a_show[i][j][0 +: 16] <= {in_data_4_split[i][1][1],in_data_4_split[i][1][0]};
				end
			end
			ST_4_ENABLE: begin
				if (valid_mac_reg < 3)begin
					if (j == valid_mac_reg) data_a_show[i][j][16 +: 16] <= {in_data_4_split[i][0][1],in_data_4_split[i][0][0]};
					else if(j == (valid_mac_reg + 1)) data_a_show[i][j][16 +: 16] <= {in_data_4_split[i][1][1],in_data_4_split[i][1][0]};
				end
				else begin
					if (j == 3) data_a_show[i][j][16 +: 16] <= {in_data_4_split[i][0][1],in_data_4_split[i][0][0]};
					else if(j == 0) data_a_show[i][j][16 +: 16] <= {in_data_4_split[i][1][1],in_data_4_split[i][1][0]};
				end
			end
			ST_4_END1: begin
				if (valid_mac_reg < 3)begin
					if (j == valid_mac_reg) data_a_show[i][j][0 +: 16] <= {in_data_4_split[i][0][1],in_data_4_split[i][0][0]};
					else if(j == (valid_mac_reg + 1)) data_a_show[i][j][0 +: 16] <= {in_data_4_split[i][1][1],in_data_4_split[i][1][0]};
				end
				else begin
					if (j == 3) data_a_show[i][j][0 +: 16] <= {in_data_4_split[i][0][1],in_data_4_split[i][0][0]};
					else if(j == 0) data_a_show[i][j][0 +: 16] <= {in_data_4_split[i][1][1],in_data_4_split[i][1][0]};
				end
			end
			endcase
		end
		always @ (posedge clk) begin
			if(valid_mac_reg < 3) begin
				if(( control== ST_1_END1 || control== ST_1_END2 || control== ST_1_END3 || control == ST_1_ENABLE) && j == valid_mac_reg ) begin
					wea_show[i][j] <= 1;
				end
				else if((control == ST_4_ENABLE || control == ST_4_END1) && (j == valid_mac_reg || j == (valid_mac_reg + 1))) begin
					wea_show[i][j] <= 1;
				end
				else
					wea_show[i][j] <= 0;
			end
			else begin
				if(( control== ST_1_END1 || control== ST_1_END2 || control== ST_1_END3 || control == ST_1_ENABLE) && j == 3 ) begin
					wea_show[i][j] <= 1;
				end
				else if((control == ST_4_ENABLE || control == ST_4_END1) && (j == 3 || j == 0)) begin
					wea_show[i][j] <= 1;
				end
				else
					wea_show[i][j] <= 0;
			end
		end
	end
end
endgenerate


assign req = working;
assign idle = (!working && (control == ST_IDLE) ); 

endmodule

module relu_shift#(
parameter COM_DATALEN = 24
)
(
	input wire signed [COM_DATALEN-1:0] input_data,
	output reg signed [8 - 1:0] output_data,
	input wire [4:0] shift_len,
	input wire is_relu
);
	wire signed [COM_DATALEN-1:0] input_data_shift;
	wire signed [COM_DATALEN-1:0] input_data_shift_neg;
	
	wire [COM_DATALEN-1:0] round_flag_vec = input_data >>> (shift_len-1);
	
	wire round_flag = round_flag_vec[0];
	
	assign input_data_shift = round_flag ? (input_data >>> shift_len)+1 :(input_data >>> shift_len);
	assign input_data_shift_neg = input_data_shift >>> 3;
	
	
	always @* begin
		if(input_data_shift > 127) output_data = 127;
		else if(input_data_shift >= 0) output_data = input_data_shift;
		else if(is_relu) output_data = input_data_shift_neg;
		else if(input_data_shift < -128) output_data = -128;
		else output_data = input_data_shift;
	end


endmodule



