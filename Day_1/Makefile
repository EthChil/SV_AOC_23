day1-build:
# -Wno-COMBDLY supresses warnings that appear when using non-blocking
# assignments in combinational logic blocks.
# See V3Error.h and V3Error.cpp for more details and
# justification on why this is safe.
	verilator --build --exe --cc --trace \
		-Wno-COMBDLY -Wno-Width \
		--top-module dut_tb \
                dut_tb.sv day1.sv dut_tb.cpp \
		--Mdir $(shell pwd)/dut_tb \
		-o dut_tb

day1-test: day1-build
	./dut_tb/dut_tb

day1-lint:
	verilator -Wall --lint-only day1.sv