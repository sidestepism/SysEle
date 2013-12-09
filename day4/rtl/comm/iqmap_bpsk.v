
module iqmap_bpsk
  (
   input         CLK,
   input         RST,

   input         ce,
   
   input         valid_i,
   input [127:0] reader_data,
   output        reader_en,

   output [10:0] xr,
   output [10:0] xi,
   output        valid_o,

   output        valid_raw,
   output        raw
   );
	
	assign valid_o = 0;
	assign valid_raw = 0;

endmodule
