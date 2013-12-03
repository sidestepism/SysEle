
module num2char
  (
   input        CLK,
   input        RST,

   input        start_update,
   input [31:0] error_rate,

   output [7:0] char,
   output       valid_o
   );

   assign char = 8'd0;
   assign valid_o = 1'b0;

endmodule
