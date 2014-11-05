module mem_counter #(Features,Vectors) (
     input logic clk,
     input logic rst,
     input logic start,
     output logic [31:0] next_vector,
     output logic [31:0] next_feat,
     output logic addr_valid,
     output logic addr_start,
     output logic addr_stop
);

    enum {WAIT,RUNNING,DONE} s,ns;

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            s <= WAIT;
        end else begin
            s <= ns;
        end
    end

    always_comb case(s)
        WAIT: ns = start == 1'b1 ? RUNNING : WAIT;
        DONE: ns = start == 1'b1 ? RUNNING : DONE;
        RUNNING: ns = next_vector == Vectors - 1 
                   || next_feat == Features - 1
                    ? DONE : RUNNING;
    endcase

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            addr_valid <= 0;
        end else begin
            addr_valid <= ns == RUNNING ? 1'b1 : 1'b0;
        end
    end

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            addr_start <= 0;
        end
        else begin
            addr_start <= start;
        end
    end

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            addr_stop <= 0;
        end else if(ns == DONE && s == RUNNING) begin
            addr_stop <= 1;
        end else begin
            addr_stop <= 0;
        end
    end

   
    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            next_vector <= '0;
            next_feat <= '0;
        end else if(ns == WAIT) begin
            next_vector <= '0;
            next_feat <= '0;
        end else if(ns == RUNNING) begin
            if(next_feat == Features - 1) begin
                next_feat <= 0;
                next_vector <= next_vector + 1;
            end else begin
                next_feat <= next_feat + 1;
            end
        end
    end

endmodule: mem_counter

