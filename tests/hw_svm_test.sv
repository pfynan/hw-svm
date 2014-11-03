module hw_svm_test;

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
    logic        test_valid;
    logic       test_ready;
    logic       label;
    logic       label_valid;
    logic        label_ready;

    hw_svm dut(.*);

    initial begin
        rst = 0;

        @(posedge clk);
        rst <= 1;

        @(posedge clk);
        rst <= 0;

        test <= 'ha24e;

        @(posedge clk);

        @(posedge label_valid);

        $display("l %b \n",label);

        $finish;
    end

endmodule
