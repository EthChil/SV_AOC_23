`timescale 1 ps / 1 ps

`define LOWER_BOUND 8'h30
`define UPPER_BOUND 8'h39

`define RED {8'h72, 8'h65, 8'h64}
`define BLUE {8'h62, 8'h6C, 8'h75, 8'h65}
`define GREEN {8'h67, 8'h72, 8'h65, 8'h65, 8'h6E}

`define NUM_LINES 100

module day2pt1 #(
  parameter RED = 12,
  parameter GREEN = 13,
  parameter BLUE = 14
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
  output logic [7:0] tdata_tx,
  output logic tlast_tx
);

logic [$clog2(`NUM_LINES)-1:0] line_count;
logic [31:0] acc;
logic [6:0] read_val;

logic is_number;

assign is_number = (tdata_rx <= `UPPER_BOUND && tdata_rx >= `LOWER_BOUND);

typedef enum {PARSE_FRONT, READ_COLOUR, READ_NUMBER_1, READ_NUMBER_2, OUTPUT_RESULT} state_t;

// state machine register
state_t state;

always @(posedge clk) begin
  if(rst) begin
    state <= FIRST_DIG_SEARCH;
    acc <= '0;

    read_val <= '0;

    tready_rx <= 1'b0;
    first_dig <= 4'h0;
    second_dig <= 4'hF;

    tlast_tx <= 1'b0;
    tdata_tx <= '0;
    tvalid_tx <= 1'b0;
  end else begin
    case (state)
      PARSE_FRONT: begin
        tready_rx <= 1'b1;

        if(tvalid_rx && tdata_rx == 8'h3A) begin
          state <= READ_NUMBER;
        end
      end
      READ_NUMBER_1: begin
        tready_rx <= 1'b1;

        if(tvalid_rx && is_number) begin
          read_val <= tdata_rx * 10;
          state <= READ_NUMBER_2;
        end
      end
      READ_NUMBER_2: begin
        tready_rx <= 1'b1;

        if(tvalid_rx)
          if(is_number) begin
            read_val <= tdata_rx;
          end else begin
            state <= l;
          end
        end

        if(tlast_rx) begin
          tready_rx <= 1'b0;
          state <= DO_MAC;
        end
      end
      READ_NUMBER: begin
        // tready_rx <= 1'b0;

        if(second_dig == 4'hF) begin
          acc <= acc + (first_dig * 4'd10) + {28'd0, first_dig};
        end
        else acc <= acc + (first_dig * 4'd10) + {28'd0, second_dig};

        second_dig <= 4'hF;
        first_dig <= 4'h0;

        if(tready_tx) state <= OUTPUT_RESULT;
        else begin
          tready_rx <= 1'b1;
          state <= FIRST_DIG_SEARCH;
        end
      end
      OUTPUT_RESULT: begin
        tready_rx <= 1'b0;
        tvalid_tx <= 1'b1;
        tdata_tx <= acc;
        tlast_tx <= 1'b1;
      end
      default: state <= FIRST_DIG_SEARCH;
    endcase
  end
end



endmodule

