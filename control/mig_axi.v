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
    
  parameter APP_DATA_WIDTH   = 512,        // DDR data bus width.
  parameter APP_ADDR_WIDTH   = 29,        // Address bus width of the 
  //parameter RLD_BANK_WIDTH   = 4,         // RLD3 - 4, RLD2 - 3
  parameter APP_CMD_WIDTH    = 3,
	 
	parameter SINGLE_LEN  = 20,
	parameter DDR_DATA_LEN = 64,
	parameter DM_WIDTH = 8,
	parameter DDR_ADDR_LEN = 32
  
)
(
// ********* ALL SIGNALS AT THIS INTERFACE ARE ACTIVE HIGH SIGNALS ********/
   input 				       clk, // memory controller (MC) user interface (UI) clock
   input 				       rst_n, // MC UI reset signal.
   input 				       init_calib_complete, // MC calibration done signal coming from MC UI.
   // DDR3/4, RLD3, QDRIIP Shared Interface
   input 				       app_rdy, // cmd fifo ready signal coming from MC UI.
   input 				       app_wdf_rdy, // write data fifo ready signal coming from MC UI.
   input [0:0] 		       app_rd_data_valid, // read data valid signal coming from MC UI
   input [APP_DATA_WIDTH-1 : 0] 	       app_rd_data, // read data bus coming from MC UI
   
   
   output [APP_CMD_WIDTH-1 : 0] 	       app_cmd, // command bus to the MC UI
   output [APP_ADDR_WIDTH-1 : 0] 	       app_addr, // address bus to the MC UI
   output 				       app_en, // command enable signal to MC UI.
   output [(APP_DATA_WIDTH/DM_WIDTH)-1 : 0]    app_wdf_mask, // write data mask signal which
                                              // is tied to 0 in this example.
   output [APP_DATA_WIDTH-1: 0] 	       app_wdf_data, // write data bus to MC UI.
   output 				       app_wdf_end, // write burst end signal to MC UI
   output 				       app_wdf_wren, // write enable signal to MC UI

  // QDRIIP Interface
   output 				       app_wdf_en, // QDRIIP, write enable
   output [APP_ADDR_WIDTH-1:0] 		       app_wdf_addr, // QDRIIP, write address
   output [APP_CMD_WIDTH-1:0] 		       app_wdf_cmd, // QDRIIP write command
  
  
  
  // output interface to ddr face
   input  [DDR_ADDR_LEN - 1:0]   ddr_st_addr_out,
   input  [SINGLE_LEN - 1:0]     ddr_len,
   input                         ddr_conf,


   output   wire                      ddr_fifo_empty,
   input wire                          ddr_fifo_req,
   output   wire [DDR_DATA_LEN - 1:0] ddr_fifo_data,

   output reg idle
   
   );

   
   
       output [APP_CMD_WIDTH-1 : 0] 	       reg_app_cmd;      // command bus to the MC UI
   output [APP_ADDR_WIDTH-1 : 0] 	           reg_app_addr;     // address bus to the MC UI
   output 				                       reg_app_en;       // command enable signal to MC UI.
   output [(APP_DATA_WIDTH/DM_WIDTH)-1 : 0]    reg_app_wdf_mask; // write data mask signal which
   output [APP_DATA_WIDTH-1: 0] 	           reg_app_wdf_data; // write data bus to MC UI.
   output 				                       reg_app_wdf_end;  // write burst end signal to MC UI
   output 				                       reg_app_wdf_wren; // write enable signal to MC UI

                                                                 // QDRIIP Interface
   output 				                       reg_app_wdf_en;   // QDRIIP; write enable
   output [APP_ADDR_WIDTH-1:0] 		           reg_app_wdf_addr; // QDRIIP; write address
   output [APP_CMD_WIDTH-1:0] 		           reg_app_wdf_cmd;  // QDRIIP write command
   
   assign app_cmd = reg_app_cmd;      
   assign app_addr = reg_app_addr;     
   assign app_en = reg_app_en;       
   assign app_wdf_mask = reg_app_wdf_mask; 
   assign app_wdf_data = reg_app_wdf_data; 
   assign app_wdf_end = reg_app_wdf_end;  
   assign app_wdf_wren = reg_app_wdf_wren; 
   
   assign app_wdf_en = reg_app_wdf_en;   
   assign app_wdf_addr = reg_app_wdf_addr; 
   assign app_wdf_cmd = reg_app_wdf_cmd;  



   
	
    
	reg rd_data_idle;
	reg rd_cmd_idle;
	reg [20:0] rd_cmd_left;
	reg [20:0] rd_data_left;
	
    always @ (posedge clk) begin
		if (!rst_n || !init_calib_complete) begin
			reg_app_cmd <= 0;
			reg_app_addr <= 0;
			reg_app_en <= 0;    
			reg_app_wdf_en <= 0; 
			reg_app_wdf_addr <= 0;
			reg_app_wdf_cmd <= 0;	
			rd_cmd_idle <= 1;
			rd_cmd_left <= 0;
		end
		else if (ddr_conf) begin
			rd_cmd_idle <= 0;
			reg_app_cmd <= 1;
			reg_app_addr <= ddr_st_addr_out;
			reg_app_en <= 1;
			rd_cmd_left <= ((ddr_len-1) >> 6);
		end
		else if (!rd_cmd_idle && app_rdy) begin
			if (rd_cmd_left == 0) begin
				reg_app_en <= 0;
				rd_cmd_idle <= 1;
			end
			else if(rd_cmd_left >= 1) begin
				reg_app_addr <= reg_app_addr + 64;
			end
		end
    end   
	
	always @ (posedge clk) begin
		if (!rst_n || !init_calib_complete) begin
			rd_data_idle <= 1;
			rd_data_left <= 0;
		end
		else if (ddr_conf) begin
			rd_data_idle <= 0;
			rd_data_left <= ((ddr_len-1) >> 6);
		end
		else if (!rd_data_idle && app_rd_data_valid) begin
			if (rd_data_left >= 1) begin
				rd_data_left <= rd_data_left - 1;			
			end
			else if (rd_data_left < 1) begin
				rd_data_idle <= 1;			
			end
		end
	end
	
	
    always @ (posedge clk) begin
		if (!rst_n || !init_calib_complete) begin
			reg_app_wdf_mask <= 0;
			reg_app_wdf_data <= 0;
			reg_app_wdf_end <= 0; 
			reg_app_wdf_wren <= 0;
				                 
		end
    end 	
   
   

endmodule