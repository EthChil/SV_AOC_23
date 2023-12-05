`timescale 1 ps / 1 ps

// day sepcific
`define LINE_LEN 140
`define NUM_PTR 16

`define LOWER_BOUND_NUM 8'h30
`define UPPER_BOUND_NUM 8'h39

//`define RED {8'h72, 8'h65, 8'h64}
//`define BLUE {8'h62, 8'h6C, 8'h75, 8'h65}
//`define GREEN {8'h67, 8'h72, 8'h65, 8'h65, 8'h6E}
`define RED   8'h72
`define BLUE  8'h62
`define GREEN 8'h67

// 237 too low
// 247 too low

`define SPACE 8'h20
`define PERIOD 8'h2E

`define NUM_LINES 100

module day3pt1 (
  input  logic clk,
  input  logic rst,

  // axis input
  input logic tvalid_rx,
  output logic tready_rx,
  input logic [7:0] tdata_rx,
  input logic tlast_rx,

  // axis output
  output logic tvalid_tx,
  input logic tready_tx,
  output logic [31:0] tdata_tx,
  output logic tlast_tx
);

// 3 line buffers this stores unmatched digits ptr locations
logic [`LINE_LEN-1:0][$clog2(`NUM_PTR)-1:0] pipe [3];

// memory holds the values of pointers assume no number is larger than 32 bits
logic [31:0] memory [`NUM_PTR];
logic [$clog2(`NUM_PTR)-1:0] ptr; // ptr is current pointer location to use

// parse_pipe holds the pipe line being read in currently
logic [`LINE_LEN-1:0][$clog2(`NUM_PTR)-1:0] parse_pipe;

logic [31:0] acc;
logic [7:0] read_val;
logic [3:0] num_shift;

logic is_number, is_space, is_period;

assign is_number = (tdata_rx <= `UPPER_BOUND_NUM && tdata_rx >= `LOWER_BOUND_NUM);
assign is_space = (tdata_rx == `SPACE);
assign is_period = (tdata_rx == `PERIOD);
assign num_shift = (tdata_rx - 8'h30);

typedef enum {PARSE, HANDLE_PART, ACCUM_PART, SHIFT_PIPE, OUTPUT_RESULT} state_t;

// PARSE -> actively reading into the parse_pipe and looking for parts on middle row (part is read to an FF)
// HANLDE_PART -> when a part is seen jump to handle part which will increment cell_loc and jump to accumulate part
// ACCUM_PART -> resolve pointer and accumulate jumps back to handle part
// SHIFT_PIPE -> once line is parsed shift the pipe up

// PARSE <-> HANDLE_PART <-> ACCUM_PART
// HANDLE_PART will jump to OUTPUT_RESULT once all lines are parsed

// state machine register
state_t state;

always @(posedge clk) begin
  if(rst) begin
    // reset state and accumulator
    state <= PARSE;
    acc <= '0;

    ptr <= '0;

    for(integer i = 0; i < `LINE_LEN; i = i + 1) begin
      pipe[0][i] = 8'd0;
      pipe[1][i] = 8'd0;
    end
    for(integer i = 0; i < `NUM_PTR; i = i + 1) begin
      memory[i] = 32'd0;
    end

    // AXI-S slave
    tready_rx <= 1'b0;

    // AXI-S master
    tlast_tx <= 1'b0;
    tdata_tx <= '0;
    tvalid_tx <= 1'b0;
  end else begin
    case (state)
      PARSE_FRONT: begin
        tready_rx <= 1'b1;
        is_valid <= 1'b1;

        // this is the character for ':'
        if(tvalid_rx && tdata_rx == 8'h3A) begin
          state <= READ_NUMBER_1;
        end
        if(tready_tx) begin
          state <= OUTPUT_RESULT;
        end
      end
      READ_NUMBER_1: begin
        tready_rx <= 1'b1;

        if(tvalid_rx && is_number) begin
          read_val <= num_shift;

          state <= READ_NUMBER_2;
        end
        if(tlast_rx) begin
          state <= PARSE_FRONT;

          if(is_valid) begin
            acc <= acc + line_count;
          end
          line_count <= line_count + 1;
        end
      end
      READ_NUMBER_2: begin
        tready_rx <= 1'b1;

        if(tvalid_rx) begin
          if(is_number) begin
            read_val <= (read_val * 10) + num_shift;
          end

          state <= READ_COLOUR;
        end
      end
      READ_COLOUR: begin
        tready_rx <= 1'b1;

        if(tvalid_rx && ~is_space) begin
          if(`RED == tdata_rx && read_val > RED_CNT) begin
            is_valid <= 1'b0;
          end
          if(`BLUE == tdata_rx && read_val > BLUE_CNT) begin
            is_valid <= 1'b0;
          end
          if(`GREEN == tdata_rx && read_val > GREEN_CNT) begin
            is_valid <= 1'b0;
          end

          state <= READ_NUMBER_1;
        end
      end
      OUTPUT_RESULT: begin
        tready_rx <= 1'b0;
        tvalid_tx <= 1'b1;
        tdata_tx <= acc;
        tlast_tx <= 1'b1;
      end
      default: state <= PARSE_FRONT;
    endcase
  end
end



endmodule