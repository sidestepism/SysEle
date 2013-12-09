
module vidbuf
  (
   input        CLK_VGA,
   input        RST,

   input [9:0]  ROW,
   input [10:0] COL,
   output [7:0] R,
   output [7:0] G,
   output [7:0] B,

   input        CLK_WRITE,
   input [8:0]  x,
   input [7:0]  y,
   input [23:0] data,
   input        we
   );

   wire [23:0]   data_o;
   wire [16:0]   write_address;
   wire [16:0]   read_address;

   assign {R, G, B} 
     = ((| ROW[9:8]) || (| COL[10:9])) ?
       24'h0 :
       data_o;
   assign write_address = {y, x};
   assign read_address  = {ROW[7:0], COL[8:0]};
   
   dual_clk 
     #(.addr_width(17),
       .data_width(24))
     dual_clk_inst
       (.write_clk(CLK_WRITE),
        .read_clk(CLK_VGA),

        .q(data_o),
        .d(data),
        .write_address(write_address),
        .read_address(read_address),
        .we(we)
        );

endmodule // vidbuf

   