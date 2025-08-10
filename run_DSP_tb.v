vlib work
vlog DSP_tb.v DSP.v Reg&Mux.v
vsim -voptargs=+acc work.DSP_tb.v
add wave *
run -all
#quit -sim