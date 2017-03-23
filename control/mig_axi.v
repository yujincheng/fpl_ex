//*****************************************************************************
// (c) Copyright 2009 - 2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 3.6
//  \   \         Application: MIG
//  /   /         Filename: axi4_wrapper.v
// /___/   /\     Date Last Modified: $Date: 2011/06/02 08:37:18 $
// \   \  /  \    Date Created: Sept 16, 2009
//  \___\/\___\
//
//Device: Virtex-6, Spartan-6 and 7series
//Design Name: DDR3 SDRAM
//Purpose:
//   This module is wrapper for converting the reads and writes to transactions
//   that follow the AXI protocol.
//
//Reference:
//Revision History:
//*****************************************************************************
`timescale 1ps/1ps

module mig_axi #(
    
     parameter C_AXI_ID_WIDTH           = 4, // The AXI id width used for read and write
                                             // This is an integer between 1-16
     parameter C_AXI_ADDR_WIDTH         = 32, // This is AXI address width for all 
                                              // SI and MI slots
     parameter C_AXI_DATA_WIDTH         = 32, // Width of the AXI write and read data
  
     parameter C_AXI_NBURST_SUPPORT     = 0, // Support for narrow burst transfers
                                             // 1-supported, 0-not supported 
     parameter C_EN_WRAP_TRANS          = 0, // Set 1 to enable wrap transactions

     parameter C_BEGIN_ADDRESS          = 0, // Start address of the address map
  
     parameter C_END_ADDRESS            = 32'hFFFF_FFFF, // End address of the address map
     
     parameter PRBS_EADDR_MASK_POS      = 32'hFFFFD000,

     parameter PRBS_SADDR_MASK_POS      = 32'h00002000,

     parameter DBG_WR_STS_WIDTH         = 40,

     parameter DBG_RD_STS_WIDTH         = 40,
  
     parameter ENFORCE_RD_WR            = 0,

     parameter ENFORCE_RD_WR_CMD        = 8'h11,

     parameter EN_UPSIZER               = 0,

     parameter ENFORCE_RD_WR_PATTERN    = 3'b000,
	 
	 	parameter SINGLE_LEN  = 20,
	parameter DDR_DATA_LEN = 64,
	parameter DDR_ADDR_LEN = 32
  
)
(
   input                               aclk,    // AXI input clock
   input                               aresetn, // Active low AXI reset signal

// Input control signals
   input                               init_cmptd, // Initialization completed

// AXI write address channel signals
  input                                  axi_awready, // Indicates slave is ready to accept a 
  output [C_AXI_ID_WIDTH-1:0]            axi_awid,    // Write ID
  output [C_AXI_ADDR_WIDTH-1:0]          axi_awaddr,  // Write address
  output [7:0]                           axi_awlen,   // Write Burst Length
  output [2:0]                           axi_awsize,  // Write Burst size
  output [1:0]                           axi_awburst, // Write Burst type
  output                                 axi_awlock,  // Write lock type
  output [3:0]                           axi_awcache, // Write Cache type
  output [2:0]                           axi_awprot,  // Write Protection type
  output                                 axi_awvalid, // Write address valid
// AXI write data channel signals
  input                                  axi_wready,  // Write data ready
  output [C_AXI_DATA_WIDTH-1:0]          axi_wdata,    // Write data
  output [C_AXI_DATA_WIDTH/8-1:0]        axi_wstrb,    // Write strobes
  output                                 axi_wlast,    // Last write transaction   
  output                                 axi_wvalid,   // Write valid  
// AXI write response channel signals
  input  [C_AXI_ID_WIDTH-1:0]            axi_bid,     // Response ID
  input  [1:0]                           axi_bresp,   // Write response
  input                                  axi_bvalid,  // Write reponse valid
  output                                 axi_bready,  // Response ready
// AXI read address channel signals
  input                                  axi_arready,     // Read address ready
  output [C_AXI_ID_WIDTH-1:0]            axi_arid,        // Read ID
  output [C_AXI_ADDR_WIDTH-1:0]          axi_araddr,      // Read address
  output [7:0]                           axi_arlen,       // Read Burst Length
  output [2:0]                           axi_arsize,      // Read Burst size
  output [1:0]                           axi_arburst,     // Read Burst type
  output                                 axi_arlock,      // Read lock type
  output [3:0]                           axi_arcache,     // Read Cache type
  output [2:0]                           axi_arprot,      // Read Protection type
  output                                 axi_arvalid,     // Read address valid 
// AXI read data channel signals   
  input  [C_AXI_ID_WIDTH-1:0]            axi_rid,     // Response ID
  input  [1:0]                           axi_rresp,   // Read response
  input                                  axi_rvalid,  // Read reponse valid
  input  [C_AXI_DATA_WIDTH-1:0]          axi_rdata,   // Read data
  input                                  axi_rlast,   // Read last
  output                                 axi_rready,  // Read Response ready

// cmd input
		// output interface to ddr face
	input  [DDR_ADDR_LEN - 1:0]   ddr_st_addr_out,
	input  [SINGLE_LEN - 1:0]     ddr_len,
	input                         ddr_conf,
	
	
	output   wire                      ddr_fifo_empty,
	input wire                          ddr_fifo_req,
	output   wire [DDR_DATA_LEN - 1:0] ddr_fifo_data,
   
	output reg idle
   
);


reg [C_AXI_ID_WIDTH-1:0]         reg_axi_arid;        // Read ID
reg [C_AXI_ADDR_WIDTH-1:0]       reg_axi_araddr;      // Read address
reg [7:0]                        reg_axi_arlen;       // Read Burst Lengthalways @ (posedge clock) begin
reg [2:0]                        reg_axi_arsize;      // Read Burst size	if (!aresetn) begin
reg [1:0]                        reg_axi_arburst;     // Read Burst type		
reg [1:0]                        reg_axi_arlock;      // Read lock type	end
reg [3:0]                        reg_axi_arcache;     // Read Cache type
reg [2:0]                        reg_axi_arprot;      // Read Protection typeend
reg                              reg_axi_arvalid;     // Read address valid



  reg [C_AXI_ID_WIDTH-1:0]            reg_axi_awid;    // Write ID
  reg [C_AXI_ADDR_WIDTH-1:0]          reg_axi_awaddr;  // Write address
  reg [7:0]                           reg_axi_awlen;   // Write Burst Length
  reg [2:0]                           reg_axi_awsize;  // Write Burst size
  reg [1:0]                           reg_axi_awburst; // Write Burst type
  reg                                 reg_axi_awlock;  // Write lock type
  reg [3:0]                           reg_axi_awcache; // Write Cache type
  reg [2:0]                           reg_axi_awprot;  // Write Protection type
  reg                                 reg_axi_awvalid; // Write address valid

reg                              reg_axi_rready;  // Read Response ready


assign  axi_arid = reg_axi_arid;        
assign  axi_araddr = reg_axi_araddr;      
assign  axi_arlen = reg_axi_arlen;       
assign  axi_arsize = reg_axi_arsize;      
assign  axi_arburst = reg_axi_arburst;     
assign  axi_arlock = reg_axi_arlock;      
assign  axi_arcache = reg_axi_arcache;     
assign  axi_arprot = reg_axi_arprot;      
assign  axi_arvalid = reg_axi_arvalid;     
   

assign axi_awid    = reg_axi_awid;      
assign axi_awaddr  = reg_axi_awaddr;    
assign axi_awlen   = reg_axi_awlen;     
assign axi_awsize  = reg_axi_awsize;    
assign axi_awburst = reg_axi_awburst;   
assign axi_awlock  = reg_axi_awlock;    
assign axi_awcache = reg_axi_awcache;   
assign axi_awprot  = reg_axi_awprot;    
assign axi_awvalid = reg_axi_awvalid;   
   
   
   
   
   
   
assign  axi_rready = reg_axi_rready;  

wire [7:0]	burst_arlen = 8;
wire [31:0] addr_step = (({{28'd0},burst_arlen}+1) << 3);

assign axi_wvalid = 0;
reg [20-1:0] transleft;
reg [20-1:0] count_last;
reg aidle;

always @ (posedge aclk) begin
	if(!aresetn) begin
		reg_axi_arid <= 0;       
		reg_axi_araddr <= 0;     
		reg_axi_arlen <= 0;      
		reg_axi_arsize <= 0;     
		reg_axi_arburst <= 0;    
		reg_axi_arlock <= 0;     
		reg_axi_arcache <= 0;    
		reg_axi_arprot <= 0;     
		reg_axi_arvalid <= 0;    
		transleft <= 0;
		count_last <= 0;
		aidle <= 1;
	end
	else if(ddr_conf) begin
		aidle <= 0;
		reg_axi_araddr <= ddr_st_addr_out;
		reg_axi_arburst <= 2'b01;
		reg_axi_arsize <= 3'b011;
		reg_axi_arvalid <= 1;
		if(ddr_len <= 8) begin
			reg_axi_arlen <= ddr_len;
			transleft <= 0;
			count_last <= 1;
		end
		else begin
			reg_axi_arlen <= 8;
			transleft <= ddr_len  - 8;
			count_last <= (ddr_len >> 3);
		end
	end
	else if(!aidle) begin
		if(transleft > 8) begin
			if(axi_arvalid & axi_arready) begin
				transleft <= transleft - 8;
				reg_axi_araddr <= reg_axi_araddr + 64;
				reg_axi_arvalid <= 1;
				reg_axi_arlen <= 8;
			end
		end
		else if(transleft > 0) begin
			if(reg_axi_arvalid & axi_arready) begin
				reg_axi_arlen <= transleft;
				reg_axi_arvalid <= 1;
				transleft <= 0;
			end
		end
		else if(transleft == 0) begin
			if(reg_axi_arvalid & axi_arready) begin
				aidle <= 1;
				reg_axi_arvalid <= 0;
			end
		end
	end
end


always @ (posedge aclk) begin
	if(!aresetn) begin
		reg_axi_awid <= 0;   
		reg_axi_awaddr <= 0; 
		reg_axi_awlen <= 0;  
		reg_axi_awsize <= 0; 
		reg_axi_awburst <= 0;
		reg_axi_awlock <= 0; 
		reg_axi_awcache <= 0;
		reg_axi_awprot <= 0; 
		reg_axi_awvalid <= 0;
	end
end

reg [3-1:0] now_last;
reg fifo_wr_en;
wire fifo_full;

xip_fifo_64_64 f64(
  .clk(aclk),      // input wire clk
  .srst(!aresetn),    // input wire srst
  .din(axi_rdata),      // input wire [63 : 0] din
  .wr_en(fifo_wr_en),  // input wire wr_en
  .rd_en(ddr_fifo_req),  // input wire rd_en
  .dout(ddr_fifo_data),    // output wire [63 : 0] dout
  .full(fifo_full),    // output wire full
  .empty(ddr_fifo_empty)  // output wire empty
);


always @ (posedge aclk) begin
	if(!aresetn ) begin
		now_last <= 0;
		idle <= 1;
	end
	else if(ddr_conf) begin		
		idle <= 0;
	end
	else if(idle) begin
		now_last <= 0;
	end
	else begin
		if(axi_rlast) begin
			if(now_last == count_last - 1) begin
				idle <= 1;
			end
			now_last <= now_last + 1;
		end
	end
end

always @ (posedge aclk) begin
	if(!aresetn) begin
		fifo_wr_en <= 0;
	end
	else begin
		if(!idle & axi_rready & axi_rvalid) begin
			fifo_wr_en <= 1;		
		end
		else begin
			fifo_wr_en <= 0;
		end
	end
end

always @ (posedge aclk) begin
	if(!aresetn) begin
		reg_axi_rready <= 0;
	end
	else if(axi_rvalid) begin
		reg_axi_rready <= 1;
	end
	else begin
		reg_axi_rready <= 0;
	end

end






endmodule