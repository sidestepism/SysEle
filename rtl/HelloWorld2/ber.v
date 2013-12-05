
module ber
  (
   input         CLK,
   input         RST,

   input         valid_i,
   input [7:0]   sent_data,
   input [7:0]   recv_data,
   input [3:0]   number_of_bits,

   output        valid_o, 
   output [31:0] error_rate
   );
   
   assign valid_o = 1'b0;
   assign error_rate = 123456789;

endmodule
