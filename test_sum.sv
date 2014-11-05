module test_sum (
     input logic clk,
     input logic rst,
     input logic signed [31:0] test,
     input logic signed [31:0] support_vector,
     input logic signed [31:0] alpha,
     input logic in_valid,
     input logic in_start,
     input logic in_end,
     input logic vector_start,
     input logic vector_end,
     output logic label,
     output logic label_valid
);

    logic signed [31:0] k;
    logic k_valid;

    kernel K
        (.clk(clk)
        ,.rst(rst)
        ,.test(test)
        ,.support(support_vector)
        ,.in_valid(in_valid)
        ,.in_start(vector_start)
        ,.in_end(vector_end)
        ,.out(k)
        ,.out_valid(k_valid)
        );

    logic k_start,k_end;

    delay_signal delay_start
        (.clk(clk)
        ,.rst(rst)
        ,.capture_l(in_start & in_valid)
        ,.release_l(k_valid)
        ,.out(k_start)
        );

    delay_signal delay_end
        (.clk(clk)
        ,.rst(rst)
        ,.capture_l(in_end & in_valid)
        ,.release_l(k_valid)
        ,.out(k_end)
        );


    logic signed [31:0] accum;

    enum {WAIT,RUNNING,DONE} s,ns;

    always_comb case(s)
        WAIT: ns = k_start ? RUNNING : WAIT;
        RUNNING: ns = k_end ? DONE : RUNNING;
        DONE: ns = k_start ? RUNNING : DONE;
    endcase

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            s <= WAIT;
        end
        else begin
            s <= ns;
        end
    end

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            label_valid <= 0;
        end else if(ns == DONE && s == RUNNING) begin
            label_valid <= 1;
        end else begin
            label_valid <= 0;
        end
    end

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            accum <= 0;
        end else if(s == WAIT && ns == RUNNING) begin
            accum <= alpha * k;
        end else if(s == RUNNING && ns == RUNNING) begin
            accum <= accum + alpha * k;
        end
    end

    assign label = ~accum[31];

   
endmodule: test_sum
