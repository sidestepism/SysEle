module sim_iqmap_bpsk;

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
    reg ck, rst, ce, valid_i;
    output signed [10:0] xr, xi;
    output valid_o, valid_raw, raw;

    initial begin
        $dumpfile("testadd.vcd");
        $dumpvars;

        reader_data <= ($random << 96) + ($random << 64) + ($random << 32) + $random;
        $monitor("reader_data: %b", reader_data);
        ck <= 0;
        #0 rst = 0;
        #10 rst = 1;
        #30 valid_i = 1;
        #40 valid_i = 0;
        #1600 $finish;
    end
    always #10 ck <= ~ck;

    always @(posedge ck) begin
      $monitor("%t, ck:%b, valid_i: %b, valid_o: %b, (%d, %d), raw: %d", $time, ck, valid_i, valid_o, xr, xi, raw);
    end

    iqmap_bpsk iqmap_bpsk_ins(
        ck,
        rst,
        ce,
        valid_i,
        reader_data[127:0],
        reader_en,
        xr,
        xi,
        valid_o,
        valid_raw,
        raw
    );

endmodule

