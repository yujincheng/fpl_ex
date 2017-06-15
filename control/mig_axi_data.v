module mig_axi_data #(
   parameter C_AXI_ID_WIDTH           = 4,
   parameter C_AXI_ADDR_WIDTH         = 64, 
   parameter C_AXI_DATA_WIDTH         = 256,
   parameter DDR_DATA_LEN = 256,
   
	parameter SINGLE_LEN  = 24
)(
  input clk                        ,
  input rst_n                     ,
  // Input control signals
  input init_cmptd                ,
  // Slave Interface Write Address Ports
// AXI write address channel signals
  input                                  axi_awready, // Indicates slave is ready to accept a 
  output reg [C_AXI_ID_WIDTH-1:0]        axi_awid,    // Write ID
  output reg [C_AXI_ADDR_WIDTH-1:0]      axi_awaddr,  // Write address
  output reg [7:0]                       axi_awlen,   // Write Burst Length
  output reg [2:0]                       axi_awsize,  // Write Burst size
  output reg [1:0]                       axi_awburst, // Write Burst type
  output reg                             axi_awlock,  // Write lock type
  output reg [3:0]                       axi_awcache, // Write Cache type
  output reg [2:0]                       axi_awprot,  // Write Protection type
  output reg                             axi_awvalid, // Write address valid
// AXI write data channel signals
  input                                  axi_wready,  // Write data ready
  output [C_AXI_DATA_WIDTH-1:0]          axi_wdata,    // Write data
  output [C_AXI_DATA_WIDTH/8-1:0]        axi_wstrb,    // Write strobes
  output                                 axi_wlast,    // Last write transaction   
  output reg                             axi_wvalid,   // Write valid  
// AXI write response channel signals
  input  [C_AXI_ID_WIDTH-1:0]            axi_bid,     // Response ID
  input  [1:0]                           axi_bresp,   // Write response
  input                                  axi_bvalid,  // Write reponse valid
  output reg                             axi_bready,  // Response ready
// AXI read address channel signals
  input                                  axi_arready,     // Read address ready
  output reg [C_AXI_ID_WIDTH-1:0]        axi_arid,        // Read ID
  output reg [C_AXI_ADDR_WIDTH-1:0]      axi_araddr,      // Read address
  output reg [7:0]                       axi_arlen,       // Read Burst Length
  output reg [2:0]                       axi_arsize,      // Read Burst size
  output reg [1:0]                       axi_arburst,     // Read Burst type
  output reg                             axi_arlock,      // Read lock type
  output reg [3:0]                       axi_arcache,     // Read Cache type
  output reg [2:0]                       axi_arprot,      // Read Protection type
  output reg                             axi_arvalid,     // Read address valid 
// AXI read data channel signals   
  input  [C_AXI_ID_WIDTH-1:0]            axi_rid,     // Response ID
  input  [1:0]                           axi_rresp,   // Read response
  input                                  axi_rvalid,  // Read reponse valid
  input  [C_AXI_DATA_WIDTH-1:0]          axi_rdata,    // Read data
  input                                  axi_rlast,    // Read last
  output reg                             axi_rready,  // Read Response ready
  
  input[2:0] axi_size,
    // output interface to ddr face
   input  [C_AXI_ADDR_WIDTH - 1:0]   ddr_st_addr_out,
   input  [SINGLE_LEN - 1:0]     ddr_len,
   input                         ddr_conf,


   output   wire                      ddr_fifo_empty,
   output ddr_fifo_near_empty,
   input wire                          ddr_fifo_req,
   output   wire [DDR_DATA_LEN - 1:0] ddr_fifo_data,
   
   input wire in_fifo_empty,
   output in_fifo_req,
   input wire [C_AXI_DATA_WIDTH - 1:0] in_fifo_data,
   
   
   input cmd_type,

   output idle,
   output read_idle,
   output write_idle

  );
 localparam shift_dlen  = clogb2(C_AXI_DATA_WIDTH/8 - 1);
 localparam addr_step  = (C_AXI_DATA_WIDTH);
reg rd_data_idle;
reg rd_cmd_idle;
reg wr_data_idle;
reg wr_cmd_idle;
reg [SINGLE_LEN - 1:0] rd_cmd_left;
reg [SINGLE_LEN - 1:0] wr_cmd_left;
reg [SINGLE_LEN - 1:0] rd_data_left;
reg [SINGLE_LEN - 1:0] wr_data_left;


reg [7:0] wr_transe_count;
//////////////////////	 
//Write Address Channel
//////////////////////
always @(posedge clk) begin
	if (!rst_n || !init_cmptd) begin
	   axi_awvalid <= 0;
	   axi_awid <= 0;
	   axi_awaddr <= 64'd0;
	   axi_awlen <= 0;
	   axi_awsize <= 0;
	   axi_awburst <= 0;
	   axi_awlock <= 0;
	   axi_awcache <= 0;
	   axi_awprot <= 0;
		wr_cmd_idle <= 1;
		wr_cmd_left <= 0;
		wr_transe_count <= 0;
	end 
	else if (ddr_conf && (cmd_type == 1) ) begin
		wr_cmd_idle <= 0;
		wr_cmd_left <= ((ddr_len >> shift_dlen  ) > 8 ) ? (ddr_len >> shift_dlen  ) - 8: 0;
		axi_awvalid <= 0;
		axi_awaddr <= ddr_st_addr_out;
		axi_awlen <= ((ddr_len >> shift_dlen  ) > 8)? 7 : (ddr_len >> shift_dlen  )-1;
		axi_awsize <= axi_size;
		axi_awburst <= 01;
        wr_transe_count <= 0;
	end
	else if (!wr_cmd_idle) begin
		if (axi_awvalid == 0)begin
		   axi_awvalid <= 1;
		end		
		else if (axi_awready && axi_awvalid) begin
			axi_awvalid <= 1'b0;
		   wr_transe_count <= wr_transe_count + 1;
		   axi_awid <= 0;
		   axi_awaddr <= axi_awaddr + addr_step;
		   axi_awlen <= (wr_cmd_left > 8) ? 7 : (wr_cmd_left-1);
		   axi_awsize <= axi_size;
		   axi_awburst <= 01;
		   wr_cmd_left <= (wr_cmd_left > 8) ? (wr_cmd_left - 8) : 0;
		   wr_cmd_idle <= (wr_cmd_left > 0) ? 0 : 1;
		end	
	end		
	else begin
		axi_awvalid <= 1'b0;
	end	
end

   
//////////////////////	 
//Write Data Channel
//////////////////////


wire wnext;
assign       axi_wstrb = 32'hffffffff;
assign axi_wdata = in_fifo_data;
assign in_fifo_req = wnext & !wr_data_idle;

assign wnext = axi_wready & axi_wvalid;
// WVALID logic, similar to the AWVALID always block above
always @(posedge clk)
  begin
     if (!rst_n || !init_cmptd)begin
       axi_wvalid <=  1'b0;  
		wr_data_idle <= 1;
		wr_data_left <= 0;
     end  
     else if ((ddr_conf && (cmd_type == 1))) begin
		wr_data_idle <= 0;
		wr_data_left <= (ddr_len >> shift_dlen  );
		axi_wvalid <= 0;
	 end
     else if (!wr_data_idle)begin
		axi_wvalid <= !in_fifo_empty;
		if(wnext) begin
			if (wr_data_left > 1) begin
				wr_data_left <= wr_data_left - 1;			
			end
			else if (wr_data_left <= 1) begin
				wr_data_idle <= 1;	
				axi_wvalid <= 0;
			end
		end	
	end 
  end

  
localparam C_WLEN_COUNT_WIDTH ='d9;
reg [C_WLEN_COUNT_WIDTH -1:0] wlen_count;
 
 assign axi_wlast = ((wr_data_left >= 2) ? (wlen_count == 7) : (wr_data_left == 1)) && !idle;
 
  always @(posedge clk)
  begin
     if (!rst_n || !init_cmptd)begin
       wlen_count <=  0;  
     end  
     else if ((ddr_conf && (cmd_type == 1))) begin
		wlen_count <= 0;
	 end
     else if (!wr_data_idle)begin
		if(wnext) begin
			if (axi_wlast) begin
				wlen_count <= 0;			
			end
			else begin
				wlen_count <= wlen_count + 1;
			end
		end	
	end 
  end

  
  
//////////////////////	 
//Read Address Channel
//////////////////////
always @(posedge clk) begin
	if (!rst_n || !init_cmptd) begin
	   axi_arvalid <= 0;
	   axi_arid <= 0;
	   axi_araddr <= 64'd00;
	   axi_arlen <= 0;
	   axi_arsize <= 0;
	   axi_arburst <= 0;
	   axi_arlock <= 0;
	   axi_arcache <= 0;
	   axi_arprot <= 0;
		rd_cmd_idle <= 1;
		rd_cmd_left <= 0;
	end 
	else if (ddr_conf && (cmd_type == 0) ) begin
		rd_cmd_idle <= 0;
		rd_cmd_left <= ((ddr_len >> shift_dlen  ) > 8 ) ? (ddr_len >> shift_dlen ) - 8: 0;
		axi_arvalid <= 0;
		axi_araddr <= ddr_st_addr_out;
		axi_arlen <= ((ddr_len >> shift_dlen  ) > 8)? 7 : (ddr_len >> shift_dlen  )-1;
		axi_arsize <= axi_size;
		axi_arburst <= 01;
	end
	else if (!rd_cmd_idle) begin
		if (axi_arvalid == 0)begin
		   axi_arvalid <= 1;
		end		
		else if (axi_arready && axi_arvalid) begin
			axi_arvalid <= 1'b0;
		   axi_arid <= 0;
		   axi_araddr <= axi_araddr + addr_step;
		   axi_arlen <= (rd_cmd_left > 8) ? 7 : (rd_cmd_left-1);
		   axi_arsize <= axi_size;
		   axi_arburst <= 01;
		   rd_cmd_left <= (rd_cmd_left > 8) ? (rd_cmd_left - 8) : 0;
		   rd_cmd_idle <= (rd_cmd_left > 0) ? 0 : 1;
		end	
	end		
	else begin
		axi_arvalid <= 1'b0;
	end	
end

//////////////////////////////////   
//Read Data (and Response) Channel
//////////////////////////////////


wire fifo_full;
wire fifo_near_full;

always @(posedge clk) begin
	if (!rst_n || !init_cmptd) begin
		axi_rready <= 0;
		rd_data_idle <= 1;
		rd_data_left <= 0;
	end 
	else if (ddr_conf && (cmd_type == 0)) begin
		rd_data_idle <= 0;
		rd_data_left <= (ddr_len >> shift_dlen   );
		axi_rready <= 0;
	end 
	else if (!rd_data_idle)begin
		axi_rready <= !fifo_near_full;
		if(axi_rready && axi_rvalid) begin
			if (rd_data_left > 1) begin
			rd_data_left <= rd_data_left - 1;		
			end
			else if (rd_data_left <= 1) begin
				rd_data_idle <= 1;	
				axi_rready <= 0;
			end
		end	
	end 
end

always @(posedge clk) begin
	if (!rst_n || !init_cmptd) begin
		axi_bready <= 1;
	end
end

assign idle = rd_data_idle & rd_cmd_idle & wr_data_idle & wr_cmd_idle;
assign write_idle = wr_data_idle & wr_cmd_idle;
assign read_idle = rd_data_idle & rd_cmd_idle;

xip_fifo_256_16 x256x32(
  .clk(clk),
  .srst(~rst_n),
  .din(axi_rdata),
  .wr_en(axi_rready && axi_rvalid),
  .rd_en(ddr_fifo_req),
  .dout(ddr_fifo_data),
  .almost_full(fifo_near_full),
  .prog_empty(ddr_fifo_near_empty),
  .full(fifo_full),
  .empty(ddr_fifo_empty)
 );

   //  The following function calculates the address width based on specified RAM depth
     function integer clogb2;
         input integer depth;
             for (clogb2=0; depth>0; clogb2=clogb2+1)
                 depth = depth >> 1;
               
       endfunction
  
  endmodule
