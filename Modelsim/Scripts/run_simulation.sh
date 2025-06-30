 #!/bin/sh
rm -rf work
vlib work
vlog +incdir+tb/ -sv ../generated_tbs/verified_accu/tb/testbench.sv ../generated_tbs/verified_accu/rtl/*.sv
vsim -voptargs=+acc -c work.tbench_top -do "run -all; exit"
gtkwave counter.vcd scounter.gtkw