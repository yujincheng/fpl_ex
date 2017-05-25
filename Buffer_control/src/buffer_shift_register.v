`timescale 1ps/1ps
module buffer_shift_register #(
parameter X_MAC = 4,
parameter X_MESH = 16,
parameter DATA_LEN = 32,
parameter MUXCONTROL = 4,
parameter BUFFER_NUM = X_MAC*X_MESH,
parameter DATAWIDTH = BUFFER_NUM*DATA_LEN,
parameter MUXCONTROLWIDTH = BUFFER_NUM*MUXCONTROL
)(
input wire [DATAWIDTH-1:0] din,
output wire [DATAWIDTH-1:0] dout,
input wire [MUXCONTROL - 1:0] control,
input wire [X_MAC*2 - 1:0] buffermux,
input wire [X_MAC - 1:0] iszero,
input clk
);


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

reg [DATA_LEN + 7 : 0] reg_out[X_MESH-1:0][X_MAC-1:0];
wire [DATA_LEN-1:0] dout_show[X_MESH-1:0][X_MAC-1:0];
reg [DATA_LEN-1:0] dout_show_after[X_MESH-1:0][X_MAC-1:0];
wire [DATA_LEN-1:0] din_show[X_MESH-1:0][X_MAC-1:0];

genvar i,j;
generate
 for (i=0;i<X_MESH;i = i+1) begin:ass   
       for (j =0;j<X_MAC;j=j+1) begin:aasda
			assign dout_show[i][j]= reg_out[i][j][0 +: DATA_LEN];
            assign dout[j*DATA_LEN+i*DATA_LEN*X_MAC +: DATA_LEN] = dout_show_after[i][j];
            assign din_show[i][j] = din[j*DATA_LEN+i*DATA_LEN*X_MAC +: DATA_LEN] ;
       end
 end
endgenerate

// INSERT BLOCK COMMENT 
always @ (posedge clk)begin:BLOCKNAME
    integer i,j;
	 for (i=0;i<X_MESH;i = i+1) begin:ass   
		   for (j =0;j<X_MAC;j=j+1) begin:assh
				case (control)
				ST_PAD_INIT_1 : begin
					reg_out[i][j][0 +: 8] <= 8'd0;
					reg_out[i][j][8 +: 32] <= din_show[i][j];
				end
				ST_PAD_INIT_2 : begin
					reg_out[i][j][0 +: 8] <= 8'd0;
					reg_out[i][j][8 +: 16] <= reg_out[i][j][16 +: 16];
					reg_out[i][j][16 +: 16] <= din_show[i][j][0 +: 16];
				end
				ST_PAD_UINIT_1 : begin
					reg_out[i][j][0 +: 24] <= reg_out[i][j][16 +: 24];
					reg_out[i][j][24 +: 16] <= din_show[i][j][0 +: 16];
				end
				ST_PAD_UINIT_2 : begin
					reg_out[i][j][0 +: 24] <= reg_out[i][j][16 +: 24];
					reg_out[i][j][24 +: 16] <= din_show[i][j][16 +: 16];
				end
				ST_UPAD_INIT_1 : begin
					reg_out[i][j][0 +: 32] = din_show[i][j];
					reg_out[i][j][32 +: 8] <=  0;
				end
				ST_UPAD_INIT_2 : begin	
					reg_out[i][j][0 +: 16] <=  din_show[i][j][16 +: 16];
					reg_out[i][j][16 +: 16] <=  din_show[i][j][15:0];
					reg_out[i][j][32 +: 8] <=  0;	
				end
				ST_UPAD_UINIT_1 : begin
					reg_out[i][j][0 +: 16] <= reg_out[i][j][16 +: 16];
					reg_out[i][j][16 +: 16] <= din_show[i][j][0 +: 16];
				end
				ST_UPAD_UINIT_2 : begin
					reg_out[i][j][0 +: 16] <= reg_out[i][j][16 +: 16];
					reg_out[i][j][16 +: 16] <= din_show[i][j][16 +: 16];
				end
				ST_PAD_END_3 : begin
					reg_out[i][j][0 +: 16] <= reg_out[i][j][16 +: 16];
					reg_out[i][j][16 +: 24] <= 0;
				end
				ST_PAD_END_4 : begin
					reg_out[i][j][0 +: 24] <= reg_out[i][j][16 +: 24];
					reg_out[i][j][24 +: 16] <= 0;
				end
				endcase
		   end
	 end
end

always @ (*)begin:BLOCKN1
	integer i,j;
    for (i = 0; i < X_MESH; i = i + 1) begin: MUX_INIT_1   
        for (j = 0; j < X_MAC; j = j + 1) begin: MUX_INIT_2   
            case (buffermux[j*2 +: 2])
                2'b00: dout_show_after[i][j] = (iszero[j]) ? {DATA_LEN{1'b0} }: dout_show[i][0];
                2'b01: dout_show_after[i][j] = (iszero[j]) ? {DATA_LEN{1'b0} }: dout_show[i][1];
                2'b10: dout_show_after[i][j] = (iszero[j]) ? {DATA_LEN{1'b0} }: dout_show[i][2];
                2'b11: dout_show_after[i][j] = (iszero[j]) ? {DATA_LEN{1'b0} }: dout_show[i][3];
                default: dout_show_after[i][j] = (iszero[j]) ? { DATA_LEN{1'b0} }: dout_show[i][j];
            endcase
        end
    end
end

endmodule