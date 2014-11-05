module hw_svm (
    input logic clk,
    input logic rst,
    input logic start,
    output logic       label,
    output logic       label_valid
    );

    localparam int Features = 13;
    localparam int Vectors = 25;

    logic signed [31:0] support;
    logic signed [31:0] alpha;
    logic signed [31:0] test;

     logic [31:0] next_vector;
     logic [31:0] next_feat;
     logic addr_valid;
     logic addr_start;
     logic addr_stop;

     mem_counter #(Features,Vectors) ctr
        (.clk(clk)
        ,.rst(rst)
        ,.start(start)
        ,.next_vector(next_vector)
        ,.next_feat(next_feat)
        ,.addr_valid(addr_valid)
        ,.addr_start(addr_start)
        ,.addr_stop(addr_stop)
        );

    logic sum_valid;
    logic sum_start;
    logic sum_stop;

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            sum_valid <= 0;
            sum_start <= 0;
            sum_stop <= 0;
        end
        else begin
            sum_valid <= addr_valid;
            sum_start <= addr_start;
            sum_stop <= addr_stop;
        end
    end

    logic [31:0] next_addr;

    assign next_addr = next_feat + next_vector;

    support_mem #(Features,Vectors) supports
        (.clk(clk)
        ,.address(next_addr)
        ,.support(support)
        );

    alpha_mem #(Features,Vectors) alphas
        (.clk(clk)
        ,.address(next_addr)
        ,.support(alpha)
        );

    test_mem #(Features,Vectors) tests
        (.clk(clk)
        ,.address(next_feat)
        ,.test(test)
        );

    logic vector_start;
    logic vector_stop;

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            vector_start <= 0;
            vector_stop <= 0;
        end
        else begin
            vector_start <= next_feat == 0;
            vector_stop <= next_feat == Features - 1;
        end
    end

    test_sum ts
        (.clk(clk)
        ,.rst(rst)
        ,.test(test)
        ,.support_vector(support)
        ,.alpha(alpha)
        ,.in_valid(sum_valid)
        ,.in_start(sum_start)
        ,.in_end(sum_stop)
        ,.vector_start(vector_start)
        ,.vector_end(vector_stop)
        ,.label(label)
        ,.label_valid(label_valid)
        );


endmodule


