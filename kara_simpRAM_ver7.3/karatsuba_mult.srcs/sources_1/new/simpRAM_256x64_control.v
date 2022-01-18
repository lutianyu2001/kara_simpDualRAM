// -*- coding: ASCII -*-
// (ISO 8859-1)
// Never use UTF-8 specific characters, since the built-in editor of Vivado can't recognize it !!!
// Language: Verilog-2001

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: BNU-HKBU United International College
// Engineer: Lu Tianyu
//
// Create Date: 2020/08/31 09:12:54
// Design Name:
// Module Name: simpRAM_256x64_control
// Project Name:
// Target Devices:
// Tool Versions:
// Description: A Brand New version
//
// Dependencies:
//
// Revision 3
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module simpRAM_256x64_control(

    input                clk,
    input                rst,
    input                in_ram_en,
    input    [255:0]     in_ram,

    output   [255:0]     ram_out


    );

// Explanation of names of in_ram and ram_out
//              ---------
//  --- in --> |   ram   | --- out -->
//              ---------
// Thus     in_ram  &  ram_out


// >>>>>> Parameters >>>>>>

`include "all_parameters.vh"

// <<<<<< Parameters <<<<<<


// >>>>>> Declarations >>>>>>

reg     [5:0]       ram_addra; // 0~63
reg     [5:0]       ram_addrb; // 0~63

// <<<<<< Declarations <<<<<<


// >>>>>> addr A >>>>>>
// [embedded counter] in ram_addra, will be activated by in_ram_en and and synchronized with it
// in_ram_en(0->1) <-> ram_addra(0->1) ,
// in_ram_en(1->0) <-> ram_addra(63->0) .

always @(posedge clk) begin
    if(rst=='b1) ram_addra<='b0;
    else if(in_ram_en && ram_addra<='d63) ram_addra<=ram_addra+'b1; // 2^6 = (64)`10 = (10 0000)`2, overflow will reset cnt to 0
end

// <<<<<< addr A <<<<<<


// >>>>>> addr B >>>>>>
// synchronized with addra

always @(posedge clk) begin
    if(rst=='b1) ram_addrb<='b0;
    else if(in_ram_en && ram_addra==DLY_ADDRB_TRIGGER) ram_addrb<=ram_addrb+'b1;
  //else if(in_ram_en && ram_addra==40               ) ram_addrb<=ram_addrb+'b1;
    else if(ram_addrb>'b0 && ram_addrb<='d63) ram_addrb<=ram_addrb+'b1; // 2^6 = (64)`10 = (10 0000)`2, overflow will reset cnt to 0
end

// <<<<<< addr B <<<<<<


// >>>>>> Connect to ram_dual >>>>>>

ram_dual ip_simp_dual (
    .clka  (clk                 ),  // input wire clka
    .ena   ('b1                 ),  // input wire ena, always 1
    .wea   (in_ram_en           ),  // input wire [0 : 0] wea
    .addra (ram_addra           ),  // input wire [5 : 0] addra
    .dina  (in_ram              ),  // input wire [255 : 0] dina
    .clkb  (clk                 ),  // input wire clkb
    .enb   ('b1                 ),  // input wire enb, always 1
    .addrb (ram_addrb           ),  // input wire [5 : 0] addrb
    .doutb (ram_out             )   // output wire [255 : 0] doutb
);

// <<<<<< Connect to ram_dual <<<<<<

endmodule
