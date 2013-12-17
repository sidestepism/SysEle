module sim_iqmap_16qam;

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
    output valid_o, valid_raw;
    output [0:3] raw;

    initial begin
        $dumpfile("testadd.vcd");
        $dumpvars;

        reader_data <= ($random << 96) + ($random << 64) + ($random << 32) + $random;
        $monitor("reader_data: %b", reader_data);
        ck <= 0;
        #0 rst = 0;
        #20 rst = 1;
        #20 valid_i = 1;
        #20 valid_i = 0;
        #640
        #20 $finish;
    end

    always #10 ck <= ~ck;

    always @(posedge ck) begin
      $monitor("%t, ck:%b, valid_i: %b, valid_o: %b, (%d, %d), raw: %b", $time, ck, valid_i, valid_o, xr, xi, raw);
    end

    iqmap_16qam iqmap_16qam_ins(
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

