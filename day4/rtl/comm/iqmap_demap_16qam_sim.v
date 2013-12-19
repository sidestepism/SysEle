
module iqmap_demap_16qam_sim;


   reg ck, rst, ce, valid_i_map;

   wire signed [10:0] xr, xi;
   wire reader_en, valid_i_demap;

   output [0:3]raw_map;
   output valid_o_map, valid_raw_map, rawdmodule_map;
   output valid_o_depmap, valid_raw_demap, rawdmodule_demap;

   reg [127:0] reader_data;
   output [127:0] writer_data;

   reg[31:0] rs;
   initial begin
      rs = 987654321 * 3456;
      $dumpfile("testadd.vcd");
      $dumpvars;
      ck <= 0;

      reader_data <= ($random(rs) << 96) + ($random(rs) << 64) + ($random(rs) << 32) + $random(rs);

      #10 rst = 0;
      #20 rst = 1;

      #20 valid_i_map = 1;
      #20 valid_i_map = 0;

      #640
      #120 $finish;
   end
   always #10 ck <= ~ck;

   always @(posedge ck) begin
      $monitor("%t valid_i_map: %b, valid_i_demap: %b, (%d, %d), raw: %b", $time, valid_i_map, valid_i_demap, xr, xi, raw_map);
      if (valid_o_demap) begin
         $monitor("reader: %b\nwriter: %b", reader_data, writer_data);
      end
   end

    iqmap_16qam iqmap_16qam_ins(
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
        .raw(raw_map[0:3])
    );

   iqdemap_16qam iqdemap_16qam_ins(
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
