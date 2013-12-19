
module sim_fft64;

  // input         CLK,
  // input         RST,
   // input         ce,
   // input         valid_i,
   // input [127:0] reader_data,
   // output        reader_en,
   // output [10:0] xr,
   // output [10:0] xi,
   // output        valid_o,
   // output        valid_raw,
   // output        raw

    reg [127:0] reader_data;
    reg ck, rst, ce, valid_i, rd_en;
    reg signed [10:0] ar, ai;
    output signed [10:0] xr, xi;
    output valid_o, full;
    output [0:3] raw;
    output [9:0] state;
    reg [9:0] samples;
    reg [31:0] rs;

    reg signed [10:0] datar[0:63];
    reg signed [10:0] datai[0:63];

    initial begin
        $dumpfile("testadd.vcd");
        $dumpvars;
    datar[0] = 5;datar[1] = 1;datar[2] = -12;datar[3] = -7;datar[4] = 1;datar[5] = 12;datar[6] = -13;datar[7] = -8;datar[8] = 13;datar[9] = -8;datar[10] = 4;datar[11] = 1;datar[12] = -6;datar[13] = -10;datar[14] = 0;datar[15] = -4;datar[16] = -9;datar[17] = -9;datar[18] = -8;datar[19] = -7;datar[20] = 14;datar[21] = 11;datar[22] = 8;datar[23] = -7;datar[24] = -4;datar[25] = 3;datar[26] = -7;datar[27] = 0;datar[28] = -5;datar[29] = -2;datar[30] = 10;datar[31] = 14;datar[32] = -8;datar[33] = -3;datar[34] = -15;datar[35] = -5;datar[36] = 8;datar[37] = -12;datar[38] = -12;datar[39] = 5;datar[40] = 4;datar[41] = -8;datar[42] = 2;datar[43] = 8;datar[44] = -8;datar[45] = -9;datar[46] = -14;datar[47] = 2;datar[48] = 12;datar[49] = -13;datar[50] = 3;datar[51] = 6;datar[52] = 10;datar[53] = -9;datar[54] = -6;datar[55] = -7;datar[56] = 10;datar[57] = -6;datar[58] = 6;datar[59] = -12;datar[60] = 12;datar[61] = 3;datar[62] = 13;datar[63] = -11;
    datai[0] = 15;datai[1] = 3;datai[2] = 3;datai[3] = 11;datai[4] = 11;datai[5] = 7;datai[6] = 5;datai[7] = 14;datai[8] = 4;datai[9] = 1;datai[10] = 5;datai[11] = 11;datai[12] = 2;datai[13] = 10;datai[14] = 6;datai[15] = 4;datai[16] = 7;datai[17] = 3;datai[18] = 12;datai[19] = 11;datai[20] = 0;datai[21] = 2;datai[22] = 2;datai[23] = 12;datai[24] = 0;datai[25] = 11;datai[26] = 4;datai[27] = 4;datai[28] = 15;datai[29] = 7;datai[30] = 2;datai[31] = 7;datai[32] = 7;datai[33] = 10;datai[34] = 0;datai[35] = 9;datai[36] = 4;datai[37] = 9;datai[38] = 13;datai[39] = 13;datai[40] = 13;datai[41] = 2;datai[42] = 15;datai[43] = 4;datai[44] = 15;datai[45] = 1;datai[46] = 5;datai[47] = 14;datai[48] = 11;datai[49] = 4;datai[50] = 2;datai[51] = 11;datai[52] = 8;datai[53] = 1;datai[54] = 9;datai[55] = 15;datai[56] = 2;datai[57] = 4;datai[58] = 1;datai[59] = 4;datai[60] = 2;datai[61] = 3;datai[62] = 12;datai[63] = 6;

        reader_data <= ($random << 96) + ($random << 64) + ($random << 32) + $random;
        $monitor("reader_data: %b", reader_data);
        rs <= 34567890 * 2345678;
        ck <= 0;
        samples <= 0;
        valid_i <= 0;

        #0 rst = 0;
        #20 rst = 1;
        #20 valid_i = 1;
        #1280 valid_i = 0;
        #2560 
        #1280
        #60 $finish;
    end

    always #10 ck <= ~ck;


   always @(posedge ck) begin
      samples = samples + valid_i;
      // ar = samples == 1 ? 2048 : 0;
      ar <= (samples == 48) ? 256 : 0;
      ai <= (samples == 1) ? 0 : 0;

      // ar <= datar[samples];
      // ai <= datai[samples];

      $monitor("%t valid_i: %b, valid_o: %b, full: %b, state: %d, (%d, %d)", $time, valid_i, valid_o, full, state, ar, ai);
      if (valid_o) begin
         $monitor("output: (%d, %d)", xr, xi);
      end
   end

   fft64 fft64_ins(
        .CLK(ck),
        .RST(rst),
        .valid_a(valid_i),
        .ar(ar),
        .ai(ai),
        .valid_o(valid_o),
        .rd_en(rd_en),
        .full(full),
        .xr(xr),
        .xi(xi),
        .state(state)
    );
endmodule

