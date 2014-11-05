module kernel_test;

timeunit 1ns;
timeprecision 1ps;
logic clk;
logic rst;

initial begin
    clk = 0;
    // Clock at 50Mhz
    forever #10 clk = ~clk;
end

logic signed [31:0] test;
logic signed [31:0] support;

logic in_start;
logic in_end;
logic in_valid;
logic in_ready;

logic signed [31:0] out;
logic out_valid;

kernel dut(.*);

initial begin
    rst = 0;
    @(posedge clk);

    rst <= 1;
    @(posedge clk);

    rst <= 0;
    test <= -1;
    support <= 10;
    in_start <= 1;
    in_valid <= 1;
    @(posedge clk);

    in_start <= 0;
    test <= 5;
    support <= 3;
    in_end <= 1;
    @(posedge clk);

    in_end <= 0;
    in_valid <= 0;
    @(posedge clk);

    $display("Valid: %b\nOut: %d\n",out_valid,out);
    $finish;
end




endmodule

