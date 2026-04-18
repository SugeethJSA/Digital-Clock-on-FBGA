module clock_divider(
    input clk,
    input reset,
    output reg tick_1s
);

reg [25:0] count;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        count <= 0;
        tick_1s <= 0;
    end else begin
        if (count == 50_000_000 - 1) begin
            count <= 0;
            tick_1s <= 1;
        end else begin
            count <= count + 1;
            tick_1s <= 0;
        end
    end
end

endmodule

module segment(
    input [3:0] count,
    output reg [6:0] seg   
);

always @(*) begin
    case (count)
        4'd0: seg = 7'b1000000;
        4'd1: seg = 7'b1111001;
        4'd2: seg = 7'b0100100;
        4'd3: seg = 7'b0110000;
        4'd4: seg = 7'b0011001;
        4'd5: seg = 7'b0010010;
        4'd6: seg = 7'b0000010;
        4'd7: seg = 7'b1111000;
        4'd8: seg = 7'b0000000;
        4'd9: seg = 7'b0010000;
        default: seg = 7'b1111111;
    endcase
end

endmodule


module time_counter(
    input clk,
    input reset,
    output reg [3:0] sec_units,
    output reg [2:0] sec_tens,
    output reg [3:0] min_units,
    output reg [2:0] min_tens
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        sec_units <= 0;
        sec_tens <= 0;
        min_units <= 0;
        min_tens <= 0;
    end else begin

        // Seconds units
        if (sec_units == 9) begin
            sec_units <= 0;

            // Seconds tens
            if (sec_tens == 5) begin
                sec_tens <= 0;

                // Minutes units
                if (min_units == 9) begin
                    min_units <= 0;

                    // Minutes tens
                    if (min_tens == 5)
                        min_tens <= 0;
                    else
                        min_tens <= min_tens + 1;

                end else begin
                    min_units <= min_units + 1;
                end

            end else begin
                sec_tens <= sec_tens + 1;
            end

        end else begin
            sec_units <= sec_units + 1;
        end

    end
end

endmodule

module top(
    input clk,
    input reset,
    output [6:0] seg0, // sec units
    output [6:0] seg1, // sec tens
    output [6:0] seg2, // min units
    output [6:0] seg3  // min tens
);

wire tick_1s;

wire [3:0] sec_units, min_units;
wire [2:0] sec_tens, min_tens;

// Clock divider
clock_divider cd(clk, reset, tick_1s);

// Time counter
time_counter tc(
    tick_1s,
    reset,
    sec_units,
    sec_tens,
    min_units,
    min_tens
);

// Segment decoders
segment s0(sec_units, seg0);
segment s1({1'b0, sec_tens}, seg1);
segment s2(min_units, seg2);
segment s3({1'b0, min_tens}, seg3);

endmodule