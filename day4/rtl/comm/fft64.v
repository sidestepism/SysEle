
module fft64
  #(parameter width = 11)
   (
    input              CLK,
    input              RST,

    input              valid_a,
    input [width-1:0]  ar,
    input [width-1:0]  ai,

    output             valid_o,
    input              rd_en,
    output             full,
    output [width-1:0] xr,
    output [width-1:0] xi
    );

	assign valid_o = 0;
	assign full = 1;
endmodule
