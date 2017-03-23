`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/09 22:59:24
// Design Name: 
// Module Name: wino_PE_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_comp #(
	parameter X_PE = 16,
	parameter X_MAC = 4,
	parameter X_MESH = 16,
	parameter ADDR_LEN = 9,
	parameter COM_DATALEN = 24,
	parameter RAM_DEPTH = 2**ADDR_LEN,
	parameter BUFFER_NUM = X_MAC*X_MESH,
	parameter DATAWIDTH = BUFFER_NUM*32,
	parameter ADDRWIDTH = BUFFER_NUM*ADDR_LEN
  )();
  `include "init_weightsbuffer.vh"
`include "init_braminst.vh"

reg                                                 clk;
wire [64 - 1:0]                               wb_data_wr    ;
wire [ADDR_LEN - 1:0]                               wb_st_wr_addr ;
wire                                                wb_wr_en      ;
wire                                                wb_wr_ready   ;
wire [X_PE*X_MESH*8*9 - 1 : 0]                      wb_ker_out    ;
reg [ADDR_LEN - 1:0]                                wb_st_rd_addr ;
wire                                                wb_ker_en     ;
reg                                                 wb_rd_conf    ;
wire                                                wb_rd_ready   ;

wire[8 - 1:0] ker_out_show[X_MESH-1:0][X_PE-1:0][8:0];

wire [32*X_MAC*X_MESH-1:0]                                dwire;
wire [32-1:0] dwire_show[X_MESH-1:0][X_MAC-1:0];

wire  [BUFFER_NUM-1:0]                              wea;
wire [32*X_MAC*X_MESH-1:0]                                doutb;
wire [ADDRWIDTH-1:0]                                addrb;
wire [32*X_MAC*X_MESH-1:0] 							dina;
wire [ADDRWIDTH-1:0]                                addra;
wire [32-1:0] dina_show[X_MESH-1:0][X_MAC-1:0  ];
wire [32-1:0] doutb_show[X_MESH-1:0][X_MAC-1:0];
wire wea_show[X_MESH-1:0][X_MAC-1:0                  ];
wire [ADDR_LEN-1:0] addra_show[X_MESH-1:0][X_MAC-1:0 ];
wire [ADDR_LEN-1:0] addrb_show[X_MESH-1:0][X_MAC-1:0];
wire [4 - 1:0]                             control;
reg [3:0]                                           iszero;
reg 											ispad;
reg [9 : 0]										linelen;
reg [7:0]                                           buffermux;
reg                                                 valid;
wire                                                out_valid;
wire                                                indata_valid;
reg                                                 rst_n;
wire [COM_DATALEN*4*16 - 1:0] 							result_wire_unpool;
wire [COM_DATALEN-1:0] 							result_wire_unpool_show[X_MESH-1:0][2-1:0][2-1:0];
wire [COM_DATALEN*16 - 1:0] 							result_wire_pool;
wire [COM_DATALEN-1:0] 							result_wire_pool_show[X_MESH-1:0];
wire result_valid;
wire result_valid_pool;

genvar i,j,k;
generate
 for (i=0;i<X_MESH;i = i+1) begin:ass   
       for (j =0;j<X_MAC;j=j+1) begin:assh
            assign doutb_show[i][j] = doutb[j*32+i*32*X_MAC +: 32] ;
            assign dina_show[i][j] = dina[j*32+i*32*X_MAC +: 32] ;
            assign wea_show[i][j] = wea[j+i*X_MAC];
            assign addrb_show[i][j] = addrb[j*ADDR_LEN+i*ADDR_LEN*X_MAC +: ADDR_LEN] ;
            assign addra_show[i][j] = addra[j*ADDR_LEN+i*ADDR_LEN*X_MAC +: ADDR_LEN] ;
            assign dwire_show[i][j] = dwire[j*32+i*32*X_MAC +: 32] ;
       end
 end
endgenerate 

generate
 for (i=0;i< X_PE;i = i+1) begin:ass1   
       for (j =0;j< X_MESH;j=j+1) begin:assh
			for (k =0;k < 9;k=k+1) begin:asshh
				assign ker_out_show[i][j][k] = wb_ker_out[k*8 +  j*72	+	i*72*X_MESH +: 8];
			end
       end
 end
endgenerate

generate
for (i=0;i<X_MESH;i = i+1) begin:ass2   
        assign result_wire_pool_show[i] = result_wire_pool[i*COM_DATALEN +: COM_DATALEN];		
       for (j =0;j<2;j =j+1) begin:assh
		for (k =0;k<2;k = k+1) begin:assh3
            assign result_wire_unpool_show[i][j][k] = result_wire_unpool[k*COM_DATALEN + j*COM_DATALEN*2 +i*COM_DATALEN*4 +: COM_DATALEN];			
		end
       end
end
endgenerate

initial begin:asdf
	wb_st_rd_addr = 0;
	wb_rd_conf = 0;
	rst_n = 0;
	init_weightsbuffer();
	init_braminst();
	iszero = 4'b0001;
	ispad = 1;
	linelen = 66;
	//buffermux = {{2'd3},{2'd2},{2'd1},{2'd0}};
	buffermux = {{2'd2},{2'd1},{2'd0},{2'd0}};
	#20 rst_n = 1;
	#21 wb_rd_conf = 1;valid = 1;
	#10 wb_rd_conf = 0;valid = 0;
end

initial begin:asdf1
    integer i;
	integer j;
    clk = 0;
    for (i=0;i<X_MESH;i = i+1) begin:ass4   
        for (j =0;j<X_MAC;j=j+1) begin:assh
			init_braminst();
        end
    end
    forever #5 clk = !clk;
end








WeightBuffer #(
.X_PE       (X_PE      ),
.X_MESH     (X_MESH    ),
.ADDR_LEN   (ADDR_LEN  )
) WB(
.data_wr   (wb_data_wr   ),
.st_wr_addr(wb_st_wr_addr),
.wr_en     (wb_wr_en     ),
.wr_ready  (wb_wr_ready  ),
.ker_out   (wb_ker_out   ),
.st_rd_addr(wb_st_rd_addr),
.ker_en    (wb_ker_en    ),
.indata_valid(indata_valid),
.rd_conf   (wb_rd_conf   ),
.clk       (clk       ),
.rst_n     (rst_n)
);


Winograd_PE_CORE PEC
(
	.clk(clk),
	.in_valid(out_valid),
	.poolop(0),	
	.rst_n(rst_n),
	.feature(dwire),
	.weight(wb_ker_out),
	.out_valid(result_valid_pool),
	.tofifo(1),
	.fromfifo(0),
	//.inter_data(128'd0),
	.result_unpool(result_wire_unpool),
	.result_pool(result_wire_pool)
);

BufferPool#(
.X_MAC(X_MAC),
.X_MESH(X_MESH),
.ADDR_LEN(ADDR_LEN)
) bp (
    .dina(dina),
    .addra(addra),
    .wea(wea),
    .doutb(doutb),
    .addrb(addrb),
    .clk(clk)
);

buffer_shift_register#(
.X_MAC(X_MAC),
.X_MESH(X_MESH),
.ADDR_LEN(ADDR_LEN)
) bsr(
	.din(doutb),
	.dout(dwire),
	.control(control),
	.iszero(iszero),
	.buffermux(buffermux),
	.clk(clk)
);

inlinecontrol#(
.X_MAC(X_MAC),
.X_MESH(X_MESH),
.ADDR_LEN(ADDR_LEN)
) ilc(
	.st_addr(0),
	.linelen(linelen), //after_pad 至少�??4
	.ispad(ispad),
	.addrb(addrb),
	.control_out(control),
	.valid(indata_valid),
	.out_valid(out_valid),
	.rst_n(rst_n),
	.clk(clk)
	);

write2control#(
.X_MAC(X_MAC),
.X_MESH(X_MESH),
.ADDR_LEN(ADDR_LEN)
) w2c(
	.st_addr(1000),
	.pooled(0),
	.linelen((linelen - 2)), //after_pad 至少�??4
	.addra(addra),
	.data_a(dina),
	.wea(wea),
	.req(out_req),
	.shift_len(16),
	.in_data_4(result_wire_unpool),
	.in_data_1(result_wire_pool),
	.conf(wb_rd_conf),
	.dvalid(result_valid_pool),
	.valid_mac(0),
	.rst_n(rst_n),
	.clk(clk)
	);


  
endmodule
