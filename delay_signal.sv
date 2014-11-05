module delay_signal (
     input logic clk,
     input logic rst,
     input logic capture_l,
     input logic release_l,
     output logic out
);

logic [7:0] counter;

always_comb if(counter > 0 && release_l || capture_l && release_l) begin
    out = 1;
end else begin
    out = 0;
end

always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
        counter <= 0;
    end else if(capture_l & release_l) begin
        counter <= counter;
    end else if(capture_l) begin
        counter <= counter + 1;
    end else if(release_l) begin
        counter <= counter > 0 ? counter - 1 : 0;
    end
end

endmodule: delay_signal

