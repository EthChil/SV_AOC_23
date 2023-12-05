`timescale 1 ps / 1 ps

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

`define NUM_LINES 100

module day2pt1 #(
  parameter RED_CNT = 12,
  parameter GREEN_CNT = 13,
  parameter BLUE_CNT = 14
) (
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

logic [$clog2(`NUM_LINES)-1:0] line_count;
logic [31:0] acc;
logic [7:0] read_val;
logic [3:0] num_shift;

logic is_number, is_space;
logic is_valid;

assign is_number = (tdata_rx <= `UPPER_BOUND_NUM && tdata_rx >= `LOWER_BOUND_NUM);
assign is_space = (tdata_rx == `SPACE);
assign num_shift = (tdata_rx - 8'h30);


typedef enum {PARSE_FRONT, READ_NUMBER_1, READ_NUMBER_2, READ_COLOUR, OUTPUT_RESULT} state_t;

// state machine register
state_t state;

always @(posedge clk) begin
  if(rst) begin
    // reset state and accumulator
    state <= PARSE_FRONT;
    acc <= '0;

    // internal regs
    read_val <= '0;
    is_valid <= 1'b0;
    line_count <= 1;

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