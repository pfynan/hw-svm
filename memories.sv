module support_mem #(Features,Vectors) (
     input logic clk,
     input logic [$clog2(Features*Vectors)-1:0] address,
     output logic [31:0] support
);

logic [31:0] mem[Features*Vectors-1:0];

initial $readmemh("svm.hex",mem);

always_ff @(posedge clk) begin
    support <= mem[address];
end
   
endmodule

module alpha_mem #(Features,Vectors) (
     input logic clk,
     input logic [$clog2(Features*Vectors)-1:0] address,
     output logic [31:0] alpha
);

logic [31:0] mem[Features*Vectors-1:0];

initial $readmemh("weights.hex",mem);

always_ff @(posedge clk) begin
    alpha <= mem[address];
end
   
endmodule

module test_mem #(Features,Vectors) (
     input logic clk,
     input logic [$clog2(Features*Vectors)-1:0] address,
     output logic [31:0] test
);

logic [31:0] mem[Features*Vectors-1:0];

initial $readmemh("test.hex",mem);

always_ff @(posedge clk) begin
    test <= mem[address];
end
   
endmodule
