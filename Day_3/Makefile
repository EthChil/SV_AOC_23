mem:
	python3 mem_maker.py

day3-build: build-mem
	verilator --build --exe --cc --trace \
		-Wno-COMBDLY -Wno-Width \
		--top-module dut_tb \
                dut_tb.sv day3pt2.sv day3pt1.sv dut_tb.cpp \
		--Mdir $(shell pwd)/dut_tb \
		-o dut_tb

day3-test: day3-build
	./dut_tb/dut_tb

day3-lint:
	verilator -Wall --lint-only day3pt1.sv day3pt2sv