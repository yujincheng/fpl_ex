


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
//  /   /         Filename           : ddr3_0_ddr3.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Thu Apr 18 2013
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : DDR3_SDRAM
// Purpose          :
//   Top-level  module. This module can be instantiated in the
//   system and interconnect as shown in user design wrapper file 
//   (user top module).
// Reference        :
// Revision History :
//*****************************************************************************



`timescale 1ps/1ps
`ifdef MODEL_TECH
    `ifndef CALIB_SIM
       `define SIMULATION
     `endif
`elsif INCA
    `ifndef CALIB_SIM
       `define SIMULATION
     `endif
`elsif VCS
    `ifndef CALIB_SIM
       `define SIMULATION
     `endif
`elsif _vcp
    `ifndef CALIB_SIM
       `define SIMULATION
     `endif
`elsif XILINX_SIMULATOR
    `ifndef CALIB_SIM
       `define SIMULATION
     `endif
`endif

(*

  X_MIG_OLYMPUS = 1,  
  X_ULTRASCALE_IO_FLOW = "xilinx.com:ip:ddr3_phy:1.4",
  LIVE_DESIGN = 0,
  MEM_CORE_VER = "xilinx.com:ip:mem:1.4",
  PhyIP_CUSTOM_PART_ATTRIBUTES = "NONE",
  ControllerType = "ddr3_sdram",
  PhyIP_TimePeriod = 1250,
  PhyIP_InputClockPeriod = 10000,
  PhyIP_MemoryType = "SODIMMs",
  PhyIP_MemoryPart = "MT8KTF51264HZ-1G9",
  PhyIP_PhyClockRatio = "4:1",
  PhyIP_ECC = "false",
  PhyIP_CasLatency = 11,
  PhyIP_CasWriteLatency = 8,
  PhyIP_DataWidth = 64,
  PhyIP_ChipSelect = "true",
  PhyIP_isCKEShared = "false",
  PhyIP_Slot = "Single",
  PhyIP_DataMask = "true",
  PhyIP_MemoryVoltage = "1.5V",
  PhyIP_PARTIAL_RECONFIG_FLOW_MIG = "false",
  PhyIP_CLKFBOUT_MULT = "10",
  PhyIP_DIVCLK_DIVIDE = "1",
  PhyIP_CLKOUT0_DIVIDE = "5",
  PhyIP_CLKOUT1_DIVIDE = "0",
  PhyIP_CLKOUT2_DIVIDE = "0",
  PhyIP_CLKOUT3_DIVIDE = "0",
  PhyIP_CLKOUT4_DIVIDE = "0",
  PhyIP_VrefVoltage = "0.75",
  PhyIP_IS_FROM_PHY = "1",
  PhyIP_CA_MIRROR = "0",
  PhyIP_SELF_REFRESH = "false",
  PhyIP_SAVE_RESTORE = "false",
 
  PhyIP_Internal_Vref = "true",
  PhyIP_System_Clock = "Differential",
  PhyIP_Simulation_Mode = "BFM",
  PhyIP_Phy_Only = "Complete_Memory_Controller",
  PhyIP_Debug_Signal = "Disable",
  PhyIP_CLKOUTPHY_MODE = "VCO_2X",
  PhyIP_DQ_WIDTH = 64,
  PhyIP_MEM_DEVICE_WIDTH = 64,
  PhyIP_MIN_PERIOD = 1071,
  PhyIP_USE_DM_PORT = "true",
  PhyIP_USE_CS_PORT = "true",
  PhyIP_ADDR_WIDTH = 16,
  PhyIP_BANK_WIDTH = 3,
  PhyIP_CKE_WIDTH = 1,
  PhyIP_CK_WIDTH = 1,
  PhyIP_CS_WIDTH = 1,
  PhyIP_RANK_WIDTH = 1,
  PhyIP_ODT_WIDTH = 1,
  PhyIP_nCS_PER_RANK = 1,
  PhyIP_DATABITS_PER_STROBE = 8,
  PhyIP_DQS_WIDTH = 8,
  PhyIP_DM_WIDTH = 8,
  PhyIP_HR_MIN_FREQ = 1875,
  PhyIP_DCI_CASCADE_CUTOFF = 1250,
  PhyIP_IS_FASTER_SPEED_RAM = "No",
  PhyIP_tCK = 1250

*)
module ddr3_0_ddr3 #
   (
    parameter integer ADDR_WIDTH              = 16,
    parameter integer ROW_WIDTH               = 16,
    parameter integer BANK_WIDTH              = 3,
    parameter integer CKE_WIDTH               = 1,
    parameter integer CK_WIDTH                = 1,
    parameter integer COL_WIDTH               = 10,
    parameter integer CS_WIDTH                = 1,
    parameter integer ODT_WIDTH               = 1,
    parameter integer DQ_WIDTH                = 64,
    parameter integer DQS_WIDTH               = 8,
    parameter integer DM_WIDTH                = 8,

    parameter         DRAM_TYPE               = "DDR3",
    parameter         MEM_ADDR_ORDER          = "BANK_ROW_COLUMN",

    parameter DM_DBI                          = "DM_NODBI",

    parameter         USE_CS_PORT             = 1,

    parameter         NUMREF                  = 1,
    parameter         REG_CTRL                = "OFF",
    parameter         MCS_ECC_ENABLE       = "FALSE",
    parameter         tCK                     = 1250,  // Memory clock period

    parameter         tFAW                    = 22,
    parameter         tRTW                    = 9, // CL + 4 + 2tCK - CWL
    parameter         tWTR                    = 6,
    parameter         tRFC                    = 208,
    parameter         tREFI                   = 6240,
    parameter         ZQINTVL                 = 800000000,
    parameter         tZQCS                   = 64,
    parameter         tRP                     = 12,
    parameter         tRRD                    = 4,
	
    parameter         tRAS                    = 28,
    parameter         tRCD                    = 12,
    parameter         tRTP                    = 6,
    parameter         tWR                     = 12,
    parameter         PER_RD_INTVL            = 32'd200,
    parameter         ODTWRDEL                = 5'd8,
    parameter         ODTWRDUR                = 4'd6,
    parameter         ODTWRODEL               = 5'd9,
    parameter         ODTWRODUR               = 4'd6,
    parameter         ODTRDDEL                = 5'd11,
    parameter         ODTRDDUR                = 4'd6,
    parameter         ODTRDODEL               = 5'd9,
    parameter         ODTRDODUR               = 4'd6,
    parameter         ODTNOP                  = 16'h0000,

    parameter real    TCQ                     = 100,
    parameter         DRAM_WIDTH              = 8,
    parameter         RANKS                   = 1,
    parameter         ORDERING                = "NORM",
    parameter         RTL_VERSION             = 0,
    parameter         TXN_FIFO_BYPASS         = "ON",
    parameter         TXN_FIFO_PIPE           = "OFF",
    parameter         PER_RD_PERF             = 1'b1,
    parameter         CAS_FIFO_BYPASS         = "ON",
    parameter         NOP_ADD_LOW             = 1'b0,
    parameter         STARVATION_EN           = 1'b1,
    parameter         STARVE_COUNT_WIDTH      = 9,
    parameter         EXTRA_CMD_DELAY         = 1,
    parameter         nCK_PER_CLK             = 4,
    parameter         APP_ADDR_WIDTH          = 29,

    parameter         APP_DATA_WIDTH          = 512,
    parameter         APP_MASK_WIDTH          = 64,

    parameter         CLKIN_PERIOD_MMCM        = 10000,
    parameter         CLKFBOUT_MULT_MMCM       = 10,
    parameter         DIVCLK_DIVIDE_MMCM       = 1,
    parameter         CLKOUT0_DIVIDE_MMCM      = 5,
    parameter         CLKOUT1_DIVIDE_MMCM      = 5,
    parameter         CLKOUT2_DIVIDE_MMCM      = 5,
    parameter         CLKOUT3_DIVIDE_MMCM      = 5,
    parameter         CLKOUT4_DIVIDE_MMCM      = 5,
    parameter         CLKOUT6_DIVIDE_MMCM      = 10,
    parameter         CLKOUTPHY_MODE           = "VCO_2X",
    parameter         C_FAMILY                 = "kintexu",

    parameter C_S_AXI_ID_WIDTH                = 4,
                                              // Width of all master and slave ID signals.
                                              // # = >= 1.
    parameter C_S_AXI_ADDR_WIDTH              = 32,
                                              // Width of S_AXI_AWADDR, S_AXI_ARADDR, M_AXI_AWADDR and
                                              // M_AXI_ARADDR for all SI/MI slots.
                                              // # = 32.
    parameter C_S_AXI_DATA_WIDTH              = 256,
                                              // Width of WDATA and RDATA on SI slot.
                                              // Must be <= APP_DATA_WIDTH.
                                              // # = 32, 64, 128, 256.
    parameter BURST_MODE                      = "8",     // Burst length
    parameter C_S_AXI_SUPPORTS_NARROW_BURST   = 0,
                                              // Indicates whether to instatiate upsizer
                                              // Range: 0, 1
    parameter C_RD_WR_ARB_ALGORITHM           = "RD_PRI_REG",
                                             // Indicates the Arbitration
                                             // Allowed values - "TDM", "ROUND_ROBIN",
                                             // "RD_PRI_REG", "RD_PRI_REG_STARVE_LIMIT"
    parameter C_S_AXI_REG_EN0                 = 20'h00000,
                                             // Instatiates register slices before upsizer.
                                             // The type of register is specified for each channel
                                             // in a vector. 4 bits per channel are used.
                                             // C_S_AXI_REG_EN0[03:00] = AW CHANNEL REGISTER SLICE
                                             // C_S_AXI_REG_EN0[07:04] =  W CHANNEL REGISTER SLICE
                                             // C_S_AXI_REG_EN0[11:08] =  B CHANNEL REGISTER SLICE
                                             // C_S_AXI_REG_EN0[15:12] = AR CHANNEL REGISTER SLICE
                                             // C_S_AXI_REG_EN0[20:16] =  R CHANNEL REGISTER SLICE
                                             // Possible values for each channel are:
                                             //
                                             //   0 => BYPASS    = The channel is just wired through the
                                             //                    module.
                                             //   1 => FWD       = The master VALID and payload signals
                                             //                    are registrated.
                                             //   2 => REV       = The slave ready signal is registrated
                                             //   3 => FWD_REV   = Both FWD and REV
                                             //   4 => SLAVE_FWD = All slave side signals and master
                                             //                    VALID and payload are registrated.
                                             //   5 => SLAVE_RDY = All slave side signals and master
                                             //                    READY are registrated.
                                             //   6 => INPUTS    = Slave and Master side inputs are
                                             //                    registrated.
    parameter C_S_AXI_REG_EN1                 = 20'h00000,
                                             // Same as C_S_AXI_REG_EN0, but this register is after
                                             // the upsizer
    parameter ECC                               = "OFF",
    parameter ECC_TEST                          = "OFF",
    parameter PAYLOAD_WIDTH                     = (ECC == "OFF") ? DQ_WIDTH : APP_DATA_WIDTH/8,
    parameter integer DATA_BUF_ADDR_WIDTH       = 5,
    parameter AUTO_AP_COL_A3                    = "OFF",
    parameter MIG_PARAM_CHECKS                  ="FALSE",
    parameter INTERFACE                         ="AXI",
    parameter ADV_USER_REQ                      ="NONE",
    parameter FPGA			                        = "xcku060-ffva1517-1-c-",
    parameter FAMILY                            = "ULTRASCALE",
    parameter SELF_REFRESH                      = "false",
    parameter SAVE_RESTORE                      = "false",
    parameter DEVICE			                      = "xcku060-",
    parameter DEBUG_SIGNAL		                  = "Disable",
    // Memory part parameters
    parameter MEMORY_PART                       = "MT8KTF51264HZ-1G9",
    parameter         PING_PONG_PHY             = 1, 
    parameter integer COMPONENT_WIDTH	          = 64,
    parameter MEMORY_DENSITY                    = "4Gb",
    parameter MEMORY_SPEED_GRADE                = "107",
    parameter MEMORY_WIDTH                      = "8",
    parameter MEMORY_CONFIGURATION              = "SODIMM",
    parameter NUM_SLOT                          = 1,
    parameter RANK_SLOT                         = 1,
    parameter         SYSCLK_TYPE             = "DIFFERENTIAL",
                                // input clock type
    parameter CALIB_HIGH_SPEED                  = "FALSE",
    parameter         CA_MIRROR                 = "OFF",
    parameter integer DBYTES                    = 8,

    parameter         MR0                       = 13'b0110101110000,
    parameter         MR3                       = 13'b0000000000000,
    parameter         ODTRD                   = 16'h0000,
    parameter         ODTWR                   = 16'h0001,
    parameter         MR1                     = 13'b0000001000100,
    parameter         MR2                     = 13'b0000000011000,
    parameter         SLOT0_CONFIG              = {{(8-CS_WIDTH){1'b0}},{CS_WIDTH{1'b1}}},
    parameter         SLOT1_CONFIG              = 8'b0000_0000,
    parameter         SLOT0_FUNC_CS             = 8'b0000_0001,
    parameter         SLOT1_FUNC_CS             = 8'b0000_0000,
    parameter         SLOT0_ODD_CS              = 8'b0000_0000,
    parameter         SLOT1_ODD_CS              = 8'b0000_0000,
    parameter         tXPR                      = 54,
    parameter         tMOD                      = 3,
    parameter         tMRD                      = 1,
    parameter         tZQINIT                   = 128,
    parameter         MEM_CODE                  = 0,
    parameter         C_DEBUG_ENABLED           = 0,
    parameter         CPLX_PAT_LENGTH           = "LONG",
    parameter         EARLY_WR_DATA             = "OFF",
  `ifdef SIMULATION
    parameter         SIM_MODE                  = "BFM",
    parameter         BISC_EN                   = 0,
    parameter         BYPASS_CAL                = "TRUE",
    parameter         CAL_DQS_GATE              = "SKIP",
    parameter         CAL_WRLVL                 = "SKIP",
    parameter         CAL_RDLVL                 = "SKIP",
    parameter         CAL_RDLVL_DBI             = "SKIP",
    parameter         CAL_WR_DQS_DQ             = "SKIP",
    parameter         CAL_WR_DQS_DM_DBI         = "SKIP",
    parameter         CAL_WRITE_LAT             = "FAST",
    parameter         CAL_RDLVL_COMPLEX         = "SKIP",
    parameter         CAL_WR_DQS_COMPLEX        = "SKIP",
    parameter         CAL_RD_VREF               = "SKIP",
    parameter         CAL_RD_VREF_PATTERN       = "SIMPLE",
    parameter         CAL_WR_VREF               = "SKIP",
    parameter         CAL_WR_VREF_PATTERN       = "SIMPLE",
    parameter         CAL_DQS_TRACKING          = "SKIP",
    parameter         CAL_JITTER                = "NONE",
    parameter         t200us                    = 100,
    parameter         t500us                    = 150
  `else
    parameter         SIM_MODE                  = "FULL",
    parameter         BISC_EN                   = 1,
    parameter         BYPASS_CAL                = "FALSE",
    parameter         CAL_DQS_GATE              = "FULL",
    parameter         CAL_WRLVL                 = "FULL",
    parameter         CAL_RDLVL                 = "FULL",
    parameter         CAL_RDLVL_DBI             = "SKIP",
    parameter         CAL_WR_DQS_DQ             = "FULL",
    parameter         CAL_WR_DQS_DM_DBI         = "FULL",
    parameter         CAL_WRITE_LAT             = "FULL",
    parameter         CAL_RDLVL_COMPLEX         = "FULL",
    parameter         CAL_WR_DQS_COMPLEX        = "FULL",
    parameter         CAL_RD_VREF               = "SKIP",
    parameter         CAL_RD_VREF_PATTERN       = "SIMPLE",
    parameter         CAL_WR_VREF               = "SKIP",
    parameter         CAL_WR_VREF_PATTERN       = "SIMPLE",
    parameter         CAL_DQS_TRACKING          = "FULL",
    parameter         CAL_JITTER                = "FULL",
    parameter         t200us                    = 40000,
    parameter         t500us                    = 100000
  `endif
    )
   (

    input                 sys_rst,
   input                           c0_sys_clk_p,
   input                           c0_sys_clk_n,

    // iob<>DDR3 signals
    output [ADDR_WIDTH-1:0]   c0_ddr3_addr,
    output [BANK_WIDTH-1:0]   c0_ddr3_ba,
    output                    c0_ddr3_ras_n,
    output                    c0_ddr3_cas_n,
    output                    c0_ddr3_we_n,
    output [CKE_WIDTH-1:0]    c0_ddr3_cke,
    output [ODT_WIDTH-1:0]    c0_ddr3_odt,
    output [CS_WIDTH-1:0]     c0_ddr3_cs_n,
    output [CK_WIDTH-1:0]     c0_ddr3_ck_p,
    output [CK_WIDTH-1:0]     c0_ddr3_ck_n,
    output                    c0_ddr3_reset_n,
    output [DM_WIDTH-1:0]     c0_ddr3_dm,
    inout  [DQ_WIDTH-1:0]     c0_ddr3_dq,
    inout  [DQS_WIDTH-1:0]    c0_ddr3_dqs_p,
    inout  [DQS_WIDTH-1:0]    c0_ddr3_dqs_n,

   output                          c0_init_calib_complete,

   output                             addn_ui_clkout1,
   output                             addn_ui_clkout2,
   output                             addn_ui_clkout3,
   output                             addn_ui_clkout4,
   output                             dbg_clk,
   (* KEEP = "true" *) input [36:0]   sl_iport0,
   (* KEEP = "true" *) output [16:0]  sl_oport0,

   output                              c0_ddr3_ui_clk,
   output                              c0_ddr3_ui_clk_sync_rst,
   // Slave Interface Write Address Ports
   input                              c0_ddr3_aresetn,
   input  [C_S_AXI_ID_WIDTH-1:0]      c0_ddr3_s_axi_awid,
   input  [C_S_AXI_ADDR_WIDTH-1:0]    c0_ddr3_s_axi_awaddr,
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
   input  [C_S_AXI_DATA_WIDTH-1:0]    c0_ddr3_s_axi_wdata,
   input  [C_S_AXI_DATA_WIDTH/8-1:0]  c0_ddr3_s_axi_wstrb,
   input                              c0_ddr3_s_axi_wlast,
   input                              c0_ddr3_s_axi_wvalid,
   output                             c0_ddr3_s_axi_wready,
   // Slave Interface Write Response Ports
   input                              c0_ddr3_s_axi_bready,
   output [C_S_AXI_ID_WIDTH-1:0]      c0_ddr3_s_axi_bid,
   output [1:0]                       c0_ddr3_s_axi_bresp,
   output                             c0_ddr3_s_axi_bvalid,
   // Slave Interface Read Address Ports
   input  [C_S_AXI_ID_WIDTH-1:0]      c0_ddr3_s_axi_arid,
   input  [C_S_AXI_ADDR_WIDTH-1:0]    c0_ddr3_s_axi_araddr,
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
   output [C_S_AXI_ID_WIDTH-1:0]      c0_ddr3_s_axi_rid,
   output [C_S_AXI_DATA_WIDTH-1:0]    c0_ddr3_s_axi_rdata,
   output [1:0]                       c0_ddr3_s_axi_rresp,
   output                             c0_ddr3_s_axi_rlast,
   output                             c0_ddr3_s_axi_rvalid,

   // Debug Port
   output wire [511:0]             dbg_bus
   );

  function integer clogb2 (input integer size);
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
        size = size >> 1;
    end
  endfunction // clogb2

  localparam RANK_WIDTH = clogb2(RANKS);
  localparam ECC_WIDTH = 8;
  localparam DATA_BUF_OFFSET_WIDTH = 1;
  // Fixed error log definition for all DRAM configs
  // Field: RMW    Row     Column  reserved  Rank   reserved   Bank
  // Bit:   44    43:24     23:8      7:6     5:4       3       2:0
  localparam MC_ERR_ADDR_WIDTH = 45;

  wire c0_rst;
  wire c0_div_clk;
  wire c0_div_clk_rst;
  (* keep = "TRUE" *) reg div_clk_rst_r1;
  wire c0_riu_clk;
  wire c0_riu_clk_rst;
  wire c0_mmcm_clk_in;
  wire sys_clk_in;
  wire mmcm_lock;
  wire pll_lock;
  wire reset_ub;
  wire pllGate;

  wire                                   c0_ddr3_correct_en;
  wire [2*nCK_PER_CLK-1:0]               c0_ddr3_raw_not_ecc;
  wire [2*nCK_PER_CLK-1:0]               c0_ddr3_ecc_single_int;
  wire [2*nCK_PER_CLK-1:0]               c0_ddr3_ecc_multiple_int;
  wire [MC_ERR_ADDR_WIDTH-1:0]           c0_ddr3_ecc_err_addr_int;
  wire                                   c0_ddr3_app_correct_en;
  wire [2*nCK_PER_CLK-1:0]               c0_ddr3_app_ecc_multiple_err;
  wire                                   c0_ddr3_app_correct_en_i;
  reg                                    c0_ddr3_init_calib_complete_r;
  wire [DQ_WIDTH*8-1:0]                  c0_ddr3_rd_data_phy2mc;
  wire [2*nCK_PER_CLK-1:0]               c0_ddr3_app_raw_not_ecc;
  wire [DQ_WIDTH/8-1:0]                  c0_ddr3_fi_xor_we;
  wire [DQ_WIDTH-1:0]                    c0_ddr3_fi_xor_wrdata;


  //***************************************************************************
  // Added a single register stage for the calib_done to fix timing
  //***************************************************************************

  always @(posedge c0_div_clk)
    c0_ddr3_init_calib_complete_r <= c0_init_calib_complete;

  wire aclk;

  wire [APP_ADDR_WIDTH-1:0]              c0_ddr3_app_addr;
  wire [2:0]                             c0_ddr3_app_cmd;
  wire                                   c0_ddr3_app_en;
  wire                                   c0_ddr3_app_hi_pri;
  wire                                   c0_ddr3_app_autoprecharge;
  wire                                   c0_ddr3_app_wdf_end;
  wire                                   c0_ddr3_app_wdf_wren;
  wire                                   c0_ddr3_app_rd_data_end;
  wire                                   c0_ddr3_app_rd_data_valid;
  wire                                   c0_ddr3_app_rdy;
  wire                                   c0_ddr3_app_wdf_rdy;
  wire [APP_DATA_WIDTH-1:0]              c0_ddr3_app_wdf_data;
  wire [APP_MASK_WIDTH-1:0]              c0_ddr3_app_wdf_mask;
  wire [APP_DATA_WIDTH-1:0]              c0_ddr3_app_rd_data;

  assign aclk =  c0_div_clk;

  always @(posedge c0_div_clk)
    div_clk_rst_r1 <= c0_div_clk_rst;

  assign c0_ddr3_ui_clk = c0_div_clk;
  assign c0_ddr3_ui_clk_sync_rst = div_clk_rst_r1;


  ddr3_v1_4_0_infrastructure #
    (
     .CLKIN_PERIOD_MMCM   (CLKIN_PERIOD_MMCM),
     .CLKFBOUT_MULT_MMCM  (CLKFBOUT_MULT_MMCM),
     .DIVCLK_DIVIDE_MMCM  (DIVCLK_DIVIDE_MMCM),
     .CLKOUT0_DIVIDE_MMCM (CLKOUT0_DIVIDE_MMCM),
     .CLKOUT1_DIVIDE_MMCM (CLKOUT1_DIVIDE_MMCM),
     .CLKOUT2_DIVIDE_MMCM (CLKOUT2_DIVIDE_MMCM),
     .CLKOUT3_DIVIDE_MMCM (CLKOUT3_DIVIDE_MMCM),
     .CLKOUT4_DIVIDE_MMCM (CLKOUT4_DIVIDE_MMCM),
     .CLKOUT6_DIVIDE_MMCM (CLKOUT6_DIVIDE_MMCM),
     .C_FAMILY            (C_FAMILY),
     .TCQ                 (TCQ)
     )
  u_ddr3_infrastructure
    (
     .sys_rst          (sys_rst),
     .sys_clk_in       (sys_clk_in),
     .mmcm_clk_in      (c0_mmcm_clk_in),
     .pll_lock         (pll_lock),
	 
     .mmcm_lock        (mmcm_lock),
     .div_clk          (c0_div_clk),
     .riu_clk          (c0_riu_clk),
     .addn_ui_clkout1  (addn_ui_clkout1),
     .addn_ui_clkout2  (addn_ui_clkout2),
     .addn_ui_clkout3  (addn_ui_clkout3),
     .addn_ui_clkout4  (addn_ui_clkout4),
     .dbg_clk          (dbg_clk),
     .rstdiv0          (c0_div_clk_rst),
     .rstdiv1          (c0_riu_clk_rst),
     .reset_ub         (reset_ub),
     .pllgate          (pllGate)
     );

  // memc_ui_top instance repeats for each controller
ddr3_0_ddr3_mem_intfc #
    (
     .ADDR_WIDTH            (ADDR_WIDTH),
     .ROW_WIDTH             (ROW_WIDTH),
     .BANK_WIDTH            (BANK_WIDTH),
     .CKE_WIDTH             (CKE_WIDTH),
     .CK_WIDTH              (CK_WIDTH),
     .COL_WIDTH             (COL_WIDTH),
     .CS_WIDTH              (CS_WIDTH),
     .ODT_WIDTH             (ODT_WIDTH),
     .DRAM_TYPE             (DRAM_TYPE),
     .DQ_WIDTH              (DQ_WIDTH),
     .DBYTES                (DBYTES),
     .DEVICE                (DEVICE),
     .SAVE_RESTORE          (1'b0),
     .SELF_REFRESH          (1'b0),
     .NUM_SLOT              (NUM_SLOT),
     .RANK_SLOT             (RANK_SLOT),
     .DQS_WIDTH             (DQS_WIDTH),
     .DM_WIDTH              (DM_WIDTH),
     .MEM_ADDR_ORDER        (MEM_ADDR_ORDER),
     .DM_DBI                (DM_DBI),
     .USE_CS_PORT           (USE_CS_PORT),
     .ADDR_FIFO_WIDTH       (MC_ERR_ADDR_WIDTH),
     .ECC                   (ECC),
     .ECC_WIDTH             (ECC_WIDTH),
     .PAYLOAD_WIDTH         (PAYLOAD_WIDTH),
     .DATA_BUF_ADDR_WIDTH  (DATA_BUF_ADDR_WIDTH),
     .AUTO_AP_COL_A3        (AUTO_AP_COL_A3),

     .SLOT0_CONFIG          (SLOT0_CONFIG),
     .SLOT1_CONFIG          (SLOT1_CONFIG),
     .SLOT0_FUNC_CS         (SLOT0_FUNC_CS),
     .SLOT1_FUNC_CS         (SLOT1_FUNC_CS),

     .REG_CTRL              (REG_CTRL),
     .MCS_ECC_ENABLE        (MCS_ECC_ENABLE),
     .tCK                   (tCK),
     .tFAW                  (tFAW),
     .tRTW                  (tRTW),
     .tWTR                  (tWTR),
     .tRFC                  (tRFC),
     .tREFI                 (tREFI),
     .ZQINTVL               (ZQINTVL),
     .tZQCS                 (tZQCS),
     .tRP                   (tRP),
     .tRRD                  (tRRD),
     .tRAS                  (tRAS),
     .tRCD                  (tRCD),
     .tRTP                  (tRTP),
     .tWR                   (tWR),
     .NUMREF                (NUMREF),
     .PER_RD_INTVL          (PER_RD_INTVL),
     .ODTWR                 (ODTWR),
     .ODTWRDEL              (ODTWRDEL),
     .ODTWRDUR              (ODTWRDUR),
     .ODTWRODEL             (ODTWRODEL),
     .ODTWRODUR             (ODTWRODUR),
     .ODTRD                 (ODTRD),
     .ODTRDDEL              (ODTRDDEL),
     .ODTRDDUR              (ODTRDDUR),
     .ODTRDODEL             (ODTRDODEL),
     .ODTRDODUR             (ODTRDODUR),
     .ODTNOP                (ODTNOP),
     .DRAM_WIDTH            (DRAM_WIDTH),
     .RANKS                 (RANKS),
     .RANK_WIDTH            (RANK_WIDTH),
     .ORDERING              (ORDERING),
     .RTL_VERSION           (RTL_VERSION),
     .TXN_FIFO_BYPASS       (TXN_FIFO_BYPASS),
     .TXN_FIFO_PIPE         (TXN_FIFO_PIPE),
     .PER_RD_PERF           (PER_RD_PERF),
     .CAS_FIFO_BYPASS       (CAS_FIFO_BYPASS),
     .NOP_ADD_LOW           (NOP_ADD_LOW),
     .STARVATION_EN         (STARVATION_EN),
     .STARVE_COUNT_WIDTH    (STARVE_COUNT_WIDTH),
     .EXTRA_CMD_DELAY       (EXTRA_CMD_DELAY),
     .nCK_PER_CLK           (nCK_PER_CLK),
     .APP_DATA_WIDTH        (APP_DATA_WIDTH),
     .APP_MASK_WIDTH        (APP_MASK_WIDTH),
     .APP_ADDR_WIDTH        (APP_ADDR_WIDTH),

     .MIG_PARAM_CHECKS      (MIG_PARAM_CHECKS),
     .INTERFACE             (INTERFACE),
     .C_S_AXI_ADDR_WIDTH    (C_S_AXI_ADDR_WIDTH),
     .ADV_USER_REQ          (ADV_USER_REQ),
     .MEMORY_DENSITY        (MEMORY_DENSITY),
     .MEMORY_SPEED_GRADE    (MEMORY_SPEED_GRADE),
     .MEMORY_WIDTH          (MEMORY_WIDTH),
     .MEMORY_CONFIGURATION  (MEMORY_CONFIGURATION),
     .CALIB_HIGH_SPEED      (CALIB_HIGH_SPEED),

     .MR0                   (MR0),
     .MR1                   (MR1),
     .MR2                   (MR2),
     .MR3                   (MR3),
     
     .SLOT0_ODD_CS          (SLOT0_ODD_CS),
     .SLOT1_ODD_CS          (SLOT1_ODD_CS),
     
     .CA_MIRROR              (CA_MIRROR),
     
     .t200us                 (t200us),
     .t500us                 (t500us),
     .tXPR                   (tXPR),
     .tMOD                   (tMOD),
     .tMRD                   (tMRD),
     .tZQINIT                (tZQINIT),
     .TCQ                    (TCQ),
     
     .EARLY_WR_DATA          (EARLY_WR_DATA),
     .MEM_CODE               (MEM_CODE),
     
     .BISC_EN                (BISC_EN),
     .BYPASS_CAL             (BYPASS_CAL),
     .CAL_DQS_GATE           (CAL_DQS_GATE),
     .CAL_WRLVL              (CAL_WRLVL),
     .CAL_RDLVL              (CAL_RDLVL),
     .CAL_RDLVL_DBI          (CAL_RDLVL_DBI),
     .CAL_WR_DQS_DQ          (CAL_WR_DQS_DQ),
     .CAL_WR_DQS_DM_DBI      (CAL_WR_DQS_DM_DBI),
     .CAL_WRITE_LAT          (CAL_WRITE_LAT),
     .CAL_RDLVL_COMPLEX      (CAL_RDLVL_COMPLEX),
     .CAL_WR_DQS_COMPLEX     (CAL_WR_DQS_COMPLEX),
     .CAL_RD_VREF            (CAL_RD_VREF),
     .CAL_RD_VREF_PATTERN    (CAL_RD_VREF_PATTERN),
     .CAL_WR_VREF            (CAL_WR_VREF),
     .CAL_WR_VREF_PATTERN    (CAL_WR_VREF_PATTERN),
     .CAL_DQS_TRACKING       (CAL_DQS_TRACKING),
     .CAL_JITTER             (CAL_JITTER),
     .CPLX_PAT_LENGTH        (CPLX_PAT_LENGTH),
     .C_FAMILY               (C_FAMILY),
     .CLKOUTPHY_MODE         (CLKOUTPHY_MODE),
     .CLKFBOUT_MULT_MMCM     (CLKFBOUT_MULT_MMCM),
     .DIVCLK_DIVIDE_MMCM     (DIVCLK_DIVIDE_MMCM),
     .CLKOUT0_DIVIDE_MMCM    (CLKOUT0_DIVIDE_MMCM)
  )
  u_ddr3_mem_intfc
    (

   .sys_clk_p           (c0_sys_clk_p),
   .sys_clk_n           (c0_sys_clk_n),
   .mmcm_lock           (mmcm_lock),
   .reset_ub            (reset_ub),
   .pllGate             (pllGate),
   .div_clk             (c0_div_clk),
   .div_clk_rst         (c0_div_clk_rst),
   .riu_clk             (c0_riu_clk),
   .riu_clk_rst         (c0_riu_clk_rst),
   .pll_lock            (pll_lock),
   .sys_clk_in          (sys_clk_in),
   .mmcm_clk_in         (c0_mmcm_clk_in),
   .calDone             (c0_init_calib_complete),

     .ddr3_addr           (c0_ddr3_addr),
     .ddr3_ba             (c0_ddr3_ba),
     .ddr3_ras_n          (c0_ddr3_ras_n),
     .ddr3_cas_n          (c0_ddr3_cas_n),
     .ddr3_we_n           (c0_ddr3_we_n),
     .ddr3_cke            (c0_ddr3_cke),
     .ddr3_odt            (c0_ddr3_odt),
     .ddr3_cs_n           (c0_ddr3_cs_n),
     .ddr3_ck_p           (c0_ddr3_ck_p),
     .ddr3_ck_n           (c0_ddr3_ck_n),
     .ddr3_reset_n        (c0_ddr3_reset_n),
     .ddr3_dm             (c0_ddr3_dm),
     .ddr3_dq             (c0_ddr3_dq),
     .ddr3_dqs_p          (c0_ddr3_dqs_p),
     .ddr3_dqs_n          (c0_ddr3_dqs_n),

   .app_addr              (c0_ddr3_app_addr),
   .app_cmd               (c0_ddr3_app_cmd),
   .app_en                (c0_ddr3_app_en),
   .app_hi_pri            (c0_ddr3_app_hi_pri),
   .app_autoprecharge     (c0_ddr3_app_autoprecharge),
   .app_wdf_data          (c0_ddr3_app_wdf_data),
   .app_wdf_end           (c0_ddr3_app_wdf_end),
   .app_wdf_mask          (c0_ddr3_app_wdf_mask),
   .app_wdf_wren          (c0_ddr3_app_wdf_wren),
   .app_correct_en_i      (1'b1),
   .app_raw_not_ecc       (c0_ddr3_app_raw_not_ecc),
   .app_ecc_multiple_err  (c0_ddr3_app_ecc_multiple_err),
   .app_rd_data           (c0_ddr3_app_rd_data),
   .app_rd_data_end       (c0_ddr3_app_rd_data_end),
   .app_rd_data_valid     (c0_ddr3_app_rd_data_valid),
   .app_rdy               (c0_ddr3_app_rdy),
   .app_wdf_rdy           (c0_ddr3_app_wdf_rdy),
   .app_ref_req           (1'b0),
   .app_ref_ack           (),
   .app_zq_req            (1'b0),
   .app_zq_ack            (),   
   .sl_iport0             (sl_iport0),
   .sl_oport0             (sl_oport0),
   .ddr3_mcs_lmb_ue                (),
   .ddr3_mcs_lmb_ce                (),
   .app_sr_req            (1'b0),
   .app_sr_active         (),
   .app_mem_init_skip     (1'b0),
   .app_save_req          (1'b0),
   .app_save_ack          (),
   .app_restore_en        (1'b0),
   .app_restore_complete  (1'b0),
   .xsdb_select           (1'b0),
   .xsdb_rd_en            (1'b0),
   .xsdb_wr_en            (1'b0),
   .xsdb_addr             (16'b0),
   .xsdb_wr_data          (9'b0),
   .xsdb_rd_data          (),
   .xsdb_rdy              (),
   .dbg_out               (),
   .cal_pre_status        (),
   .cal_r1_status         (),
   .cal_r2_status         (),
   .cal_r3_status         (),
   .cal_post_status       (),
   .cal_error             (),
   .cal_error_bit         (),
   .cal_error_nibble      (),
   .cal_error_code        (),

   .traffic_wr_done               (1'b0),
   .traffic_status_err_bit_valid  (1'b0),
   .traffic_status_err_type_valid (1'b0),
   .traffic_status_err_type       (1'b0),
   .traffic_status_done           (1'b0),
   .traffic_status_watch_dog_hang (1'b0),
   .traffic_error                 ({APP_DATA_WIDTH{1'b0}}),
   .win_start                     (4'b0),
   .traffic_clr_error             (),
   .traffic_start                 (),
   .traffic_rst                   (),
   .traffic_err_chk_en            (),
   .traffic_instr_addr_mode       (),
   .traffic_instr_data_mode       (),
   .traffic_instr_rw_mode         (),
   .traffic_instr_rw_submode      (),
   .traffic_instr_num_of_iter     (),
   .traffic_instr_nxt_instr       (),
   .win_status                    (),
   .ecc_err_addr          (c0_ddr3_ecc_err_addr_int),
   .eccSingle             (c0_ddr3_ecc_single_int),
   .eccMultiple           (c0_ddr3_ecc_multiple_int),
   .fi_xor_we             (c0_ddr3_fi_xor_we),
   .fi_xor_wrdata         (c0_ddr3_fi_xor_wrdata),
   .rd_data_phy2mc        (c0_ddr3_rd_data_phy2mc),
     //Debug Port
   .dbg_bus               (dbg_bus), 
   .dbg_rd_data_cmp           (),
   .dbg_expected_data         (),
   .dbg_cal_seq               (),
   .dbg_cal_seq_cnt           (),
   .dbg_cal_seq_rd_cnt        (),
   .dbg_rd_valid              (),
   .dbg_cmp_byte              (),
   .dbg_rd_data               (),
   .dbg_cplx_config           (),
   .dbg_cplx_status           (),
   .dbg_io_address            (),
   .dbg_pllGate               (),
   .dbg_phy2clb_fixdly_rdy_low(),
   .dbg_phy2clb_fixdly_rdy_upp(),
   .dbg_phy2clb_phy_rdy_low   (),
   .dbg_phy2clb_phy_rdy_upp   (),
   .cal_r0_status             ()
     );
ddr3_v1_4_0_axi #
  (
   .C_ECC                         (ECC),
   .C_S_AXI_ID_WIDTH              (C_S_AXI_ID_WIDTH),
   .C_S_AXI_ADDR_WIDTH            (C_S_AXI_ADDR_WIDTH),
   .C_S_AXI_DATA_WIDTH            (C_S_AXI_DATA_WIDTH),
   .C_MC_DATA_WIDTH               (APP_DATA_WIDTH),
   .C_MC_ADDR_WIDTH               (APP_ADDR_WIDTH),
   .C_MC_BURST_MODE               (BURST_MODE),
   .C_MC_nCK_PER_CLK              (nCK_PER_CLK),
   .C_S_AXI_SUPPORTS_NARROW_BURST (C_S_AXI_SUPPORTS_NARROW_BURST),
   .C_RD_WR_ARB_ALGORITHM         (C_RD_WR_ARB_ALGORITHM),
   .C_S_AXI_REG_EN0               (C_S_AXI_REG_EN0),
   .C_S_AXI_REG_EN1               (C_S_AXI_REG_EN1)
  )
  u_ddr_axi
    (
     .aclk                                   (aclk),

     // Slave Interface Write Address Ports
     .aresetn                                (c0_ddr3_aresetn),
     .s_axi_awid                             (c0_ddr3_s_axi_awid),
     .s_axi_awaddr                           (c0_ddr3_s_axi_awaddr),
     .s_axi_awlen                            (c0_ddr3_s_axi_awlen),
     .s_axi_awsize                           (c0_ddr3_s_axi_awsize),
     .s_axi_awburst                          (c0_ddr3_s_axi_awburst),
     .s_axi_awlock                           (c0_ddr3_s_axi_awlock),
     .s_axi_awcache                          (c0_ddr3_s_axi_awcache),
     .s_axi_awprot                           (c0_ddr3_s_axi_awprot),
     .s_axi_awqos                            (c0_ddr3_s_axi_awqos),
     .s_axi_awvalid                          (c0_ddr3_s_axi_awvalid),
     .s_axi_awready                          (c0_ddr3_s_axi_awready),
     // Slave Interface Write Data Ports
     .s_axi_wdata                            (c0_ddr3_s_axi_wdata),
     .s_axi_wstrb                            (c0_ddr3_s_axi_wstrb),
     .s_axi_wlast                            (c0_ddr3_s_axi_wlast),
     .s_axi_wvalid                           (c0_ddr3_s_axi_wvalid),
     .s_axi_wready                           (c0_ddr3_s_axi_wready),
     // Slave Interface Write Response Ports
     .s_axi_bid                              (c0_ddr3_s_axi_bid),
     .s_axi_bresp                            (c0_ddr3_s_axi_bresp),
     .s_axi_bvalid                           (c0_ddr3_s_axi_bvalid),
     .s_axi_bready                           (c0_ddr3_s_axi_bready),
     // Slave Interface Read Address Ports
     .s_axi_arid                             (c0_ddr3_s_axi_arid),
     .s_axi_araddr                           (c0_ddr3_s_axi_araddr),
     .s_axi_arlen                            (c0_ddr3_s_axi_arlen),
     .s_axi_arsize                           (c0_ddr3_s_axi_arsize),
     .s_axi_arburst                          (c0_ddr3_s_axi_arburst),
     .s_axi_arlock                           (c0_ddr3_s_axi_arlock),
     .s_axi_arcache                          (c0_ddr3_s_axi_arcache),
     .s_axi_arprot                           (c0_ddr3_s_axi_arprot),
     .s_axi_arqos                            (c0_ddr3_s_axi_arqos),
     .s_axi_arvalid                          (c0_ddr3_s_axi_arvalid),
     .s_axi_arready                          (c0_ddr3_s_axi_arready),
     // Slave Interface Read Data Ports
     .s_axi_rid                              (c0_ddr3_s_axi_rid),
     .s_axi_rdata                            (c0_ddr3_s_axi_rdata),
     .s_axi_rresp                            (c0_ddr3_s_axi_rresp),
     .s_axi_rlast                            (c0_ddr3_s_axi_rlast),
     .s_axi_rvalid                           (c0_ddr3_s_axi_rvalid),
     .s_axi_rready                           (c0_ddr3_s_axi_rready),

     // MC Master Interface
     //CMD PORT
     .mc_app_en                              (c0_ddr3_app_en),
     .mc_app_cmd                             (c0_ddr3_app_cmd),
     .mc_app_sz                              (),
     .mc_app_addr                            (c0_ddr3_app_addr),
     .mc_app_hi_pri                          (c0_ddr3_app_hi_pri),
     .mc_app_autoprecharge                   (c0_ddr3_app_autoprecharge),
     .mc_app_rdy                             (c0_ddr3_app_rdy),
     .mc_init_complete                       (c0_init_calib_complete),

     //DATA PORT
     .mc_app_wdf_wren                        (c0_ddr3_app_wdf_wren),
     .mc_app_wdf_mask                        (c0_ddr3_app_wdf_mask),
     .mc_app_wdf_data                        (c0_ddr3_app_wdf_data),
     .mc_app_wdf_end                         (c0_ddr3_app_wdf_end),
     .mc_app_wdf_rdy                         (c0_ddr3_app_wdf_rdy),

     .mc_app_rd_valid                        (c0_ddr3_app_rd_data_valid),
     .mc_app_rd_data                         (c0_ddr3_app_rd_data),
     .mc_app_rd_end                          (c0_ddr3_app_rd_data_end),
     .mc_app_ecc_multiple_err                (c0_ddr3_app_ecc_multiple_err)
     );

    assign c0_ddr3_app_raw_not_ecc    = {2*nCK_PER_CLK{1'b0}};
    assign c0_ddr3_fi_xor_we          = {DQ_WIDTH/8{1'b0}};
    assign c0_ddr3_fi_xor_wrdata      = {DQ_WIDTH{1'b0}};

endmodule
