module kernel (
     input logic clk,
     input logic rst,
     input logic signed [31:0] test,
     input logic signed [31:0] support,

     input logic in_start,
     input logic in_end,
     input logic in_valid,
     output logic in_ready,

     output logic signed [31:0] out,
     output logic out_valid

);

    enum {START,RUNNING,DONE} s,ns;

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            s <= START;
        end
        else begin
            s <= ns;
        end
    end

    always_comb case(s)
        START: ns = in_start == 1'b1 && in_valid == 1'b1 && in_ready == 1'b1 ?
                    RUNNING : START;
        RUNNING: ns = in_end == 1'b1 && in_valid == 1'b1 && in_valid == 1'b1 ?
                    DONE : RUNNING;
        DONE: ns = in_start == 1'b1 && in_valid == 1'b1 && in_ready == 1'b1 ?
                    RUNNING : DONE;
    endcase

    assign in_ready = s == START | s == DONE | s == RUNNING;
    assign out_valid = s == DONE;
        

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            out <= '0;
        end else if(in_valid & in_ready & in_start) begin
            out <= test * support;
        end else if(in_valid & in_ready) begin
            out <= out + test * support;
        end
    end
   
endmodule: kernel
