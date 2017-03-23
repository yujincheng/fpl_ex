`timescale 1ns/1ns

module tb;

parameter X_MAC = 4;
parameter X_MESH = 16;
parameter ADDR_LEN = 9;
parameter DATA_LEN = 32;
parameter BUFFER_NUM = X_MAC*X_MESH;
parameter DATAWIDTH = BUFFER_NUM*DATA_LEN;
parameter ADDRWIDTH = BUFFER_NUM*ADDR_LEN;

reg clka;

wire [DATAWIDTH-1:0] dina;
wire [ADDRWIDTH-1:0] addra;
wire  [BUFFER_NUM-1:0] wea;
wire [DATAWIDTH-1:0] doutb;
wire [ADDRWIDTH-1:0] addrb;
reg [DATA_LEN-1:0] dina_show[X_MESH-1:0][X_MAC-1:0];
wire [DATA_LEN-1:0] doutb_show[X_MESH-1:0][X_MAC-1:0];
reg wea_show[X_MESH-1:0][X_MAC-1:0];
reg [ADDR_LEN-1:0] addra_show[X_MESH-1:0][X_MAC-1:0];
reg [ADDR_LEN-1:0] addrb_show[X_MESH-1:0][X_MAC-1:0];

genvar i,j;
generate
 for (i=0;i<X_MESH;i = i+1) begin:ass   
       for (j =0;j<X_MAC;j=j+1) begin:assh
            assign dina[j*DATA_LEN+i*DATA_LEN*X_MAC +: DATA_LEN] = dina_show[i][j];
            assign doutb_show[i][j] = doutb[j*DATA_LEN+i*DATA_LEN*X_MAC +: DATA_LEN] ;
            assign wea[j+i*X_MAC] = wea_show[i][j];
            assign addra[j*ADDR_LEN+i*ADDR_LEN*X_MAC +: ADDR_LEN] = addra_show[i][j];
            assign addrb[j*ADDR_LEN+i*ADDR_LEN*X_MAC +: ADDR_LEN] = addrb_show[i][j];
       end
 end
endgenerate 




initial begin:asdf
	integer i;
	integer j;
    clka = 0;
    for (i=0;i<X_MESH;i = i+1) begin:ass   
        for (j =0;j<X_MAC;j=j+1) begin:assh
			addra_show[i][j] = 3;
            dina_show[i][j] = i*16+j;
			addrb_show[i][j] = 0;
			wea_show[i][j] = (j == 1);
        end
    end
    forever #5 clka = !clka;
end

always@ (posedge clka) begin:asa
	integer i;
	integer j;
	for (i=0;i<X_MESH;i = i+1) begin:ass   
        for (j =0;j<X_MAC;j=j+1) begin:assh
			addra_show[i][j] = addra_show[i][j] + 1;
            dina_show[i][j] = dina_show[i][j] + 1;
			addrb_show[i][j] = addrb_show[i][j] + 1;
			//wea_show[i][j] = 1'b1;
        end
    end
end


BufferPool#(
.X_MAC(X_MAC),
.X_MESH(X_MESH)
) test (
    .dina(dina),
    .addra(addra),
    .wea(wea),
    .doutb(doutb),
    .addrb(addrb),
    .clk(clka)
);






endmodule