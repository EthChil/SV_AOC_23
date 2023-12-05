day2-build:
	python3 mem_maker.py
	verilator --build --exe --cc --trace \
		-Wno-COMBDLY -Wno-Width \
		--top-module dut_tb \
                dut_tb.sv day2pt2.sv day2pt1.sv dut_tb.cpp \
		--Mdir $(shell pwd)/dut_tb \
		-o dut_tb

day2-test: day2-build
	./dut_tb/dut_tb

day2-lint:
	verilator -Wall --lint-only day2pt1.sv day2pt2.sv