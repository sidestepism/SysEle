
module iqdemap_16qam_sim;


   reg ck, rst, ce, valid_i;
   reg signed [10:0] ar, ai;
   output valid_o, valid_raw, rawdmodule;
   output [127:0] writer_data;
   reg [31:0] rs;
   output [3:0] raw;

   reg data[127:0];

   initial begin
      $dumpfile("testadd.vcd");
      $dumpvars;
      ck <= 0;
      rs = 456779 * 87654;

      #20 rst <= 0;
      #20 rst <= 1;
      #20 valid_i <= 1;
      #640 valid_i <= 0;
      #100 $finish;
   end
   always #10 ck <= ~ck;

   always @(posedge ck) begin
      ar = $random(rs) % 2 ? ($random(rs) % 2 ? 1023 : 342) :($random(rs) % 2? -342 : -1024);
      ai = $random(rs) % 2 ? ($random(rs) % 2 ? 1023 : 342) :($random(rs) % 2? -342 : -1024);
      $monitor("%t valid_i: %b, valid_o: %b, (%d, %d) raw: %b", $time, valid_i, valid_o, ar, ai, raw);
      if (valid_o) begin
         $monitor("%b", writer_data);
      end
   end

   iqdemap_16qam iqdemap_16qam_ins(ck, rst, ce, valid_i, ar, ai, valid_o, writer_data [127:0], valid_raw, raw);
endmodule
