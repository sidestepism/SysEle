
// 荵礼ｮ怜勣
module butterfly
  #(parameter width = 11)
    (
        input CLK, 
        input RST,
        input signed [width-1:0] ar,
        input signed [width-1:0] ai,
        input signed [width-1:0] br,
        input signed [width-1:0] bi,
        input signed [23:0] wr,
        input signed [23:0] wi,
        output reg signed [width-1:0] xr,
        output reg signed [width-1:0] xi,
        output reg signed [width-1:0] yr,
        output reg signed [width-1:0] yi
    );

    wire signed [width-1:0] wbr, wbi;
    assign wbr = ((br * wr) - (bi * wi)) >>> 22;
    assign wbi = ((br * wi) + (bi * bi)) >>> 22;

    always @(posedge CLK) begin
        xr <= ar + wbr;
        xi <= ai + wbi;
        yr <= ar - wbr;
        yi <= ai - wbi;
    end

endmodule

module fft64
  #(parameter width = 11)
   (
    input              CLK,
    input              RST,

    input              valid_a,
    input [width-1:0]  ar,
    input [width-1:0]  ai,

    output             valid_o,
    input              rd_en, // ignore
    output             full,  // 0
    output [width-1:0] xr,
    output [width-1:0] xi,
    output reg[9:0]    state
    );
    
    // reg [9:0] state;
    // 0 = idle, 1 = input, 2 = output, 3 = 
    reg [5:0] samples;

    reg [width-1:0] datar [0:63];
    reg [width-1:0] datai [0:63];


// debug

wire [width-1:0] datawr0; assign datawr0 = datar[0]; 
wire [width-1:0] datawi0; assign datawi0 = datai[0]; 
wire [width-1:0] datawr1; assign datawr1 = datar[1]; 
wire [width-1:0] datawi1; assign datawi1 = datai[1]; 
wire [width-1:0] datawr2; assign datawr2 = datar[2]; 
wire [width-1:0] datawi2; assign datawi2 = datai[2]; 
wire [width-1:0] datawr3; assign datawr3 = datar[3]; 
wire [width-1:0] datawi3; assign datawi3 = datai[3]; 
wire [width-1:0] datawr4; assign datawr4 = datar[4]; 
wire [width-1:0] datawi4; assign datawi4 = datai[4]; 
wire [width-1:0] datawr5; assign datawr5 = datar[5]; 
wire [width-1:0] datawi5; assign datawi5 = datai[5]; 
wire [width-1:0] datawr6; assign datawr6 = datar[6]; 
wire [width-1:0] datawi6; assign datawi6 = datai[6]; 
wire [width-1:0] datawr7; assign datawr7 = datar[7]; 
wire [width-1:0] datawi7; assign datawi7 = datai[7]; 
wire [width-1:0] datawr8; assign datawr8 = datar[8]; 
wire [width-1:0] datawi8; assign datawi8 = datai[8]; 
wire [width-1:0] datawr9; assign datawr9 = datar[9]; 
wire [width-1:0] datawi9; assign datawi9 = datai[9]; 
wire [width-1:0] datawr10; assign datawr10 = datar[10]; 
wire [width-1:0] datawi10; assign datawi10 = datai[10]; 
wire [width-1:0] datawr11; assign datawr11 = datar[11]; 
wire [width-1:0] datawi11; assign datawi11 = datai[11]; 
wire [width-1:0] datawr12; assign datawr12 = datar[12]; 
wire [width-1:0] datawi12; assign datawi12 = datai[12]; 
wire [width-1:0] datawr13; assign datawr13 = datar[13]; 
wire [width-1:0] datawi13; assign datawi13 = datai[13]; 
wire [width-1:0] datawr14; assign datawr14 = datar[14]; 
wire [width-1:0] datawi14; assign datawi14 = datai[14]; 
wire [width-1:0] datawr15; assign datawr15 = datar[15]; 
wire [width-1:0] datawi15; assign datawi15 = datai[15]; 
wire [width-1:0] datawr16; assign datawr16 = datar[16]; 
wire [width-1:0] datawi16; assign datawi16 = datai[16]; 
wire [width-1:0] datawr17; assign datawr17 = datar[17]; 
wire [width-1:0] datawi17; assign datawi17 = datai[17]; 
wire [width-1:0] datawr18; assign datawr18 = datar[18]; 
wire [width-1:0] datawi18; assign datawi18 = datai[18]; 
wire [width-1:0] datawr19; assign datawr19 = datar[19]; 
wire [width-1:0] datawi19; assign datawi19 = datai[19]; 
wire [width-1:0] datawr20; assign datawr20 = datar[20]; 
wire [width-1:0] datawi20; assign datawi20 = datai[20]; 
wire [width-1:0] datawr21; assign datawr21 = datar[21]; 
wire [width-1:0] datawi21; assign datawi21 = datai[21]; 
wire [width-1:0] datawr22; assign datawr22 = datar[22]; 
wire [width-1:0] datawi22; assign datawi22 = datai[22]; 
wire [width-1:0] datawr23; assign datawr23 = datar[23]; 
wire [width-1:0] datawi23; assign datawi23 = datai[23]; 
wire [width-1:0] datawr24; assign datawr24 = datar[24]; 
wire [width-1:0] datawi24; assign datawi24 = datai[24]; 
wire [width-1:0] datawr25; assign datawr25 = datar[25]; 
wire [width-1:0] datawi25; assign datawi25 = datai[25]; 
wire [width-1:0] datawr26; assign datawr26 = datar[26]; 
wire [width-1:0] datawi26; assign datawi26 = datai[26]; 
wire [width-1:0] datawr27; assign datawr27 = datar[27]; 
wire [width-1:0] datawi27; assign datawi27 = datai[27]; 
wire [width-1:0] datawr28; assign datawr28 = datar[28]; 
wire [width-1:0] datawi28; assign datawi28 = datai[28]; 
wire [width-1:0] datawr29; assign datawr29 = datar[29]; 
wire [width-1:0] datawi29; assign datawi29 = datai[29]; 
wire [width-1:0] datawr30; assign datawr30 = datar[30]; 
wire [width-1:0] datawi30; assign datawi30 = datai[30]; 
wire [width-1:0] datawr31; assign datawr31 = datar[31]; 
wire [width-1:0] datawi31; assign datawi31 = datai[31]; 
wire [width-1:0] datawr32; assign datawr32 = datar[32]; 
wire [width-1:0] datawi32; assign datawi32 = datai[32]; 
wire [width-1:0] datawr33; assign datawr33 = datar[33]; 
wire [width-1:0] datawi33; assign datawi33 = datai[33]; 
wire [width-1:0] datawr34; assign datawr34 = datar[34]; 
wire [width-1:0] datawi34; assign datawi34 = datai[34]; 
wire [width-1:0] datawr35; assign datawr35 = datar[35]; 
wire [width-1:0] datawi35; assign datawi35 = datai[35]; 
wire [width-1:0] datawr36; assign datawr36 = datar[36]; 
wire [width-1:0] datawi36; assign datawi36 = datai[36]; 
wire [width-1:0] datawr37; assign datawr37 = datar[37]; 
wire [width-1:0] datawi37; assign datawi37 = datai[37]; 
wire [width-1:0] datawr38; assign datawr38 = datar[38]; 
wire [width-1:0] datawi38; assign datawi38 = datai[38]; 
wire [width-1:0] datawr39; assign datawr39 = datar[39]; 
wire [width-1:0] datawi39; assign datawi39 = datai[39]; 
wire [width-1:0] datawr40; assign datawr40 = datar[40]; 
wire [width-1:0] datawi40; assign datawi40 = datai[40]; 
wire [width-1:0] datawr41; assign datawr41 = datar[41]; 
wire [width-1:0] datawi41; assign datawi41 = datai[41]; 
wire [width-1:0] datawr42; assign datawr42 = datar[42]; 
wire [width-1:0] datawi42; assign datawi42 = datai[42]; 
wire [width-1:0] datawr43; assign datawr43 = datar[43]; 
wire [width-1:0] datawi43; assign datawi43 = datai[43]; 
wire [width-1:0] datawr44; assign datawr44 = datar[44]; 
wire [width-1:0] datawi44; assign datawi44 = datai[44]; 
wire [width-1:0] datawr45; assign datawr45 = datar[45]; 
wire [width-1:0] datawi45; assign datawi45 = datai[45]; 
wire [width-1:0] datawr46; assign datawr46 = datar[46]; 
wire [width-1:0] datawi46; assign datawi46 = datai[46]; 
wire [width-1:0] datawr47; assign datawr47 = datar[47]; 
wire [width-1:0] datawi47; assign datawi47 = datai[47]; 
wire [width-1:0] datawr48; assign datawr48 = datar[48]; 
wire [width-1:0] datawi48; assign datawi48 = datai[48]; 
wire [width-1:0] datawr49; assign datawr49 = datar[49]; 
wire [width-1:0] datawi49; assign datawi49 = datai[49]; 
wire [width-1:0] datawr50; assign datawr50 = datar[50]; 
wire [width-1:0] datawi50; assign datawi50 = datai[50]; 
wire [width-1:0] datawr51; assign datawr51 = datar[51]; 
wire [width-1:0] datawi51; assign datawi51 = datai[51]; 
wire [width-1:0] datawr52; assign datawr52 = datar[52]; 
wire [width-1:0] datawi52; assign datawi52 = datai[52]; 
wire [width-1:0] datawr53; assign datawr53 = datar[53]; 
wire [width-1:0] datawi53; assign datawi53 = datai[53]; 
wire [width-1:0] datawr54; assign datawr54 = datar[54]; 
wire [width-1:0] datawi54; assign datawi54 = datai[54]; 
wire [width-1:0] datawr55; assign datawr55 = datar[55]; 
wire [width-1:0] datawi55; assign datawi55 = datai[55]; 
wire [width-1:0] datawr56; assign datawr56 = datar[56]; 
wire [width-1:0] datawi56; assign datawi56 = datai[56]; 
wire [width-1:0] datawr57; assign datawr57 = datar[57]; 
wire [width-1:0] datawi57; assign datawi57 = datai[57]; 
wire [width-1:0] datawr58; assign datawr58 = datar[58]; 
wire [width-1:0] datawi58; assign datawi58 = datai[58]; 
wire [width-1:0] datawr59; assign datawr59 = datar[59]; 
wire [width-1:0] datawi59; assign datawi59 = datai[59]; 
wire [width-1:0] datawr60; assign datawr60 = datar[60]; 
wire [width-1:0] datawi60; assign datawi60 = datai[60]; 
wire [width-1:0] datawr61; assign datawr61 = datar[61]; 
wire [width-1:0] datawi61; assign datawi61 = datai[61]; 
wire [width-1:0] datawr62; assign datawr62 = datar[62]; 
wire [width-1:0] datawi62; assign datawi62 = datai[62]; 
wire [width-1:0] datawr63; assign datawr63 = datar[63]; 
wire [width-1:0] datawi63; assign datawi63 = datai[63];


    wire[width-1:0] 
        ar0, ai0, br0, bi0, xr0, xi0, yr0, yi0,
        ar1, ai1, br1, bi1, xr1, xi1, yr1, yi1,
        ar2, ai2, br2, bi2, xr2, xi2, yr2, yi2,
        ar3, ai3, br3, bi3, xr3, xi3, yr3, yi3,
        ar4, ai4, br4, bi4, xr4, xi4, yr4, yi4,
        ar5, ai5, br5, bi5, xr5, xi5, yr5, yi5;

    wire signed [23:0] 
        wr0, wi0,
        wr1, wi1,
        wr2, wi2,
        wr3, wi3,
        wr4, wi4,
        wr5, wi5;

    butterfly butterfly0(.CLK(CLK), .RST(RST), .ar(ar0), .ai(ai0), .br(br0), .bi(bi0), .wr(wr0), .wi(wi0), .xr(xr0), .xi(xi0), .yr(yr0), .yi(yi0));
    butterfly butterfly1(.CLK(CLK), .RST(RST), .ar(ar1), .ai(ai1), .br(br1), .bi(bi1), .wr(wr1), .wi(wi1), .xr(xr1), .xi(xi1), .yr(yr1), .yi(yi1));
    butterfly butterfly2(.CLK(CLK), .RST(RST), .ar(ar2), .ai(ai2), .br(br2), .bi(bi2), .wr(wr2), .wi(wi2), .xr(xr2), .xi(xi2), .yr(yr2), .yi(yi2));
    butterfly butterfly3(.CLK(CLK), .RST(RST), .ar(ar3), .ai(ai3), .br(br3), .bi(bi3), .wr(wr3), .wi(wi3), .xr(xr3), .xi(xi3), .yr(yr3), .yi(yi3));
    butterfly butterfly4(.CLK(CLK), .RST(RST), .ar(ar4), .ai(ai4), .br(br4), .bi(bi4), .wr(wr4), .wi(wi4), .xr(xr4), .xi(xi4), .yr(yr4), .yi(yi4));
    butterfly butterfly5(.CLK(CLK), .RST(RST), .ar(ar5), .ai(ai5), .br(br5), .bi(bi5), .wr(wr5), .wi(wi5), .xr(xr5), .xi(xi5), .yr(yr5), .yi(yi5));

    assign ar0 = 
     state == 2 ? datar[0] : state == 3 ? datar[12] : state == 4 ? datar[6] : state == 5 ? datar[9] : state == 6 ? datar[3] : state == 7 ? datar[15] : state == 8 ? datar[4] : state == 9 ? datar[10] : state == 10 ? datar[1] : state == 11 ? datar[13] : state == 12 ? datar[7] : state == 13 ? datar[16] : state == 14 ? datar[2] : state == 15 ? datar[22] : state == 16 ? datar[5] : state == 17 ? datar[19] : state == 18 ? datar[0] : state == 19 ? datar[24] : state == 20 ? datar[10] : state == 21 ? datar[17] : state == 22 ? datar[3] : state == 23 ? datar[27] : state == 24 ? datar[8] : state == 25 ? datar[20] : state == 26 ? datar[1] : state == 27 ? datar[25] : state == 28 ? datar[13] : state == 29 ? datar[16] : state == 30 ? datar[4] : state == 31 ? datar[28] : state == 32 ? datar[10] : state == 33 ? datar[22] :    0;
    assign ar1 = 
     state == 2 ? datar[16] : state == 3 ? datar[28] : state == 4 ? datar[22] : state == 5 ? datar[25] : state == 6 ? datar[19] : state == 7 ? datar[31] : state == 8 ? datar[36] : state == 9 ? datar[42] : state == 10 ? datar[33] : state == 11 ? datar[45] : state == 12 ? datar[39] : state == 13 ? datar[48] : state == 14 ? datar[34] : state == 15 ? datar[54] : state == 16 ? datar[37] : state == 17 ? datar[51] : state == 18 ? datar[32] : state == 19 ? datar[56] : state == 20 ? datar[42] : state == 21 ? datar[49] : state == 22 ? datar[35] : state == 23 ? datar[59] : state == 24 ? datar[40] : state == 25 ? datar[52] : state == 26 ? datar[33] : state == 27 ? datar[57] : state == 28 ? datar[45] : state == 29 ? datar[48] : state == 30 ? datar[36] : state == 31 ? datar[60] : state == 32 ? datar[42] : state == 33 ? datar[54] :    0;
    assign ar2 = 
     state == 2 ? datar[8] : state == 3 ? datar[2] : state == 4 ? datar[14] : state == 5 ? datar[5] : state == 6 ? datar[11] : state == 7 ? datar[0] : state == 8 ? datar[12] : state == 9 ? datar[6] : state == 10 ? datar[9] : state == 11 ? datar[3] : state == 12 ? datar[15] : state == 13 ? datar[4] : state == 14 ? datar[18] : state == 15 ? datar[1] : state == 16 ? datar[21] : state == 17 ? datar[7] : state == 18 ? datar[16] : state == 19 ? datar[2] : state == 20 ? datar[26] : state == 21 ? datar[9] : state == 22 ? datar[19] : state == 23 ? datar[0] : state == 24 ? datar[24] : state == 25 ? datar[12] : state == 26 ? datar[17] : state == 27 ? datar[5] : state == 28 ? datar[29] : state == 29 ? datar[8] : state == 30 ? datar[20] : state == 31 ? datar[2] : state == 32 ? datar[26] : state == 33 ? datar[14] :    0;
    assign ar3 = 
     state == 2 ? datar[24] : state == 3 ? datar[18] : state == 4 ? datar[30] : state == 5 ? datar[21] : state == 6 ? datar[27] : state == 7 ? datar[32] : state == 8 ? datar[44] : state == 9 ? datar[38] : state == 10 ? datar[41] : state == 11 ? datar[35] : state == 12 ? datar[47] : state == 13 ? datar[36] : state == 14 ? datar[50] : state == 15 ? datar[33] : state == 16 ? datar[53] : state == 17 ? datar[39] : state == 18 ? datar[48] : state == 19 ? datar[34] : state == 20 ? datar[58] : state == 21 ? datar[41] : state == 22 ? datar[51] : state == 23 ? datar[32] : state == 24 ? datar[56] : state == 25 ? datar[44] : state == 26 ? datar[49] : state == 27 ? datar[37] : state == 28 ? datar[61] : state == 29 ? datar[40] : state == 30 ? datar[52] : state == 31 ? datar[34] : state == 32 ? datar[58] : state == 33 ? datar[46] :    0;
    assign ar4 = 
     state == 2 ? datar[4] : state == 3 ? datar[10] : state == 4 ? datar[1] : state == 5 ? datar[13] : state == 6 ? datar[7] : state == 7 ? datar[8] : state == 8 ? datar[2] : state == 9 ? datar[14] : state == 10 ? datar[5] : state == 11 ? datar[11] : state == 12 ? datar[0] : state == 13 ? datar[20] : state == 14 ? datar[6] : state == 15 ? datar[17] : state == 16 ? datar[3] : state == 17 ? datar[23] : state == 18 ? datar[8] : state == 19 ? datar[18] : state == 20 ? datar[1] : state == 21 ? datar[25] : state == 22 ? datar[11] : state == 23 ? datar[16] : state == 24 ? datar[4] : state == 25 ? datar[28] : state == 26 ? datar[9] : state == 27 ? datar[21] : state == 28 ? datar[0] : state == 29 ? datar[24] : state == 30 ? datar[12] : state == 31 ? datar[18] : state == 32 ? datar[6] : state == 33 ? datar[30] :    0;
    assign ar5 = 
     state == 2 ? datar[20] : state == 3 ? datar[26] : state == 4 ? datar[17] : state == 5 ? datar[29] : state == 6 ? datar[23] : state == 7 ? datar[40] : state == 8 ? datar[34] : state == 9 ? datar[46] : state == 10 ? datar[37] : state == 11 ? datar[43] : state == 12 ? datar[32] : state == 13 ? datar[52] : state == 14 ? datar[38] : state == 15 ? datar[49] : state == 16 ? datar[35] : state == 17 ? datar[55] : state == 18 ? datar[40] : state == 19 ? datar[50] : state == 20 ? datar[33] : state == 21 ? datar[57] : state == 22 ? datar[43] : state == 23 ? datar[48] : state == 24 ? datar[36] : state == 25 ? datar[60] : state == 26 ? datar[41] : state == 27 ? datar[53] : state == 28 ? datar[32] : state == 29 ? datar[56] : state == 30 ? datar[44] : state == 31 ? datar[50] : state == 32 ? datar[38] : state == 33 ? datar[62] :    0;
    assign ai0 = 
     state == 2 ? datai[0] : state == 3 ? datai[12] : state == 4 ? datai[6] : state == 5 ? datai[9] : state == 6 ? datai[3] : state == 7 ? datai[15] : state == 8 ? datai[4] : state == 9 ? datai[10] : state == 10 ? datai[1] : state == 11 ? datai[13] : state == 12 ? datai[7] : state == 13 ? datai[16] : state == 14 ? datai[2] : state == 15 ? datai[22] : state == 16 ? datai[5] : state == 17 ? datai[19] : state == 18 ? datai[0] : state == 19 ? datai[24] : state == 20 ? datai[10] : state == 21 ? datai[17] : state == 22 ? datai[3] : state == 23 ? datai[27] : state == 24 ? datai[8] : state == 25 ? datai[20] : state == 26 ? datai[1] : state == 27 ? datai[25] : state == 28 ? datai[13] : state == 29 ? datai[16] : state == 30 ? datai[4] : state == 31 ? datai[28] : state == 32 ? datai[10] : state == 33 ? datai[22] :    0;
    assign ai1 = 
     state == 2 ? datai[16] : state == 3 ? datai[28] : state == 4 ? datai[22] : state == 5 ? datai[25] : state == 6 ? datai[19] : state == 7 ? datai[31] : state == 8 ? datai[36] : state == 9 ? datai[42] : state == 10 ? datai[33] : state == 11 ? datai[45] : state == 12 ? datai[39] : state == 13 ? datai[48] : state == 14 ? datai[34] : state == 15 ? datai[54] : state == 16 ? datai[37] : state == 17 ? datai[51] : state == 18 ? datai[32] : state == 19 ? datai[56] : state == 20 ? datai[42] : state == 21 ? datai[49] : state == 22 ? datai[35] : state == 23 ? datai[59] : state == 24 ? datai[40] : state == 25 ? datai[52] : state == 26 ? datai[33] : state == 27 ? datai[57] : state == 28 ? datai[45] : state == 29 ? datai[48] : state == 30 ? datai[36] : state == 31 ? datai[60] : state == 32 ? datai[42] : state == 33 ? datai[54] :    0;
    assign ai2 = 
     state == 2 ? datai[8] : state == 3 ? datai[2] : state == 4 ? datai[14] : state == 5 ? datai[5] : state == 6 ? datai[11] : state == 7 ? datai[0] : state == 8 ? datai[12] : state == 9 ? datai[6] : state == 10 ? datai[9] : state == 11 ? datai[3] : state == 12 ? datai[15] : state == 13 ? datai[4] : state == 14 ? datai[18] : state == 15 ? datai[1] : state == 16 ? datai[21] : state == 17 ? datai[7] : state == 18 ? datai[16] : state == 19 ? datai[2] : state == 20 ? datai[26] : state == 21 ? datai[9] : state == 22 ? datai[19] : state == 23 ? datai[0] : state == 24 ? datai[24] : state == 25 ? datai[12] : state == 26 ? datai[17] : state == 27 ? datai[5] : state == 28 ? datai[29] : state == 29 ? datai[8] : state == 30 ? datai[20] : state == 31 ? datai[2] : state == 32 ? datai[26] : state == 33 ? datai[14] :    0;
    assign ai3 = 
     state == 2 ? datai[24] : state == 3 ? datai[18] : state == 4 ? datai[30] : state == 5 ? datai[21] : state == 6 ? datai[27] : state == 7 ? datai[32] : state == 8 ? datai[44] : state == 9 ? datai[38] : state == 10 ? datai[41] : state == 11 ? datai[35] : state == 12 ? datai[47] : state == 13 ? datai[36] : state == 14 ? datai[50] : state == 15 ? datai[33] : state == 16 ? datai[53] : state == 17 ? datai[39] : state == 18 ? datai[48] : state == 19 ? datai[34] : state == 20 ? datai[58] : state == 21 ? datai[41] : state == 22 ? datai[51] : state == 23 ? datai[32] : state == 24 ? datai[56] : state == 25 ? datai[44] : state == 26 ? datai[49] : state == 27 ? datai[37] : state == 28 ? datai[61] : state == 29 ? datai[40] : state == 30 ? datai[52] : state == 31 ? datai[34] : state == 32 ? datai[58] : state == 33 ? datai[46] :    0;
    assign ai4 = 
     state == 2 ? datai[4] : state == 3 ? datai[10] : state == 4 ? datai[1] : state == 5 ? datai[13] : state == 6 ? datai[7] : state == 7 ? datai[8] : state == 8 ? datai[2] : state == 9 ? datai[14] : state == 10 ? datai[5] : state == 11 ? datai[11] : state == 12 ? datai[0] : state == 13 ? datai[20] : state == 14 ? datai[6] : state == 15 ? datai[17] : state == 16 ? datai[3] : state == 17 ? datai[23] : state == 18 ? datai[8] : state == 19 ? datai[18] : state == 20 ? datai[1] : state == 21 ? datai[25] : state == 22 ? datai[11] : state == 23 ? datai[16] : state == 24 ? datai[4] : state == 25 ? datai[28] : state == 26 ? datai[9] : state == 27 ? datai[21] : state == 28 ? datai[0] : state == 29 ? datai[24] : state == 30 ? datai[12] : state == 31 ? datai[18] : state == 32 ? datai[6] : state == 33 ? datai[30] :    0;
    assign ai5 = 
     state == 2 ? datai[20] : state == 3 ? datai[26] : state == 4 ? datai[17] : state == 5 ? datai[29] : state == 6 ? datai[23] : state == 7 ? datai[40] : state == 8 ? datai[34] : state == 9 ? datai[46] : state == 10 ? datai[37] : state == 11 ? datai[43] : state == 12 ? datai[32] : state == 13 ? datai[52] : state == 14 ? datai[38] : state == 15 ? datai[49] : state == 16 ? datai[35] : state == 17 ? datai[55] : state == 18 ? datai[40] : state == 19 ? datai[50] : state == 20 ? datai[33] : state == 21 ? datai[57] : state == 22 ? datai[43] : state == 23 ? datai[48] : state == 24 ? datai[36] : state == 25 ? datai[60] : state == 26 ? datai[41] : state == 27 ? datai[53] : state == 28 ? datai[32] : state == 29 ? datai[56] : state == 30 ? datai[44] : state == 31 ? datai[50] : state == 32 ? datai[38] : state == 33 ? datai[62] :    0;
    assign br0 = 
     state == 2 ? datar[32] : state == 3 ? datar[44] : state == 4 ? datar[38] : state == 5 ? datar[41] : state == 6 ? datar[35] : state == 7 ? datar[47] : state == 8 ? datar[20] : state == 9 ? datar[26] : state == 10 ? datar[17] : state == 11 ? datar[29] : state == 12 ? datar[23] : state == 13 ? datar[24] : state == 14 ? datar[10] : state == 15 ? datar[30] : state == 16 ? datar[13] : state == 17 ? datar[27] : state == 18 ? datar[4] : state == 19 ? datar[28] : state == 20 ? datar[14] : state == 21 ? datar[21] : state == 22 ? datar[7] : state == 23 ? datar[31] : state == 24 ? datar[10] : state == 25 ? datar[22] : state == 26 ? datar[3] : state == 27 ? datar[27] : state == 28 ? datar[15] : state == 29 ? datar[17] : state == 30 ? datar[5] : state == 31 ? datar[29] : state == 32 ? datar[11] : state == 33 ? datar[23] :    0;
    assign br1 = 
     state == 2 ? datar[48] : state == 3 ? datar[60] : state == 4 ? datar[54] : state == 5 ? datar[57] : state == 6 ? datar[51] : state == 7 ? datar[63] : state == 8 ? datar[52] : state == 9 ? datar[58] : state == 10 ? datar[49] : state == 11 ? datar[61] : state == 12 ? datar[55] : state == 13 ? datar[56] : state == 14 ? datar[42] : state == 15 ? datar[62] : state == 16 ? datar[45] : state == 17 ? datar[59] : state == 18 ? datar[36] : state == 19 ? datar[60] : state == 20 ? datar[46] : state == 21 ? datar[53] : state == 22 ? datar[39] : state == 23 ? datar[63] : state == 24 ? datar[42] : state == 25 ? datar[54] : state == 26 ? datar[35] : state == 27 ? datar[59] : state == 28 ? datar[47] : state == 29 ? datar[49] : state == 30 ? datar[37] : state == 31 ? datar[61] : state == 32 ? datar[43] : state == 33 ? datar[55] :    0;
    assign br2 = 
     state == 2 ? datar[40] : state == 3 ? datar[34] : state == 4 ? datar[46] : state == 5 ? datar[37] : state == 6 ? datar[43] : state == 7 ? datar[16] : state == 8 ? datar[28] : state == 9 ? datar[22] : state == 10 ? datar[25] : state == 11 ? datar[19] : state == 12 ? datar[31] : state == 13 ? datar[12] : state == 14 ? datar[26] : state == 15 ? datar[9] : state == 16 ? datar[29] : state == 17 ? datar[15] : state == 18 ? datar[20] : state == 19 ? datar[6] : state == 20 ? datar[30] : state == 21 ? datar[13] : state == 22 ? datar[23] : state == 23 ? datar[2] : state == 24 ? datar[26] : state == 25 ? datar[14] : state == 26 ? datar[19] : state == 27 ? datar[7] : state == 28 ? datar[31] : state == 29 ? datar[9] : state == 30 ? datar[21] : state == 31 ? datar[3] : state == 32 ? datar[27] : state == 33 ? datar[15] :    0;
    assign br3 = 
     state == 2 ? datar[56] : state == 3 ? datar[50] : state == 4 ? datar[62] : state == 5 ? datar[53] : state == 6 ? datar[59] : state == 7 ? datar[48] : state == 8 ? datar[60] : state == 9 ? datar[54] : state == 10 ? datar[57] : state == 11 ? datar[51] : state == 12 ? datar[63] : state == 13 ? datar[44] : state == 14 ? datar[58] : state == 15 ? datar[41] : state == 16 ? datar[61] : state == 17 ? datar[47] : state == 18 ? datar[52] : state == 19 ? datar[38] : state == 20 ? datar[62] : state == 21 ? datar[45] : state == 22 ? datar[55] : state == 23 ? datar[34] : state == 24 ? datar[58] : state == 25 ? datar[46] : state == 26 ? datar[51] : state == 27 ? datar[39] : state == 28 ? datar[63] : state == 29 ? datar[41] : state == 30 ? datar[53] : state == 31 ? datar[35] : state == 32 ? datar[59] : state == 33 ? datar[47] :    0;
    assign br4 = 
     state == 2 ? datar[36] : state == 3 ? datar[42] : state == 4 ? datar[33] : state == 5 ? datar[45] : state == 6 ? datar[39] : state == 7 ? datar[24] : state == 8 ? datar[18] : state == 9 ? datar[30] : state == 10 ? datar[21] : state == 11 ? datar[27] : state == 12 ? datar[8] : state == 13 ? datar[28] : state == 14 ? datar[14] : state == 15 ? datar[25] : state == 16 ? datar[11] : state == 17 ? datar[31] : state == 18 ? datar[12] : state == 19 ? datar[22] : state == 20 ? datar[5] : state == 21 ? datar[29] : state == 22 ? datar[15] : state == 23 ? datar[18] : state == 24 ? datar[6] : state == 25 ? datar[30] : state == 26 ? datar[11] : state == 27 ? datar[23] : state == 28 ? datar[1] : state == 29 ? datar[25] : state == 30 ? datar[13] : state == 31 ? datar[19] : state == 32 ? datar[7] : state == 33 ? datar[31] :    0;
    assign br5 = 
     state == 2 ? datar[52] : state == 3 ? datar[58] : state == 4 ? datar[49] : state == 5 ? datar[61] : state == 6 ? datar[55] : state == 7 ? datar[56] : state == 8 ? datar[50] : state == 9 ? datar[62] : state == 10 ? datar[53] : state == 11 ? datar[59] : state == 12 ? datar[40] : state == 13 ? datar[60] : state == 14 ? datar[46] : state == 15 ? datar[57] : state == 16 ? datar[43] : state == 17 ? datar[63] : state == 18 ? datar[44] : state == 19 ? datar[54] : state == 20 ? datar[37] : state == 21 ? datar[61] : state == 22 ? datar[47] : state == 23 ? datar[50] : state == 24 ? datar[38] : state == 25 ? datar[62] : state == 26 ? datar[43] : state == 27 ? datar[55] : state == 28 ? datar[33] : state == 29 ? datar[57] : state == 30 ? datar[45] : state == 31 ? datar[51] : state == 32 ? datar[39] : state == 33 ? datar[63] :    0;
    assign bi0 = 
     state == 2 ? datai[32] : state == 3 ? datai[44] : state == 4 ? datai[38] : state == 5 ? datai[41] : state == 6 ? datai[35] : state == 7 ? datai[47] : state == 8 ? datai[20] : state == 9 ? datai[26] : state == 10 ? datai[17] : state == 11 ? datai[29] : state == 12 ? datai[23] : state == 13 ? datai[24] : state == 14 ? datai[10] : state == 15 ? datai[30] : state == 16 ? datai[13] : state == 17 ? datai[27] : state == 18 ? datai[4] : state == 19 ? datai[28] : state == 20 ? datai[14] : state == 21 ? datai[21] : state == 22 ? datai[7] : state == 23 ? datai[31] : state == 24 ? datai[10] : state == 25 ? datai[22] : state == 26 ? datai[3] : state == 27 ? datai[27] : state == 28 ? datai[15] : state == 29 ? datai[17] : state == 30 ? datai[5] : state == 31 ? datai[29] : state == 32 ? datai[11] : state == 33 ? datai[23] :    0;
    assign bi1 = 
     state == 2 ? datai[48] : state == 3 ? datai[60] : state == 4 ? datai[54] : state == 5 ? datai[57] : state == 6 ? datai[51] : state == 7 ? datai[63] : state == 8 ? datai[52] : state == 9 ? datai[58] : state == 10 ? datai[49] : state == 11 ? datai[61] : state == 12 ? datai[55] : state == 13 ? datai[56] : state == 14 ? datai[42] : state == 15 ? datai[62] : state == 16 ? datai[45] : state == 17 ? datai[59] : state == 18 ? datai[36] : state == 19 ? datai[60] : state == 20 ? datai[46] : state == 21 ? datai[53] : state == 22 ? datai[39] : state == 23 ? datai[63] : state == 24 ? datai[42] : state == 25 ? datai[54] : state == 26 ? datai[35] : state == 27 ? datai[59] : state == 28 ? datai[47] : state == 29 ? datai[49] : state == 30 ? datai[37] : state == 31 ? datai[61] : state == 32 ? datai[43] : state == 33 ? datai[55] :    0;
    assign bi2 = 
     state == 2 ? datai[40] : state == 3 ? datai[34] : state == 4 ? datai[46] : state == 5 ? datai[37] : state == 6 ? datai[43] : state == 7 ? datai[16] : state == 8 ? datai[28] : state == 9 ? datai[22] : state == 10 ? datai[25] : state == 11 ? datai[19] : state == 12 ? datai[31] : state == 13 ? datai[12] : state == 14 ? datai[26] : state == 15 ? datai[9] : state == 16 ? datai[29] : state == 17 ? datai[15] : state == 18 ? datai[20] : state == 19 ? datai[6] : state == 20 ? datai[30] : state == 21 ? datai[13] : state == 22 ? datai[23] : state == 23 ? datai[2] : state == 24 ? datai[26] : state == 25 ? datai[14] : state == 26 ? datai[19] : state == 27 ? datai[7] : state == 28 ? datai[31] : state == 29 ? datai[9] : state == 30 ? datai[21] : state == 31 ? datai[3] : state == 32 ? datai[27] : state == 33 ? datai[15] :    0;
    assign bi3 = 
     state == 2 ? datai[56] : state == 3 ? datai[50] : state == 4 ? datai[62] : state == 5 ? datai[53] : state == 6 ? datai[59] : state == 7 ? datai[48] : state == 8 ? datai[60] : state == 9 ? datai[54] : state == 10 ? datai[57] : state == 11 ? datai[51] : state == 12 ? datai[63] : state == 13 ? datai[44] : state == 14 ? datai[58] : state == 15 ? datai[41] : state == 16 ? datai[61] : state == 17 ? datai[47] : state == 18 ? datai[52] : state == 19 ? datai[38] : state == 20 ? datai[62] : state == 21 ? datai[45] : state == 22 ? datai[55] : state == 23 ? datai[34] : state == 24 ? datai[58] : state == 25 ? datai[46] : state == 26 ? datai[51] : state == 27 ? datai[39] : state == 28 ? datai[63] : state == 29 ? datai[41] : state == 30 ? datai[53] : state == 31 ? datai[35] : state == 32 ? datai[59] : state == 33 ? datai[47] :    0;
    assign bi4 = 
     state == 2 ? datai[36] : state == 3 ? datai[42] : state == 4 ? datai[33] : state == 5 ? datai[45] : state == 6 ? datai[39] : state == 7 ? datai[24] : state == 8 ? datai[18] : state == 9 ? datai[30] : state == 10 ? datai[21] : state == 11 ? datai[27] : state == 12 ? datai[8] : state == 13 ? datai[28] : state == 14 ? datai[14] : state == 15 ? datai[25] : state == 16 ? datai[11] : state == 17 ? datai[31] : state == 18 ? datai[12] : state == 19 ? datai[22] : state == 20 ? datai[5] : state == 21 ? datai[29] : state == 22 ? datai[15] : state == 23 ? datai[18] : state == 24 ? datai[6] : state == 25 ? datai[30] : state == 26 ? datai[11] : state == 27 ? datai[23] : state == 28 ? datai[1] : state == 29 ? datai[25] : state == 30 ? datai[13] : state == 31 ? datai[19] : state == 32 ? datai[7] : state == 33 ? datai[31] :    0;
    assign bi5 = 
     state == 2 ? datai[52] : state == 3 ? datai[58] : state == 4 ? datai[49] : state == 5 ? datai[61] : state == 6 ? datai[55] : state == 7 ? datai[56] : state == 8 ? datai[50] : state == 9 ? datai[62] : state == 10 ? datai[53] : state == 11 ? datai[59] : state == 12 ? datai[40] : state == 13 ? datai[60] : state == 14 ? datai[46] : state == 15 ? datai[57] : state == 16 ? datai[43] : state == 17 ? datai[63] : state == 18 ? datai[44] : state == 19 ? datai[54] : state == 20 ? datai[37] : state == 21 ? datai[61] : state == 22 ? datai[47] : state == 23 ? datai[50] : state == 24 ? datai[38] : state == 25 ? datai[62] : state == 26 ? datai[43] : state == 27 ? datai[55] : state == 28 ? datai[33] : state == 29 ? datai[57] : state == 30 ? datai[45] : state == 31 ? datai[51] : state == 32 ? datai[39] : state == 33 ? datai[63] :    0;
assign wr0 = 
 state == 2 ? 8388607 : state == 3 ? 8388607 : state == 4 ? 8388607 : state == 5 ? 8388607 : state == 6 ? 8388607 : state == 7 ? 8388607 : state == 8 ? 8388607 : state == 9 ? -8388608 : state == 10 ? 8388607 : state == 11 ? -8388608 : state == 12 ? 8388607 : state == 13 ? 0 : state == 14 ? 8388607 : state == 15 ? -1 : state == 16 ? -8388608 : state == 17 ? 0 : state == 18 ? 8388607 : state == 19 ? -5931642 : state == 20 ? -1 : state == 21 ? 5931641 : state == 22 ? -8388608 : state == 23 ? 5931641 : state == 24 ? 5931641 : state == 25 ? -3210182 : state == 26 ? -8388608 : state == 27 ? -3210182 : state == 28 ? 5931641 : state == 29 ? 8227423 : state == 30 ? 5931641 : state == 31 ? 1636536 : state == 32 ? -3210182 : state == 33 ? -6974873 :    0;
assign wr1 = 
 state == 2 ? -8388608 : state == 3 ? -8388608 : state == 4 ? -8388608 : state == 5 ? -8388608 : state == 6 ? -8388608 : state == 7 ? -8388608 : state == 8 ? 0 : state == 9 ? -1 : state == 10 ? 0 : state == 11 ? -1 : state == 12 ? 0 : state == 13 ? -5931642 : state == 14 ? 5931641 : state == 15 ? 5931641 : state == 16 ? -5931642 : state == 17 ? -5931642 : state == 18 ? 7750063 : state == 19 ? -7750064 : state == 20 ? 3210181 : state == 21 ? 3210181 : state == 22 ? -7750064 : state == 23 ? 7750063 : state == 24 ? 4660460 : state == 25 ? -4660461 : state == 26 ? -8227424 : state == 27 ? -1636537 : state == 28 ? 6974872 : state == 29 ? 8027397 : state == 30 ? 5321676 : state == 31 ? 822227 : state == 32 ? -3954363 : state == 33 ? -7398092 :    0;
assign wr2 = 
 state == 2 ? 8388607 : state == 3 ? 8388607 : state == 4 ? 8388607 : state == 5 ? 8388607 : state == 6 ? 8388607 : state == 7 ? 8388607 : state == 8 ? -8388608 : state == 9 ? 8388607 : state == 10 ? -8388608 : state == 11 ? 8388607 : state == 12 ? -8388608 : state == 13 ? -8388608 : state == 14 ? 0 : state == 15 ? 8388607 : state == 16 ? -1 : state == 17 ? -8388608 : state == 18 ? 5931641 : state == 19 ? -8388608 : state == 20 ? 5931641 : state == 21 ? 0 : state == 22 ? -5931642 : state == 23 ? 8388607 : state == 24 ? 3210181 : state == 25 ? -5931642 : state == 26 ? -7750064 : state == 27 ? -1 : state == 28 ? 7750063 : state == 29 ? 7750063 : state == 30 ? 4660460 : state == 31 ? 0 : state == 32 ? -4660461 : state == 33 ? -7750064 :    0;
assign wr3 = 
 state == 2 ? -8388608 : state == 3 ? -8388608 : state == 4 ? -8388608 : state == 5 ? -8388608 : state == 6 ? -8388608 : state == 7 ? 0 : state == 8 ? -1 : state == 9 ? 0 : state == 10 ? -1 : state == 11 ? 0 : state == 12 ? -1 : state == 13 ? -5931642 : state == 14 ? -5931642 : state == 15 ? 5931641 : state == 16 ? 5931641 : state == 17 ? -5931642 : state == 18 ? 3210181 : state == 19 ? -7750064 : state == 20 ? 7750063 : state == 21 ? -3210182 : state == 22 ? -3210182 : state == 23 ? 8227423 : state == 24 ? 1636536 : state == 25 ? -6974873 : state == 26 ? -6974873 : state == 27 ? 1636536 : state == 28 ? 8227423 : state == 29 ? 7398091 : state == 30 ? 3954362 : state == 31 ? -822228 : state == 32 ? -5321677 : state == 33 ? -8027398 :    0;
assign wr4 = 
 state == 2 ? 8388607 : state == 3 ? 8388607 : state == 4 ? 8388607 : state == 5 ? 8388607 : state == 6 ? 8388607 : state == 7 ? -8388608 : state == 8 ? 8388607 : state == 9 ? -8388608 : state == 10 ? 8388607 : state == 11 ? -8388608 : state == 12 ? 8388607 : state == 13 ? -1 : state == 14 ? -8388608 : state == 15 ? 0 : state == 16 ? 8388607 : state == 17 ? -1 : state == 18 ? 0 : state == 19 ? -5931642 : state == 20 ? 8388607 : state == 21 ? -5931642 : state == 22 ? -1 : state == 23 ? 7750063 : state == 24 ? 0 : state == 25 ? -7750064 : state == 26 ? -5931642 : state == 27 ? 3210181 : state == 28 ? 8388607 : state == 29 ? 6974872 : state == 30 ? 3210181 : state == 31 ? -1636537 : state == 32 ? -5931642 : state == 33 ? -8227424 :    0;
assign wr5 = 
 state == 2 ? -8388608 : state == 3 ? -8388608 : state == 4 ? -8388608 : state == 5 ? -8388608 : state == 6 ? -8388608 : state == 7 ? -1 : state == 8 ? 0 : state == 9 ? -1 : state == 10 ? 0 : state == 11 ? -1 : state == 12 ? 5931641 : state == 13 ? 5931641 : state == 14 ? -5931642 : state == 15 ? -5931642 : state == 16 ? 5931641 : state == 17 ? 5931641 : state == 18 ? -3210182 : state == 19 ? -3210182 : state == 20 ? 7750063 : state == 21 ? -7750064 : state == 22 ? 3210181 : state == 23 ? 6974872 : state == 24 ? -1636537 : state == 25 ? -8227424 : state == 26 ? -4660461 : state == 27 ? 4660460 : state == 28 ? 8348214 : state == 29 ? 6484481 : state == 30 ? 2435084 : state == 31 ? -2435085 : state == 32 ? -6484482 : state == 33 ? -8348215 :    0;
assign wi0 = 
 state == 2 ? 0 : state == 3 ? 0 : state == 4 ? 0 : state == 5 ? 0 : state == 6 ? 0 : state == 7 ? 0 : state == 8 ? 0 : state == 9 ? 0 : state == 10 ? 0 : state == 11 ? 0 : state == 12 ? 0 : state == 13 ? 8388607 : state == 14 ? 0 : state == 15 ? -8388608 : state == 16 ? 0 : state == 17 ? 8388607 : state == 18 ? 0 : state == 19 ? 5931641 : state == 20 ? -8388608 : state == 21 ? 5931641 : state == 22 ? 0 : state == 23 ? -5931642 : state == 24 ? 5931641 : state == 25 ? 7750063 : state == 26 ? 0 : state == 27 ? -7750064 : state == 28 ? -5931642 : state == 29 ? 1636536 : state == 30 ? 5931641 : state == 31 ? 8227423 : state == 32 ? 7750063 : state == 33 ? 4660460 :    0;
assign wi1 = 
 state == 2 ? 0 : state == 3 ? 0 : state == 4 ? 0 : state == 5 ? 0 : state == 6 ? 0 : state == 7 ? 0 : state == 8 ? 8388607 : state == 9 ? -8388608 : state == 10 ? 8388607 : state == 11 ? -8388608 : state == 12 ? 8388607 : state == 13 ? 5931641 : state == 14 ? 5931641 : state == 15 ? -5931642 : state == 16 ? -5931642 : state == 17 ? 5931641 : state == 18 ? 3210181 : state == 19 ? 3210181 : state == 20 ? -7750064 : state == 21 ? 7750063 : state == 22 ? -3210182 : state == 23 ? -3210182 : state == 24 ? 6974872 : state == 25 ? 6974872 : state == 26 ? -1636537 : state == 27 ? -8227424 : state == 28 ? -4660461 : state == 29 ? 2435084 : state == 30 ? 6484481 : state == 31 ? 8348214 : state == 32 ? 7398091 : state == 33 ? 3954362 :    0;
assign wi2 = 
 state == 2 ? 0 : state == 3 ? 0 : state == 4 ? 0 : state == 5 ? 0 : state == 6 ? 0 : state == 7 ? 0 : state == 8 ? 0 : state == 9 ? 0 : state == 10 ? 0 : state == 11 ? 0 : state == 12 ? 0 : state == 13 ? 0 : state == 14 ? 8388607 : state == 15 ? 0 : state == 16 ? -8388608 : state == 17 ? 0 : state == 18 ? 5931641 : state == 19 ? 0 : state == 20 ? -5931642 : state == 21 ? 8388607 : state == 22 ? -5931642 : state == 23 ? 0 : state == 24 ? 7750063 : state == 25 ? 5931641 : state == 26 ? -3210182 : state == 27 ? -8388608 : state == 28 ? -3210182 : state == 29 ? 3210181 : state == 30 ? 6974872 : state == 31 ? 8388607 : state == 32 ? 6974872 : state == 33 ? 3210181 :    0;
assign wi3 = 
 state == 2 ? 0 : state == 3 ? 0 : state == 4 ? 0 : state == 5 ? 0 : state == 6 ? 0 : state == 7 ? 8388607 : state == 8 ? -8388608 : state == 9 ? 8388607 : state == 10 ? -8388608 : state == 11 ? 8388607 : state == 12 ? -8388608 : state == 13 ? -5931642 : state == 14 ? 5931641 : state == 15 ? 5931641 : state == 16 ? -5931642 : state == 17 ? -5931642 : state == 18 ? 7750063 : state == 19 ? -3210182 : state == 20 ? -3210182 : state == 21 ? 7750063 : state == 22 ? -7750064 : state == 23 ? 1636536 : state == 24 ? 8227423 : state == 25 ? 4660460 : state == 26 ? -4660461 : state == 27 ? -8227424 : state == 28 ? -1636537 : state == 29 ? 3954362 : state == 30 ? 7398091 : state == 31 ? 8348214 : state == 32 ? 6484481 : state == 33 ? 2435084 :    0;
assign wi4 = 
 state == 2 ? 0 : state == 3 ? 0 : state == 4 ? 0 : state == 5 ? 0 : state == 6 ? 0 : state == 7 ? 0 : state == 8 ? 0 : state == 9 ? 0 : state == 10 ? 0 : state == 11 ? 0 : state == 12 ? 0 : state == 13 ? -8388608 : state == 14 ? 0 : state == 15 ? 8388607 : state == 16 ? 0 : state == 17 ? -8388608 : state == 18 ? 8388607 : state == 19 ? -5931642 : state == 20 ? 0 : state == 21 ? 5931641 : state == 22 ? -8388608 : state == 23 ? 3210181 : state == 24 ? 8388607 : state == 25 ? 3210181 : state == 26 ? -5931642 : state == 27 ? -7750064 : state == 28 ? 0 : state == 29 ? 4660460 : state == 30 ? 7750063 : state == 31 ? 8227423 : state == 32 ? 5931641 : state == 33 ? 1636536 :    0;
assign wi5 = 
 state == 2 ? 0 : state == 3 ? 0 : state == 4 ? 0 : state == 5 ? 0 : state == 6 ? 0 : state == 7 ? -8388608 : state == 8 ? 8388607 : state == 9 ? -8388608 : state == 10 ? 8388607 : state == 11 ? -8388608 : state == 12 ? 5931641 : state == 13 ? -5931642 : state == 14 ? -5931642 : state == 15 ? 5931641 : state == 16 ? 5931641 : state == 17 ? -5931642 : state == 18 ? 7750063 : state == 19 ? -7750064 : state == 20 ? 3210181 : state == 21 ? 3210181 : state == 22 ? -7750064 : state == 23 ? 4660460 : state == 24 ? 8227423 : state == 25 ? 1636536 : state == 26 ? -6974873 : state == 27 ? -6974873 : state == 28 ? 822227 : state == 29 ? 5321676 : state == 30 ? 8027397 : state == 31 ? 8027397 : state == 32 ? 5321676 : state == 33 ? 822227 :    0;

    // 768 = 12 * 64
    // reg[23:0] sintable[0:16];
    // function [width-1:0] wr;
    //     input [5:0] i;
    //     begin
    //         case (i[5:4])
    //             0: w = sintable[i[3:0]];
    //             1: w = sintable[32 - i[3:0]];
    //             2: w = -sintable[i[3:0]];
    //             3: w = -sintable[32 - i[3:0]];
    //         endcase
    //     end
    // endfunction

    // function [width-1:0] wi;
    //     input [5:0] i;
    //     begin
    //         case (i[5:4])
    //             0: w = sintable[32 - i[3:0]];
    //             1: w = -sintable[i[3:0]];
    //             2: w = -sintable[32 - i[3:0]];
    //             3: w = sintable[i[3:0]];
    //         endcase
    //     end
    // endfunction

    // function [5:0] xk;
    //     input [0:5] x;
    //     begin
    //         xk = x;
    //     end
    // endfunction

    assign valid_o = state == 35;
    assign full = state > 1;
    assign xr = datar[samples];
    assign xi = datai[samples];

    always @(posedge CLK) begin
        if(!RST) begin
            // reset 
            samples <= 0;
            state <= 0;
        end else begin
            case(state)
                0: begin
                    if(valid_a) begin
                        datar[samples] <= ar;
                        datai[samples] <= ai;
                        samples <= 1;
                        state <= 1;
                    end
                end
                1: begin
                    if(valid_a) begin
                        // datar << width;
                        // datar <= datar + ar;
                        // datai << width;
                        // datai <= datai + ai;
                        datar[samples] <= ar;
                        datai[samples] <= ai;
                        samples <= samples + 1;
                        if(samples == 64) begin
                            state <= 2;
                            samples <= 0;
                        end
                    end
                end
2: begin
    state <= 3;
end
3: begin
datar[0] <= xr0; datai[0] <= xi0; datar[32] <= yr0; datai[32] <= yi0; 
datar[16] <= xr1; datai[16] <= xi1; datar[48] <= yr1; datai[48] <= yi1; 
datar[8] <= xr2; datai[8] <= xi2; datar[40] <= yr2; datai[40] <= yi2; 
datar[24] <= xr3; datai[24] <= xi3; datar[56] <= yr3; datai[56] <= yi3; 
datar[4] <= xr4; datai[4] <= xi4; datar[36] <= yr4; datai[36] <= yi4; 
datar[20] <= xr5; datai[20] <= xi5; datar[52] <= yr5; datai[52] <= yi5; 
    state <= 4;
end
4: begin
datar[12] <= xr0; datai[12] <= xi0; datar[44] <= yr0; datai[44] <= yi0; 
datar[28] <= xr1; datai[28] <= xi1; datar[60] <= yr1; datai[60] <= yi1; 
datar[2] <= xr2; datai[2] <= xi2; datar[34] <= yr2; datai[34] <= yi2; 
datar[18] <= xr3; datai[18] <= xi3; datar[50] <= yr3; datai[50] <= yi3; 
datar[10] <= xr4; datai[10] <= xi4; datar[42] <= yr4; datai[42] <= yi4; 
datar[26] <= xr5; datai[26] <= xi5; datar[58] <= yr5; datai[58] <= yi5; 
    state <= 5;
end
5: begin
datar[6] <= xr0; datai[6] <= xi0; datar[38] <= yr0; datai[38] <= yi0; 
datar[22] <= xr1; datai[22] <= xi1; datar[54] <= yr1; datai[54] <= yi1; 
datar[14] <= xr2; datai[14] <= xi2; datar[46] <= yr2; datai[46] <= yi2; 
datar[30] <= xr3; datai[30] <= xi3; datar[62] <= yr3; datai[62] <= yi3; 
datar[1] <= xr4; datai[1] <= xi4; datar[33] <= yr4; datai[33] <= yi4; 
datar[17] <= xr5; datai[17] <= xi5; datar[49] <= yr5; datai[49] <= yi5; 
    state <= 6;
end
6: begin
datar[9] <= xr0; datai[9] <= xi0; datar[41] <= yr0; datai[41] <= yi0; 
datar[25] <= xr1; datai[25] <= xi1; datar[57] <= yr1; datai[57] <= yi1; 
datar[5] <= xr2; datai[5] <= xi2; datar[37] <= yr2; datai[37] <= yi2; 
datar[21] <= xr3; datai[21] <= xi3; datar[53] <= yr3; datai[53] <= yi3; 
datar[13] <= xr4; datai[13] <= xi4; datar[45] <= yr4; datai[45] <= yi4; 
datar[29] <= xr5; datai[29] <= xi5; datar[61] <= yr5; datai[61] <= yi5; 
    state <= 7;
end
7: begin
datar[3] <= xr0; datai[3] <= xi0; datar[35] <= yr0; datai[35] <= yi0; 
datar[19] <= xr1; datai[19] <= xi1; datar[51] <= yr1; datai[51] <= yi1; 
datar[11] <= xr2; datai[11] <= xi2; datar[43] <= yr2; datai[43] <= yi2; 
datar[27] <= xr3; datai[27] <= xi3; datar[59] <= yr3; datai[59] <= yi3; 
datar[7] <= xr4; datai[7] <= xi4; datar[39] <= yr4; datai[39] <= yi4; 
datar[23] <= xr5; datai[23] <= xi5; datar[55] <= yr5; datai[55] <= yi5; 
    state <= 8;
end
8: begin
datar[15] <= xr0; datai[15] <= xi0; datar[47] <= yr0; datai[47] <= yi0; 
datar[31] <= xr1; datai[31] <= xi1; datar[63] <= yr1; datai[63] <= yi1; 
datar[0] <= xr2; datai[0] <= xi2; datar[16] <= yr2; datai[16] <= yi2; 
datar[32] <= xr3; datai[32] <= xi3; datar[48] <= yr3; datai[48] <= yi3; 
datar[8] <= xr4; datai[8] <= xi4; datar[24] <= yr4; datai[24] <= yi4; 
datar[40] <= xr5; datai[40] <= xi5; datar[56] <= yr5; datai[56] <= yi5; 
    state <= 9;
end
9: begin
datar[4] <= xr0; datai[4] <= xi0; datar[20] <= yr0; datai[20] <= yi0; 
datar[36] <= xr1; datai[36] <= xi1; datar[52] <= yr1; datai[52] <= yi1; 
datar[12] <= xr2; datai[12] <= xi2; datar[28] <= yr2; datai[28] <= yi2; 
datar[44] <= xr3; datai[44] <= xi3; datar[60] <= yr3; datai[60] <= yi3; 
datar[2] <= xr4; datai[2] <= xi4; datar[18] <= yr4; datai[18] <= yi4; 
datar[34] <= xr5; datai[34] <= xi5; datar[50] <= yr5; datai[50] <= yi5; 
    state <= 10;
end
10: begin
datar[10] <= xr0; datai[10] <= xi0; datar[26] <= yr0; datai[26] <= yi0; 
datar[42] <= xr1; datai[42] <= xi1; datar[58] <= yr1; datai[58] <= yi1; 
datar[6] <= xr2; datai[6] <= xi2; datar[22] <= yr2; datai[22] <= yi2; 
datar[38] <= xr3; datai[38] <= xi3; datar[54] <= yr3; datai[54] <= yi3; 
datar[14] <= xr4; datai[14] <= xi4; datar[30] <= yr4; datai[30] <= yi4; 
datar[46] <= xr5; datai[46] <= xi5; datar[62] <= yr5; datai[62] <= yi5; 
    state <= 11;
end
11: begin
datar[1] <= xr0; datai[1] <= xi0; datar[17] <= yr0; datai[17] <= yi0; 
datar[33] <= xr1; datai[33] <= xi1; datar[49] <= yr1; datai[49] <= yi1; 
datar[9] <= xr2; datai[9] <= xi2; datar[25] <= yr2; datai[25] <= yi2; 
datar[41] <= xr3; datai[41] <= xi3; datar[57] <= yr3; datai[57] <= yi3; 
datar[5] <= xr4; datai[5] <= xi4; datar[21] <= yr4; datai[21] <= yi4; 
datar[37] <= xr5; datai[37] <= xi5; datar[53] <= yr5; datai[53] <= yi5; 
    state <= 12;
end
12: begin
datar[13] <= xr0; datai[13] <= xi0; datar[29] <= yr0; datai[29] <= yi0; 
datar[45] <= xr1; datai[45] <= xi1; datar[61] <= yr1; datai[61] <= yi1; 
datar[3] <= xr2; datai[3] <= xi2; datar[19] <= yr2; datai[19] <= yi2; 
datar[35] <= xr3; datai[35] <= xi3; datar[51] <= yr3; datai[51] <= yi3; 
datar[11] <= xr4; datai[11] <= xi4; datar[27] <= yr4; datai[27] <= yi4; 
datar[43] <= xr5; datai[43] <= xi5; datar[59] <= yr5; datai[59] <= yi5; 
    state <= 13;
end
13: begin
datar[7] <= xr0; datai[7] <= xi0; datar[23] <= yr0; datai[23] <= yi0; 
datar[39] <= xr1; datai[39] <= xi1; datar[55] <= yr1; datai[55] <= yi1; 
datar[15] <= xr2; datai[15] <= xi2; datar[31] <= yr2; datai[31] <= yi2; 
datar[47] <= xr3; datai[47] <= xi3; datar[63] <= yr3; datai[63] <= yi3; 
datar[0] <= xr4; datai[0] <= xi4; datar[8] <= yr4; datai[8] <= yi4; 
datar[32] <= xr5; datai[32] <= xi5; datar[40] <= yr5; datai[40] <= yi5; 
    state <= 14;
end
14: begin
datar[16] <= xr0; datai[16] <= xi0; datar[24] <= yr0; datai[24] <= yi0; 
datar[48] <= xr1; datai[48] <= xi1; datar[56] <= yr1; datai[56] <= yi1; 
datar[4] <= xr2; datai[4] <= xi2; datar[12] <= yr2; datai[12] <= yi2; 
datar[36] <= xr3; datai[36] <= xi3; datar[44] <= yr3; datai[44] <= yi3; 
datar[20] <= xr4; datai[20] <= xi4; datar[28] <= yr4; datai[28] <= yi4; 
datar[52] <= xr5; datai[52] <= xi5; datar[60] <= yr5; datai[60] <= yi5; 
    state <= 15;
end
15: begin
datar[2] <= xr0; datai[2] <= xi0; datar[10] <= yr0; datai[10] <= yi0; 
datar[34] <= xr1; datai[34] <= xi1; datar[42] <= yr1; datai[42] <= yi1; 
datar[18] <= xr2; datai[18] <= xi2; datar[26] <= yr2; datai[26] <= yi2; 
datar[50] <= xr3; datai[50] <= xi3; datar[58] <= yr3; datai[58] <= yi3; 
datar[6] <= xr4; datai[6] <= xi4; datar[14] <= yr4; datai[14] <= yi4; 
datar[38] <= xr5; datai[38] <= xi5; datar[46] <= yr5; datai[46] <= yi5; 
    state <= 16;
end
16: begin
datar[22] <= xr0; datai[22] <= xi0; datar[30] <= yr0; datai[30] <= yi0; 
datar[54] <= xr1; datai[54] <= xi1; datar[62] <= yr1; datai[62] <= yi1; 
datar[1] <= xr2; datai[1] <= xi2; datar[9] <= yr2; datai[9] <= yi2; 
datar[33] <= xr3; datai[33] <= xi3; datar[41] <= yr3; datai[41] <= yi3; 
datar[17] <= xr4; datai[17] <= xi4; datar[25] <= yr4; datai[25] <= yi4; 
datar[49] <= xr5; datai[49] <= xi5; datar[57] <= yr5; datai[57] <= yi5; 
    state <= 17;
end
17: begin
datar[5] <= xr0; datai[5] <= xi0; datar[13] <= yr0; datai[13] <= yi0; 
datar[37] <= xr1; datai[37] <= xi1; datar[45] <= yr1; datai[45] <= yi1; 
datar[21] <= xr2; datai[21] <= xi2; datar[29] <= yr2; datai[29] <= yi2; 
datar[53] <= xr3; datai[53] <= xi3; datar[61] <= yr3; datai[61] <= yi3; 
datar[3] <= xr4; datai[3] <= xi4; datar[11] <= yr4; datai[11] <= yi4; 
datar[35] <= xr5; datai[35] <= xi5; datar[43] <= yr5; datai[43] <= yi5; 
    state <= 18;
end
18: begin
datar[19] <= xr0; datai[19] <= xi0; datar[27] <= yr0; datai[27] <= yi0; 
datar[51] <= xr1; datai[51] <= xi1; datar[59] <= yr1; datai[59] <= yi1; 
datar[7] <= xr2; datai[7] <= xi2; datar[15] <= yr2; datai[15] <= yi2; 
datar[39] <= xr3; datai[39] <= xi3; datar[47] <= yr3; datai[47] <= yi3; 
datar[23] <= xr4; datai[23] <= xi4; datar[31] <= yr4; datai[31] <= yi4; 
datar[55] <= xr5; datai[55] <= xi5; datar[63] <= yr5; datai[63] <= yi5; 
    state <= 19;
end
19: begin
datar[0] <= xr0; datai[0] <= xi0; datar[4] <= yr0; datai[4] <= yi0; 
datar[32] <= xr1; datai[32] <= xi1; datar[36] <= yr1; datai[36] <= yi1; 
datar[16] <= xr2; datai[16] <= xi2; datar[20] <= yr2; datai[20] <= yi2; 
datar[48] <= xr3; datai[48] <= xi3; datar[52] <= yr3; datai[52] <= yi3; 
datar[8] <= xr4; datai[8] <= xi4; datar[12] <= yr4; datai[12] <= yi4; 
datar[40] <= xr5; datai[40] <= xi5; datar[44] <= yr5; datai[44] <= yi5; 
    state <= 20;
end
20: begin
datar[24] <= xr0; datai[24] <= xi0; datar[28] <= yr0; datai[28] <= yi0; 
datar[56] <= xr1; datai[56] <= xi1; datar[60] <= yr1; datai[60] <= yi1; 
datar[2] <= xr2; datai[2] <= xi2; datar[6] <= yr2; datai[6] <= yi2; 
datar[34] <= xr3; datai[34] <= xi3; datar[38] <= yr3; datai[38] <= yi3; 
datar[18] <= xr4; datai[18] <= xi4; datar[22] <= yr4; datai[22] <= yi4; 
datar[50] <= xr5; datai[50] <= xi5; datar[54] <= yr5; datai[54] <= yi5; 
    state <= 21;
end
21: begin
datar[10] <= xr0; datai[10] <= xi0; datar[14] <= yr0; datai[14] <= yi0; 
datar[42] <= xr1; datai[42] <= xi1; datar[46] <= yr1; datai[46] <= yi1; 
datar[26] <= xr2; datai[26] <= xi2; datar[30] <= yr2; datai[30] <= yi2; 
datar[58] <= xr3; datai[58] <= xi3; datar[62] <= yr3; datai[62] <= yi3; 
datar[1] <= xr4; datai[1] <= xi4; datar[5] <= yr4; datai[5] <= yi4; 
datar[33] <= xr5; datai[33] <= xi5; datar[37] <= yr5; datai[37] <= yi5; 
    state <= 22;
end
22: begin
datar[17] <= xr0; datai[17] <= xi0; datar[21] <= yr0; datai[21] <= yi0; 
datar[49] <= xr1; datai[49] <= xi1; datar[53] <= yr1; datai[53] <= yi1; 
datar[9] <= xr2; datai[9] <= xi2; datar[13] <= yr2; datai[13] <= yi2; 
datar[41] <= xr3; datai[41] <= xi3; datar[45] <= yr3; datai[45] <= yi3; 
datar[25] <= xr4; datai[25] <= xi4; datar[29] <= yr4; datai[29] <= yi4; 
datar[57] <= xr5; datai[57] <= xi5; datar[61] <= yr5; datai[61] <= yi5; 
    state <= 23;
end
23: begin
datar[3] <= xr0; datai[3] <= xi0; datar[7] <= yr0; datai[7] <= yi0; 
datar[35] <= xr1; datai[35] <= xi1; datar[39] <= yr1; datai[39] <= yi1; 
datar[19] <= xr2; datai[19] <= xi2; datar[23] <= yr2; datai[23] <= yi2; 
datar[51] <= xr3; datai[51] <= xi3; datar[55] <= yr3; datai[55] <= yi3; 
datar[11] <= xr4; datai[11] <= xi4; datar[15] <= yr4; datai[15] <= yi4; 
datar[43] <= xr5; datai[43] <= xi5; datar[47] <= yr5; datai[47] <= yi5; 
    state <= 24;
end
24: begin
datar[27] <= xr0; datai[27] <= xi0; datar[31] <= yr0; datai[31] <= yi0; 
datar[59] <= xr1; datai[59] <= xi1; datar[63] <= yr1; datai[63] <= yi1; 
datar[0] <= xr2; datai[0] <= xi2; datar[2] <= yr2; datai[2] <= yi2; 
datar[32] <= xr3; datai[32] <= xi3; datar[34] <= yr3; datai[34] <= yi3; 
datar[16] <= xr4; datai[16] <= xi4; datar[18] <= yr4; datai[18] <= yi4; 
datar[48] <= xr5; datai[48] <= xi5; datar[50] <= yr5; datai[50] <= yi5; 
    state <= 25;
end
25: begin
datar[8] <= xr0; datai[8] <= xi0; datar[10] <= yr0; datai[10] <= yi0; 
datar[40] <= xr1; datai[40] <= xi1; datar[42] <= yr1; datai[42] <= yi1; 
datar[24] <= xr2; datai[24] <= xi2; datar[26] <= yr2; datai[26] <= yi2; 
datar[56] <= xr3; datai[56] <= xi3; datar[58] <= yr3; datai[58] <= yi3; 
datar[4] <= xr4; datai[4] <= xi4; datar[6] <= yr4; datai[6] <= yi4; 
datar[36] <= xr5; datai[36] <= xi5; datar[38] <= yr5; datai[38] <= yi5; 
    state <= 26;
end
26: begin
datar[20] <= xr0; datai[20] <= xi0; datar[22] <= yr0; datai[22] <= yi0; 
datar[52] <= xr1; datai[52] <= xi1; datar[54] <= yr1; datai[54] <= yi1; 
datar[12] <= xr2; datai[12] <= xi2; datar[14] <= yr2; datai[14] <= yi2; 
datar[44] <= xr3; datai[44] <= xi3; datar[46] <= yr3; datai[46] <= yi3; 
datar[28] <= xr4; datai[28] <= xi4; datar[30] <= yr4; datai[30] <= yi4; 
datar[60] <= xr5; datai[60] <= xi5; datar[62] <= yr5; datai[62] <= yi5; 
    state <= 27;
end
27: begin
datar[1] <= xr0; datai[1] <= xi0; datar[3] <= yr0; datai[3] <= yi0; 
datar[33] <= xr1; datai[33] <= xi1; datar[35] <= yr1; datai[35] <= yi1; 
datar[17] <= xr2; datai[17] <= xi2; datar[19] <= yr2; datai[19] <= yi2; 
datar[49] <= xr3; datai[49] <= xi3; datar[51] <= yr3; datai[51] <= yi3; 
datar[9] <= xr4; datai[9] <= xi4; datar[11] <= yr4; datai[11] <= yi4; 
datar[41] <= xr5; datai[41] <= xi5; datar[43] <= yr5; datai[43] <= yi5; 
    state <= 28;
end
28: begin
datar[25] <= xr0; datai[25] <= xi0; datar[27] <= yr0; datai[27] <= yi0; 
datar[57] <= xr1; datai[57] <= xi1; datar[59] <= yr1; datai[59] <= yi1; 
datar[5] <= xr2; datai[5] <= xi2; datar[7] <= yr2; datai[7] <= yi2; 
datar[37] <= xr3; datai[37] <= xi3; datar[39] <= yr3; datai[39] <= yi3; 
datar[21] <= xr4; datai[21] <= xi4; datar[23] <= yr4; datai[23] <= yi4; 
datar[53] <= xr5; datai[53] <= xi5; datar[55] <= yr5; datai[55] <= yi5; 
    state <= 29;
end
29: begin
datar[13] <= xr0; datai[13] <= xi0; datar[15] <= yr0; datai[15] <= yi0; 
datar[45] <= xr1; datai[45] <= xi1; datar[47] <= yr1; datai[47] <= yi1; 
datar[29] <= xr2; datai[29] <= xi2; datar[31] <= yr2; datai[31] <= yi2; 
datar[61] <= xr3; datai[61] <= xi3; datar[63] <= yr3; datai[63] <= yi3; 
datar[0] <= xr4; datai[0] <= xi4; datar[1] <= yr4; datai[1] <= yi4; 
datar[32] <= xr5; datai[32] <= xi5; datar[33] <= yr5; datai[33] <= yi5; 
    state <= 30;
end
30: begin
datar[16] <= xr0; datai[16] <= xi0; datar[17] <= yr0; datai[17] <= yi0; 
datar[48] <= xr1; datai[48] <= xi1; datar[49] <= yr1; datai[49] <= yi1; 
datar[8] <= xr2; datai[8] <= xi2; datar[9] <= yr2; datai[9] <= yi2; 
datar[40] <= xr3; datai[40] <= xi3; datar[41] <= yr3; datai[41] <= yi3; 
datar[24] <= xr4; datai[24] <= xi4; datar[25] <= yr4; datai[25] <= yi4; 
datar[56] <= xr5; datai[56] <= xi5; datar[57] <= yr5; datai[57] <= yi5; 
    state <= 31;
end
31: begin
datar[4] <= xr0; datai[4] <= xi0; datar[5] <= yr0; datai[5] <= yi0; 
datar[36] <= xr1; datai[36] <= xi1; datar[37] <= yr1; datai[37] <= yi1; 
datar[20] <= xr2; datai[20] <= xi2; datar[21] <= yr2; datai[21] <= yi2; 
datar[52] <= xr3; datai[52] <= xi3; datar[53] <= yr3; datai[53] <= yi3; 
datar[12] <= xr4; datai[12] <= xi4; datar[13] <= yr4; datai[13] <= yi4; 
datar[44] <= xr5; datai[44] <= xi5; datar[45] <= yr5; datai[45] <= yi5; 
    state <= 32;
end
32: begin
datar[28] <= xr0; datai[28] <= xi0; datar[29] <= yr0; datai[29] <= yi0; 
datar[60] <= xr1; datai[60] <= xi1; datar[61] <= yr1; datai[61] <= yi1; 
datar[2] <= xr2; datai[2] <= xi2; datar[3] <= yr2; datai[3] <= yi2; 
datar[34] <= xr3; datai[34] <= xi3; datar[35] <= yr3; datai[35] <= yi3; 
datar[18] <= xr4; datai[18] <= xi4; datar[19] <= yr4; datai[19] <= yi4; 
datar[50] <= xr5; datai[50] <= xi5; datar[51] <= yr5; datai[51] <= yi5; 
    state <= 33;
end
33: begin
datar[10] <= xr0; datai[10] <= xi0; datar[11] <= yr0; datai[11] <= yi0; 
datar[42] <= xr1; datai[42] <= xi1; datar[43] <= yr1; datai[43] <= yi1; 
datar[26] <= xr2; datai[26] <= xi2; datar[27] <= yr2; datai[27] <= yi2; 
datar[58] <= xr3; datai[58] <= xi3; datar[59] <= yr3; datai[59] <= yi3; 
datar[6] <= xr4; datai[6] <= xi4; datar[7] <= yr4; datai[7] <= yi4; 
datar[38] <= xr5; datai[38] <= xi5; datar[39] <= yr5; datai[39] <= yi5; 
    state <= 34;
end
34: begin
datar[22] <= xr0; datai[22] <= xi0; datar[23] <= yr0; datai[23] <= yi0; 
datar[54] <= xr1; datai[54] <= xi1; datar[55] <= yr1; datai[55] <= yi1; 
datar[14] <= xr2; datai[14] <= xi2; datar[15] <= yr2; datai[15] <= yi2; 
datar[46] <= xr3; datai[46] <= xi3; datar[47] <= yr3; datai[47] <= yi3; 
datar[30] <= xr4; datai[30] <= xi4; datar[31] <= yr4; datai[31] <= yi4; 
datar[62] <= xr5; datai[62] <= xi5; datar[63] <= yr5; datai[63] <= yi5; 
    state <= 35;
end
35: begin
    samples <= samples + 1;
    if(samples == 63) begin
        state <= 0;
        samples <= 0;
    end
end
            endcase
        end
    end
endmodule
