module pipeline_stage
  #(parameter DATA_SIZE = 32,
    parameter ACCUM_SIZE = 64,
    parameter NUM_FEAT = 2,
    parameter FEAT_I = 0)
( input   logic                               clk, rst, start_inner, last_inner,
  input   logic [DATA_SIZE-1:0]               sv,
  input   logic [NUM_FEAT-1:0][DATA_SIZE-1:0] curr_vector_in,
  input   logic [ACCUM_SIZE-1:0]              accum_in,
  output  logic [NUM_FEAT-1:0][DATA_SIZE-1:0] curr_vector_out,
  output  logic [ACCUM_SIZE-1:0]              accum_out);

  // state
  enum  logic {INIT, RUN} cs;

  //logic LOAD;
  logic [24:0] A;
  logic [17:0] B;
  logic [47:0] P;
  logic [47:0] LOAD_DATA;
 //FIXME: MACC blocks have smaller width than stored data. Kind of a problem.
  
     MACC_MACRO #(
     .DEVICE("7SERIES"), // Target Device: "7SERIES" 
     .LATENCY(0),        // Desired clock cycle latency, 1-4
     .WIDTH_A(25),       // Multiplier A-input bus width, 1-25
     .WIDTH_B(18),       // Multiplier B-input bus width, 1-18
     .WIDTH_P(48)        // Accumulator output bus width, 1-48
  ) MACC_MACRO_inst (
     .P(P),     // MACC output bus, width determined by WIDTH_P parameter 
     .A(A),     // MACC input A bus, width determined by WIDTH_A parameter 
     .ADDSUB(1), // 1-bit add/sub input, high selects add, low selects subtract
     .B(B),     // MACC input B bus, width determined by WIDTH_B parameter 
     .CARRYIN(0), // 1-bit carry-in input to accumulator
     .CE(1),     // 1-bit active high input clock enable
     .CLK(clk),   // 1-bit positive edge clock input
     .LOAD(1), // 1-bit active high input load accumulator enable
     .LOAD_DATA(LOAD_DATA), // Load accumulator input data, width determined by WIDTH_P parameter
     .RST(rst)    // 1-bit input active high reset
  );
  
  assign A = sv;
  
  always_comb begin
  case (cs)
    INIT: begin
      LOAD_DATA = accum_in;
      B = curr_vector_in[FEAT_I];
    end
    RUN: begin
      LOAD_DATA = accum_out;
      B = curr_vector_out[FEAT_I];
    end
  endcase
  end
  
  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      accum_out <= 0;
      curr_vector_out <= 0;
      cs <= INIT;
    end else begin
      case (cs)
        INIT: if (start_inner) begin
                curr_vector_out <= curr_vector_in;
                accum_out <= P;
                cs <= RUN;
              end
        RUN:  begin
                accum_out <= P;
                cs <= (last_inner) ? INIT : RUN;
              end
      endcase
    end
  end
  
 

endmodule: pipeline_stage

module pipeline_tb;

  logic clk, rst, start_inner, last_inner;
  logic [31:0]      sv;
  logic [1:0][31:0] curr_vector_in, curr_vector_out;
  logic [63:0]      accum_in, accum_out;

  pipeline_stage dut(.*);

  initial begin
    clk = 1;
    forever #5 clk = ~clk;
  end

  initial begin
    rst = 1; start_inner = 0; last_inner = 0; curr_vector_in = 0;
    accum_in = 0; sv = 0;
    @(posedge clk);
    rst <= 0;
    @(posedge clk);
    curr_vector_in <= {32'd3, 32'd7};
    accum_in <= 0;
    sv <= 4;
    start_inner <= 1;
    @(posedge clk);
    start_inner <= 0;
    sv <= 2;
    last_inner <= 1;
    @(posedge clk);
    last_inner <= 0;
    @(posedge clk);
    $display("result = %d", accum_out); // should be 7*4 + 7*2 = 42
    $finish;
  end

endmodule: pipeline_tb
