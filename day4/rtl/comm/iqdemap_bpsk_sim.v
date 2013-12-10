
module iqdemap_bpsk_sim;


   reg ck, rst, ce, valid_i;
   reg signed [10:0] ar, ai;
   output valid_o, valid_raw, rawdmodule;
   output [127:0] writer_data;
   
   reg data[127:0];

   initial begin
      $dumpfile("testadd.vcd");
      $dumpvars;
      ck <= 0;
      $monitor("%t valid_i: %b, valid_o: %b, (%d, %d)", $time, valid_i, valid_o, ar, ai);

      #20 rst <= 0;
      #20 rst <= 1;
      #20 valid_i <= 1;
      #2560 valid_i <= 0;
      #100 $finish;
   end
   always #10 ck <= ~ck;

   always @(posedge ck) begin
      ar = $random % 2 ? 1023 : -1024;
      ai = 0;
      $monitor("%t valid_i: %b, valid_o: %b, (%d, %d)", $time, valid_i, valid_o, ar, ai);
      if (valid_o) begin
         $monitor("%b", writer_data);
      end
   end

   iqdemap_bpsk iqdemap_bpsk_ins(ck, rst, ce, valid_i, ar, ai, valid_o, writer_data [127:0], valid_raw, raw);
endmodule
