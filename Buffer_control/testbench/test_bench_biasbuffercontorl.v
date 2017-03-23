`timescale 1ns/1ns

module tb_biasbuffercontrol;
parameter X_MESH = 16;
parameter X_PE = 16;
parameter ADDR_LEN = 9;
parameter RAM_DEPTH = 2**ADDR_LEN;
parameter DATA_LEN = 64;
parameter BUFFER_NUM = 8*X_MESH/(DATA_LEN);
parameter DATAWIDTH = BUFFER_NUM*DATA_LEN;
parameter ADDRWIDTH = BUFFER_NUM*ADDR_LEN;

//`include "write_weights.vh"


reg clka;
wire [DATA_LEN - 1:0]           data_wr    ;

wire [DATA_LEN - 1:0]           ddr_fifo_data;
wire [ADDR_LEN - 1:0]           st_wr_addr ;
wire [BUFFER_NUM - 1:0]        wr_en      ;
wire                           wr_ready   ;
//wire [X_PE*X_MESH*8*9 - 1 : 0] ker_out    ;
reg [ADDR_LEN - 1:0]           st_rd_addr ;
wire                           ker_en     ;
reg                          rd_conf    ;
wire                            rd_ready   ;
wire idle;
wire indata_valid;
reg                           clk        ;
reg 							  rst_n      ;

wire [ADDR_LEN - 1:0] bb_addr;
wire [DATA_LEN - 1:0] bb_data;

//wire[8 - 1:0] ker_out_show[X_MESH-1:0][X_PE-1:0][8:0];


//genvar i,j,k;
// generate
 // for (i=0;i< X_PE;i = i+1) begin:ass   
       // for (j =0;j< X_MESH;j=j+1) begin:assh
			// for (k =0;k < 9;k=k+1) begin:asshh
				// assign ker_out_show[i][j][k] = ker_out[k*8 +  j*72	+	i*72*X_MESH +: 8];
			// end
       // end
 // end
// endgenerate


initial begin:asdf
	st_rd_addr = 0;
	rd_conf = 0;
	rst_n = 0;
	#20 rst_n = 1;
	#21 rd_conf = 1;
	#10 rd_conf = 0;
	
	//#4000 write_weightsbuffer();
	//$finish();
end

initial begin:asdf1
    clk = 0;
    forever #5 clk = !clk;
end

Bias_FIFO_CONTROL #(
.X_PE       (X_PE      ),
.ADDR_LEN   (ADDR_LEN  ),
.DATA_LEN   (DATA_LEN  )
)wfc(
.clk       (clk       ),
.rst_n     (rst_n),

.bias_num(13),
.bb_st_addr(0),
.ddr_fifo_empty (ddr_fifo_empty),
.ddr_fifo_req   (ddr_fifo_req  ),
.ddr_fifo_data  (ddr_fifo_data ),


.conf(rd_conf),
.bb_wea (wr_en),
.bb_addr (bb_addr),
.bb_data (bb_data)
);


weightfifo_file#(
.FILE_NAME("D://study//boshi1//nics//huawei_cnn//validate_data//sim_data//weight_test.txt"),
.DATA_DEEPTH(9*X_MESH*X_PE*2)
) wff(
.weights (ddr_fifo_data),
.weight_empty (ddr_fifo_empty),
.weight_req(ddr_fifo_req) ,
.clk       (clk       ),
.rst_n     (rst_n)
);




BiasBuffer #(
.X_PE       (X_PE      ),
.X_MESH     (X_MESH    ),
.ADDR_LEN   (ADDR_LEN  ),
.DATA_LEN   (DATA_LEN  )
) WB(
.data_wr   (bb_data   ),
.wr_addr   (bb_addr   ),
.wr_en     (wr_en     ),

// .ker_out   (ker_out   ),
// .st_rd_addr(st_rd_addr),
// .ker_en    (ker_en    ),
// .rd_conf   (rd_conf   ),
// .idle      (idle      ),
// .indata_valid(indata_valid),


.clk       (clk       ),
.rst_n     (rst_n)
);

endmodule