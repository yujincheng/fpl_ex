`timescale 1ns/1ns

module tb_writelineinput;

//`include "init_writebraminst.vh"
parameter X_MAC = 4;
parameter X_MESH = 16;
parameter ADDR_LEN = 13;
parameter DATA_LEN = 32;
parameter MUXCONTROL = 4;
parameter COM_DATALEN  =24;
parameter BUFFER_NUM = X_MAC*X_MESH;
parameter DATAWIDTH = BUFFER_NUM*DATA_LEN;
parameter ADDRWIDTH = BUFFER_NUM*ADDR_LEN;

reg clka;

wire [DATAWIDTH-1:0] dwire;
wire [DATA_LEN-1:0] dwire_show[X_MESH-1:0][X_MAC-1:0];


wire [DATAWIDTH-1:0] dina;
wire [ADDRWIDTH-1:0] addra;
wire  [BUFFER_NUM-1:0] wea;
wire [DATAWIDTH-1:0] doutb;
wire [ADDRWIDTH-1:0] addrb;
wire [DATA_LEN-1:0] dina_show[X_MESH-1:0][X_MAC-1:0];
wire [DATA_LEN-1:0] doutb_show[X_MESH-1:0][X_MAC-1:0];
wire wea_show[X_MESH-1:0][X_MAC-1:0];
wire [ADDR_LEN-1:0] addra_show[X_MESH-1:0][X_MAC-1:0];
wire [ADDR_LEN-1:0] addrb_show[X_MESH-1:0][X_MAC-1:0];
wire [MUXCONTROL - 1:0] control;
reg [3:0] iszero;
reg [7:0] buffermux;
reg valid;
reg [4*COM_DATALEN*X_MESH - 1:0]  in_data;
wire out_req;
reg rst_n;

genvar i,j;
generate
 for (i=0;i<X_MESH;i = i+1) begin:ass   
       for (j =0;j<X_MAC;j=j+1) begin:assh
            assign  dina_show[i][j] = dina[j*DATA_LEN+i*DATA_LEN*X_MAC +: DATA_LEN];
            assign doutb_show[i][j] = doutb[j*DATA_LEN+i*DATA_LEN*X_MAC +: DATA_LEN] ;
            assign wea_show[i][j] = wea[j+i*X_MAC];
            assign addra_show[i][j]= addra[j*ADDR_LEN+i*ADDR_LEN*X_MAC +: ADDR_LEN] ;
            assign addrb_show[i][j] = addrb[j*ADDR_LEN+i*ADDR_LEN*X_MAC +: ADDR_LEN] ;
            assign dwire_show[i][j] = dwire[j*DATA_LEN+i*DATA_LEN*X_MAC +: DATA_LEN] ;
       end
 end
endgenerate 




initial begin:asdf
	iszero = 0;
	valid = 0;
	buffermux = {{2'd3},{2'd2},{2'd1},{2'd0}};
	rst_n = 0;
	#30 rst_n = 1;
	#11 valid = 1;
	#10 valid = 0;
	
end

initial begin:asdf1
	integer i;
	integer j;
    clka = 0;
	in_data = {4*X_MESH*12{2'b10}};
    forever #5 clka = !clka;
end


write2control#(
.X_MAC(X_MAC),
.X_MESH(X_MESH),
.ADDR_LEN(ADDR_LEN)
) wilc(
	.st_addr(0),
	.pooled(1),
	.linelen(3), //after_pad 至少�??4
	.addra(addra),
	.data_a(dina),
	.wea(wea),
	.req(out_req),
	.shift_len(16),
	.in_data_4(in_data),
	.in_data_1(in_data),
	.conf(valid),
	.dvalid(1),
	.valid_mac(3),
	.rst_n(rst_n),
	.clk(clka)
	);





endmodule