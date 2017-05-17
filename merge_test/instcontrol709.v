`timescale 1ns / 1ps
module instfifo_control#(
   parameter C_AXI_ID_WIDTH           = 10,
   parameter C_AXI_ADDR_WIDTH         = 32, 
   parameter C_AXI_DATA_WIDTH         = 32,
   
	parameter SINGLE_LEN  = 24
)(
  input clk                        ,
  input rst_n                     ,
  // Input control signals
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
  output                              axi_rready,  // Read Response ready
  input[2:0] axi_size,
  
    // output interface to ddr face
   input  [C_AXI_ADDR_WIDTH - 1:0]   inst_st_addr_out,
   input  [SINGLE_LEN - 1:0]     inst_len,
   input                         itrp,


   output   wire                      ddr_fifo_empty,
   input wire                          ddr_fifo_req,
   output   wire [C_AXI_DATA_WIDTH - 1:0] ddr_fifo_data,
      
   output idle

  );
    	
	
    // output interface to ddr face
   reg   [SINGLE_LEN - 1:0]     ddr_len ;
   reg                         ddr_conf;   
   wire  cmd_type = 0;
   
   wire axi_idle;
   
   reg  [C_AXI_ADDR_WIDTH - 1:0] inst_addr;
   
   reg itrp_r1;
   
   reg axi_conf;
   
	wire ddr_fifo_near_empty;
	
	wire ddr_conf_comp = (itrp && (~itrp_r1));
	
	always @ (posedge clk) begin
		itrp_r1 <= itrp;	
		ddr_conf <= ddr_conf_comp;
	end
		
	reg working;
	
	always @ (posedge clk) begin
		if (!rst_n || !init_cmptd) begin
			working <= 0;
			ddr_len <= 0;
			inst_addr <= 64'd0;
			axi_conf <= 0;
		end	
		else if (axi_conf) begin
			axi_conf <= 0;
			if (working && ddr_len > 0) begin
				if(ddr_len <=8 ) begin
					ddr_len <= 0;					
				end
				else begin
					ddr_len <= ddr_len - 8;
					inst_addr <= inst_addr + C_AXI_DATA_WIDTH;
				end
			end
		end
		else if( ddr_conf ) begin
			working <= 1;
			inst_addr <= inst_st_addr_out;
			ddr_len <= inst_len;
			axi_conf <= 0;		
		end
		else if (working && ddr_len == 0) begin		
			if(axi_conf == 0 && axi_idle == 0)begin
				working <= 0;
			end
		end
		else if(working && ddr_len > 0) begin
			if (axi_idle && ddr_fifo_near_empty) begin
				axi_conf <= 1;
			end
		end
		else if(!working) begin
		       
		  
		end
	end
	
	
	mig_axi #(
     .C_AXI_ID_WIDTH (C_AXI_ID_WIDTH),
     .C_AXI_ADDR_WIDTH (C_AXI_ADDR_WIDTH),
     .C_AXI_DATA_WIDTH (C_AXI_DATA_WIDTH)
) mig_axi_inst(
  .clk                        (clk),
  .rst_n                     (rst_n),
  // Input control signals
  .init_cmptd                  (init_cmptd),
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
  
  .axi_size(axi_size),
  ////////////////////////////////////////////////////////////
  .ddr_st_addr_out(inst_addr),
  .ddr_len(ddr_len > 8?(8<<clogb2(C_AXI_DATA_WIDTH/8 )):(ddr_len<<clogb2(C_AXI_DATA_WIDTH/8 ))),
  .ddr_conf(axi_conf),
  
  .cmd_type(0),
  
  .ddr_fifo_empty(ddr_fifo_empty),
  .ddr_fifo_req(ddr_fifo_req),
  .ddr_fifo_data(ddr_fifo_data),
  .ddr_fifo_near_empty(ddr_fifo_near_empty),
  .idle(axi_idle)
	);

    //  The following function calculates the address width based on specified RAM depth
         function integer clogb2;
             input integer depth;
               for (clogb2=0; depth>0; clogb2=clogb2+1)
                     depth = depth >> 1;
             endfunction
	
	
endmodule
