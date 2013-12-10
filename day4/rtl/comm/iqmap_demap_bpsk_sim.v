
module iqmap_demap_bpsk_sim;


   reg ck, rst, ce, valid_i_map;

   wire signed [10:0] xr, xi;
   wire reader_en, valid_i_demap;

   output valid_o_map, valid_raw_map, rawdmodule_map, raw;
   output valid_o_depmap, valid_raw_demap, rawdmodule_demap;

   reg [127:0] reader_data;
   output [127:0] writer_data;

   initial begin
      $dumpfile("testadd.vcd");
      $dumpvars;
      ck <= 0;

      reader_data <= ($random << 96) + ($random << 64) + ($random << 32) + $random;

      #20 rst = 0;
      #20 rst = 1;

      #20 valid_i_map = 1;
      #20 valid_i_map = 0;

      #1000 $finish;
   end
   always #10 ck <= ~ck;

   always @(posedge ck) begin
      $monitor("%t valid_i_map: %b, valid_i_demap: %b, (%d, %d)", $time, valid_i_map, valid_i_demap, xr, xi);
      if (valid_o_demap) begin
         $monitor("%b", writer_data);
      end
   end

    iqmap_bpsk iqmap_bpsk_ins(
        .CLK(ck),
        .RST(rst),
        .ce(ce),
        .valid_i(valid_i_map),
        .reader_data(reader_data[127:0]),
        .reader_en(reader_en),
        .xr(xr),
        .xi(xi),
        .valid_o(valid_i_demap),
        .valid_raw(valid_raw_map),
        .raw(raw_map)
    );

   iqdemap_bpsk iqdemap_bpsk_ins(
       .CLK(ck),
       .RST(rst),
       .ce(ce),
       .valid_i(valid_i_demap),
       .ar(xr),
       .ai(xi),
       .valid_o(valid_o_demap),
       .writer_data(writer_data[127:0]),
       .valid_raw(valid_raw_demap),
       .raw(raw_demap)
   );
endmodule
