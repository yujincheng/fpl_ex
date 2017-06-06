

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
//  \   \         Application        : DDR3
//  /   /         Filename           : ddr3_0.v
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Thu Apr 18 2013
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : DDR3_SDRAM
// Purpose          :
//   Wrapper module for the user design top level file. This module can be 
//   instantiated in the system and interconnect as shown in example design 
//   (example_top module).
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ns/1ps
(* CORE_GENERATION_INFO = "DDR3_SDRAM, DDR3_SDRAM,{x_ipProduct=Vivado 2017.1.0,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=DDR3_SDRAM,x_ipVersion=1.4, Controller_Type = DDR3_SDRAM, Time_Period = 1250, Input_Clock_Period = 10000, Memory_Type = SODIMMs, Memory_Part = MT8KTF51264HZ-1G9, Ecc = false, Cas_Latency = 11, Cas_Write_Latency = 8, DQ_Width = 64, Chip_Select = true, Data_Mask = true, MEM_ADDR_ORDER = BANK_ROW_COLUMN,  Is_AXI_Enabled = true , Slot_cofiguration =  Single ,IS_FASTER_SPEED_RAM = No, Is_custom_part = false, Memory_Voltage = 1.5V, Phy_Only = Complete_Memory_Controller, Debug_Signal = Disable, Burst_Length = 8, System_Clock = Differential, AXI_Selection = true, AXI_Data_Width = 256,  AXI_ArbitrationScheme = RD_PRI_REG, AXI_Narrow_Burst = false, Simulation_Mode = BFM, Debug_Mode = Disable, Example_TG = SIMPLE_TG, Self_Refresh = false, Save_Restore = false, MicroBlaze_ECC = false,  Specify_MandD = false, CLKBOUT_MULT = 10, DIVCLK_DIVIDE = 1, CLKOUT0_DIVIDE = 5 }" *)
(* X_CORE_INFO = "ddr3_v1_4_0,Vivado 2017.1" *)
 module ddr3_0
 (
    input                 sys_rst,
    input                 c0_sys_clk_p,
    input                 c0_sys_clk_n,


    output [15:0]          c0_ddr3_addr,
    output [2:0]          c0_ddr3_ba,
    output                c0_ddr3_ras_n,
    output                c0_ddr3_cas_n,
    output                c0_ddr3_we_n,
    output [0:0]          c0_ddr3_cke,
    output [0:0]          c0_ddr3_odt,
    output [0:0]          c0_ddr3_cs_n,
    output [0:0]               c0_ddr3_ck_p,
    output [0:0]               c0_ddr3_ck_n,
    output                c0_ddr3_reset_n,
    output [7:0]          c0_ddr3_dm,
    inout  [63:0]          c0_ddr3_dq,
    inout  [7:0]          c0_ddr3_dqs_p,
    inout  [7:0]          c0_ddr3_dqs_n,

    output                c0_init_calib_complete,

   output                c0_ddr3_ui_clk,
   output                c0_ddr3_ui_clk_sync_rst,

   output               dbg_clk,

   // Slave Interface Write Address Ports
    input                c0_ddr3_aresetn,
    input  [3:0]      c0_ddr3_s_axi_awid,
    input  [31:0]    c0_ddr3_s_axi_awaddr,
    input  [7:0]                       c0_ddr3_s_axi_awlen,
    input  [2:0]                       c0_ddr3_s_axi_awsize,
    input  [1:0]                       c0_ddr3_s_axi_awburst,
    input  [0:0]                       c0_ddr3_s_axi_awlock,
    input  [3:0]                       c0_ddr3_s_axi_awcache,
    input  [2:0]                       c0_ddr3_s_axi_awprot,
    input  [3:0]                       c0_ddr3_s_axi_awqos,
    input                              c0_ddr3_s_axi_awvalid,
    output                             c0_ddr3_s_axi_awready,
    // Slave Interface Write Data Ports
    input  [255:0]    c0_ddr3_s_axi_wdata,
    input  [31:0]  c0_ddr3_s_axi_wstrb,
    input                              c0_ddr3_s_axi_wlast,
    input                              c0_ddr3_s_axi_wvalid,
    output                             c0_ddr3_s_axi_wready,
    // Slave Interface Write Response Ports
    input                              c0_ddr3_s_axi_bready,
    output [3:0]      c0_ddr3_s_axi_bid,
    output [1:0]                       c0_ddr3_s_axi_bresp,
    output                             c0_ddr3_s_axi_bvalid,
    // Slave Interface Read Address Ports
    input  [3:0]      c0_ddr3_s_axi_arid,
    input  [31:0]    c0_ddr3_s_axi_araddr,
    input  [7:0]                       c0_ddr3_s_axi_arlen,
    input  [2:0]                       c0_ddr3_s_axi_arsize,
    input  [1:0]                       c0_ddr3_s_axi_arburst,
    input  [0:0]                       c0_ddr3_s_axi_arlock,
    input  [3:0]                       c0_ddr3_s_axi_arcache,
    input  [2:0]                       c0_ddr3_s_axi_arprot,
    input  [3:0]                       c0_ddr3_s_axi_arqos,
    input                              c0_ddr3_s_axi_arvalid,
    output                             c0_ddr3_s_axi_arready,
    // Slave Interface Read Data Ports
    input                              c0_ddr3_s_axi_rready,
    output [3:0]      c0_ddr3_s_axi_rid,
    output [255:0]    c0_ddr3_s_axi_rdata,
    output [1:0]                       c0_ddr3_s_axi_rresp,
    output                             c0_ddr3_s_axi_rlast,
    output                             c0_ddr3_s_axi_rvalid,
   // Debug Port
   output wire [511:0]             dbg_bus
   );

ddr3_0_ddr3
    inst (
     .sys_rst                     (sys_rst),
   .c0_sys_clk_p                          (c0_sys_clk_p),
   .c0_sys_clk_n                          (c0_sys_clk_n),
   .c0_init_calib_complete                (c0_init_calib_complete),
   .c0_ddr3_addr                  (c0_ddr3_addr),
   .c0_ddr3_ba                    (c0_ddr3_ba),
   .c0_ddr3_ras_n                 (c0_ddr3_ras_n),
   .c0_ddr3_cas_n                 (c0_ddr3_cas_n),
   .c0_ddr3_we_n                  (c0_ddr3_we_n),
   .c0_ddr3_cke                   (c0_ddr3_cke),
   .c0_ddr3_odt                   (c0_ddr3_odt),
   .c0_ddr3_cs_n                  (c0_ddr3_cs_n),
   .c0_ddr3_ck_p                  (c0_ddr3_ck_p),
   .c0_ddr3_ck_n                  (c0_ddr3_ck_n),
   .c0_ddr3_reset_n               (c0_ddr3_reset_n),
   .c0_ddr3_dm                    (c0_ddr3_dm),
   .c0_ddr3_dq                    (c0_ddr3_dq),
   .c0_ddr3_dqs_p                 (c0_ddr3_dqs_p),
   .c0_ddr3_dqs_n                 (c0_ddr3_dqs_n),
   .c0_ddr3_ui_clk                (c0_ddr3_ui_clk),
   .c0_ddr3_ui_clk_sync_rst       (c0_ddr3_ui_clk_sync_rst),
   .addn_ui_clkout1                            (),
   .addn_ui_clkout2                            (),
   .addn_ui_clkout3                            (),
   .addn_ui_clkout4                            (),
   .dbg_clk                                    (dbg_clk),
   .sl_iport0                                  (37'b0),
   .sl_oport0                                  (),


   // Slave Interface Write Address Ports
   .c0_ddr3_aresetn                                (c0_ddr3_aresetn),
   .c0_ddr3_s_axi_awid                             (c0_ddr3_s_axi_awid),
   .c0_ddr3_s_axi_awaddr                           (c0_ddr3_s_axi_awaddr),
   .c0_ddr3_s_axi_awlen                            (c0_ddr3_s_axi_awlen),
   .c0_ddr3_s_axi_awsize                           (c0_ddr3_s_axi_awsize),
   .c0_ddr3_s_axi_awburst                          (c0_ddr3_s_axi_awburst),
   .c0_ddr3_s_axi_awlock                           (c0_ddr3_s_axi_awlock),
   .c0_ddr3_s_axi_awcache                          (c0_ddr3_s_axi_awcache),
   .c0_ddr3_s_axi_awprot                           (c0_ddr3_s_axi_awprot),
   .c0_ddr3_s_axi_awqos                            (c0_ddr3_s_axi_awqos),
   .c0_ddr3_s_axi_awvalid                          (c0_ddr3_s_axi_awvalid),
   .c0_ddr3_s_axi_awready                          (c0_ddr3_s_axi_awready),
   // Slave Interface Write Data Ports
   .c0_ddr3_s_axi_wdata                            (c0_ddr3_s_axi_wdata),
   .c0_ddr3_s_axi_wstrb                            (c0_ddr3_s_axi_wstrb),
   .c0_ddr3_s_axi_wlast                            (c0_ddr3_s_axi_wlast),
   .c0_ddr3_s_axi_wvalid                           (c0_ddr3_s_axi_wvalid),
   .c0_ddr3_s_axi_wready                           (c0_ddr3_s_axi_wready),
   // Slave Interface Write Response Ports
   .c0_ddr3_s_axi_bid                              (c0_ddr3_s_axi_bid),
   .c0_ddr3_s_axi_bresp                            (c0_ddr3_s_axi_bresp),
   .c0_ddr3_s_axi_bvalid                           (c0_ddr3_s_axi_bvalid),
   .c0_ddr3_s_axi_bready                           (c0_ddr3_s_axi_bready),
   // Slave Interface Read Address Ports
   .c0_ddr3_s_axi_arid                             (c0_ddr3_s_axi_arid),
   .c0_ddr3_s_axi_araddr                           (c0_ddr3_s_axi_araddr),
   .c0_ddr3_s_axi_arlen                            (c0_ddr3_s_axi_arlen),
   .c0_ddr3_s_axi_arsize                           (c0_ddr3_s_axi_arsize),
   .c0_ddr3_s_axi_arburst                          (c0_ddr3_s_axi_arburst),
   .c0_ddr3_s_axi_arlock                           (c0_ddr3_s_axi_arlock),
   .c0_ddr3_s_axi_arcache                          (c0_ddr3_s_axi_arcache),
   .c0_ddr3_s_axi_arprot                           (c0_ddr3_s_axi_arprot),
   .c0_ddr3_s_axi_arqos                            (c0_ddr3_s_axi_arqos),
   .c0_ddr3_s_axi_arvalid                          (c0_ddr3_s_axi_arvalid),
   .c0_ddr3_s_axi_arready                          (c0_ddr3_s_axi_arready),
   // Slave Interface Read Data Ports
   .c0_ddr3_s_axi_rid                              (c0_ddr3_s_axi_rid),
   .c0_ddr3_s_axi_rdata                            (c0_ddr3_s_axi_rdata),
   .c0_ddr3_s_axi_rresp                            (c0_ddr3_s_axi_rresp),
   .c0_ddr3_s_axi_rlast                            (c0_ddr3_s_axi_rlast),
   .c0_ddr3_s_axi_rvalid                           (c0_ddr3_s_axi_rvalid),
   .c0_ddr3_s_axi_rready                           (c0_ddr3_s_axi_rready),

   // Debug Port
   .dbg_bus               (dbg_bus) 
   );

 endmodule
