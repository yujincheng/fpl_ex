// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.1 (lin64) Build 1846317 Fri Apr 14 18:54:47 MDT 2017
// Date        : Fri Jun  9 01:03:41 2017
// Host        : yujc-Z97-HD3 running 64-bit Ubuntu 16.04.2 LTS
// Command     : write_verilog -force -mode synth_stub -rename_top xip_fifo_96_1k -prefix
//               xip_fifo_96_1k_ xip_fifo_96_1k_stub.v
// Design      : xip_fifo_96_1k
// Purpose     : Stub declaration of top-level module interface
// Device      : xcku060-ffva1517-1-c
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_1_4,Vivado 2017.1" *)
module xip_fifo_96_1k(clk, srst, din, wr_en, rd_en, dout, full, empty, 
  wr_rst_busy, rd_rst_busy)
/* synthesis syn_black_box black_box_pad_pin="clk,srst,din[95:0],wr_en,rd_en,dout[95:0],full,empty,wr_rst_busy,rd_rst_busy" */;
  input clk;
  input srst;
  input [95:0]din;
  input wr_en;
  input rd_en;
  output [95:0]dout;
  output full;
  output empty;
  output wr_rst_busy;
  output rd_rst_busy;
endmodule
