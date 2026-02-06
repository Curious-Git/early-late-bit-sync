`timescale 1ns / 1ps

module tb_early_late;

    localparam DATA_WIDTH = 8;
    localparam SAMPLES_PER_BIT = 250;

    reg clk = 0;
    always #5 clk = ~clk;   // 100 MHz

    reg rst;
    reg signed [DATA_WIDTH-1:0] data_in;

    wire bit_clk;
    wire lock;

    early_late_bitsync #(
        .DATA_WIDTH(DATA_WIDTH),
        .SAMPLES_PER_BIT(SAMPLES_PER_BIT)
    ) dut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .bit_clk(bit_clk),
        .lock(lock)
    );

    initial begin
        rst = 1;
        data_in = 8'sd28;

        #100;
        rst = 0;

        // EXPLICIT bit pattern
        #2500 data_in = -28;
        #2500 data_in =  28;
        #2500 data_in = -28;
        #2500 data_in =  28;
        #2500 data_in = -28;
        #2500 data_in =  28;
        #20000 $finish;
        

    end
    always @(data_in)
    $display("Time=%0t ns  data_in=%d", $time, data_in);

endmodule
