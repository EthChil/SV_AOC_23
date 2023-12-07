//#include <bits/stdint-uintn.h>
#include <cstddef>
#include <cstdint>
#include <ios>
#include <iostream>
#include <random>
#include <array>
#include <queue>
#include <utility>

#include <verilated.h>
#include "verilated_vcd_c.h"


#include <Vdut_tb.h>


constexpr vluint64_t maxtime = 100000;
static vluint64_t time_stamp = 0;


double sc_time_stamp() {
    return static_cast<double>(time_stamp);
}

class DutTb {

public:
    DutTb() 
        : dut_tb(new Vdut_tb)
    {
        dut_tb->clk = 0;
        dut_tb->rst = 1;
        enableTrace();
    }

    void enableTrace() {
        vtrace = new VerilatedVcdC();
        dut_tb->trace(vtrace, 0);
        vtrace->open("sim.vcd");
    }

    ~DutTb() {
        dut_tb->final();
        delete dut_tb;

        vtrace->flush();
        vtrace->close();
        delete vtrace;
    }

    void half_tick() {

        dut_tb->eval();
        dut_tb->clk = !dut_tb->clk;
        dut_tb->eval();

        vtrace->dump(time_stamp);
        
     
        time_stamp++;
    }

    void tick() {
        // Toggle the clock edge twice

        half_tick();
        half_tick();
    }

    void initial() {
        dut_tb->rst = 1;

        dut_tb->eval();
        
        vtrace->dump(time_stamp);
        
        time_stamp++;

        dut_tb->eval();
        tick();

        dut_tb->eval();
        tick();

        // Release reset
        dut_tb->rst = 0;
        dut_tb->eval();
        tick();
    }

    void test() {
        while(!Verilated::gotFinish() && time_stamp < maxtime){
            tick();
        }
    }



private:
    Vdut_tb* dut_tb;
    VerilatedVcdC* vtrace;

   
};


int main(int argc, char* argv[]) {

    Verilated::traceEverOn(true);
    Verilated::commandArgs(argc, argv);

    DutTb tb;

    tb.initial();
    tb.test();

    if (time_stamp >= maxtime) {
        std::cerr << "Timed out!";
        return -1;
    }

    return 0;
}