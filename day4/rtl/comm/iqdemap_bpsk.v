
module iqdemap_bpsk 
  (
   input               CLK,
   input               RST,

   input               ce,

   input               valid_i,
   input signed [10:0] ar,
   input signed [10:0] ai,

   output              valid_o,
   output [127:0]      writer_data,

   output              valid_raw,
   output              raw
   );

   assign valid_o = 0;
	assign valid_raw = 0;
endmodule
