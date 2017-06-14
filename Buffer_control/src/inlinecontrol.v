`timescale 1ps/1ps
module inlinecontrol#(
parameter X_MAC = 4,
parameter X_MESH = 16,
parameter ADDR_LEN = 13,
parameter DATA_LEN = 32,
parameter MUXCONTROL = 4,
parameter MAX_LINE_LEN = 10,
parameter RAM_DEPTH = 2**ADDR_LEN,
parameter BUFFER_NUM = X_MAC*X_MESH,
parameter DATAWIDTH = BUFFER_NUM*DATA_LEN,
parameter ADDRWIDTH = BUFFER_NUM*ADDR_LEN
)(
input wire[ADDR_LEN*X_MAC - 1:0] st_addr,
input [MAX_LINE_LEN - 1:0] linelen,
input linealign,
input wire ispad,
output wire [ADDRWIDTH - 1:0] addrb,
(* dont_touch = "yes" *) output reg [MUXCONTROL - 1:0] control_out,
output wire ready,

input wire valid,
input wire tofifo,
input wire fromfifo,

output wire pe_tofifo,
output wire pe_fromfifo,


output reg out_valid,
output wire idle_soon,

input rst_n,
input clk

);

reg regtofifo;
reg regfromfifo;

localparam [MUXCONTROL - 1:0] ST_PAD_INIT_1 = 	0;
localparam [MUXCONTROL - 1:0] ST_PAD_INIT_2 = 	1;
localparam [MUXCONTROL - 1:0] ST_PAD_UINIT_1 = 	2;
localparam [MUXCONTROL - 1:0] ST_PAD_UINIT_2 = 	3;
localparam [MUXCONTROL - 1:0] ST_UPAD_INIT_1 = 	4;
localparam [MUXCONTROL - 1:0] ST_UPAD_INIT_2 = 	5;
localparam [MUXCONTROL - 1:0] ST_UPAD_UINIT_1 = 6;
localparam [MUXCONTROL - 1:0] ST_UPAD_UINIT_2 = 7;
localparam [MUXCONTROL - 1:0] ST_PAD_END_3 = 	8;
localparam [MUXCONTROL - 1:0] ST_PAD_END_4 = 	9;


// wire [DATAWIDTH-1:0] dina;
// wire [ADDRWIDTH-1:0] addra;
// wire  [BUFFER_NUM-1:0] wea;
wire [DATAWIDTH-1:0] doutb;
wire [ADDR_LEN-1:0] addrb_show[X_MESH-1:0][X_MAC-1:0];

reg out_valid_1;//
reg out_valid_2;//
reg out_valid_3;//
(* dont_touch = "yes" *)reg  [MUXCONTROL - 1:0] control;
reg  [MUXCONTROL - 1:0] control_reg1;
reg working;
reg [MAX_LINE_LEN - 1:0] linelen_left;


always@(posedge clk)begin
	if(!rst_n) begin
		control_out <= 0;
		out_valid <= 0;
        out_valid_2 <= 0;
		out_valid_1 <= 0;
	end
	else begin
		control_out <= control_reg1;
		control_reg1 <= control;
		
		out_valid <= out_valid_3;
		out_valid_3 <= out_valid_2;
		out_valid_2 <= out_valid_1;
		out_valid_1 <= working;
	end
end

reg [ADDR_LEN - 1:0]  st_addr_show[X_MAC-1:0];

genvar i,j;
generate
 for (i=0;i<X_MESH;i = i+1) begin:ass   
       for (j =0;j<X_MAC;j=j+1) begin:assh
            assign addrb[j*ADDR_LEN+i*ADDR_LEN*X_MAC +: ADDR_LEN] = addrb_show[i][j];
			assign addrb_show[i][j] = st_addr_show[j];
       end
 end
endgenerate


always @ (posedge clk) begin:ere
	integer i;
	integer j;
if (!rst_n) begin
	working <= 0;
	control <= 0;
	linelen_left <= 0;
	regfromfifo <= 0;
	regtofifo <= 0;
	for (j =0;j<X_MAC;j=j+1) begin
        st_addr_show[j] <= 0;
    end
end
else begin
	if(valid) begin
		for (j =0;j<X_MAC;j=j+1) begin
			st_addr_show[j] <= st_addr[j*ADDR_LEN +: ADDR_LEN];
		end
		working <= 1;
		regtofifo <= tofifo;
		regfromfifo <= fromfifo;
		linelen_left <= linelen - 4;
		control <= ispad ? ST_PAD_INIT_1 : ST_UPAD_INIT_1;
	end
	else if (working)begin
		case (control)
		ST_PAD_INIT_1: begin 
			if (linelen_left > 2) begin
				control <= ST_PAD_UINIT_1;
				for (j =0;j<X_MAC;j=j+1) begin:assh0
					st_addr_show[j] <= st_addr_show[j] + 1;
				end
			end
			else if (linelen_left == 2) begin 
				control <= ST_PAD_END_4;
			end
			else begin
				control <= ST_PAD_END_3;
			end
		end
		ST_PAD_UINIT_1: begin 
			if (linelen_left > 2) begin
				control <= ST_PAD_UINIT_2;
			end
			else if (linelen_left == 2) begin 
				control <= ST_PAD_END_4;
			end
			else begin
				control <= ST_PAD_END_3;
			end
		end
		ST_PAD_UINIT_2: begin
			if (linelen_left > 2) begin
				control <= ST_PAD_UINIT_1;
				for (j =0;j<X_MAC;j=j+1) begin:assh2
					st_addr_show[j] <= st_addr_show[j] + 1;
				end
			end
			else if (linelen_left == 2) begin 
				control <= ST_PAD_END_4;
			end
			else begin
				control <= ST_PAD_END_3;
			end
		end
		
		ST_UPAD_INIT_1: begin 
			control <= ST_UPAD_UINIT_1;
			for (j =0;j<X_MAC;j=j+1) begin:assh3
				st_addr_show[j] <= st_addr_show[j] + 1;
			end
		end
		ST_UPAD_UINIT_1: begin 
			control <= ST_UPAD_UINIT_2;
		end
		ST_UPAD_UINIT_2: begin 
			control <= ST_UPAD_UINIT_1;
			for (j =0;j<X_MAC;j=j+1) begin:assh4
				st_addr_show[j] <= st_addr_show[j] + 1;
			end
		end
		default: begin
		  control <= 0;		  
		end		
		endcase
		if (linelen_left >= 2) linelen_left <= linelen_left - 2;
		else if (linelen_left == 1) linelen_left <= 0;
		else working <= 0;
	end
end
end

reg regfromfifo1[2:0];
reg regtofifo1[2:0];
always @ (posedge clk) begin
    regfromfifo1[0] <= regfromfifo;
    regtofifo1[0] <= regtofifo;
    regfromfifo1[1] <= regfromfifo1[0];
    regtofifo1[1] <= regtofifo1[0];
    regfromfifo1[2] <= regfromfifo1[1];
    regtofifo1[2] <= regtofifo1[1];

end

assign ready = working;
assign idle_soon = (!working || linelen_left < 10);
assign pe_fromfifo = regfromfifo1[0] & out_valid;
assign pe_tofifo = regtofifo1[0] & out_valid;

endmodule