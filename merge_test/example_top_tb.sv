

/******************************************************************************
// (c) Copyright 2013 - 2014 Xilinx, Inc. All rights reserved.
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
******************************************************************************/
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : 1.0
//  \   \         Application        : MIG
//  /   /         Filename           : example_top.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Thu Apr 18 2013
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : DDR3_SDRAM
// Purpose          :
//                    Top-level  module. This module serves both as an example,
//                    and allows the user to synthesize a self-contained
//                    design, which they can be used to test their hardware.
//                    In addition to the memory controller,
//                    the module instantiates:
//                      1. Synthesizable testbench - used to model
//                      user's backend logic and generate different
//                      traffic patterns
//
// Reference        :
// Revision History :
//*****************************************************************************
`ifdef MODEL_TECH
    `define SIMULATION_MODE
`elsif INCA
    `define SIMULATION_MODE
`elsif VCS
    `define SIMULATION_MODE
`elsif XILINX_SIMULATOR
    `define SIMULATION_MODE
`endif

`timescale 1ns/1ps

module example_top_tb #
  (
    parameter nCK_PER_CLK           = 4,   // This parameter is controllerwise
    parameter         APP_DATA_WIDTH          = 512, // This parameter is controllerwise
    parameter         APP_MASK_WIDTH          = 64,   // This parameter is controllerwise
	parameter INST_LEN = 220,
	parameter FILE_NAME = "..//sim_data//inst.txt",
  `ifdef SIMULATION_MODE
    parameter SIMULATION            = "TRUE" 
  `else
    parameter SIMULATION            = "FALSE"
  `endif
  )
   (
);

  localparam  APP_ADDR_WIDTH = 29;
  localparam  MEM_ADDR_ORDER = "BANK_ROW_COLUMN";
  localparam DBG_WR_STS_WIDTH      = 32;
  localparam DBG_RD_STS_WIDTH      = 32;
  localparam ECC                   = "OFF";

  wire [APP_ADDR_WIDTH-1:0]          c0_ddr3_app_addr;
  wire [2:0]          c0_ddr3_app_cmd;
  wire                c0_ddr3_app_en;
  wire [APP_DATA_WIDTH-1:0]          c0_ddr3_app_wdf_data;
  wire                c0_ddr3_app_wdf_end;
  wire [APP_MASK_WIDTH-1:0]          c0_ddr3_app_wdf_mask;
  wire                c0_ddr3_app_wdf_wren;
  wire [APP_DATA_WIDTH-1:0]          c0_ddr3_app_rd_data;
  wire                c0_ddr3_app_rd_data_end;
  wire                c0_ddr3_app_rd_data_valid;
  wire                c0_ddr3_app_rdy;
  wire                c0_ddr3_app_wdf_rdy;

  
  wire                             dbg_clk;
  wire                  c0_wr_rd_complete;
  
  
  reg                c0_ddr3_clk;
  reg                c0_ddr3_rst;

  initial begin
	c0_ddr3_clk = 0;
	c0_ddr3_rst = 1;
	#300 c0_ddr3_rst = 0;
  end
  
  always begin
  c0_ddr3_clk = #2 ~c0_ddr3_clk;
  end



//***************************************************************************
// The User design is instantiated below. The memory interface ports are
// connected to the top-level and the application interface ports are
// connected to the traffic generator module. This provides a reference
// for connecting the memory controller to system.
//***************************************************************************


   wire [INST_LEN-1:0] instruct;
 wire inst_req;   
wire inst_empty;   


instfifo_file #(
.INST_DEEPTH(400000),
.INST_LEN(INST_LEN),
.FILE_NAME(FILE_NAME)
)
instfifo
(
	.instruct(instruct),
	.inst_req(inst_req),
	.inst_empty(inst_empty),
	.clk(c0_ddr3_clk),
	.rst_n(~c0_ddr3_rst  & 1)
);






    hwcnn_top #
      (
       .APP_DATA_WIDTH  (APP_DATA_WIDTH),
       .APP_ADDR_WIDTH  (APP_ADDR_WIDTH)
       )
      u_hw_tg
        (
			.instruct(instruct),
			.inst_req(inst_req),
			.inst_empty(inst_empty),
         .clk                  (c0_ddr3_clk),
         .rst_n                 (~c0_ddr3_rst & 1),
         .init_calib_complete  (1)
        
         );

endmodule
