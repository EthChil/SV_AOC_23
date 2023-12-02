`timescale 1 ps / 1 ps

`define LOWER_BOUND 8'h30
`define UPPER_BOUND 8'h39

module day1 (
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

typedef enum {FIRST_DIG_SEARCH, SECOND_DIG_SEARCH, DO_MAC, OUTPUT_RESULT} state_t;

// state machine register
state_t state;

// accumulator with the output value
logic [31:0] acc;

// digit registers
logic [3:0] first_dig;
logic [3:0] second_dig;

// convienient functions
logic is_number;
logic [3:0] num_shift;

assign is_number = (tdata_rx <= `UPPER_BOUND && tdata_rx >= `LOWER_BOUND);

assign num_shift = (tdata_rx - 8'h30);

always @(posedge clk) begin
  if(rst) begin
    state <= FIRST_DIG_SEARCH;
    acc <= '0;
    tready_rx <= 1'b0;
    first_dig <= 4'h0;
    second_dig <= 4'hF;

    tlast_tx <= 1'b0;
    tdata_tx <= '0;
    tvalid_tx <= 1'b0;
  end else begin
    case (state)
      FIRST_DIG_SEARCH: begin
        tready_rx <= 1'b1;
        if(tvalid_rx && is_number) begin
          first_dig <= num_shift[3:0];

          if(tlast_rx) begin
            state <= DO_MAC;
            tready_rx <= 1'b0;
          end
          else state <= SECOND_DIG_SEARCH;
        end
      end
      SECOND_DIG_SEARCH: begin
        tready_rx <= 1'b1;

        if(tvalid_rx && is_number) begin
          second_dig <= num_shift[3:0];
        end

        if(tlast_rx) begin
          tready_rx <= 1'b0;
          state <= DO_MAC;
        end
      end
      DO_MAC: begin
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

