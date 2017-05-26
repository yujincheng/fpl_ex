`timescale 1ps/1ps
module BiasBuffer#(
parameter X_PE = 16,
parameter ADDR_LEN = 9,
parameter DATA_LEN = 64,
parameter MUXCONTROL = 4,
parameter RAM_DEPTH = 2**ADDR_LEN,
parameter BUFFER_NUM = 8*X_PE/(DATA_LEN),
parameter BIAS_DATALEN = 20,
parameter DATAWIDTH = BUFFER_NUM*DATA_LEN,
parameter ADDRWIDTH = BUFFER_NUM*ADDR_LEN
)(

input wire [DATA_LEN*BUFFER_NUM - 1:0]           data_wr                 ,
input wire [ADDR_LEN - 1:0]           wr_addr                 ,
input wire [BUFFER_NUM - 1:0]         wr_en                   ,

input wire [4:0]					bias_shift,

output wire [X_PE*BIAS_DATALEN - 1 : 0] 		bias_out              ,
input wire [ADDR_LEN - 1:0]           st_rd_addr           ,
output wire                           bias_en               ,


input wire                            rd_conf              ,
input wire 							 usebias,



output wire                            idle             ,
input wire                            clk                  ,
input wire 							  rst_n

);

reg signed [BIAS_DATALEN - 1:0] bias_out_reg[X_PE - 1:0];


wire [DATAWIDTH - 1:0] doutb;
wire signed [8- 1:0] doutb_show[X_PE-1:0];
wire [ADDRWIDTH - 1:0]	addrb;
wire [ADDR_LEN - 1:0] addrb_show[BUFFER_NUM-1:0];
reg [ADDR_LEN - 1:0] valid_addr;
wire [BUFFER_NUM - 1:0] wea;
wire [DATAWIDTH - 1:0] dina;
wire [ADDRWIDTH - 1:0] addra;

genvar i,j,k;
generate
   for (j =0;j<X_PE;j=j+1) begin:assh
		assign doutb_show[j] = doutb[j*8 +: 8];
		assign bias_out[j*BIAS_DATALEN +: BIAS_DATALEN] = bias_out_reg[j];
   end
endgenerate
generate
 for (i=0;i<BUFFER_NUM;i = i+1) begin:ass21
		assign addrb[i*ADDR_LEN +: ADDR_LEN] = addrb_show[i];
		assign addra[i*ADDR_LEN +: ADDR_LEN] = wr_addr;
		assign wea[i] = wr_en[i];
		assign addrb_show[i] = valid_addr;
 end
endgenerate
assign dina = data_wr;


reg working;
reg cto1;
reg is_zero;
always@ (posedge clk) begin:always1
	integer i,j,k;
	if(!rst_n) begin
		working <= 0;
		valid_addr <= 0;
		is_zero <= 0;
		cto1 <= 0;
	end
	else if(rd_conf) begin
		working <= 1;
		valid_addr <= st_rd_addr;
		cto1 <= 0;
		if(usebias) is_zero <= 0;
		else is_zero <= 1;
	end
	else if(working) begin
		if(!cto1) begin
			cto1 <= 1;
		end
		else if(cto1) begin
           working <= 0;
           for (j =0;j<X_PE;j=j+1) begin:assh
                if(is_zero) bias_out_reg[j] <= 0;
                else bias_out_reg[j] <= (doutb_show[j] <<< bias_shift);
           end
		
		end
	end
end

assign bias_en = (cto1 == 1);
assign idle = (!working || bias_en); 

BiasBufferPool#(
.X_PE       (X_PE      ),
.ADDR_LEN   (ADDR_LEN  ),
.DATA_LEN   (DATA_LEN  )
) bbp(
.dina 	(dina ),
.addra	(addra),
.wea 	(wea ),
.doutb	(doutb),
.addrb  (addrb),
.clk		(clk)
);

endmodule





module BiasBufferPool#(
parameter X_PE = 16,
parameter ADDR_LEN = 9,
parameter DATA_LEN = 64,
parameter MUXCONTROL = 4,
parameter RAM_DEPTH = 2**ADDR_LEN,
parameter BUFFER_NUM = X_PE/(DATA_LEN/8),
parameter DATAWIDTH = BUFFER_NUM*DATA_LEN,
parameter ADDRWIDTH = BUFFER_NUM*ADDR_LEN
)
(
input  wire [DATAWIDTH-1:0] dina ,
input  wire [ADDRWIDTH-1:0] addra,
input  wire [BUFFER_NUM-1:0] wea ,
output wire [DATAWIDTH-1:0] doutb,
input  wire [ADDRWIDTH-1:0] addrb,
input  clk
);

genvar kernel;
generate 
	for (kernel = 0; kernel < X_PE/(DATA_LEN/8); kernel = kernel + 1) begin: BUF_UNIT  
		xip_dbram_32_512#(
			.RAM_WIDTH(DATA_LEN),                
			.RAM_DEPTH(RAM_DEPTH),               
			.RAM_PERFORMANCE("LOW_LATENCY")
		
		) bram_inst (
			// port A
			.addra  (addra[(kernel*ADDR_LEN ) +: ADDR_LEN ]),
			.clka   (clk        ),
			.dina   (dina[(kernel*DATA_LEN) +: DATA_LEN]),
			.wea    (wea[(kernel)]),
			// port B
			.addrb  (addrb[(kernel*ADDR_LEN) +: ADDR_LEN]),
			.doutb  (doutb[(kernel*DATA_LEN) +: DATA_LEN]),
			.enb    (1'b1       ),
			.rstb (1'b0)
		);
	end
endgenerate

endmodule