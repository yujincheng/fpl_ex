`timescale 1ns/1ns

module tb;

parameter X_MAC = 4;
parameter X_MESH = 16;
parameter ADDR_LEN = 9;
parameter DATA_LEN = 32;
parameter BUFFER_NUM = X_MAC*X_MESH;
parameter DATAWIDTH = BUFFER_NUM*DATA_LEN;
parameter ADDRWIDTH = BUFFER_NUM*ADDR_LEN;

reg clk;
reg rst_n;
reg[8:0] pic_x;
reg[8:0] pic_y;
wire[DATA_LEN - 1:0] dwire;
wire rd_en;
wire empty;

wire[DATA_LEN-1:0] bpdina;
wire[ADDR_LEN-1:0] bpaddra;
wire[BUFFER_NUM-1:0] bpwea;


initial begin:asdf
    clk = 0;
    forever #5 clk = !clk;
end

initial begin:aa
    rst_n = 0;
	pic_x = 9'd300;
	pic_y = 9'd300;
    #15 rst_n = 1;
end


FakeDDRFifo#(
.DATA_LEN(DATA_LEN)
) fdf(
	.rd_en(rd_en),
	.dout(dwire),
	.empty(empty),
	
	.clk(clk),
	.rst_n(rst_n)
);

Fifo2BP#(
	.X_MAC(X_MAC),
	.X_MESH(X_MESH),
	.ADDR_LEN(ADDR_LEN),
	.DATA_LEN(DATA_LEN)
)	fifobp(

	.clk(clk),
	.rst_n(rst_n),
	
	//图片尺寸
	.pic_x(pic_x),
	.pic_y(pic_y),
	
	//FIFO口控�?
	.din(dwire),
	.empty(empty),
	.rd_en(rd_en),
	
	.bpdina(bpdina),
	.bpaddra(bpaddra),
	.bpwea(bpwea)
);

BufferPool#(
		.X_MAC(X_MAC),
		.X_MESH(X_MESH),
		.ADDR_LEN(ADDR_LEN),
		.DATA_LEN(DATA_LEN)
) BP(
	.dina(bpdina),
	.addra(bpaddra),
	.wea(bpwea),
	// .doutb(doutb),
	// .addrb(addrb),
	.clk(clk)
);
	






endmodule