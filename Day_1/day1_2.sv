`timescale 1 ps / 1 ps

`define LOWER_BOUND 8'h30
`define UPPER_BOUND 8'h39

`define LOWER_BOUND_TXT 8'h61
`define UPPER_BOUND_TXT 8'h7A

`define ZERO  {8'h7A, 8'h65, 8'h72, 8'h6f}
`define ONE   {8'h6F, 8'h6E, 8'h65}
`define TWO   {8'h74, 8'h77, 8'h6F}
`define THREE {8'h74, 8'h68, 8'h72, 8'h65, 8'h65}
`define FOUR  {8'h66, 8'h6f, 8'h75, 8'h72}
`define FIVE  {8'h66, 8'h69, 8'h76, 8'h65}
`define SIX   {8'h73, 8'h69, 8'h78}
`define SEVEN {8'h73, 8'h65, 8'h76, 8'h65, 8'h6E}
`define EIGHT {8'h65, 8'h69, 8'h67, 8'h68, 8'h74}
`define NINE  {8'h6E, 8'h69, 8'h6E, 8'h65}

module day1_2 (
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

logic [4:0][7:0] sliding_window;

// convienient functions
logic is_number;
logic [7:0] num_shift;

assign is_number = (tdata_rx <= `UPPER_BOUND && tdata_rx >= `LOWER_BOUND);
assign num_shift = (tdata_rx - 8'h30);

logic [3:0] text_num;
logic [3:0] text_num_3;
logic [3:0] text_num_4;
logic [3:0] text_num_5;
logic is_number_text;

// decode the sliding window values into digits with a single hot bit if there is a valid digit decoded
always_comb begin
  case({sliding_window[1:0], tdata_rx})
    `ONE: text_num_3 = 4'h1;
    `TWO: text_num_3 = 4'h2;
    `SIX: text_num_3 = 4'h6;
    default: text_num_3 = 4'hF;
  endcase

  case({sliding_window[2:0], tdata_rx})
    `ZERO: text_num_4 = 4'h0;
    `FOUR: text_num_4 = 4'h4;
    `FIVE: text_num_4 = 4'h5;
    `NINE: text_num_4 = 4'h9;
    default: text_num_4 = 4'hF;
  endcase

  case({sliding_window[3:0], tdata_rx})
    `THREE: text_num_5 = 4'h3;
    `SEVEN: text_num_5 = 4'h7;
    `EIGHT: text_num_5 = 4'h8;
    default: text_num_5 = 4'hF;
  endcase

  assign is_number_text = (text_num_3 != 4'hF || text_num_4 != 4'hF || text_num_5 != 4'hF);

  if(text_num_3 != 4'hF) text_num = text_num_3;
  else if(text_num_4 != 4'hF) text_num = text_num_4;
  else if(text_num_5 != 4'hF) text_num = text_num_5;
end

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

    for(integer i = 0; i < 5; i = i + 1) begin
      sliding_window[i] <= '0;
    end
  end else begin
    case (state)
      FIRST_DIG_SEARCH: begin
        tready_rx <= 1'b1;
        if(tvalid_rx) sliding_window <= {sliding_window[3:0], tdata_rx};

        if(tvalid_rx && (is_number || is_number_text)) begin
          if(is_number) begin
            first_dig <= num_shift[3:0];
          end

          if(is_number_text) begin
            first_dig <= text_num;
          end

          if(tlast_rx) begin
            state <= DO_MAC;
            tready_rx <= 1'b0;
          end
          else state <= SECOND_DIG_SEARCH;
        end
      end
      SECOND_DIG_SEARCH: begin
        tready_rx <= 1'b1;
        if(tvalid_rx) sliding_window <= {sliding_window[3:0], tdata_rx};

        if(tvalid_rx && (is_number || is_number_text)) begin
          if(is_number) begin
            second_dig <= num_shift[3:0];
          end

          if(is_number_text) begin
            second_dig <= text_num;
          end
        end

        if(tlast_rx) begin
          tready_rx <= 1'b0;
          state <= DO_MAC;
        end
      end
      DO_MAC: begin
        // tready_rx <= 1'b0;
        // reset the sliding window
        for(integer i = 0; i < 5; i = i + 1) begin
          sliding_window[i] <= '0;
        end

        if(second_dig == 4'hF) begin
          acc <= acc + (first_dig * 4'd10) + first_dig;
        end
        else acc <= acc + (first_dig * 4'd10) + second_dig;

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

