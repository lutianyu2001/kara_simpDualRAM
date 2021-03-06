######################################################################
#
# File name : tb_kara_128bit_simulate.do
# Created on: Tue Sep 08 19:57:24 +0800 2020
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vsim -voptargs="+acc" -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm -lib xil_defaultlib xil_defaultlib.tb_kara_128bit xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {tb_kara_128bit_wave.do}

view wave
view structure
view signals

log -r /*

do {tb_kara_128bit.udo}

run 500ns
