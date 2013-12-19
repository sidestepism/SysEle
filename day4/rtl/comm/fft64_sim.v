
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

    initial begin
        $dumpfile("testadd.vcd");
        $dumpvars;

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
<<<<<<< HEAD
      ar <= (samples == 0) ? 1 : 0;
=======
      ar <= (samples == 1) ? 256 : 0;
>>>>>>> bugfix
      ai <= (samples == 0) ? 0 : 0;
      $monitor("%t valid_i: %b, valid_o: %b, full: %b, state: %d, (%d, %d)", $time, valid_i, valid_o, full, state, ar, ai);
      if (valid_o) begin
         $monitor("(%d, %d)", xr, xi);
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

