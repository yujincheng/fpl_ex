// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.1 (lin64) Build 1846317 Fri Apr 14 18:54:47 MDT 2017
// Date        : Tue Jun  6 19:13:05 2017
// Host        : yujc-Z97-HD3 running 64-bit Ubuntu 16.04.2 LTS
// Command     : write_verilog -force -mode synth_stub /home/yujc/690t/fpl_ex/ip/ku115/ddr3_0/ddr3_0_stub.v
// Design      : ddr3_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xcku060-ffva1517-1-c
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ddr3_v1_4_0,Vivado 2017.1" *)
module ddr3_0(sys_rst, c0_sys_clk_p, c0_sys_clk_n, 
  c0_ddr3_addr, c0_ddr3_ba, c0_ddr3_ras_n, c0_ddr3_cas_n, c0_ddr3_we_n, c0_ddr3_cke, 
  c0_ddr3_odt, c0_ddr3_cs_n, c0_ddr3_ck_p, c0_ddr3_ck_n, c0_ddr3_reset_n, c0_ddr3_dm, 
  c0_ddr3_dq, c0_ddr3_dqs_p, c0_ddr3_dqs_n, c0_init_calib_complete, c0_ddr3_ui_clk, 
  c0_ddr3_ui_clk_sync_rst, dbg_clk, c0_ddr3_aresetn, c0_ddr3_s_axi_awid, 
  c0_ddr3_s_axi_awaddr, c0_ddr3_s_axi_awlen, c0_ddr3_s_axi_awsize, c0_ddr3_s_axi_awburst, 
  c0_ddr3_s_axi_awlock, c0_ddr3_s_axi_awcache, c0_ddr3_s_axi_awprot, c0_ddr3_s_axi_awqos, 
  c0_ddr3_s_axi_awvalid, c0_ddr3_s_axi_awready, c0_ddr3_s_axi_wdata, c0_ddr3_s_axi_wstrb, 
  c0_ddr3_s_axi_wlast, c0_ddr3_s_axi_wvalid, c0_ddr3_s_axi_wready, c0_ddr3_s_axi_bready, 
  c0_ddr3_s_axi_bid, c0_ddr3_s_axi_bresp, c0_ddr3_s_axi_bvalid, c0_ddr3_s_axi_arid, 
  c0_ddr3_s_axi_araddr, c0_ddr3_s_axi_arlen, c0_ddr3_s_axi_arsize, c0_ddr3_s_axi_arburst, 
  c0_ddr3_s_axi_arlock, c0_ddr3_s_axi_arcache, c0_ddr3_s_axi_arprot, c0_ddr3_s_axi_arqos, 
  c0_ddr3_s_axi_arvalid, c0_ddr3_s_axi_arready, c0_ddr3_s_axi_rready, c0_ddr3_s_axi_rid, 
  c0_ddr3_s_axi_rdata, c0_ddr3_s_axi_rresp, c0_ddr3_s_axi_rlast, c0_ddr3_s_axi_rvalid, 
  dbg_bus)
/* synthesis syn_black_box black_box_pad_pin="sys_rst,c0_sys_clk_p,c0_sys_clk_n,c0_ddr3_addr[15:0],c0_ddr3_ba[2:0],c0_ddr3_ras_n,c0_ddr3_cas_n,c0_ddr3_we_n,c0_ddr3_cke[0:0],c0_ddr3_odt[0:0],c0_ddr3_cs_n[0:0],c0_ddr3_ck_p[0:0],c0_ddr3_ck_n[0:0],c0_ddr3_reset_n,c0_ddr3_dm[7:0],c0_ddr3_dq[63:0],c0_ddr3_dqs_p[7:0],c0_ddr3_dqs_n[7:0],c0_init_calib_complete,c0_ddr3_ui_clk,c0_ddr3_ui_clk_sync_rst,dbg_clk,c0_ddr3_aresetn,c0_ddr3_s_axi_awid[3:0],c0_ddr3_s_axi_awaddr[31:0],c0_ddr3_s_axi_awlen[7:0],c0_ddr3_s_axi_awsize[2:0],c0_ddr3_s_axi_awburst[1:0],c0_ddr3_s_axi_awlock[0:0],c0_ddr3_s_axi_awcache[3:0],c0_ddr3_s_axi_awprot[2:0],c0_ddr3_s_axi_awqos[3:0],c0_ddr3_s_axi_awvalid,c0_ddr3_s_axi_awready,c0_ddr3_s_axi_wdata[255:0],c0_ddr3_s_axi_wstrb[31:0],c0_ddr3_s_axi_wlast,c0_ddr3_s_axi_wvalid,c0_ddr3_s_axi_wready,c0_ddr3_s_axi_bready,c0_ddr3_s_axi_bid[3:0],c0_ddr3_s_axi_bresp[1:0],c0_ddr3_s_axi_bvalid,c0_ddr3_s_axi_arid[3:0],c0_ddr3_s_axi_araddr[31:0],c0_ddr3_s_axi_arlen[7:0],c0_ddr3_s_axi_arsize[2:0],c0_ddr3_s_axi_arburst[1:0],c0_ddr3_s_axi_arlock[0:0],c0_ddr3_s_axi_arcache[3:0],c0_ddr3_s_axi_arprot[2:0],c0_ddr3_s_axi_arqos[3:0],c0_ddr3_s_axi_arvalid,c0_ddr3_s_axi_arready,c0_ddr3_s_axi_rready,c0_ddr3_s_axi_rid[3:0],c0_ddr3_s_axi_rdata[255:0],c0_ddr3_s_axi_rresp[1:0],c0_ddr3_s_axi_rlast,c0_ddr3_s_axi_rvalid,dbg_bus[511:0]" */;
  input sys_rst;
  input c0_sys_clk_p;
  input c0_sys_clk_n;
  output [15:0]c0_ddr3_addr;
  output [2:0]c0_ddr3_ba;
  output c0_ddr3_ras_n;
  output c0_ddr3_cas_n;
  output c0_ddr3_we_n;
  output [0:0]c0_ddr3_cke;
  output [0:0]c0_ddr3_odt;
  output [0:0]c0_ddr3_cs_n;
  output [0:0]c0_ddr3_ck_p;
  output [0:0]c0_ddr3_ck_n;
  output c0_ddr3_reset_n;
  output [7:0]c0_ddr3_dm;
  inout [63:0]c0_ddr3_dq;
  inout [7:0]c0_ddr3_dqs_p;
  inout [7:0]c0_ddr3_dqs_n;
  output c0_init_calib_complete;
  output c0_ddr3_ui_clk;
  output c0_ddr3_ui_clk_sync_rst;
  output dbg_clk;
  input c0_ddr3_aresetn;
  input [3:0]c0_ddr3_s_axi_awid;
  input [31:0]c0_ddr3_s_axi_awaddr;
  input [7:0]c0_ddr3_s_axi_awlen;
  input [2:0]c0_ddr3_s_axi_awsize;
  input [1:0]c0_ddr3_s_axi_awburst;
  input [0:0]c0_ddr3_s_axi_awlock;
  input [3:0]c0_ddr3_s_axi_awcache;
  input [2:0]c0_ddr3_s_axi_awprot;
  input [3:0]c0_ddr3_s_axi_awqos;
  input c0_ddr3_s_axi_awvalid;
  output c0_ddr3_s_axi_awready;
  input [255:0]c0_ddr3_s_axi_wdata;
  input [31:0]c0_ddr3_s_axi_wstrb;
  input c0_ddr3_s_axi_wlast;
  input c0_ddr3_s_axi_wvalid;
  output c0_ddr3_s_axi_wready;
  input c0_ddr3_s_axi_bready;
  output [3:0]c0_ddr3_s_axi_bid;
  output [1:0]c0_ddr3_s_axi_bresp;
  output c0_ddr3_s_axi_bvalid;
  input [3:0]c0_ddr3_s_axi_arid;
  input [31:0]c0_ddr3_s_axi_araddr;
  input [7:0]c0_ddr3_s_axi_arlen;
  input [2:0]c0_ddr3_s_axi_arsize;
  input [1:0]c0_ddr3_s_axi_arburst;
  input [0:0]c0_ddr3_s_axi_arlock;
  input [3:0]c0_ddr3_s_axi_arcache;
  input [2:0]c0_ddr3_s_axi_arprot;
  input [3:0]c0_ddr3_s_axi_arqos;
  input c0_ddr3_s_axi_arvalid;
  output c0_ddr3_s_axi_arready;
  input c0_ddr3_s_axi_rready;
  output [3:0]c0_ddr3_s_axi_rid;
  output [255:0]c0_ddr3_s_axi_rdata;
  output [1:0]c0_ddr3_s_axi_rresp;
  output c0_ddr3_s_axi_rlast;
  output c0_ddr3_s_axi_rvalid;
  output [511:0]dbg_bus;
endmodule
