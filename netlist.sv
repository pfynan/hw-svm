
module hw_svm ( clk, rst, test, test_valid, test_ready, label, label_valid, 
        label_ready );
  input [31:0] test;
  input clk, rst, test_valid, label_ready;
  output test_ready, label, label_valid;
  wire   N19, N20, N54, N59, N60, N61, N63, N64, N65, N66, N67, N262, n5, n39,
         n40, n72, n73, n74, n142, \add_57/carry[2] , \add_57/carry[3] ,
         \add_57/carry[4] , n213, n214;
  wire   [31:0] s;
  wire   [31:0] ns;
  wire   [4:0] cur_vector;
  assign label = 1'b1;
  assign label_valid = N262;

  DFFRHQX1 \cur_vector_reg[4]  ( .D(N67), .CK(clk), .RN(n142), .Q(
        cur_vector[4]) );
  DFFRHQX1 \cur_vector_reg[3]  ( .D(N66), .CK(clk), .RN(n142), .Q(
        cur_vector[3]) );
  DFFRHQX1 \cur_vector_reg[2]  ( .D(N65), .CK(clk), .RN(n142), .Q(
        cur_vector[2]) );
  DFFRHQX1 \cur_vector_reg[1]  ( .D(N64), .CK(clk), .RN(n142), .Q(
        cur_vector[1]) );
  DFFRHQX1 \cur_vector_reg[0]  ( .D(N63), .CK(clk), .RN(n142), .Q(
        cur_vector[0]) );
  DFFRHQX1 \s_reg[0]  ( .D(ns[0]), .CK(clk), .RN(n142), .Q(s[0]) );
  DFFRHQX1 \s_reg[1]  ( .D(ns[1]), .CK(clk), .RN(n142), .Q(s[1]) );
  ADDHXL \add_57/U1_1_3  ( .A(cur_vector[3]), .B(\add_57/carry[3] ), .CO(
        \add_57/carry[4] ), .S(N61) );
  ADDHXL \add_57/U1_1_2  ( .A(cur_vector[2]), .B(\add_57/carry[2] ), .CO(
        \add_57/carry[3] ), .S(N60) );
  ADDHXL \add_57/U1_1_1  ( .A(cur_vector[1]), .B(cur_vector[0]), .CO(
        \add_57/carry[2] ), .S(N59) );
  TLATX1 \ns_reg[0]  ( .G(N54), .D(N19), .Q(ns[0]) );
  TLATX1 \ns_reg[1]  ( .G(N54), .D(N20), .Q(ns[1]) );
  INVX1 U154 ( .A(n5), .Y(n214) );
  INVX1 U155 ( .A(n72), .Y(N262) );
  OAI22X1 U156 ( .A0(n40), .A1(n72), .B0(n214), .B1(n73), .Y(N20) );
  INVX1 U157 ( .A(n39), .Y(n40) );
  OAI2BB1X1 U158 ( .A0N(n73), .A1N(n5), .B0(n39), .Y(N19) );
  NOR2BX1 U159 ( .AN(N59), .B(n214), .Y(N64) );
  NOR2BX1 U160 ( .AN(N60), .B(n214), .Y(N65) );
  NOR2BX1 U161 ( .AN(N61), .B(n214), .Y(N66) );
  NAND2X1 U162 ( .A(s[1]), .B(test_ready), .Y(n72) );
  INVX1 U163 ( .A(s[0]), .Y(test_ready) );
  NAND3BX1 U164 ( .AN(n74), .B(cur_vector[3]), .C(cur_vector[4]), .Y(n73) );
  NAND3X1 U165 ( .A(cur_vector[1]), .B(cur_vector[0]), .C(cur_vector[2]), .Y(
        n74) );
  NAND2X1 U166 ( .A(test_valid), .B(test_ready), .Y(n39) );
  NOR2X1 U167 ( .A(test_ready), .B(s[1]), .Y(n5) );
  NAND2X1 U168 ( .A(s[1]), .B(s[0]), .Y(N54) );
  NOR2X1 U169 ( .A(n213), .B(n214), .Y(N67) );
  XNOR2X1 U170 ( .A(\add_57/carry[4] ), .B(cur_vector[4]), .Y(n213) );
  NOR2X1 U171 ( .A(cur_vector[0]), .B(n214), .Y(N63) );
  INVX1 U172 ( .A(rst), .Y(n142) );
endmodule

