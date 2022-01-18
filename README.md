# kara_simpDualRAM

An modified version of [128 bit Pipelined Karatsuba Multiplier based on DSP48 IP](https://github.com/lutianyu2001/kara_128_pipe_dsp48) with a simple dual port BRAM added, the data will firstly be inputted into BRAM, each time when the BRAM are full, it output the data to multiplier in pipelined, and the multiplication result will be input into the BRAM again.

Language: Verilog

Platform: Xilinx Vivado 2018.3 + ModelSIM 10.6d
