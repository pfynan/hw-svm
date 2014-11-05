module kernel (
     input logic clk,
     input logic rst,
     input logic signed [31:0] test,
     input logic signed [31:0] support,

     input logic in_start,
     input logic in_end,
     input logic in_valid,

     output logic signed [31:0] out,
     output logic out_valid

);

    enum {WAIT,RUNNING,DONE} s,ns;

    always_comb case(s)
        WAIT: ns = in_valid & in_start ? RUNNING : WAIT;
        RUNNING: ns = in_valid & in_end ? DONE : RUNNING;
        DONE: ns = in_valid & in_start ? RUNNING : DONE;
    endcase

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            s <= WAIT;
        end else begin
            s <= ns;
        end
    end

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            out_valid <= 0;
        end else if(ns == DONE && s == RUNNING) begin
            out_valid <= 1;
        end else begin
            out_valid <= 0;
        end
    end


    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            out <= '0;
        end else if(ns == RUNNING && (s == WAIT || s == DONE)) begin
            out <= test * support;
        end else if(ns == RUNNING && s == RUNNING) begin
            out <= out + test * support;
        end
    end
   
endmodule: kernel
