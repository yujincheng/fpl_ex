// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (lin64) Build 1756540 Mon Jan 23 19:11:19 MST 2017
// Date        : Tue May 23 22:21:15 2017
// Host        : yujc-Z97-HD3 running 64-bit Ubuntu 16.04.2 LTS
// Command     : write_verilog -force -mode synth_stub /home/yujc/690t/fpl_ex/ip/ku115/xip_w256_r512/xip_w256_r512_stub.v
// Design      : xip_w256_r512
// Purpose     : Stub declaration of top-level module interface
// Device      : xcku060-ffva1517-1-c
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_1_3,Vivado 2016.4" *)
module xip_w256_r512(clk, srst, din, wr_en, rd_en, dout, full, almost_full, 
  empty, prog_empty, wr_rst_busy, rd_rst_busy)
/* synthesis syn_black_box black_box_pad_pin="clk,srst,din[255:0],wr_en,rd_en,dout[511:0],full,almost_full,empty,prog_empty,wr_rst_busy,rd_rst_busy" */;
  input clk;
  input srst;
  input [255:0]din;
  input wr_en;
  input rd_en;
  output [511:0]dout;
  output full;
  output almost_full;
  output empty;
  output prog_empty;
  output wr_rst_busy;
  output rd_rst_busy;
endmodule
