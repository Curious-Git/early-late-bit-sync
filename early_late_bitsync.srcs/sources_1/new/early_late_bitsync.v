`timescale 1ns / 1ps

module early_late_bitsync #
(
    parameter DATA_WIDTH = 8,
    parameter SAMPLES_PER_BIT = 250
)
(
    input  wire                         clk,
    input  wire                         rst,
    input  wire signed [DATA_WIDTH-1:0] data_in,

    output reg                          bit_clk,   // bit strobe
    output reg                          lock
);

localparam COUNTER_WIDTH = $clog2(SAMPLES_PER_BIT);

// -------------------------------------------------
// Sample counter (defines one bit period)
// -------------------------------------------------
reg [COUNTER_WIDTH-1:0] sample_cnt;

always @(posedge clk) begin
    if (rst)
        sample_cnt <= 0;
    else if (sample_cnt == SAMPLES_PER_BIT-1)
        sample_cnt <= 0;
    else
        sample_cnt <= sample_cnt + 1;
end

// -------------------------------------------------
// Bit slicer (CENTER of bit)
// -------------------------------------------------
reg current_bit;

always @(posedge clk) begin
    if (rst)
        current_bit <= 0;
    else if (sample_cnt == (SAMPLES_PER_BIT >> 1))
        current_bit <= (data_in >= 0);
end

// -------------------------------------------------
// Transition detector (key fix)
// -------------------------------------------------
reg prev_bit;
wire transition;

always @(posedge clk) begin
    if (rst)
        prev_bit <= 0;
    else if (sample_cnt == (SAMPLES_PER_BIT >> 1))
        prev_bit <= current_bit;
end

assign transition = current_bit ^ prev_bit;

// -------------------------------------------------
// Early / Late gates
// -------------------------------------------------
wire early_en = (sample_cnt >= SAMPLES_PER_BIT/4) &&
                (sample_cnt <  SAMPLES_PER_BIT/2);

wire late_en  = (sample_cnt >= SAMPLES_PER_BIT/2) &&
                (sample_cnt <  (3*SAMPLES_PER_BIT)/4);

// -------------------------------------------------
// Early / Late accumulators (TRANSITION ENERGY)
// -------------------------------------------------
reg signed [15:0] early_acc, late_acc;

always @(posedge clk) begin
    if (rst) begin
        early_acc <= 0;
        late_acc  <= 0;
    end else begin
        if (early_en && transition)
            early_acc <= early_acc + 1;

        if (late_en && transition)
            late_acc <= late_acc + 1;

        if (sample_cnt == SAMPLES_PER_BIT-1) begin
            early_acc <= 0;
            late_acc  <= 0;
        end
    end
end

// -------------------------------------------------
// Phase detector
// -------------------------------------------------
reg signed [16:0] phase_error;

always @(posedge clk) begin
    if (rst)
        phase_error <= 0;
    else if (sample_cnt == SAMPLES_PER_BIT-1)
        phase_error <= early_acc - late_acc;
end

// -------------------------------------------------
// Loop filter (PI)
// -------------------------------------------------
reg signed [23:0] integrator;
reg signed [23:0] lf_out;

always @(posedge clk) begin
    if (rst) begin
        integrator <= 0;
        lf_out     <= 0;
    end else if (sample_cnt == SAMPLES_PER_BIT-1) begin
        integrator <= integrator + (phase_error >>> 6);
        lf_out     <= (phase_error >>> 3) + integrator;
    end
end

// -------------------------------------------------
// DCO
// -------------------------------------------------
reg [31:0] phase_acc;
localparam BASE_STEP = 32'd17179869;

always @(posedge clk) begin
    if (rst)
        phase_acc <= 0;
    else
        phase_acc <= phase_acc + BASE_STEP + lf_out;
end

// -------------------------------------------------
// Bit clock strobe (NOT free-running clock)
// -------------------------------------------------
always @(posedge clk) begin
    bit_clk <= (phase_acc[31] && !phase_acc[30]);
end

// -------------------------------------------------
// Lock detector
// -------------------------------------------------
reg [7:0] lock_cnt;

always @(posedge clk) begin
    if (rst) begin
        lock_cnt <= 0;
        lock     <= 0;
    end else if ((phase_error < 2 && phase_error > -2) && transition) begin
        if (lock_cnt < 50)
            lock_cnt <= lock_cnt + 1;
        else
            lock <= 1;
    end else begin
        lock_cnt <= 0;
        lock     <= 0;
    end
end

endmodule
