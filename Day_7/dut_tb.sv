`timescale 1 ps / 1 ps

`define FILE_NAME "day7.mem"

// `define MEM_LENGTH 9893
`define MEM_LENGTH 49
// `define PART2
`define PART1

module dut_tb
(
    input wire clk,
    input wire rst
);

logic [$clog2(`MEM_LENGTH)-1:0] ptr;
logic [7:0] mem0 [0:`MEM_LENGTH];
logic [31:0] result [7:0];

// into DUT
logic tvalid_rx;
logic tready_rx;
logic [7:0] tdata_rx;
logic tlast_rx;

// out of DUT
logic tvalid_tx;
logic tready_tx;
logic [31:0] tdata_tx;
logic tlast_tx;

typedef enum {WRITE, READ} state_t;

state_t state;

initial begin
  $readmemh(`FILE_NAME, mem0);
end

always @(negedge clk) begin
  if(rst) begin
    ptr <= '0;
    tvalid_rx <= 1'b0;
    tready_tx <= 1'b0;
    tdata_rx <= '0;
    tlast_rx <= 1'b0;
  end else begin
    case(state)
      WRITE: begin
        if(ptr == `MEM_LENGTH) begin
            state <= READ;
            tvalid_rx <= 1'b0;
            tready_tx <= 1'b1;
        end else begin
            tvalid_rx <= 1'b1;
            tdata_rx <= mem0[ptr];

            if(mem0[ptr+1] == 8'hFF) tlast_rx <= 1'b1;
            else tlast_rx <= 1'b0;

            if(tready_rx) begin
              if(mem0[ptr+1] == 8'hFF) ptr <= ptr + 2;
              else ptr <= ptr + 1;
            end
        end
      end
      READ: begin
        tready_tx <= 1'b1;

        result[0] <= tdata_tx;

        if(tvalid_tx) ptr <= '0;

        if(ptr == '0)
            $finish;
      end
      default: begin
        state <= WRITE;
      end
    endcase
  end
end

`ifdef PART1
day7pt1 dut (
  .clk(clk),
  .rst(rst),

  // axis input
  .tvalid_rx(tvalid_rx),
  .tready_rx(tready_rx),
  .tdata_rx(tdata_rx),
  .tlast_rx(tlast_rx),

  // axis output
  .tvalid_tx(tvalid_tx),
  .tready_tx(tready_tx),
  .tdata_tx(tdata_tx),
  .tlast_tx(tlast_tx)
);
`endif

`ifdef PART2
day7pt2 dut (
  .clk(clk),
  .rst(rst),

  // axis input
  .tvalid_rx(tvalid_rx),
  .tready_rx(tready_rx),
  .tdata_rx(tdata_rx),
  .tlast_rx(tlast_rx),

  // axis output
  .tvalid_tx(tvalid_tx),
  .tready_tx(tready_tx),
  .tdata_tx(tdata_tx),
  .tlast_tx(tlast_tx)
);
`endif



  final begin
    $writememb("result.mem", result);
  end

endmodule
