
testbench:  bfp_converter.sv tb.sv
	iverilog -g2012 -o testbench -D DEBUG bfp_converter.sv tb.sv

test: testbench
	vvp -N testbench +vcd

show:
	gtkwave testbench.vcd testbench.gtkw >> gtkwave.log 2>&1 &


clean:
	rm -rf testbench testbench.vcd gtkwave.log
