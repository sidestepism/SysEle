
module iqdemap_bpsk_sim;


   reg ck, rst, ce, valid_i;
   reg signed [10:0] ar, ai;
   wire valid_o, valid_raw, rawdmodule;
   wire [127:0] writer_data;
   
   parameter STEP = 10;

   always begin
      ck = 0; # (STEP/2)
      ck = 1; # (STEP/2)
   end
   reg data[127:0];
   iqdemap_bpsk(ck, rst, ce, valid_i, ar, ai, valid_o, writer_data, valid_raw, raw);
   always #10 begin
      ar = $random % 2 ? 1 : -1;
      ai = 0;
      $monitor("%t valid_i: %b, valid_o: %b, (%d, %d)", $time, valid_i, valid_o, ar, ai)
      if(valid_o) begin
         $monitor("%b", writer_data);
      end
    end

   initial begin
      #20 rst <= 0;
      #20 rst <= 1;
      #20
      valid_i <= 1;
      #2560
      valid_i <= 0;
   end



endmodule
















