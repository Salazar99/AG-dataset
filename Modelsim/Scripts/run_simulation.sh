 #!/bin/sh
rm -rf work
vlib work
vlog +incdir+tb/ -sv ../generated_tbs/comparator_3bit/tb/testbench.sv ../generated_tbs/comparator_3bit/rtl/*.sv
vsim -voptargs=+acc -c work.tbench_top -do "run -all; exit"