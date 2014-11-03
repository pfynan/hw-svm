module hw_svm (
    input logic clk,
    input logic rst,
    input logic signed [31:0] test,
    input logic        test_valid,
    output logic       test_ready,
    output logic       label,
    output logic       label_valid,
    input logic        label_ready);

    logic signed [31:0] support_vectors[31:0];

    logic signed [31:0] alpha[31:0];

    initial begin
        $readmemh("svm.hex",support_vectors);
        $readmemh("weights.hex",alpha);
    end

    logic [4:0] cur_vector;

    enum {BEGIN,RUNNING,DONE} s,ns;

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            s <= BEGIN;
        end
        else begin
            s <= ns;
        end
    end

    always_comb case(s)
        BEGIN: ns = test_valid & test_ready ? RUNNING : BEGIN;
        RUNNING: ns = cur_vector == '1 ? DONE : RUNNING;
        DONE: ns = test_valid & test_ready ? RUNNING : DONE;
    endcase

    logic [31:0] my_test;

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            my_test <= '0;
        end
        else if(test_valid & test_ready) begin
            my_test <= test;
        end
    end

    assign test_ready = s == BEGIN | s == DONE;
    assign label_valid = s == DONE;

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            cur_vector <= '0;
        end else if(s == RUNNING) begin
            cur_vector <= cur_vector + 1;
        end else begin
            cur_vector <= '0;
        end
    end

    logic signed [31:0] accum;

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            accum <= '0;
        end else if(s == RUNNING) begin
            accum <= accum + alpha[cur_vector] * ( support_vectors[cur_vector]
                                                 * my_test);
        end
    end

    assign label = ~accum[31];


endmodule

