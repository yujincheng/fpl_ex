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


module topcontrol #(
	parameter X_PE = 16,
	parameter X_MAC = 4,
	parameter X_MESH = 16,
	parameter ADDR_LEN_WB = 10,
	parameter ADDR_LEN_BP = 13,
	parameter ADDR_LEN_BB = 7,
	parameter INST_LEN = 220,
	parameter INST_ADDR_LEN = 16,
	parameter MAX_LINE_LEN = 10,
	parameter SINGLE_LEN  = 24,
	parameter DDR_ADDR_LEN = 32,
	parameter COM_DATALEN = 24
  )(
	input   wire clk,
	input   wire rst_n,
	output  reg [1:0] switch,
	
	input	wire [INST_LEN - 1:0]	instruct,
										//  ilc_st_addr   35:0 
										//	ilc_ispad     36:36
										//	ilc_linelen   45:37
										//	bsr_iszero    49:46
										//	bsr_buffermux 57:50
										//	ilc_fromfifo  58:58
										//	ilc_tofifo    59:59
										//	is_w2c_back   60:60
										//  w2c_st_addr   96:61
	                                    //  w2c_linelen   105:97
	                                    //	w2c_pooled    106:106
	                                    //  pooled_type   107:107
										//  wb_st_rd_addr 116:108
										//  w2c_shift_len 121:117
										//	w2c_valid_mac 123:122
										//  is_bb_        124:124
										//  bias_addr     131:125
										//  bias_shift    136:132
										
	input	wire inst_empty,                 
	output  reg inst_req,
	
	input 	wire idle_data_soon,
	input   wire idle_write_back,
	
	input   wire idle_weights_in,
	input   wire idle_bias_in,
	input   wire idle_data_in,
	
	output	reg [ADDR_LEN_WB - 1:0]      	wb_st_rd_addr ,
	output	reg                         	wb_rd_conf    ,
	output	reg [3:0]                   	bsr_iszero    ,
	output	reg [7:0]                   	bsr_buffermux ,
	output  reg								ilc_fromfifo  ,
	output  reg								ilc_tofifo    ,
	output	reg 							ilc_ispad     ,
	output	reg [ADDR_LEN_BP*X_MAC - 1:0] 	ilc_st_addr   ,
	output	reg [MAX_LINE_LEN - 1 : 0]						ilc_linelen   ,
	output	reg [MAX_LINE_LEN - 1 : 0]						w2c_linelen   ,
	output	reg [ADDR_LEN_BP*X_MAC - 1:0]	w2c_st_addr   ,
	output	reg 							w2c_pooled    ,
	output	reg 							w2c_conf      ,
	output	reg 							pooled_type   ,
	output  reg	[4:0]						w2c_shift_len ,
	output reg 								is_w2c_back,
	output	reg [1:0]						w2c_valid_mac,
	output reg 								is_bb_add,
	output reg  [ADDR_LEN_BB - 1:0]						bb_addr,
	output reg  [4:0]						bb_shift,
	
	input  wire                         bfc_idle,
	output reg 							bfc_conf,
	output reg [SINGLE_LEN - 1:0  ]     bfc_bias_num, // �?要一次读这么多个bias，bias=9代表�?有bb中地�?增加1个�?�在DDR中是连续 X_PE byte�?
	output reg [SINGLE_LEN - 1:0  ]     bfc_bias_ddr_byte, // X_PE*bias
	output reg [DDR_ADDR_LEN - 1:0]     bfc_ddr_st_addr,
	output reg [ADDR_LEN_BB - 1:0 ]     bfc_bb_st_addr,
	
	
	input  wire                         wfc_idle,
	output reg 							wfc_conf,
	output reg [SINGLE_LEN - 1:0  ]     wfc_weight_num, // 
	output reg [SINGLE_LEN - 1:0  ]     wfc_weight_ddr_byte, // X_PE*X_MESH*weights
	output reg [DDR_ADDR_LEN - 1:0]     wfc_ddr_st_addr,
	output reg [ADDR_LEN_WB - 1:0 ]     wfc_wb_st_addr,
	
	
	input  wire                         dfc_idle,
	output reg 							dfc_conf,
	output reg [SINGLE_LEN - 1:0  ]     dfc_data_width, // 
	output reg [SINGLE_LEN - 1:0  ]     dfc_data_ddr_byte, //
	output reg [DDR_ADDR_LEN - 1:0]     dfc_ddr_st_addr,
	output reg [ADDR_LEN_BP - 1:0 ]     dfc_data_st_addr
	
);


wire  [3:0]						 inst_type;
wire  [3:0]						 inst_type_t1;
wire  [3:0]						 inst_type_t2;
wire  [3:0]						 inst_type_t3;

// compute
wire  [INST_ADDR_LEN * 4 - 1:0]  inst_ilc_st_addr    ;
wire  [0:0                    ]  inst_ilc_ispad      ;
wire  [MAX_LINE_LEN - 1 :0    ]  inst_ilc_linelen    ;
wire  [3:0                    ]  inst_bsr_iszero     ;
wire  [7:0                    ]  inst_bsr_buffermux  ;
wire  [0:0                    ]  inst_ilc_fromfifo   ;
wire  [0:0                    ]  inst_ilc_tofifo     ;
wire  [0:0                    ]  inst_is_w2c_back    ;
wire  [INST_ADDR_LEN * 4 - 1:0]  inst_w2c_st_addr    ;
wire  [MAX_LINE_LEN - 1:0     ]  inst_w2c_linelen    ;
wire  [0:0                    ]  inst_w2c_pooled     ;
wire  [0:0                    ]  inst_pooled_type    ;
wire  [INST_ADDR_LEN - 1:0    ]  inst_wb_st_rd_addr  ;
wire  [4:0                    ]  inst_w2c_shift_len  ;
wire  [1:0                    ]  inst_w2c_valid_mac  ;
wire  [0:0                    ]  inst_is_bb_         ;
wire  [INST_ADDR_LEN - 1:0    ]  inst_bias_addr      ;
wire  [5:0                    ]  inst_bias_shift     ;
wire  [3:0]                      inst_dep;

// load_bias
wire  [SINGLE_LEN - 1:0]         inst_bfc_bias_num;
wire  [SINGLE_LEN - 1:0] inst_bfc_bias_ddr_byte; //inst_bfc_bias_num * 16 
wire  [DDR_ADDR_LEN - 1:0] inst_bfc_ddr_st_addr;
wire  [SINGLE_LEN - 1:0] inst_bfc_bb_st_addr;

//load_weight
wire  [SINGLE_LEN - 1:0]         inst_wfc_weight_num;
wire  [SINGLE_LEN - 1:0] inst_wfc_weight_ddr_byte; 
wire  [DDR_ADDR_LEN - 1:0] inst_wfc_ddr_st_addr;
wire  [SINGLE_LEN - 1:0] inst_wfc_wb_st_addr;

//load_data
wire  [SINGLE_LEN - 1:0]         inst_dfc_data_width;
wire  [SINGLE_LEN - 1:0] inst_dfc_data_ddr_byte;
wire  [DDR_ADDR_LEN - 1:0] inst_dfc_ddr_st_addr;
wire  [SINGLE_LEN - 1:0] inst_dfc_data_st_addr;




assign {inst_dep,inst_bias_shift     ,inst_bias_addr      ,inst_is_bb_         ,inst_w2c_valid_mac  ,inst_w2c_shift_len  ,inst_wb_st_rd_addr  ,inst_pooled_type    ,inst_w2c_pooled     ,inst_w2c_linelen    ,inst_w2c_st_addr    ,inst_is_w2c_back    ,inst_ilc_tofifo     ,inst_ilc_fromfifo   ,inst_bsr_buffermux  ,inst_bsr_iszero     ,inst_ilc_linelen    ,inst_ilc_ispad      ,inst_ilc_st_addr,inst_type} = instruct;


assign {inst_bfc_bb_st_addr,inst_bfc_ddr_st_addr,inst_bfc_bias_ddr_byte,inst_bfc_bias_num,inst_type_t1} = instruct;

assign {inst_wfc_wb_st_addr,inst_wfc_ddr_st_addr,inst_wfc_weight_ddr_byte,inst_wfc_weight_num,inst_type_t2} = instruct;

assign {inst_dfc_data_st_addr,inst_dfc_ddr_st_addr,inst_dfc_data_ddr_byte,inst_dfc_data_width,inst_type_t3} = instruct;






localparam OVER_ADDR = ADDR_LEN_BP - INST_ADDR_LEN;
wire [ADDR_LEN_BP*4 - 1:0] ilc_st_addr_tmp;
wire [ADDR_LEN_BP*4 - 1:0] w2c_st_addr_tmp;
genvar index_i;
generate
	if (OVER_ADDR > 0) begin:long
		for (index_i = 0;index_i < 4;index_i = index_i + 1) begin
			assign ilc_st_addr_tmp[ADDR_LEN_BP*(index_i+1)-1:index_i*ADDR_LEN_BP] = {{OVER_ADDR{1'b0}},inst_ilc_st_addr[(index_i+1)*INST_ADDR_LEN -1 :index_i*INST_ADDR_LEN]};
			assign w2c_st_addr_tmp[ADDR_LEN_BP*(index_i+1)-1:index_i*ADDR_LEN_BP] = {{OVER_ADDR{1'b0}},inst_w2c_st_addr[(index_i+1)*INST_ADDR_LEN -1 :index_i*INST_ADDR_LEN]};
		end
	end
	else  begin:short
		for (index_i = 0;index_i < 4;index_i = index_i + 1) begin
			assign ilc_st_addr_tmp[ADDR_LEN_BP*(index_i+1)-1:index_i*ADDR_LEN_BP] = {inst_ilc_st_addr[(index_i+1)*INST_ADDR_LEN -1 :index_i*INST_ADDR_LEN]};
			assign w2c_st_addr_tmp[ADDR_LEN_BP*(index_i+1)-1:index_i*ADDR_LEN_BP] = {inst_w2c_st_addr[(index_i+1)*INST_ADDR_LEN -1 :index_i*INST_ADDR_LEN]};
		end
	end
endgenerate


always @( posedge clk) begin
	if(!rst_n) begin
		wb_st_rd_addr      <= 0;
		wb_rd_conf         <= 0;
		bsr_iszero         <= 0;
		bsr_buffermux      <= 0;
		ilc_fromfifo       <= 0;
		ilc_tofifo         <= 0;
		ilc_ispad          <= 0;
		ilc_st_addr        <= 0;
		ilc_linelen        <= 0;
		w2c_linelen        <= 0;
		w2c_st_addr        <= 0;
		w2c_pooled         <= 0;
		w2c_conf           <= 0;
		inst_req 	       <= 0;
		pooled_type        <= 0;
		w2c_valid_mac      <= 0;
		w2c_shift_len      <= 0;
		bb_addr            <= 0;
		bb_shift           <= 0;
		is_w2c_back        <= 0;
		is_bb_add          <= 0;
		
		bfc_conf           <= 0;
		bfc_bias_num       <= 0;
		bfc_bias_ddr_byte  <= 0;
		bfc_ddr_st_addr    <= 0;
		bfc_bb_st_addr     <= 0;
		
		wfc_conf           <= 0;		
		wfc_weight_num     <= 0;
		wfc_weight_ddr_byte <= 0;
		wfc_ddr_st_addr    <= 0;
		wfc_wb_st_addr     <= 0;
		dfc_conf <= 0;
		switch <= 0;
		
	end
	else if(!inst_empty) begin	
		if( inst_type == 4'd0) begin
			if( ( inst_is_w2c_back ? (idle_data_soon && idle_write_back): idle_data_soon)) begin
				if(wb_rd_conf) begin 
					w2c_conf <= 0;
					wb_rd_conf <= 0;
					inst_req <= 0;
				end
				else if( ~((inst_dep[0] && ~wfc_idle) || (inst_dep[1] && ~bfc_idle) ) ) begin
					inst_req <= 1;
					wb_rd_conf <= 1;
					wb_st_rd_addr  <= inst_wb_st_rd_addr;
					bsr_iszero     <= inst_bsr_iszero;
					bsr_buffermux  <= inst_bsr_buffermux;
					ilc_fromfifo   <= inst_ilc_fromfifo;
					ilc_tofifo     <= inst_ilc_tofifo;
					ilc_ispad      <= inst_ilc_ispad;
					ilc_st_addr    <= inst_ilc_st_addr;
					ilc_linelen    <= inst_ilc_linelen;
					pooled_type <= inst_pooled_type;
					if(inst_is_w2c_back) begin
						w2c_conf <= 1;
						w2c_st_addr <= w2c_st_addr_tmp;
						w2c_linelen <= inst_w2c_linelen;
						w2c_pooled  <= inst_w2c_pooled;
						w2c_shift_len <= inst_w2c_shift_len;
						w2c_valid_mac <= inst_w2c_valid_mac;
						is_w2c_back <= 1;
					end
					else begin
						w2c_conf <= 0;
						is_w2c_back <= 0;
					end
					if(inst_is_bb_) begin
						bb_addr <= inst_bias_addr;
						bb_shift <= inst_bias_shift;
						is_bb_add <= 1;
					end
					else begin
						is_bb_add <= 0;
					end
				end		
			end
			else begin
			if(wb_rd_conf) begin 
				w2c_conf <= 0;
				wb_rd_conf <= 0;
				inst_req <= 0;
			end
		end
		end
		else if (inst_type == 4'd1) begin
			if(wfc_idle && bfc_idle) begin
				if(wfc_conf) begin
					wfc_conf <= 0;
					inst_req <= 0;
				end
				else begin
					wfc_conf <= 1;
					switch <= 1;
					inst_req <= 1;
					
					
					
					wfc_weight_num <= inst_wfc_weight_num;
					wfc_weight_ddr_byte <= inst_wfc_weight_ddr_byte;
					wfc_ddr_st_addr <= inst_wfc_ddr_st_addr;
					wfc_wb_st_addr <= inst_wfc_wb_st_addr;					
				end
			end
			else begin
				wfc_conf <= 0;
				inst_req <= 0;
			end
		end
		else if (inst_type == 4'd2) begin
			if(bfc_idle && wfc_idle) begin
				if(bfc_conf) begin
					bfc_conf <= 0;
					inst_req <= 0;
				end
				else begin
					bfc_conf <= 1;
					switch <= 2;
					inst_req <= 1;
					bfc_bias_num <= inst_bfc_bias_num;
					bfc_bias_ddr_byte <= inst_bfc_bias_ddr_byte;
					bfc_ddr_st_addr <= inst_bfc_ddr_st_addr;
					bfc_bb_st_addr <= inst_bfc_bb_st_addr;					
				end
			end
			else begin
				bfc_conf <= 0;
				inst_req <= 0;
			end
		end
		else if (inst_type == 4'd3) begin
			if(dfc_idle) begin
				if(dfc_conf) begin
					dfc_conf <= 0;
					inst_req <= 0;
				end
				else begin
					dfc_conf <= 1;
					switch <= 3;
					inst_req <= 1;
					dfc_data_width <= inst_dfc_data_width;
					dfc_data_ddr_byte <= inst_dfc_data_ddr_byte;
					dfc_ddr_st_addr <= inst_dfc_ddr_st_addr;
					dfc_data_st_addr <= inst_dfc_data_st_addr;					
				end
			end
			else begin
				dfc_conf <= 0;
				inst_req <= 0;
			end
		end
	end
end
  
endmodule
