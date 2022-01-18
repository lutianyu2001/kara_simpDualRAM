// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Tue Sep  8 20:28:36 2020
// Host        : ZWG-OMEN running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/program/Vivado/Project/ip_ram/ip_ram/ip_ram.srcs/sources_1/ip/ram_dual/ram_dual_stub.v
// Design      : ram_dual
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *)
module ram_dual(clka, ena, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[5:0],dina[255:0],clkb,enb,addrb[5:0],doutb[255:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [5:0]addra;
  input [255:0]dina;
  input clkb;
  input enb;
  input [5:0]addrb;
  output [255:0]doutb;
endmodule
