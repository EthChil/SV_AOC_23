day1-build:
	verilator --build --exe --cc --trace \
		-Wno-COMBDLY -Wno-Width \
		--top-module dut_tb \
                dut_tb.sv day1_2.sv day1.sv dut_tb.cpp \
		--Mdir $(shell pwd)/dut_tb \
		-o dut_tb

day1-test: day1-build
	./dut_tb/dut_tb

day1-lint:
	verilator -Wall --lint-only day1.sv day1_2.sv