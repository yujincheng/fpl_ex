
`timescale 1ps/1ps
module BufferPool#(
parameter X_MAC = 4,
parameter X_MESH = 16,
parameter ADDR_LEN = 13,
parameter DATA_LEN = 32,
parameter MUXCONTROL = 4,
parameter RAM_DEPTH = 2**ADDR_LEN,
parameter BUFFER_NUM = X_MAC*X_MESH,
parameter DATAWIDTH = BUFFER_NUM*DATA_LEN,
parameter ADDRWIDTH = BUFFER_NUM*ADDR_LEN
)(
input wire [DATAWIDTH-1:0] dina,
input wire [ADDRWIDTH-1:0] addra,
input wire [BUFFER_NUM-1:0] wea,
output wire [DATAWIDTH-1:0] doutb,
input wire [ADDRWIDTH-1:0] addrb,
input clk
);

reg [DATAWIDTH-1:0] dina_reg;
reg [ADDRWIDTH-1:0] addra_reg;
reg [BUFFER_NUM-1:0] wea_reg;

always @ (posedge clk) begin
    dina_reg <= dina;
    addra_reg <= addra;
    wea_reg <= wea;

end


genvar port,kernel;
generate
    for (port = 0; port < X_MESH; port = port + 1) begin: BUF_UNIT_1   
        for (kernel = 0; kernel < X_MAC; kernel = kernel + 1) begin: BUF_UNIT_2   
			xip_dbram_32_512#(
				.RAM_WIDTH(DATA_LEN),                
				.RAM_DEPTH(RAM_DEPTH),               
				.RAM_PERFORMANCE("HIGH_PERFORMANCE")
			
			) bram_inst (
                // port A
                .addra  (addra[(kernel*ADDR_LEN+port*ADDR_LEN*X_MAC ) +: ADDR_LEN ]),
                .clka   (clk        ),
                .dina   (dina[(kernel*DATA_LEN+port*DATA_LEN*X_MAC) +: DATA_LEN]),
                .wea    (wea[(kernel+port*X_MAC)]),
                // port B
                .addrb  (addrb[(kernel*ADDR_LEN+port*ADDR_LEN*X_MAC) +: ADDR_LEN]),
                .doutb  (doutb[(kernel*DATA_LEN+port*DATA_LEN*X_MAC) +: DATA_LEN]),
                .enb    (1'b1       ),
                .rstb (1'b0)
            );
        end
    end    
endgenerate

endmodule