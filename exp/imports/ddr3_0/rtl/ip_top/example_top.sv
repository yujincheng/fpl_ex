

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

`timescale 1ps/1ps

module example_top #
  (
    parameter nCK_PER_CLK           = 4,   // This parameter is controllerwise
    parameter         APP_DATA_WIDTH          = 512, // This parameter is controllerwise
    parameter         APP_MASK_WIDTH          = 64,   // This parameter is controllerwise
	parameter INST_LEN = 220,
  `ifdef SIMULATION_MODE
    parameter SIMULATION            = "TRUE" 
  `else
    parameter SIMULATION            = "FALSE"
  `endif
  )
   (
    input                 sys_rst,       // common port for all controllers

    input                 c0_sys_clk_p,    // This port is controllerwise unless shared across controllers
    input                 c0_sys_clk_n,    // This port is controllerwise unless shared across controllers
    output                c0_init_calib_complete,
    output                c0_data_compare_error,

    // iob<>DDR3 signals
    output [15:0]          c0_ddr3_addr,
    output [2:0]          c0_ddr3_ba,
    output                c0_ddr3_ras_n,
    output                c0_ddr3_cas_n,
    output                c0_ddr3_we_n,
    output [0:0]          c0_ddr3_cke,
    output [0:0]          c0_ddr3_odt,
    output [0:0]              c0_ddr3_ck_p,
    output [0:0]                c0_ddr3_ck_n,
    output                c0_ddr3_reset_n,
    output [7:0]          c0_ddr3_dm,      // This port varies based on Data Mask option selection
    inout  [63:0]          c0_ddr3_dq,
    inout  [7:0]          c0_ddr3_dqs_p,
    inout  [7:0]          c0_ddr3_dqs_n
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
  wire                c0_ddr3_clk;
  wire                c0_ddr3_rst;
  wire                             dbg_clk;
  wire                  c0_wr_rd_complete;

    



//***************************************************************************
// The User design is instantiated below. The memory interface ports are
// connected to the top-level and the application interface ports are
// connected to the traffic generator module. This provides a reference
// for connecting the memory controller to system.
//***************************************************************************

  // user design top is one instance for all controllers
ddr3_0  u_ddr3_0
    (
     .sys_rst                     (sys_rst),
     .c0_sys_clk_p                          (c0_sys_clk_p),
     .c0_sys_clk_n                          (c0_sys_clk_n),
     .c0_init_calib_complete        (c0_init_calib_complete),

     .c0_ddr3_addr                  (c0_ddr3_addr),
     .c0_ddr3_ba                    (c0_ddr3_ba),
     .c0_ddr3_ras_n                 (c0_ddr3_ras_n),
     .c0_ddr3_cas_n                 (c0_ddr3_cas_n),
     .c0_ddr3_we_n                  (c0_ddr3_we_n),
     .c0_ddr3_cke                   (c0_ddr3_cke),
     .c0_ddr3_odt                   (c0_ddr3_odt),
     .c0_ddr3_ck_p                  (c0_ddr3_ck_p),
     .c0_ddr3_ck_n                  (c0_ddr3_ck_n),
     .c0_ddr3_reset_n               (c0_ddr3_reset_n),
     .c0_ddr3_dm                    (c0_ddr3_dm),
     .c0_ddr3_dq                    (c0_ddr3_dq),
     .c0_ddr3_dqs_p                 (c0_ddr3_dqs_p),
     .c0_ddr3_dqs_n                 (c0_ddr3_dqs_n),

     .c0_ddr3_ui_clk                (c0_ddr3_clk),
     .c0_ddr3_ui_clk_sync_rst       (c0_ddr3_rst),
     .dbg_clk                                    (dbg_clk),

     .c0_ddr3_app_addr              (c0_ddr3_app_addr),
     .c0_ddr3_app_cmd               (c0_ddr3_app_cmd),
     .c0_ddr3_app_en                (c0_ddr3_app_en),
     .c0_ddr3_app_hi_pri            (1'b0),
     .c0_ddr3_app_wdf_data          (c0_ddr3_app_wdf_data),
     .c0_ddr3_app_wdf_end           (c0_ddr3_app_wdf_end),
     .c0_ddr3_app_wdf_mask          (c0_ddr3_app_wdf_mask),
     .c0_ddr3_app_wdf_wren          (c0_ddr3_app_wdf_wren),
     .c0_ddr3_app_rd_data           (c0_ddr3_app_rd_data),
     .c0_ddr3_app_rd_data_end       (c0_ddr3_app_rd_data_end),
     .c0_ddr3_app_rd_data_valid     (c0_ddr3_app_rd_data_valid),
     .c0_ddr3_app_rdy               (c0_ddr3_app_rdy),
     .c0_ddr3_app_wdf_rdy           (c0_ddr3_app_wdf_rdy)
                                        

  );

//***************************************************************************
// The example testbench module instantiated below drives traffic (patterns)
// on the application interface of the memory controller
//***************************************************************************
// In DDR3, there are two test generators (TG) available for user to select:
//  1) Simple Test Generator (STG)
//  2) Advanced Test Generator (ATG)
// 

   wire [INST_LEN-1:0] instruct;
 wire inst_req;   
wire inst_empty;   


instfifo_file #(
.INST_DEEPTH(12000),
.INST_LEN(INST_LEN),
.FILE_NAME("..//sim_data//inst.txt")
)
instfifo
(
	.instruct(instruct),
	.inst_req(inst_req),
	.inst_empty(inst_empty),
	.clk(c0_ddr3_clk),
	.rst_n(~c0_ddr3_rst  & c0_init_calib_complete)
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
         .rst_n                 (~c0_ddr3_rst & c0_init_calib_complete),
         .init_calib_complete  (c0_init_calib_complete),
         .app_rdy              (c0_ddr3_app_rdy),
         .app_wdf_rdy          (c0_ddr3_app_wdf_rdy),
         .app_rd_data_valid    (c0_ddr3_app_rd_data_valid),
         .app_rd_data          (c0_ddr3_app_rd_data),
         .app_cmd              (c0_ddr3_app_cmd),
         .app_addr             (c0_ddr3_app_addr),
         .app_en               (c0_ddr3_app_en),
         .app_wdf_mask         (c0_ddr3_app_wdf_mask),
         .app_wdf_data         (c0_ddr3_app_wdf_data),
         .app_wdf_end          (c0_ddr3_app_wdf_end),
         .app_wdf_wren         (c0_ddr3_app_wdf_wren),
         .app_wdf_en           (), // valid for QDRII+ only
         .app_wdf_addr         (), // valid for QDRII+ only
         .app_wdf_cmd          () // valid for QDRII+ only
        
         );

endmodule
