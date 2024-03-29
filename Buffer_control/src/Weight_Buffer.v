`timescale 1ps/1ps
module WeightBuffer#(
parameter X_PE = 16,
parameter X_MESH = 16,
parameter ADDR_LEN = 16,
parameter DATA_LEN = 64,
parameter MUXCONTROL = 4,
parameter DDR_DATA_LEN = 256,
parameter RAM_DEPTH = 2**ADDR_LEN,
parameter BUFFER_NUM = 8*X_PE*X_MESH/(DATA_LEN),
parameter DATAWIDTH = BUFFER_NUM*DATA_LEN,
parameter ADDRWIDTH = BUFFER_NUM*ADDR_LEN
)(

input wire [DDR_DATA_LEN - 1:0]           data_wr              ,  //4 here is 256/DATA_LEN
input wire [ADDR_LEN - 1:0]           wr_addr           ,
input wire [BUFFER_NUM - 1:0]         wr_en                ,


(*dont_touch = "yes"*)output wire [X_PE*X_MESH*8*9 - 1 : 0] ker_out              ,
input wire [ADDR_LEN - 1:0]           st_rd_addr           ,
output reg                           ker_en               ,
input wire                            rd_conf              ,
output wire                            idle             ,
output wire 							indata_valid,
input wire                            clk                  ,
input wire 							  rst_n

);

wire ker_en_wire;
reg [8-1:0] ker_out_show[X_MESH-1:0][X_PE-1:0][9-1:0];
reg [8-1:0] ker_out_show_1[X_MESH-1:0][X_PE-1:0][9-1:0];
wire [DATAWIDTH - 1:0] doutb;
wire [8- 1:0] doutb_show[X_MESH-1:0][X_PE-1:0];
wire [ADDRWIDTH - 1:0]	addrb;
wire [ADDR_LEN - 1:0] addrb_show[BUFFER_NUM-1:0];
reg [ADDR_LEN - 1:0] valid_addr;
wire [BUFFER_NUM - 1:0] wea;
wire [DATAWIDTH - 1:0] dina;
wire [ADDRWIDTH - 1:0] addra;

reg [3:0] cto9;
reg [3:0] cto9_reg;
reg rd_conf_reg;
reg working;
reg read_en;

reg [BUFFER_NUM - 1:0] wea_r1;
reg [DATAWIDTH - 1:0] dina_r1;
reg [ADDRWIDTH - 1:0] addra_r1;


always @ (posedge clk) begin
    read_en <= working;
    ker_en <= ker_en_wire;
    cto9_reg <= cto9;
    rd_conf_reg <= rd_conf;
    
    wea_r1 <= wea;
    dina_r1 <= dina;
    addra_r1 <= addra;
    
end


genvar i,j,k;
generate
 for (i=0;i<X_PE;i = i+1) begin:ass   
       for (j =0;j<X_MESH;j=j+1) begin:assh
			for (k =0;k < 9;k=k+1) begin:asshh
				assign ker_out[k*8 +  j*72	+	i*72*X_MESH +: 8] = ker_out_show[i][j][k];
			end
			assign doutb_show[i][j] = doutb[j*8 + i*8*X_MESH +: 8];
       end
 end
endgenerate
generate
 for (i=0;i<BUFFER_NUM;i = i+1) begin:ass21
		assign  addrb[i*ADDR_LEN +: ADDR_LEN] = addrb_show[i];
		assign wea[i] = wr_en[i];
		assign addra[i*ADDR_LEN +: ADDR_LEN] = wr_addr;
		assign addrb_show[i] = valid_addr;
 end
 for (i=0;i<BUFFER_NUM/(DDR_DATA_LEN/DATA_LEN);i = i+1) begin: dina8
		assign dina[i*DDR_DATA_LEN +: DDR_DATA_LEN] = data_wr; //4 here is 256/DATA_LEN 
 end
endgenerate
generate
    for (i=0;i<X_PE;i = i+1) begin:ass32  
       for (j =0;j<X_MESH;j=j+1) begin:assh
			for (k =0;k < 9;k=k+1) begin:asshh
			
				if (k == 8) begin: keq8
					always @ (posedge clk) begin
						if(!rst_n) begin
							(*dont_touch = "yes"*)ker_out_show_1[i][j][k] <= 0;
							(*dont_touch = "yes"*)ker_out_show [i][j][k] <= 0;
						end
						else if(!rd_conf_reg &&  read_en) begin
								ker_out_show_1[i][j][k] <= doutb_show[i][j];
							if(cto9_reg == 9) begin
								ker_out_show [i][j][k] <= doutb_show[i][j];
							end
						end
					end
				end
				else begin: ken8
					always @ (posedge clk) begin
						if(!rst_n) begin
							(*dont_touch = "yes"*)ker_out_show_1[i][j][k] <= 0;
							(*dont_touch = "yes"*)ker_out_show [i][j][k] <= 0;
						end
						else if(!rd_conf_reg &&  read_en) begin
								ker_out_show_1[i][j][k] <= ker_out_show_1[i][j][k+1];
							if(cto9_reg == 9) begin
								ker_out_show[i][j][k] <= ker_out_show_1[i][j][k+1];
							end
						end
					end
				end
				
			end
       end
 end

endgenerate



always@ (posedge clk) begin:always2
	if(!rst_n) begin
		cto9 <= 0;
		working <= 0;
	end
	else if(rd_conf) begin
		cto9 <= 0;
		working <= 1;
		valid_addr <= st_rd_addr;
	end
	else if(working) begin
		cto9 <= cto9 + 1;
		valid_addr <= valid_addr + 1;
		if(cto9 == 9) begin
			working <= 0;
		end
	end	
end

assign ker_en_wire = (cto9 == 10);
assign indata_valid = (cto9 == 6);
assign idle = (!working || ker_en_wire); 

WeightBufferPool#(
.X_PE       (X_PE      ),
.X_MESH     (X_MESH    ),
.ADDR_LEN   (ADDR_LEN  ),
.DATA_LEN   (DATA_LEN  ),
.RAM_DEPTH  (RAM_DEPTH )
) wbp(
.dina 	(dina_r1 ),
.addra	(addra_r1),
.wea 	(wea_r1 ),
.doutb	(doutb),
.addrb  (addrb),
.clk		(clk)
);

endmodule





module WeightBufferPool#(
parameter X_PE = 16,
parameter X_MESH = 16,
parameter ADDR_LEN = 13,
parameter DATA_LEN = 64,
parameter MUXCONTROL = 4,
parameter RAM_DEPTH = 2**ADDR_LEN,
parameter BUFFER_NUM = X_PE*X_MESH/(DATA_LEN/8),
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

genvar port,kernel;
generate
    for (port = 0; port < X_PE; port = port + 1) begin: BUF_UNIT_1   
        for (kernel = 0; kernel < X_MESH/(DATA_LEN/8); kernel = kernel + 1) begin: BUF_UNIT_2   
			xip_dbram_32_512#(
				.RAM_WIDTH(DATA_LEN),                
				.RAM_DEPTH(RAM_DEPTH),               
				.RAM_PERFORMANCE("HIGH_PERFORMANCE")
			
			) bram_inst (
                // port A
                .addra  (addra[(kernel*ADDR_LEN+port*ADDR_LEN*X_MESH/(DATA_LEN/8) ) +: ADDR_LEN ]),
                .clka   (clk        ),
                .dina   (dina[(kernel*DATA_LEN+port*DATA_LEN*X_MESH/(DATA_LEN/8)) +: DATA_LEN]),
                .wea    (wea[(kernel+port*X_MESH/(DATA_LEN/8))]),
                // port B
                .addrb  (addrb[(kernel*ADDR_LEN+port*ADDR_LEN*X_MESH/(DATA_LEN/8)) +: ADDR_LEN]),
                .doutb  (doutb[(kernel*DATA_LEN+port*DATA_LEN*X_MESH/(DATA_LEN/8)) +: DATA_LEN]),
                .enb    (1'b1       ),
                .rstb (1'b0)
            );
        end
    end    
endgenerate

endmodule