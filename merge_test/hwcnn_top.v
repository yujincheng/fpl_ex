`timescale 1ps/1ps

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


module hwcnn_top #(
	parameter X_PE = 16,
	parameter X_MAC = 4,
	parameter X_MESH = 16,
	parameter ADDR_LEN_WB = 13,
	parameter ADDR_LEN_BB = 7,
	parameter ADDR_LEN_BP = 13,
	parameter MAX_LINE_LEN = 9,
	parameter INST_LEN = 220,
	parameter COM_DATALEN = 24,
	parameter DDR_ADDR_LEN = 32,
	parameter DDR_DATA_LEN = 512,
	parameter SINGLE_LEN = 24,
	
	parameter C_AXI_ID_WIDTH           = 4,
   parameter C_AXI_ADDR_WIDTH         = 32, 
   parameter C_AXI_DATA_WIDTH         = 256
  
  
  )(
  
input wire                                                 clk,
input wire                                                 rst_n,

input wire [INST_LEN-1:0] instruct,
output wire inst_req,
input wire inst_empty,

  input init_cmptd                ,
  // Slave Interface Write Address Ports
// AXI write address channel signals
  input                                  axi_awready, // Indicates slave is ready to accept a 
  output [C_AXI_ID_WIDTH-1:0]        axi_awid,    // Write ID
  output [C_AXI_ADDR_WIDTH-1:0]      axi_awaddr,  // Write address
  output [7:0]                       axi_awlen,   // Write Burst Length
  output [2:0]                       axi_awsize,  // Write Burst size
  output [1:0]                       axi_awburst, // Write Burst type
  output                             axi_awlock,  // Write lock type
  output [3:0]                       axi_awcache, // Write Cache type
  output [2:0]                       axi_awprot,  // Write Protection type
  output                             axi_awvalid, // Write address valid
// AXI write data channel signals
  input                                  axi_wready,  // Write data ready
  output [C_AXI_DATA_WIDTH-1:0]          axi_wdata,    // Write data
  output [C_AXI_DATA_WIDTH/8-1:0]        axi_wstrb,    // Write strobes
  output                                 axi_wlast,    // Last write transaction   
  output                              axi_wvalid,   // Write valid  
// AXI write response channel signals
  input  [C_AXI_ID_WIDTH-1:0]            axi_bid,     // Response ID
  input  [1:0]                           axi_bresp,   // Write response
  input                                  axi_bvalid,  // Write reponse valid
  output                              axi_bready,  // Response ready
// AXI read address channel signals
  input                                  axi_arready,     // Read address ready
  output [C_AXI_ID_WIDTH-1:0]        axi_arid,        // Read ID
  output [C_AXI_ADDR_WIDTH-1:0]      axi_araddr,      // Read address
  output [7:0]                       axi_arlen,       // Read Burst Length
  output [2:0]                       axi_arsize,      // Read Burst size
  output [1:0]                       axi_arburst,     // Read Burst type
  output                             axi_arlock,      // Read lock type
  output [3:0]                       axi_arcache,     // Read Cache type
  output [2:0]                       axi_arprot,      // Read Protection type
  output                             axi_arvalid,     // Read address valid 
// AXI read data channel signals   
  input  [C_AXI_ID_WIDTH-1:0]            axi_rid,     // Response ID
  input  [1:0]                           axi_rresp,   // Read response
  input                                  axi_rvalid,  // Read reponse valid
  input  [C_AXI_DATA_WIDTH-1:0]          axi_rdata,    // Read data
  input                                  axi_rlast,    // Read last
  output                              axi_rready  // Read Response ready
);

wire [64*8 - 1:0]                               wfc_wr_data    ; //8 here is 512/DATA_LEN
wire [ADDR_LEN_WB - 1:0]                               wfc_wr_addr ;
wire [X_PE*2 - 1:0]                                               wfc_wea      ;
wire                                                wb_wr_ready   ;
wire [X_PE*X_MESH*8*9 - 1 : 0]                      wb_ker_out    ;
wire [ADDR_LEN_WB - 1:0]                                wb_st_rd_addr ;
wire                                                wb_ker_en     ;
wire                                                 wb_rd_conf    ;
wire                                                wb_rd_ready   ;

wire[8 - 1:0] ker_out_show[X_MESH-1:0][X_PE-1:0][8:0];

wire [32*X_MAC*X_MESH-1:0]                                dwire;
wire [32-1:0] dwire_show[X_MESH-1:0][X_MAC-1:0];

wire [32*X_MAC*X_MESH-1:0]                                doutb;
reg [X_MAC*X_MESH*ADDR_LEN_BP-1:0]                                addrb;
wire [X_MAC*X_MESH*ADDR_LEN_BP-1:0]                                ilc_addrb;



wire  [X_MAC*X_MESH-1:0]                              w2c_wea;
wire [32*X_MAC*X_MESH-1:0] 							w2c_dina;
wire [X_MAC*X_MESH*ADDR_LEN_BP-1:0]                                w2c_addra;

wire  [X_MAC*X_MESH-1:0]                              dfc_BP_wea;
wire [32*X_MAC*X_MESH-1:0] 							dfc_BP_dina;
wire [X_MAC*X_MESH*ADDR_LEN_BP-1:0]                                dfc_BP_addra;

wire [X_MAC*X_MESH*ADDR_LEN_BP-1:0]                                dwc_BP_addr;

(*keep = "true"*)reg  [X_MAC*X_MESH-1:0]                              wea;
reg [32*X_MAC*X_MESH-1:0] 							dina;
reg [X_MAC*X_MESH*ADDR_LEN_BP-1:0]                                addra;




wire [32-1:0] dina_show[X_MESH-1:0][X_MAC-1:0  ];
wire [32-1:0] doutb_show[X_MESH-1:0][X_MAC-1:0];
wire wea_show[X_MESH-1:0][X_MAC-1:0                  ];
wire [ADDR_LEN_BP-1:0] addra_show[X_MESH-1:0][X_MAC-1:0 ];
wire [ADDR_LEN_BP-1:0] addrb_show[X_MESH-1:0][X_MAC-1:0];

wire [4 - 1:0]                             control;
wire [3:0]                                           bsr_iszero;
wire 											ilc_ispad;
wire [MAX_LINE_LEN - 1 : 0]										ilc_linelen;
wire [MAX_LINE_LEN - 1 : 0]										w2c_linelen;
wire [4*ADDR_LEN_BP-1 : 0]										ilc_st_addr;
wire [4*ADDR_LEN_BP-1 : 0]										w2c_st_addr;
wire [4:0]		w2c_shift_len;
wire [1:0] 		w2c_valid_mac;
wire [7:0]                                           bsr_buffermux;
wire                                                out_valid;
wire                                                indata_valid;
wire [COM_DATALEN*4*16 - 1:0] 							result_wire_unpool;
wire [COM_DATALEN-1:0] 							result_wire_unpool_show[X_MESH-1:0][2-1:0][2-1:0];
wire [COM_DATALEN*16 - 1:0] 							result_wire_pool;
wire [COM_DATALEN-1:0] 							result_wire_pool_show[X_MESH-1:0];
wire result_valid;
wire result_valid_pool;
wire [20*X_PE - 1:0]						bb_bias;
wire [ADDR_LEN_BB - 1:0]										bb_addr;
wire [5 - 1:0]										bb_shift;

wire [SINGLE_LEN - 1:0  ]     bfc_bias_num; // 
wire [SINGLE_LEN - 1:0  ]     bfc_bias_ddr_byte; 
wire [DDR_ADDR_LEN - 1:0]     bfc_ddr_st_addr;
wire [ADDR_LEN_BB - 1:0 ]     bfc_bb_st_addr;
wire                          wfc_idle;
wire 							wfc_conf;
wire [SINGLE_LEN - 1:0  ]     wfc_weight_num; // 
wire [SINGLE_LEN - 1:0  ]     wfc_weight_ddr_byte;
wire [DDR_ADDR_LEN - 1:0]     wfc_ddr_st_addr;
wire [ADDR_LEN_WB - 1:0 ]     wfc_wb_st_addr;


wire 							dfc_conf;
wire [SINGLE_LEN - 1:0  ]     dfc_data_width; // 
wire [SINGLE_LEN - 1:0  ]     dfc_data_ddr_byte;
wire [DDR_ADDR_LEN - 1:0]     dfc_ddr_st_addr;
wire [ADDR_LEN_BP - 1:0 ]     dfc_data_st_addr;
wire [1:0] dfc_st_mac;


wire 							dwc_conf;
wire [SINGLE_LEN - 1:0  ]     dwc_data_width; // 
wire [SINGLE_LEN - 1:0  ]     dwc_data_ddr_byte;
wire [DDR_ADDR_LEN - 1:0]     dwc_ddr_st_addr;
wire [ADDR_LEN_BP - 1:0 ]     dwc_data_st_addr;
wire [1:0] dwc_st_mac;



wire [ADDR_LEN_BB - 1:0]           bfc_wr_addr ;
wire [X_PE/8 - 1:0]        bfc_wea      ;
wire [64*8 - 1:0] bfc_data_wr;  //8 here is 512/DATA_LEN

wire [1:0] switch;
wire [DDR_ADDR_LEN - 1:0] ddr_st_addr_out_bias;
wire [SINGLE_LEN - 1:0]   ddr_len_bias;
wire                      ddr_conf_bias;
wire                      ddr_fifo_empty_bias;
wire                      ddr_fifo_req_bias;
wire [DDR_DATA_LEN - 1:0]     ddr_fifo_data_bias;

wire [DDR_ADDR_LEN - 1:0] ddr_st_addr_out_weights;
wire [SINGLE_LEN - 1:0]   ddr_len_weights;
wire                      ddr_conf_weights;
wire                      ddr_fifo_empty_weights;
wire                      ddr_fifo_req_weights;
wire [DDR_DATA_LEN - 1:0]     ddr_fifo_data_weights;

wire [DDR_ADDR_LEN - 1:0] ddr_st_addr_out_data;
wire [SINGLE_LEN - 1:0]   ddr_len_data;
wire                      ddr_conf_data;
wire                      ddr_fifo_empty_data;
wire                      ddr_fifo_req_data;
wire   [DDR_DATA_LEN - 1:0]     ddr_fifo_data_data;


wire   [DDR_ADDR_LEN - 1:0]   ddr_st_addr_out_mux;
wire  [SINGLE_LEN - 1:0]     ddr_len_mux;
wire                         ddr_conf_mux;

wire                        ddr_fifo_empty_mux;
wire                         ddr_fifo_req_mux;
wire   [DDR_DATA_LEN - 1:0]     ddr_fifo_data_mux;

wire   [C_AXI_DATA_WIDTH - 1:0]  ddr_write_data_dwrite;
wire ddr_write_empty_dwrite;
wire ddr_write_req_dwrite;
wire  [DDR_ADDR_LEN - 1:0] ddr_st_addr_out_dwrite;
wire  [SINGLE_LEN - 1:0] ddr_len_dwrite;
wire  ddr_conf_dwrite;

wire  [SINGLE_LEN - 1:0]     mig_ddr_len;
wire [DDR_ADDR_LEN - 1:0] mig_ddr_st_addr;

genvar i,j,k;
//generate
// for (i=0;i<X_MESH;i = i+1) begin:ass   
//       for (j =0;j<X_MAC;j=j+1) begin:assh
//            assign doutb_show[i][j] = doutb[j*32+i*32*X_MAC +: 32] ;
//            assign dina_show[i][j] = dina[j*32+i*32*X_MAC +: 32] ;
//            assign wea_show[i][j] = w2c_wea[j+i*X_MAC];
//            assign addrb_show[i][j] = addrb[j*ADDR_LEN_BP+i*ADDR_LEN_BP*X_MAC +: ADDR_LEN_BP] ;
//            assign addra_show[i][j] = addra[j*ADDR_LEN_BP+i*ADDR_LEN_BP*X_MAC +: ADDR_LEN_BP] ;
//            assign dwire_show[i][j] = dwire[j*32+i*32*X_MAC +: 32] ;
//       end
// end
//endgenerate 

//generate
// for (i=0;i< X_PE;i = i+1) begin:ass1   
//       for (j =0;j< X_MESH;j=j+1) begin:assh
//			for (k =0;k < 9;k=k+1) begin:asshh
//				assign ker_out_show[i][j][k] = wb_ker_out[k*8 +  j*72	+	i*72*X_MESH +: 8];
//			end
//       end
// end
//endgenerate

//generate
//for (i=0;i<X_MESH;i = i+1) begin:ass2   
//        assign result_wire_pool_show[i] = result_wire_pool[i*COM_DATALEN +: COM_DATALEN];		
//       for (j =0;j<2;j =j+1) begin:assh
//		for (k =0;k<2;k = k+1) begin:assh3
//            assign result_wire_unpool_show[i][j][k] = result_wire_unpool[k*COM_DATALEN + j*COM_DATALEN*2 +i*COM_DATALEN*4 +: COM_DATALEN];			
//		end
//       end
//end
//endgenerate


wire id_w2c;
wire id_wb;
wire id_soon_ilc;
wire ilc_fromfifo;
wire ilc_tofifo;
wire is_w2c_back;
wire w2c_pooled;
wire w2c_conf;
wire pooled_type;
wire is_bb_add;
wire bfc_idle;
wire bfc_conf;
wire dfc_idle;
wire dwc_idle;
wire mig_type;
wire bias_en;
wire bb_idle;
wire PEC_tofifo;
wire PEC_fromfifo;
wire out_req;

topcontrol#(
.ADDR_LEN_WB(ADDR_LEN_WB),
.ADDR_LEN_BP(ADDR_LEN_BP),
.ADDR_LEN_BB(ADDR_LEN_BB),
.X_PE(X_PE),
.X_MESH(X_MESH),
.MAX_LINE_LEN(MAX_LINE_LEN)
) tctrl(
	.clk(clk),
	.rst_n     (rst_n),
	.instruct(instruct),
	.inst_empty(inst_empty),
	.inst_req(inst_req),
	.idle_data_soon(id_wb && id_soon_ilc),
	.idle_write_back(id_w2c),
	.wb_st_rd_addr  (wb_st_rd_addr),
	.wb_rd_conf     (wb_rd_conf),
	.bsr_iszero     (bsr_iszero),
	.bsr_buffermux  (bsr_buffermux),
	.ilc_fromfifo   (ilc_fromfifo),
	.ilc_tofifo     (ilc_tofifo),
	.ilc_ispad      (ilc_ispad),
	.ilc_st_addr    (ilc_st_addr),
	.ilc_linelen    (ilc_linelen),
	.is_w2c_back   (is_w2c_back),
	.w2c_linelen    (w2c_linelen),
	.w2c_st_addr    (w2c_st_addr),
	.w2c_pooled     (w2c_pooled),
	.w2c_shift_len (w2c_shift_len),
	.w2c_valid_mac (w2c_valid_mac),
	.w2c_conf       (w2c_conf),
	.pooled_type    (pooled_type),
	.is_bb_add	(is_bb_add),
	.bb_addr	(bb_addr),
	.bb_shift	(bb_shift),
	
	.bfc_idle(bfc_idle),
	.bfc_conf(bfc_conf),
	.bfc_bias_num(bfc_bias_num), // 
	.bfc_bias_ddr_byte(bfc_bias_ddr_byte), 
	.bfc_ddr_st_addr(bfc_ddr_st_addr),
	.bfc_bb_st_addr(bfc_bb_st_addr),

	.wfc_idle(wfc_idle),
	.wfc_conf(wfc_conf),
	.wfc_weight_num(wfc_weight_num), // 
	.wfc_weight_ddr_byte(wfc_weight_ddr_byte),
	.wfc_ddr_st_addr(wfc_ddr_st_addr),
	.wfc_wb_st_addr(wfc_wb_st_addr),
	
	.dfc_idle(dfc_idle),
	.dfc_conf(dfc_conf),
	.dfc_data_width(dfc_data_width), // 
	.dfc_data_ddr_byte(dfc_data_ddr_byte),
	.dfc_ddr_st_addr(dfc_ddr_st_addr),
	.dfc_data_st_addr(dfc_data_st_addr),
	.dfc_st_mac(dfc_st_mac),
	
	.dwc_idle(dwc_idle),
	.dwc_conf(dwc_conf),
	.dwc_data_width(dwc_data_width), // 
	.dwc_data_ddr_byte(dwc_data_ddr_byte),
	.dwc_ddr_st_addr(dwc_ddr_st_addr),
	.dwc_data_st_addr(dwc_data_st_addr),
	.dwc_st_mac(dwc_st_mac),
	
	.switch(switch),
	.mig_type(mig_type)
	
);

Bias_FIFO_CONTROL #(
.X_PE       (X_PE      ),
.ADDR_LEN   (ADDR_LEN_BB)
) bfc(
.clk       (clk       ),
.rst_n     (rst_n),

.bias_num(bfc_bias_num),

.bias_ddr_byte(bfc_bias_ddr_byte),
.ddr_st_addr(bfc_ddr_st_addr),
.bb_st_addr(bfc_bb_st_addr),

 .ddr_st_addr_out(ddr_st_addr_out_bias),
 .ddr_len(ddr_len_bias),
 .ddr_conf(ddr_conf_bias),


 .ddr_fifo_empty (ddr_fifo_empty_bias),
 .ddr_fifo_req   (ddr_fifo_req_bias),
 .ddr_fifo_data  (ddr_fifo_data_bias),


.conf(bfc_conf),
.bb_wea (bfc_wea),
.bb_addr (bfc_wr_addr),
.bb_data (bfc_data_wr),

.idle(bfc_idle)
);

BiasBuffer #(
	.X_PE       (X_PE      ),
	.ADDR_LEN   (ADDR_LEN_BB  )
) BB(
	.data_wr(bfc_data_wr),     
	.wr_addr(bfc_wr_addr),  
	.wr_en(bfc_wea),        
	.bias_shift(bb_shift),  	
	.bias_out(bb_bias),
	.st_rd_addr(bb_addr),
	.bias_en(bias_en),   
	.rd_conf(indata_valid),
	.usebias(is_bb_add),
	.idle(bb_idle),     
	.clk(clk),       
	.rst_n(rst_n)
);


Weight_FIFO_CONTROL #(
.X_PE(X_PE),
.X_MESH(X_MESH),
.ADDR_LEN   (ADDR_LEN_WB  )
)wfc(
.clk       (clk       ),
.rst_n     (rst_n),

.weight_num(wfc_weight_num),
.weight_ddr_byte(wfc_weight_ddr_byte),
.ddr_st_addr(wfc_ddr_st_addr),
.wb_st_addr(wfc_wb_st_addr),

.ddr_st_addr_out(ddr_st_addr_out_weights),
.ddr_len(ddr_len_weights),
.ddr_conf(ddr_conf_weights),

.ddr_fifo_empty (ddr_fifo_empty_weights),
.ddr_fifo_req   (ddr_fifo_req_weights),
.ddr_fifo_data  (ddr_fifo_data_weights),


.conf  (wfc_conf),
.wb_wea (wfc_wea),
.wb_addr (wfc_wr_addr),
.wb_data (wfc_wr_data),

.idle(wfc_idle)
);


BP_FIFO_CONTROL #(
.X_PE(X_PE),
.X_MESH(X_MESH),
.ADDR_LEN   (ADDR_LEN_BP  )
)dfc(
.clk       (clk       ),
.rst_n     (rst_n),

.Line_width(dfc_data_width), // line/4
.data_ddr_byte(dfc_data_ddr_byte), // line*16*2
.ddr_st_addr(dfc_ddr_st_addr),
.BP_st_addr(dfc_data_st_addr),

.BP_st_num(dfc_st_mac),

.ddr_st_addr_out(ddr_st_addr_out_data),
.ddr_len(ddr_len_data),
.ddr_conf(ddr_conf_data),

.ddr_fifo_empty (ddr_fifo_empty_data),
.ddr_fifo_req   (ddr_fifo_req_data),
.ddr_fifo_data  (ddr_fifo_data_data),


.conf  (dfc_conf),
.BP_wea (dfc_BP_wea),
.BP_addr_out (dfc_BP_addra),
.BP_data_out (dfc_BP_dina),

.idle(dfc_idle)

);


BP_WRITE_CONTROL #(
.X_PE(X_PE),
.X_MESH(X_MESH),
.ADDR_LEN   (ADDR_LEN_BP  )
)dwc(
.clk       (clk       ),
.rst_n     (rst_n),

.Line_width(dwc_data_width), // line/4
.data_ddr_byte(dwc_data_ddr_byte), // line*16*2
.ddr_st_addr(dwc_ddr_st_addr),
.BP_st_addr(dwc_data_st_addr),

.BP_st_num(dwc_st_mac),

.ddr_st_addr_out(ddr_st_addr_out_dwrite),
.ddr_len(ddr_len_dwrite),
.ddr_conf(ddr_conf_dwrite),

.ddr_write_empty (ddr_write_empty_dwrite),
.ddr_write_req   (ddr_write_req_dwrite),
.ddr_write_data_out  (ddr_write_data_dwrite),


.conf  (dwc_conf),
.BP_addr_out (dwc_BP_addr),
.BP_data_in (doutb),

.idle(dwc_idle)

);


always @ (posedge clk) begin
    addrb <= (!dwc_idle) ? dwc_BP_addr : ilc_addrb;
    addra <= (!dfc_idle) ? dfc_BP_addra : w2c_addra;
    dina <= (!dfc_idle) ? dfc_BP_dina : w2c_dina;
    wea <= (!dfc_idle) ? dfc_BP_wea : w2c_wea;
end 
assign mig_ddr_len = (!dwc_idle) ? ddr_len_dwrite : ddr_len_mux;
assign mig_ddr_st_addr = (!dwc_idle) ? dwc_ddr_st_addr : ddr_st_addr_out_mux;

muxddr mddr(
.clk(clk),
.rst_n(rst_n),
.switch(switch),


.ddr_st_addr_out(ddr_st_addr_out_mux),
.ddr_len(ddr_len_mux),
.ddr_conf(ddr_conf_mux),


.ddr_fifo_empty(ddr_fifo_empty_mux),
.ddr_fifo_req(ddr_fifo_req_mux),
.ddr_fifo_data(ddr_fifo_data_mux),


.ddr_st_addr_out_bias(ddr_st_addr_out_bias),
.ddr_len_bias(ddr_len_bias),
.ddr_conf_bias(ddr_conf_bias),
.ddr_fifo_empty_bias(ddr_fifo_empty_bias),
.ddr_fifo_req_bias(ddr_fifo_req_bias),
.ddr_fifo_data_bias(ddr_fifo_data_bias),

.ddr_st_addr_out_weights(ddr_st_addr_out_weights),
.ddr_len_weights        (ddr_len_weights),
.ddr_conf_weights       (ddr_conf_weights),
.ddr_fifo_empty_weights (ddr_fifo_empty_weights),
.ddr_fifo_req_weights   (ddr_fifo_req_weights),
.ddr_fifo_data_weights  (ddr_fifo_data_weights),

.ddr_st_addr_out_data  (ddr_st_addr_out_data),
.ddr_len_data          (ddr_len_data),
.ddr_conf_data         (ddr_conf_data),
.ddr_fifo_empty_data   (ddr_fifo_empty_data),
.ddr_fifo_req_data     (ddr_fifo_req_data),
.ddr_fifo_data_data    (ddr_fifo_data_data)
);


mig_axi_data#(
    .C_AXI_ID_WIDTH(C_AXI_ID_WIDTH),
   .C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH), 
   .C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH)
) u_axi4_tg_inst
   (
     .clk                             (clk),
     .rst_n                          (rst_n),

// Input control signals
     .init_cmptd                       (init_cmptd),
	 

// Slave Interface Write Address Ports
   .axi_awready(axi_awready),      
   .axi_awid(axi_awid),         
   .axi_awaddr(axi_awaddr),       
   .axi_awlen(axi_awlen),        
   .axi_awsize(axi_awsize),       
   .axi_awburst(axi_awburst),      
   .axi_awlock(axi_awlock),       
   .axi_awcache(axi_awcache),      
   .axi_awprot(axi_awprot),       
   .axi_awvalid(axi_awvalid),      
   // .lave(lave), .nterface(nterface),
   .axi_wready(axi_wready),       
   .axi_wdata(axi_wdata),        
   .axi_wstrb(axi_wstrb),        
   .axi_wlast(axi_wlast),        
   .axi_wvalid(axi_wvalid),       
   // .lave(lave), .nterface(nterface),
   .axi_bid(axi_bid),          
   .axi_bresp(axi_bresp),        
   .axi_bvalid(axi_bvalid),       
   .axi_bready(axi_bready),       
   // .lave(lave), .nterface(nterface),
   .axi_arready(axi_arready),      
   .axi_arid(axi_arid),         
   .axi_araddr(axi_araddr),       
   .axi_arlen(axi_arlen),        
   .axi_arsize(axi_arsize),       
   .axi_arburst(axi_arburst),      
   .axi_arlock(axi_arlock),       
   .axi_arcache(axi_arcache),      
   .axi_arprot(axi_arprot),       
   .axi_arvalid(axi_arvalid),      
   // .lave(lave), .nterface(nterface),
   .axi_rid(axi_rid),          
   .axi_rresp(axi_rresp),        
   .axi_rvalid(axi_rvalid),       
   .axi_rdata(axi_rdata),        
   .axi_rlast(axi_rlast),        
   .axi_rready(axi_rready),       
  
  .axi_size(3'd5),
	 
	 
	 .cmd_type(mig_type),
	 
	 
 .ddr_st_addr_out(mig_ddr_st_addr),
 .ddr_len(mig_ddr_len),
 .ddr_conf(ddr_conf_mux || ddr_conf_dwrite),
 
 
 .ddr_fifo_empty(ddr_fifo_empty_mux),
 .ddr_fifo_req(ddr_fifo_req_mux),
 .ddr_fifo_data(ddr_fifo_data_mux),
 
 .in_fifo_empty(ddr_write_empty_dwrite),
 .in_fifo_req(ddr_write_req_dwrite),
 .in_fifo_data(ddr_write_data_dwrite)
	 
 );

WeightBuffer #(
.X_PE       (X_PE      ),
.X_MESH     (X_MESH    ),
.ADDR_LEN   (ADDR_LEN_WB  )
) WB(
.data_wr   (wfc_wr_data   ),
.wr_addr(wfc_wr_addr),
.wr_en     (wfc_wea),
.ker_out   (wb_ker_out   ),
.idle	(id_wb),
.st_rd_addr(wb_st_rd_addr),
.ker_en    (wb_ker_en    ),
.indata_valid(indata_valid),
.rd_conf   (wb_rd_conf   ),
.clk       (clk       ),
.rst_n     (rst_n)
);


Winograd_PE_CORE#(

.X_PE(15),
.MESH_N(15)
) PEC
(
	.clk(clk),
	.in_valid(out_valid),
	.poolop(pooled_type),	
	.rst_n(rst_n),
	.feature(dwire),
	.weight(wb_ker_out),
	.out_valid(result_valid_pool),
	.tofifo(PEC_tofifo),
	.fromfifo(PEC_fromfifo),
	.bias(bb_bias),
	.bias_valid(1),
	.result_unpool(result_wire_unpool),
	.result_pool(result_wire_pool)
);

BufferPool#(
.X_MAC(X_MAC),
.X_MESH(X_MESH),
.ADDR_LEN(ADDR_LEN_BP)
) bp /* synthesis syn_keep = 1 */
 (
    .dina(dina),
    .addra(addra),
    .wea(wea),
    .doutb(doutb),
    .addrb(addrb),
    .clk(clk)
); /* synthesis syn_keep = 1 */

buffer_shift_register#(
.X_MAC(X_MAC),
.X_MESH(X_MESH)
) bsr(
	.din(doutb),
	.dout(dwire),
	.control(control),
	.iszero(bsr_iszero),
	.buffermux(bsr_buffermux),
	.clk(clk)
);

inlinecontrol#(
.X_MAC(X_MAC),
.X_MESH(X_MESH),
.MAX_LINE_LEN(MAX_LINE_LEN),
.ADDR_LEN(ADDR_LEN_BP)
) ilc(
	.st_addr(ilc_st_addr),
	.linelen(ilc_linelen), //after_pad 至少�??????4
	.ispad(ilc_ispad),
	.idle_soon(id_soon_ilc),
	.addrb(ilc_addrb),
	.control_out(control),
	.tofifo(ilc_tofifo),
	.fromfifo(ilc_fromfifo),
	.pe_tofifo(PEC_tofifo),
	.pe_fromfifo(PEC_fromfifo),
	.valid(indata_valid),
	.out_valid(out_valid),
	.rst_n(rst_n),
	.clk(clk)
	);

write2control#(
.X_MAC(X_MAC),
.X_MESH(X_MESH),
.MAX_LINE_LEN(MAX_LINE_LEN),
.ADDR_LEN(ADDR_LEN_BP)
) w2c(
	.st_addr(w2c_st_addr),
	.pooled(w2c_pooled),
	.linelen(w2c_linelen),
	.addra(w2c_addra),
	.data_a(w2c_dina),
	.wea(w2c_wea),
	.req(out_req),
	.idle(id_w2c),
	.shift_len(w2c_shift_len),
	.in_data_4(result_wire_unpool),
	.in_data_1(result_wire_pool),
	.conf(w2c_conf),
	.dvalid(result_valid_pool),
	.valid_mac(w2c_valid_mac),
	.rst_n(rst_n),
	.clk(clk)
	);


  
endmodule
