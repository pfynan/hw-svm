`define DATA_SIZE 32
`define ACCUM_SIZE 64
`define NUM_FEAT 2
`define NUM_SV 3

module hw_svm
( input   logic clk, rst, start, last_input,
  input   logic [`NUM_FEAT-1:0][`DATA_SIZE-1:0]               test_vector,
  input   logic [`NUM_SV-1:0][`NUM_FEAT-1:0][`DATA_SIZE-1:0]  support_vectors,
  output  logic valid,
  output  logic [`ACCUM_SIZE-1:0]  result);

  // support vectors
  logic [$clog2(`NUM_SV)-1:0]   sv_i;
  logic [`NUM_FEAT-1:0][`DATA_SIZE-1:0]                 sv_in;
  // interconnect
  logic [`NUM_FEAT-1:0][`NUM_FEAT-1:0][`DATA_SIZE-1:0]  curr_vector_in,
                                                        curr_vector_out;
  logic [`NUM_FEAT-1:0][`ACCUM_SIZE-1:0]                accum_in, accum_out;
  // misc
  logic                         start_inner, last_inner, final_inst;
  logic [$clog2(`NUM_FEAT)-1:0] delay;

  // interconnect
  always_comb begin
    sv_in = support_vectors[sv_i];
    curr_vector_in = {curr_vector_out[`NUM_FEAT-2:0], test_vector};
    accum_in = {accum_out[`NUM_FEAT-2:0], `ACCUM_SIZE'd0};
    result = accum_out[`NUM_FEAT-1];
  end

  generate
    genvar i; // i is index of feature
    for (i=0; i<`NUM_FEAT; i++) begin
      pipeline_stage #(`DATA_SIZE, `ACCUM_SIZE, `NUM_FEAT, i)
                      pipeline_module(.sv(sv_in[i]),
                                      .curr_vector_in(curr_vector_in[i]),
                                      .accum_in(accum_in[i]),
                                      .curr_vector_out(curr_vector_out[i]),
                                      .accum_out(accum_out[i]),
                                      .*);
    end
  endgenerate

  // state stuff
  enum  logic [1:0] {INIT, RUN, RUN_LAST, DONE} cs;

  always_comb begin
    start_inner = ((cs == INIT) && start) ||
                  (((cs == RUN) || (cs == RUN_LAST)) && (sv_i == 0));
    last_inner = sv_i == (`NUM_SV-1);
    final_inst = delay == (`NUM_FEAT-1);
  end

  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      sv_i <= 0;
      delay <= 0;
      cs <= INIT;
    end else begin
      case (cs)
        INIT:     begin
                    sv_i <= (start) ? 1 : sv_i;
                    cs <= (start) ? RUN : INIT;
                  end
        RUN:      begin
                    sv_i <= (last_inner) ? 0 : sv_i + 1;
                    delay <= (last_input) ? 0 : delay;
                    cs <= (last_input) ? RUN_LAST : RUN;
                  end
        RUN_LAST: begin
                    sv_i <= (last_inner) ? 0 : sv_i + 1;
                    delay <= (last_inner) ? delay + 1 : delay;
                    cs <= (final_inst && last_inner) ? DONE : RUN_LAST;
                  end
        DONE:     begin
                    sv_i <= 0;
                    cs <= INIT;
                  end
      endcase
    end
  end
  
  enum  logic [1:0] {IDLE, FIRST, LATER} count_cs;
  logic [$clog2(`NUM_SV*`NUM_FEAT)-1:0] count;

  // separate counter to track when results are valid
  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      count <= 0;
      count_cs <= IDLE;
    end else begin
      case (count_cs)
        IDLE:   begin
                  count <= (start) ? count + 1 : 0;
                  count_cs <= (start) ? FIRST : IDLE;
                end
        FIRST:  begin
                  count <= (count == `NUM_SV*`NUM_FEAT) ? 1 : count + 1;
                  count_cs <= (count == `NUM_SV*`NUM_FEAT) ? LATER : FIRST;
                end
        LATER:  begin
                  if (cs == DONE) begin
                    count <= 0;
                    count_cs <= IDLE;
                  end else begin
                    count <= (count == `NUM_SV) ? 1 : count + 1;
                    count_cs <= LATER;
                  end
                end
      endcase
    end
  end

  always_comb begin
    valid = ((count_cs == FIRST) && (count == `NUM_SV*`NUM_FEAT)) ||
            ((count_cs == LATER) && (count == `NUM_SV));
  end

endmodule: hw_svm

module hw_svm_tb;

  // assume 3 SVs, 2 features, 2 test instances, 32 bit data, 64 bit accum
  logic clk, rst, start, last_input;
  logic [1:0][31:0] test_vector;
  logic [2:0][1:0][31:0]  support_vectors;
  logic valid;
  logic [63:0]  result;

  hw_svm dut(.*);

  initial begin
    clk = 1;
    forever #5 clk = ~clk;
  end

  initial begin
    rst = 1; start = 0; last_input = 0; test_vector = 0; support_vectors = 0;
    @(posedge clk);
    rst <= 0;
    @(posedge clk);
    // begin test sequence
    test_vector <= {32'd1, 32'd2};
    support_vectors <= {{32'd6, 32'd5}, {32'd4, 32'd3}, {32'd2, 32'd1}};
    start <= 1;
    @(posedge clk);
    start <= 0;
    repeat (2) @(posedge clk);
    test_vector <= {32'd3, 32'd4};
    last_input <= 1;
    @(posedge clk);
    last_input <= 0;
    repeat (2) @(posedge clk);
    
    repeat (8) @(posedge clk);
    $finish;
  end

endmodule: hw_svm_tb
