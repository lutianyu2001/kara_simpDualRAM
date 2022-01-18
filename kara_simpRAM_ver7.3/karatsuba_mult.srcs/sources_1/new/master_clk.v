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
// Module Name: master_clk
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision: 24
// Revision 7.3
// Additional Comments:
//

//
// Workflow:
//
//  ===============                          ------------------
// |               | ---- tb_2_master ----> |                  |
// |   testbench   |                        |                  |
// |               | <--- master_2_tb ----- |                  |                         -----------------------
//  ===============                         |    master_clk    | ---- master_2_ram ---> |                       |
//  ---------------                         |                  |                        |  RAM_control ( RAM )  |
// |               | --- kara_2_master ---> |                  | <--- ram_2_master ---- |                       |
// |   kara_mult   |                        |                  |                         -----------------------
// |               | <-- master_2_kara ---- |                  |
//  ---------------                          ------------------

//////////////////////////////////////////////////////////////////////////////////

// >>>>>> Declarations of pins >>>>>>

module master_clk( // Pins for testbench

    input                   clk,
    input                   rst,

    input                   tb_2_master_en,
    input    [255:0]        tb_2_master,

    output reg              master_2_tb_en,
    output reg  [255:0]     master_2_tb

    );


// >>>>>> Pins for others >>>>>>

    wire                  kara_2_master_en;
    wire      [255:0]     kara_2_master;

    reg                   master_2_kara_en;
    reg       [255:0]     master_2_kara;

    wire      [255:0]     ram_2_master;

    reg                   master_2_ram_en;
    reg       [255:0]     master_2_ram;

// <<<<<< Pins for others <<<<<<

// <<<<<<  Declarations of pins <<<<<<


// ############################ Signal Connection of Pins ############################

// Pins for testbench will be connected in tb_master

karatsuba_top u_karatsuba_top (

    .clk                (clk                        ),
    .rst                (rst                        ),
    .mult_in_en         (master_2_kara_en           ),
    .mult_in_a          (master_2_kara[255:128]     ),
    .mult_in_b          (master_2_kara[127:0]       ),
    .mult_out_en        (kara_2_master_en           ),
    .mult_out           (kara_2_master              )
);

simpRAM_256x64_control u_simpRAM_256x64_control (

    .clk                (clk                ),
    .rst                (rst                ),
    .in_ram_en          (master_2_ram_en    ),
    .in_ram             (master_2_ram       ),
    .ram_out            (ram_2_master       )
    );

// ############################ Signal Connection of Pins ############################


// >>>>>> Parameters >>>>>>

`include "all_parameters.vh"

// <<<<<< Parameters <<<<<<


// >>>>>> Declarations >>>>>>

    reg                   tb_2_master_en_1r;
    reg                   kara_2_master_en_1r;

    reg                   ram_2_master_2_kara_en;
    reg                   ram_2_master_2_tb_en;

  //reg   [6:0]           ram_2_master_2_kara_en_cnt;
  //reg   [6:0]           ram_2_master_2_tb_en_cnt;
    reg   [7:0]           ram_2_master_en_cnt;
    // counter for replacing delays

    reg                   ram_2_master_2_kara_en_1r;
    reg                   ram_2_master_2_tb_en_1r;

// <<<<<< Declarations <<<<<<


// >>>>>> Stage 1  >>>>>>
//
//  ===============
// |   testbench   | ---- tb_2_master  -----\
//  ===============         (Step 1)         |                      ---------
//                                           |--- master_2_ram --> |   RAM   |
//  ---------------                          |                      ---------
// |   kara_mult   | ---- kara_2_master ----/
//  ---------------         (Step 5)
//

// >>>>>> Delays for transfering edge transaction >>>>>>

// They are used to make sure the negedge of source can be <= to destination
// For example:
always @(posedge clk) if(rst) tb_2_master_en_1r <= 'b0;   else tb_2_master_en_1r <= tb_2_master_en;
// master_2_kara_en_1r is used to make sure the negedge of master_2_kara_en could be <= to master_2_ram

always @(posedge clk) if(rst) kara_2_master_en_1r <= 'b0;   else kara_2_master_en_1r <= kara_2_master_en;

always @(posedge clk) if(rst) ram_2_master_2_kara_en_1r <= 'b0;   else ram_2_master_2_kara_en_1r <= ram_2_master_2_kara_en;

always @(posedge clk) if(rst) ram_2_master_2_tb_en_1r <= 'b0;   else ram_2_master_2_tb_en_1r <= ram_2_master_2_tb_en;

// <<<<<< Delays for transfering edge transaction <<<<<<

always @(posedge clk) begin
    if(tb_2_master_en || tb_2_master_en_1r) begin
        master_2_ram_en <= tb_2_master_en;    // delay 1 ------------\
        master_2_ram    <= tb_2_master;       // delay 1 -------------\
    end else if(kara_2_master_en || kara_2_master_en_1r) begin //      |-----> Flag: delay_in
        master_2_ram_en <= kara_2_master_en;  // delay 1 -------------/
        master_2_ram    <= kara_2_master;     // delay 1 ------------/
    end
end

// <<<<<< Stage 1 <<<<<<


// Total time of stage 1 -> stage 2: 62 clk


// >>>>>> Stage 2 >>>>>>
//
//                   <---------------------------  ram_2_master_2_tb_en  ( Delayed from kara_2_master_en )
//  ===============
// |   testbench   | <--- master_2_tb  -----\
//  ===============         (Step 4)         |                      ---------
//                                           |<-- ram_2_master --- |   RAM   |
//  ---------------                          |                      ---------
// |   kara_mult   | <-- master_2_kara -----/
//  ---------------         (Step 2)
//
//                   <---------------------------- ram_2_master_2_kara_en ( Delayed from tb_2_master_en )
//
// We won't only use tb_2_master_en since only using it will cause an inefficient routing and use many unnecessary registers


// >>>>>> Enables >>>>>>

/*
// ram_2_master_2_kara_en ( Delayed 1+(2+DLY_ADDRB_TRIGGER) from tb_2_master_en, the 1 is "delay_in" )
srl_lut  #(
    .WID_DATA                   (1                        ),
    .DLY_NUM                    (3+DLY_ADDRB_TRIGGER      )
    //.DLY_NUM                  (40                       )
) u_srl_ram_2_master_2_kara_en (
    .clk                        (clk                         ),
    .d                          (tb_2_master_en              ),
    .q                          (ram_2_master_2_kara_en      )
    );

// ram_2_master_2_tb_en ( Delayed 1+(2+DLY_ADDRB_TRIGGER) from kara_2_master_en, the 1 is "delay_in" )
srl_lut  #(
    .WID_DATA                   (1                        ),
    .DLY_NUM                    (3+DLY_ADDRB_TRIGGER      )
    //.DLY_NUM                  (40                       )
) u_srl_ram_2_master_2_tb_en (
    .clk                        (clk                         ),
    .d                          (kara_2_master_en            ),
    .q                          (ram_2_master_2_tb_en        )
    );
*/ // Those delays of enables is a waste of resources, we can use counters to replace them

/*
// ram_2_master_2_kara_en ( Delayed 1+(2+DLY_ADDRB_TRIGGER)-1 from tb_2_master_en)
always @(posedge clk) begin
    if(rst=='b1)                                                                                 ram_2_master_2_kara_en_cnt <= 'b0;
    else if(tb_2_master_en && ram_2_master_2_kara_en_cnt=='b0)                                   ram_2_master_2_kara_en_cnt <= ram_2_master_2_kara_en_cnt+'b1;
    else if(ram_2_master_2_kara_en_cnt>'b0 && ram_2_master_2_kara_en_cnt<'d66+DLY_ADDRB_TRIGGER) ram_2_master_2_kara_en_cnt <= ram_2_master_2_kara_en_cnt+'b1;
  //else if(ram_2_master_2_kara_en_cnt>'b0 && ram_2_master_2_kara_en_cnt<'d103)                  ram_2_master_2_kara_en_cnt <= ram_2_master_2_kara_en_cnt+'b1;
    else if(ram_2_master_2_kara_en_cnt=='d66+DLY_ADDRB_TRIGGER)                                  ram_2_master_2_kara_en_cnt <= 'b0;
  //else if(ram_2_master_2_kara_en_cnt=='d103)                                                   ram_2_master_2_kara_en_cnt <= 'b0;

    if(rst=='b1)                                                ram_2_master_2_kara_en <= 'b0;
    else if(ram_2_master_2_kara_en_cnt=='d2+DLY_ADDRB_TRIGGER)  ram_2_master_2_kara_en <= 'b1; // ram_2_master_2_kara_en = 1 lasts 64 clk
  //else if(ram_2_master_2_kara_en_cnt=='d39)                   ram_2_master_2_kara_en <= 'b1;
    else if(ram_2_master_2_kara_en_cnt=='d66+DLY_ADDRB_TRIGGER) ram_2_master_2_kara_en <= 'b0;
  //else if(ram_2_master_2_kara_en_cnt=='d103)                  ram_2_master_2_kara_en <= 'b0;
end

// ram_2_master_2_tb_en ( Delayed 1+(2+DLY_ADDRB_TRIGGER)-1 from kara_2_master_en)
always @(posedge clk) begin
    if(rst=='b1)                                                                             ram_2_master_2_tb_en_cnt <= 'b0;
    else if(kara_2_master_en && ram_2_master_2_tb_en_cnt=='b0)                               ram_2_master_2_tb_en_cnt <= ram_2_master_2_tb_en_cnt+'b1;
    else if(ram_2_master_2_tb_en_cnt>'b0 && ram_2_master_2_tb_en_cnt<'d66+DLY_ADDRB_TRIGGER) ram_2_master_2_tb_en_cnt <= ram_2_master_2_tb_en_cnt+'b1;
  //else if(ram_2_master_2_tb_en_cnt>'b0 && ram_2_master_2_tb_en_cnt<'d103)                  ram_2_master_2_tb_en_cnt <= ram_2_master_2_tb_en_cnt+'b1;
    else if(ram_2_master_2_tb_en_cnt=='d66+DLY_ADDRB_TRIGGER)                                ram_2_master_2_tb_en_cnt <= 'b0;
  //else if(ram_2_master_2_tb_en_cnt=='d103)                                                 ram_2_master_2_tb_en_cnt <= 'b0;

    if(rst=='b1)                                              ram_2_master_2_tb_en <= 'b0;
    else if(ram_2_master_2_tb_en_cnt=='d2+DLY_ADDRB_TRIGGER)  ram_2_master_2_tb_en <= 'b1; // ram_2_master_2_tb_en = 1 lasts 64 clk
  //else if(ram_2_master_2_tb_en_cnt=='d39)                   ram_2_master_2_tb_en <= 'b1;
    else if(ram_2_master_2_tb_en_cnt=='d66+DLY_ADDRB_TRIGGER) ram_2_master_2_tb_en <= 'b0;
  //else if(ram_2_master_2_tb_en_cnt=='d103)                  ram_2_master_2_tb_en <= 'b0;
end
*/ // The code used two counters, which is also a waste of resource, we can rewrite it to use only one counter

always @(posedge clk) begin
    if(rst=='b1)                                                                    ram_2_master_en_cnt <= 'b0;
    else if(tb_2_master_en && ram_2_master_en_cnt=='b0)                             ram_2_master_en_cnt <= ram_2_master_en_cnt+'b1;
    else if(ram_2_master_en_cnt>'b0 && ram_2_master_en_cnt<'d131+DLY_ADDRB_TRIGGER) ram_2_master_en_cnt <= ram_2_master_en_cnt+'b1;
  //else if(ram_2_master_en_cnt>'b0 && ram_2_master_en_cnt<'d168)                   ram_2_master_en_cnt <= ram_2_master_en_cnt+'b1;
    else if(ram_2_master_en_cnt=='d131+DLY_ADDRB_TRIGGER)                           ram_2_master_en_cnt <= 'b0;
  //else if(ram_2_master_en_cnt=='d168)                                             ram_2_master_en_cnt <= 'b0;

    if(rst=='b1) begin
        ram_2_master_2_kara_en <= 'b0;
        ram_2_master_2_tb_en   <= 'b0;
    end else if(ram_2_master_en_cnt=='d2+DLY_ADDRB_TRIGGER)   ram_2_master_2_kara_en <= 'b1; // ram_2_master_2_kara_en = 1 lasts 64 clk
  //end else if(ram_2_master_en_cnt=='d39)                    ram_2_master_2_kara_en <= 'b1;
        else if(ram_2_master_en_cnt=='d66+DLY_ADDRB_TRIGGER)  ram_2_master_2_kara_en <= 'b0;
      //else if(ram_2_master_en_cnt=='d103)                   ram_2_master_2_kara_en <= 'b0;
        else if(ram_2_master_en_cnt=='d67+DLY_ADDRB_TRIGGER)  ram_2_master_2_tb_en   <= 'b1; // ram_2_master_2_tb_en = 1 lasts 64 clk
      //else if(ram_2_master_en_cnt=='d104)                   ram_2_master_2_tb_en   <= 'b1;
        else if(ram_2_master_en_cnt=='d131+DLY_ADDRB_TRIGGER) ram_2_master_2_tb_en   <= 'b0;
      //else if(ram_2_master_en_cnt=='d168)                   ram_2_master_2_tb_en   <= 'b0;
end

// <<<<<< Enables <<<<<<


always @(posedge clk) begin
    if(ram_2_master_2_kara_en || ram_2_master_2_kara_en_1r) begin
        master_2_tb_en   <= ram_2_master_2_kara_en;
        master_2_tb      <= ram_2_master;

        master_2_kara_en <= ram_2_master_2_kara_en;
        master_2_kara    <= ram_2_master;
    end else if(ram_2_master_2_tb_en || ram_2_master_2_tb_en_1r) begin
        master_2_tb_en   <= ram_2_master_2_tb_en;
        master_2_tb      <= ram_2_master;
    end
end

// <<<<<< Stage 2 <<<<<<

endmodule
