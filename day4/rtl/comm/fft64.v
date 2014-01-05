/* verilator lint_off WIDTH */

// 乗算器
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
    wire signed [width-1+20:0] sbr, sbi;
    wire msbr, msbi, carryr, carryi;

    // * でつぶれてしまう
    // assign sbr = (br * wr) - (bi * wi);
    // assign sbi = (br * wi) + (bi * wr);

    // assign wbr = sbr >>> 11;
    // assign wbi = sbi >>> 11;

    // always @(posedge CLK) begin
    //     xr <= ar + wbr;
    //     xi <= ai + wbi;
    //     yr <= ar - wbr;
    //     yi <= ai - wbi;
    // end

    assign sbr = (((ar - br) * wr) - ((ai - bi) * wi));
    assign sbi = (((ar - br) * wi) + ((ai - bi) * wr));

    assign msbr = sbr[width-1+20];
    assign msbi = sbi[width-1+20];

    assign carryr = sbr[18];
    assign carryi = sbi[18];

    assign wbr = sbr >>> 19;
    assign wbi = sbi >>> 19;

    // sddd dddd dddd *
    // sbbb bbbb bbbb bbbb
    // sddd dddd dddd nnnn nnnn nnnn nnnn >>> 15
    // s000 0000 0000 0000 0000 ddd dddd dddd n

    always @(posedge CLK) begin
        xr <= ar + br;
        xi <= ai + bi;
        // 四捨五入
        // yr <= sbr[width-1+16:16] + (sbr[17] ? (sbr[width-1+16] ? -1 : 1) : 0);
        // yi <= sbi[width-1+16:16] + (sbi[17] ? (sbi[width-1+16] ? -1 : 1) : 0);
        // yr <= (sbr >>> 15) + (carryr ? (sbr[width-1+16] ? 1 : -1) : 0);
        // yi <= (sbi >>> 15) + (carryi ? (sbi[width-1+16] ? 1 : -1) : 0);
        yr <= wbr + carryr;
        yi <= wbi + carryi;
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
 state == 2 ? datar[0] : state == 3 ? datar[6] : state == 4 ? datar[12] : state == 5 ? datar[18] : state == 6 ? datar[24] : state == 7 ? datar[30] : state == 8 ? datar[4] : state == 9 ? datar[10] : state == 10 ? datar[32] : state == 11 ? datar[38] : state == 12 ? datar[44] : state == 13 ? datar[2] : state == 14 ? datar[16] : state == 15 ? datar[22] : state == 16 ? datar[36] : state == 17 ? datar[50] : state == 18 ? datar[0] : state == 19 ? datar[10] : state == 20 ? datar[24] : state == 21 ? datar[34] : state == 22 ? datar[48] : state == 23 ? datar[58] : state == 24 ? datar[8] : state == 25 ? datar[20] : state == 26 ? datar[32] : state == 27 ? datar[44] : state == 28 ? datar[56] : state == 29 ? datar[4] : state == 30 ? datar[16] : state == 31 ? datar[28] : state == 32 ? datar[40] : state == 33 ? datar[52] :    0;
assign ai0 =
 state == 2 ? datai[0] : state == 3 ? datai[6] : state == 4 ? datai[12] : state == 5 ? datai[18] : state == 6 ? datai[24] : state == 7 ? datai[30] : state == 8 ? datai[4] : state == 9 ? datai[10] : state == 10 ? datai[32] : state == 11 ? datai[38] : state == 12 ? datai[44] : state == 13 ? datai[2] : state == 14 ? datai[16] : state == 15 ? datai[22] : state == 16 ? datai[36] : state == 17 ? datai[50] : state == 18 ? datai[0] : state == 19 ? datai[10] : state == 20 ? datai[24] : state == 21 ? datai[34] : state == 22 ? datai[48] : state == 23 ? datai[58] : state == 24 ? datai[8] : state == 25 ? datai[20] : state == 26 ? datai[32] : state == 27 ? datai[44] : state == 28 ? datai[56] : state == 29 ? datai[4] : state == 30 ? datai[16] : state == 31 ? datai[28] : state == 32 ? datai[40] : state == 33 ? datai[52] :    0;
assign br0 =
 state == 2 ? datar[32] : state == 3 ? datar[38] : state == 4 ? datar[44] : state == 5 ? datar[50] : state == 6 ? datar[56] : state == 7 ? datar[62] : state == 8 ? datar[20] : state == 9 ? datar[26] : state == 10 ? datar[48] : state == 11 ? datar[54] : state == 12 ? datar[60] : state == 13 ? datar[10] : state == 14 ? datar[24] : state == 15 ? datar[30] : state == 16 ? datar[44] : state == 17 ? datar[58] : state == 18 ? datar[4] : state == 19 ? datar[14] : state == 20 ? datar[28] : state == 21 ? datar[38] : state == 22 ? datar[52] : state == 23 ? datar[62] : state == 24 ? datar[10] : state == 25 ? datar[22] : state == 26 ? datar[34] : state == 27 ? datar[46] : state == 28 ? datar[58] : state == 29 ? datar[5] : state == 30 ? datar[17] : state == 31 ? datar[29] : state == 32 ? datar[41] : state == 33 ? datar[53] :    0;
assign bi0 =
 state == 2 ? datai[32] : state == 3 ? datai[38] : state == 4 ? datai[44] : state == 5 ? datai[50] : state == 6 ? datai[56] : state == 7 ? datai[62] : state == 8 ? datai[20] : state == 9 ? datai[26] : state == 10 ? datai[48] : state == 11 ? datai[54] : state == 12 ? datai[60] : state == 13 ? datai[10] : state == 14 ? datai[24] : state == 15 ? datai[30] : state == 16 ? datai[44] : state == 17 ? datai[58] : state == 18 ? datai[4] : state == 19 ? datai[14] : state == 20 ? datai[28] : state == 21 ? datai[38] : state == 22 ? datai[52] : state == 23 ? datai[62] : state == 24 ? datai[10] : state == 25 ? datai[22] : state == 26 ? datai[34] : state == 27 ? datai[46] : state == 28 ? datai[58] : state == 29 ? datai[5] : state == 30 ? datai[17] : state == 31 ? datai[29] : state == 32 ? datai[41] : state == 33 ? datai[53] :    0;
assign wr0 =
 state == 2 ? 524288 : state == 3 ? 435930 : state == 4 ? 200636 : state == 5 ? -102284 : state == 6 ? -370728 : state == 7 ? -514214 : state == 8 ? 370728 : state == 9 ? -200636 : state == 10 ? 524288 : state == 11 ? 200636 : state == 12 ? -370728 : state == 13 ? 370728 : state == 14 ? 524288 : state == 15 ? -370728 : state == 16 ? 0 : state == 17 ? 370728 : state == 18 ? 524288 : state == 19 ? 0 : state == 20 ? 524288 : state == 21 ? 0 : state == 22 ? 524288 : state == 23 ? 0 : state == 24 ? 524288 : state == 25 ? 524288 : state == 26 ? 524288 : state == 27 ? 524288 : state == 28 ? 524288 : state == 29 ? 524288 : state == 30 ? 524288 : state == 31 ? 524288 : state == 32 ? 524288 : state == 33 ? 524288 :    0;
assign wi0 =
 state == 2 ? 0 : state == 3 ? -291279 : state == 4 ? -484379 : state == 5 ? -514214 : state == 6 ? -370728 : state == 7 ? -102284 : state == 8 ? -370728 : state == 9 ? -484379 : state == 10 ? 0 : state == 11 ? -484379 : state == 12 ? -370728 : state == 13 ? -370728 : state == 14 ? 0 : state == 15 ? -370728 : state == 16 ? -524288 : state == 17 ? -370728 : state == 18 ? 0 : state == 19 ? -524288 : state == 20 ? 0 : state == 21 ? -524288 : state == 22 ? 0 : state == 23 ? -524288 : state == 24 ? 0 : state == 25 ? 0 : state == 26 ? 0 : state == 27 ? 0 : state == 28 ? 0 : state == 29 ? 0 : state == 30 ? 0 : state == 31 ? 0 : state == 32 ? 0 : state == 33 ? 0 :    0;
assign ar1 =
 state == 2 ? datar[1] : state == 3 ? datar[7] : state == 4 ? datar[13] : state == 5 ? datar[19] : state == 6 ? datar[25] : state == 7 ? datar[31] : state == 8 ? datar[5] : state == 9 ? datar[11] : state == 10 ? datar[33] : state == 11 ? datar[39] : state == 12 ? datar[45] : state == 13 ? datar[3] : state == 14 ? datar[17] : state == 15 ? datar[23] : state == 16 ? datar[37] : state == 17 ? datar[51] : state == 18 ? datar[1] : state == 19 ? datar[11] : state == 20 ? datar[25] : state == 21 ? datar[35] : state == 22 ? datar[49] : state == 23 ? datar[59] : state == 24 ? datar[9] : state == 25 ? datar[21] : state == 26 ? datar[33] : state == 27 ? datar[45] : state == 28 ? datar[57] : state == 29 ? datar[6] : state == 30 ? datar[18] : state == 31 ? datar[30] : state == 32 ? datar[42] : state == 33 ? datar[54] :    0;
assign ai1 =
 state == 2 ? datai[1] : state == 3 ? datai[7] : state == 4 ? datai[13] : state == 5 ? datai[19] : state == 6 ? datai[25] : state == 7 ? datai[31] : state == 8 ? datai[5] : state == 9 ? datai[11] : state == 10 ? datai[33] : state == 11 ? datai[39] : state == 12 ? datai[45] : state == 13 ? datai[3] : state == 14 ? datai[17] : state == 15 ? datai[23] : state == 16 ? datai[37] : state == 17 ? datai[51] : state == 18 ? datai[1] : state == 19 ? datai[11] : state == 20 ? datai[25] : state == 21 ? datai[35] : state == 22 ? datai[49] : state == 23 ? datai[59] : state == 24 ? datai[9] : state == 25 ? datai[21] : state == 26 ? datai[33] : state == 27 ? datai[45] : state == 28 ? datai[57] : state == 29 ? datai[6] : state == 30 ? datai[18] : state == 31 ? datai[30] : state == 32 ? datai[42] : state == 33 ? datai[54] :    0;
assign br1 =
 state == 2 ? datar[33] : state == 3 ? datar[39] : state == 4 ? datar[45] : state == 5 ? datar[51] : state == 6 ? datar[57] : state == 7 ? datar[63] : state == 8 ? datar[21] : state == 9 ? datar[27] : state == 10 ? datar[49] : state == 11 ? datar[55] : state == 12 ? datar[61] : state == 13 ? datar[11] : state == 14 ? datar[25] : state == 15 ? datar[31] : state == 16 ? datar[45] : state == 17 ? datar[59] : state == 18 ? datar[5] : state == 19 ? datar[15] : state == 20 ? datar[29] : state == 21 ? datar[39] : state == 22 ? datar[53] : state == 23 ? datar[63] : state == 24 ? datar[11] : state == 25 ? datar[23] : state == 26 ? datar[35] : state == 27 ? datar[47] : state == 28 ? datar[59] : state == 29 ? datar[7] : state == 30 ? datar[19] : state == 31 ? datar[31] : state == 32 ? datar[43] : state == 33 ? datar[55] :    0;
assign bi1 =
 state == 2 ? datai[33] : state == 3 ? datai[39] : state == 4 ? datai[45] : state == 5 ? datai[51] : state == 6 ? datai[57] : state == 7 ? datai[63] : state == 8 ? datai[21] : state == 9 ? datai[27] : state == 10 ? datai[49] : state == 11 ? datai[55] : state == 12 ? datai[61] : state == 13 ? datai[11] : state == 14 ? datai[25] : state == 15 ? datai[31] : state == 16 ? datai[45] : state == 17 ? datai[59] : state == 18 ? datai[5] : state == 19 ? datai[15] : state == 20 ? datai[29] : state == 21 ? datai[39] : state == 22 ? datai[53] : state == 23 ? datai[63] : state == 24 ? datai[11] : state == 25 ? datai[23] : state == 26 ? datai[35] : state == 27 ? datai[47] : state == 28 ? datai[59] : state == 29 ? datai[7] : state == 30 ? datai[19] : state == 31 ? datai[31] : state == 32 ? datai[43] : state == 33 ? datai[55] :    0;
assign wr1 =
 state == 2 ? 521763 : state == 3 ? 405280 : state == 4 ? 152193 : state == 5 ? -152193 : state == 6 ? -405280 : state == 7 ? -521763 : state == 8 ? 291279 : state == 9 ? -291279 : state == 10 ? 514214 : state == 11 ? 102284 : state == 12 ? -435930 : state == 13 ? 200636 : state == 14 ? 484379 : state == 15 ? -484379 : state == 16 ? -200636 : state == 17 ? 200636 : state == 18 ? 370728 : state == 19 ? -370728 : state == 20 ? 370728 : state == 21 ? -370728 : state == 22 ? 370728 : state == 23 ? -370728 : state == 24 ? 0 : state == 25 ? 0 : state == 26 ? 0 : state == 27 ? 0 : state == 28 ? 0 : state == 29 ? 524288 : state == 30 ? 524288 : state == 31 ? 524288 : state == 32 ? 524288 : state == 33 ? 524288 :    0;
assign wi1 =
 state == 2 ? -51389 : state == 3 ? -332605 : state == 4 ? -501712 : state == 5 ? -501712 : state == 6 ? -332605 : state == 7 ? -51389 : state == 8 ? -435930 : state == 9 ? -435930 : state == 10 ? -102284 : state == 11 ? -514214 : state == 12 ? -291279 : state == 13 ? -484379 : state == 14 ? -200636 : state == 15 ? -200636 : state == 16 ? -484379 : state == 17 ? -484379 : state == 18 ? -370728 : state == 19 ? -370728 : state == 20 ? -370728 : state == 21 ? -370728 : state == 22 ? -370728 : state == 23 ? -370728 : state == 24 ? -524288 : state == 25 ? -524288 : state == 26 ? -524288 : state == 27 ? -524288 : state == 28 ? -524288 : state == 29 ? 0 : state == 30 ? 0 : state == 31 ? 0 : state == 32 ? 0 : state == 33 ? 0 :    0;
assign ar2 =
 state == 2 ? datar[2] : state == 3 ? datar[8] : state == 4 ? datar[14] : state == 5 ? datar[20] : state == 6 ? datar[26] : state == 7 ? datar[0] : state == 8 ? datar[6] : state == 9 ? datar[12] : state == 10 ? datar[34] : state == 11 ? datar[40] : state == 12 ? datar[46] : state == 13 ? datar[4] : state == 14 ? datar[18] : state == 15 ? datar[32] : state == 16 ? datar[38] : state == 17 ? datar[52] : state == 18 ? datar[2] : state == 19 ? datar[16] : state == 20 ? datar[26] : state == 21 ? datar[40] : state == 22 ? datar[50] : state == 23 ? datar[0] : state == 24 ? datar[12] : state == 25 ? datar[24] : state == 26 ? datar[36] : state == 27 ? datar[48] : state == 28 ? datar[60] : state == 29 ? datar[8] : state == 30 ? datar[20] : state == 31 ? datar[32] : state == 32 ? datar[44] : state == 33 ? datar[56] :    0;
assign ai2 =
 state == 2 ? datai[2] : state == 3 ? datai[8] : state == 4 ? datai[14] : state == 5 ? datai[20] : state == 6 ? datai[26] : state == 7 ? datai[0] : state == 8 ? datai[6] : state == 9 ? datai[12] : state == 10 ? datai[34] : state == 11 ? datai[40] : state == 12 ? datai[46] : state == 13 ? datai[4] : state == 14 ? datai[18] : state == 15 ? datai[32] : state == 16 ? datai[38] : state == 17 ? datai[52] : state == 18 ? datai[2] : state == 19 ? datai[16] : state == 20 ? datai[26] : state == 21 ? datai[40] : state == 22 ? datai[50] : state == 23 ? datai[0] : state == 24 ? datai[12] : state == 25 ? datai[24] : state == 26 ? datai[36] : state == 27 ? datai[48] : state == 28 ? datai[60] : state == 29 ? datai[8] : state == 30 ? datai[20] : state == 31 ? datai[32] : state == 32 ? datai[44] : state == 33 ? datai[56] :    0;
assign br2 =
 state == 2 ? datar[34] : state == 3 ? datar[40] : state == 4 ? datar[46] : state == 5 ? datar[52] : state == 6 ? datar[58] : state == 7 ? datar[16] : state == 8 ? datar[22] : state == 9 ? datar[28] : state == 10 ? datar[50] : state == 11 ? datar[56] : state == 12 ? datar[62] : state == 13 ? datar[12] : state == 14 ? datar[26] : state == 15 ? datar[40] : state == 16 ? datar[46] : state == 17 ? datar[60] : state == 18 ? datar[6] : state == 19 ? datar[20] : state == 20 ? datar[30] : state == 21 ? datar[44] : state == 22 ? datar[54] : state == 23 ? datar[2] : state == 24 ? datar[14] : state == 25 ? datar[26] : state == 26 ? datar[38] : state == 27 ? datar[50] : state == 28 ? datar[62] : state == 29 ? datar[9] : state == 30 ? datar[21] : state == 31 ? datar[33] : state == 32 ? datar[45] : state == 33 ? datar[57] :    0;
assign bi2 =
 state == 2 ? datai[34] : state == 3 ? datai[40] : state == 4 ? datai[46] : state == 5 ? datai[52] : state == 6 ? datai[58] : state == 7 ? datai[16] : state == 8 ? datai[22] : state == 9 ? datai[28] : state == 10 ? datai[50] : state == 11 ? datai[56] : state == 12 ? datai[62] : state == 13 ? datai[12] : state == 14 ? datai[26] : state == 15 ? datai[40] : state == 16 ? datai[46] : state == 17 ? datai[60] : state == 18 ? datai[6] : state == 19 ? datai[20] : state == 20 ? datai[30] : state == 21 ? datai[44] : state == 22 ? datai[54] : state == 23 ? datai[2] : state == 24 ? datai[14] : state == 25 ? datai[26] : state == 26 ? datai[38] : state == 27 ? datai[50] : state == 28 ? datai[62] : state == 29 ? datai[9] : state == 30 ? datai[21] : state == 31 ? datai[33] : state == 32 ? datai[45] : state == 33 ? datai[57] :    0;
assign wr2 =
 state == 2 ? 514214 : state == 3 ? 370728 : state == 4 ? 102284 : state == 5 ? -200636 : state == 6 ? -435930 : state == 7 ? 524288 : state == 8 ? 200636 : state == 9 ? -370728 : state == 10 ? 484379 : state == 11 ? 0 : state == 12 ? -484379 : state == 13 ? 0 : state == 14 ? 370728 : state == 15 ? 524288 : state == 16 ? -370728 : state == 17 ? 0 : state == 18 ? 0 : state == 19 ? 524288 : state == 20 ? 0 : state == 21 ? 524288 : state == 22 ? 0 : state == 23 ? 524288 : state == 24 ? 524288 : state == 25 ? 524288 : state == 26 ? 524288 : state == 27 ? 524288 : state == 28 ? 524288 : state == 29 ? 524288 : state == 30 ? 524288 : state == 31 ? 524288 : state == 32 ? 524288 : state == 33 ? 524288 :    0;
assign wi2 =
 state == 2 ? -102284 : state == 3 ? -370728 : state == 4 ? -514214 : state == 5 ? -484379 : state == 6 ? -291279 : state == 7 ? 0 : state == 8 ? -484379 : state == 9 ? -370728 : state == 10 ? -200636 : state == 11 ? -524288 : state == 12 ? -200636 : state == 13 ? -524288 : state == 14 ? -370728 : state == 15 ? 0 : state == 16 ? -370728 : state == 17 ? -524288 : state == 18 ? -524288 : state == 19 ? 0 : state == 20 ? -524288 : state == 21 ? 0 : state == 22 ? -524288 : state == 23 ? 0 : state == 24 ? 0 : state == 25 ? 0 : state == 26 ? 0 : state == 27 ? 0 : state == 28 ? 0 : state == 29 ? 0 : state == 30 ? 0 : state == 31 ? 0 : state == 32 ? 0 : state == 33 ? 0 :    0;
assign ar3 =
 state == 2 ? datar[3] : state == 3 ? datar[9] : state == 4 ? datar[15] : state == 5 ? datar[21] : state == 6 ? datar[27] : state == 7 ? datar[1] : state == 8 ? datar[7] : state == 9 ? datar[13] : state == 10 ? datar[35] : state == 11 ? datar[41] : state == 12 ? datar[47] : state == 13 ? datar[5] : state == 14 ? datar[19] : state == 15 ? datar[33] : state == 16 ? datar[39] : state == 17 ? datar[53] : state == 18 ? datar[3] : state == 19 ? datar[17] : state == 20 ? datar[27] : state == 21 ? datar[41] : state == 22 ? datar[51] : state == 23 ? datar[1] : state == 24 ? datar[13] : state == 25 ? datar[25] : state == 26 ? datar[37] : state == 27 ? datar[49] : state == 28 ? datar[61] : state == 29 ? datar[10] : state == 30 ? datar[22] : state == 31 ? datar[34] : state == 32 ? datar[46] : state == 33 ? datar[58] :    0;
assign ai3 =
 state == 2 ? datai[3] : state == 3 ? datai[9] : state == 4 ? datai[15] : state == 5 ? datai[21] : state == 6 ? datai[27] : state == 7 ? datai[1] : state == 8 ? datai[7] : state == 9 ? datai[13] : state == 10 ? datai[35] : state == 11 ? datai[41] : state == 12 ? datai[47] : state == 13 ? datai[5] : state == 14 ? datai[19] : state == 15 ? datai[33] : state == 16 ? datai[39] : state == 17 ? datai[53] : state == 18 ? datai[3] : state == 19 ? datai[17] : state == 20 ? datai[27] : state == 21 ? datai[41] : state == 22 ? datai[51] : state == 23 ? datai[1] : state == 24 ? datai[13] : state == 25 ? datai[25] : state == 26 ? datai[37] : state == 27 ? datai[49] : state == 28 ? datai[61] : state == 29 ? datai[10] : state == 30 ? datai[22] : state == 31 ? datai[34] : state == 32 ? datai[46] : state == 33 ? datai[58] :    0;
assign br3 =
 state == 2 ? datar[35] : state == 3 ? datar[41] : state == 4 ? datar[47] : state == 5 ? datar[53] : state == 6 ? datar[59] : state == 7 ? datar[17] : state == 8 ? datar[23] : state == 9 ? datar[29] : state == 10 ? datar[51] : state == 11 ? datar[57] : state == 12 ? datar[63] : state == 13 ? datar[13] : state == 14 ? datar[27] : state == 15 ? datar[41] : state == 16 ? datar[47] : state == 17 ? datar[61] : state == 18 ? datar[7] : state == 19 ? datar[21] : state == 20 ? datar[31] : state == 21 ? datar[45] : state == 22 ? datar[55] : state == 23 ? datar[3] : state == 24 ? datar[15] : state == 25 ? datar[27] : state == 26 ? datar[39] : state == 27 ? datar[51] : state == 28 ? datar[63] : state == 29 ? datar[11] : state == 30 ? datar[23] : state == 31 ? datar[35] : state == 32 ? datar[47] : state == 33 ? datar[59] :    0;
assign bi3 =
 state == 2 ? datai[35] : state == 3 ? datai[41] : state == 4 ? datai[47] : state == 5 ? datai[53] : state == 6 ? datai[59] : state == 7 ? datai[17] : state == 8 ? datai[23] : state == 9 ? datai[29] : state == 10 ? datai[51] : state == 11 ? datai[57] : state == 12 ? datai[63] : state == 13 ? datai[13] : state == 14 ? datai[27] : state == 15 ? datai[41] : state == 16 ? datai[47] : state == 17 ? datai[61] : state == 18 ? datai[7] : state == 19 ? datai[21] : state == 20 ? datai[31] : state == 21 ? datai[45] : state == 22 ? datai[55] : state == 23 ? datai[3] : state == 24 ? datai[15] : state == 25 ? datai[27] : state == 26 ? datai[39] : state == 27 ? datai[51] : state == 28 ? datai[63] : state == 29 ? datai[11] : state == 30 ? datai[23] : state == 31 ? datai[35] : state == 32 ? datai[47] : state == 33 ? datai[59] :    0;
assign wr3 =
 state == 2 ? 501712 : state == 3 ? 332605 : state == 4 ? 51389 : state == 5 ? -247148 : state == 6 ? -462381 : state == 7 ? 514214 : state == 8 ? 102284 : state == 9 ? -435930 : state == 10 ? 435930 : state == 11 ? -102284 : state == 12 ? -514214 : state == 13 ? -200636 : state == 14 ? 200636 : state == 15 ? 484379 : state == 16 ? -484379 : state == 17 ? -200636 : state == 18 ? -370728 : state == 19 ? 370728 : state == 20 ? -370728 : state == 21 ? 370728 : state == 22 ? -370728 : state == 23 ? 0 : state == 24 ? 0 : state == 25 ? 0 : state == 26 ? 0 : state == 27 ? 0 : state == 28 ? 0 : state == 29 ? 524288 : state == 30 ? 524288 : state == 31 ? 524288 : state == 32 ? 524288 : state == 33 ? 524288 :    0;
assign wi3 =
 state == 2 ? -152193 : state == 3 ? -405280 : state == 4 ? -521763 : state == 5 ? -462381 : state == 6 ? -247148 : state == 7 ? -102284 : state == 8 ? -514214 : state == 9 ? -291279 : state == 10 ? -291279 : state == 11 ? -514214 : state == 12 ? -102284 : state == 13 ? -484379 : state == 14 ? -484379 : state == 15 ? -200636 : state == 16 ? -200636 : state == 17 ? -484379 : state == 18 ? -370728 : state == 19 ? -370728 : state == 20 ? -370728 : state == 21 ? -370728 : state == 22 ? -370728 : state == 23 ? -524288 : state == 24 ? -524288 : state == 25 ? -524288 : state == 26 ? -524288 : state == 27 ? -524288 : state == 28 ? -524288 : state == 29 ? 0 : state == 30 ? 0 : state == 31 ? 0 : state == 32 ? 0 : state == 33 ? 0 :    0;
assign ar4 =
 state == 2 ? datar[4] : state == 3 ? datar[10] : state == 4 ? datar[16] : state == 5 ? datar[22] : state == 6 ? datar[28] : state == 7 ? datar[2] : state == 8 ? datar[8] : state == 9 ? datar[14] : state == 10 ? datar[36] : state == 11 ? datar[42] : state == 12 ? datar[0] : state == 13 ? datar[6] : state == 14 ? datar[20] : state == 15 ? datar[34] : state == 16 ? datar[48] : state == 17 ? datar[54] : state == 18 ? datar[8] : state == 19 ? datar[18] : state == 20 ? datar[32] : state == 21 ? datar[42] : state == 22 ? datar[56] : state == 23 ? datar[4] : state == 24 ? datar[16] : state == 25 ? datar[28] : state == 26 ? datar[40] : state == 27 ? datar[52] : state == 28 ? datar[0] : state == 29 ? datar[12] : state == 30 ? datar[24] : state == 31 ? datar[36] : state == 32 ? datar[48] : state == 33 ? datar[60] :    0;
assign ai4 =
 state == 2 ? datai[4] : state == 3 ? datai[10] : state == 4 ? datai[16] : state == 5 ? datai[22] : state == 6 ? datai[28] : state == 7 ? datai[2] : state == 8 ? datai[8] : state == 9 ? datai[14] : state == 10 ? datai[36] : state == 11 ? datai[42] : state == 12 ? datai[0] : state == 13 ? datai[6] : state == 14 ? datai[20] : state == 15 ? datai[34] : state == 16 ? datai[48] : state == 17 ? datai[54] : state == 18 ? datai[8] : state == 19 ? datai[18] : state == 20 ? datai[32] : state == 21 ? datai[42] : state == 22 ? datai[56] : state == 23 ? datai[4] : state == 24 ? datai[16] : state == 25 ? datai[28] : state == 26 ? datai[40] : state == 27 ? datai[52] : state == 28 ? datai[0] : state == 29 ? datai[12] : state == 30 ? datai[24] : state == 31 ? datai[36] : state == 32 ? datai[48] : state == 33 ? datai[60] :    0;
assign br4 =
 state == 2 ? datar[36] : state == 3 ? datar[42] : state == 4 ? datar[48] : state == 5 ? datar[54] : state == 6 ? datar[60] : state == 7 ? datar[18] : state == 8 ? datar[24] : state == 9 ? datar[30] : state == 10 ? datar[52] : state == 11 ? datar[58] : state == 12 ? datar[8] : state == 13 ? datar[14] : state == 14 ? datar[28] : state == 15 ? datar[42] : state == 16 ? datar[56] : state == 17 ? datar[62] : state == 18 ? datar[12] : state == 19 ? datar[22] : state == 20 ? datar[36] : state == 21 ? datar[46] : state == 22 ? datar[60] : state == 23 ? datar[6] : state == 24 ? datar[18] : state == 25 ? datar[30] : state == 26 ? datar[42] : state == 27 ? datar[54] : state == 28 ? datar[1] : state == 29 ? datar[13] : state == 30 ? datar[25] : state == 31 ? datar[37] : state == 32 ? datar[49] : state == 33 ? datar[61] :    0;
assign bi4 =
 state == 2 ? datai[36] : state == 3 ? datai[42] : state == 4 ? datai[48] : state == 5 ? datai[54] : state == 6 ? datai[60] : state == 7 ? datai[18] : state == 8 ? datai[24] : state == 9 ? datai[30] : state == 10 ? datai[52] : state == 11 ? datai[58] : state == 12 ? datai[8] : state == 13 ? datai[14] : state == 14 ? datai[28] : state == 15 ? datai[42] : state == 16 ? datai[56] : state == 17 ? datai[62] : state == 18 ? datai[12] : state == 19 ? datai[22] : state == 20 ? datai[36] : state == 21 ? datai[46] : state == 22 ? datai[60] : state == 23 ? datai[6] : state == 24 ? datai[18] : state == 25 ? datai[30] : state == 26 ? datai[42] : state == 27 ? datai[54] : state == 28 ? datai[1] : state == 29 ? datai[13] : state == 30 ? datai[25] : state == 31 ? datai[37] : state == 32 ? datai[49] : state == 33 ? datai[61] :    0;
assign wr4 =
 state == 2 ? 484379 : state == 3 ? 291279 : state == 4 ? 0 : state == 5 ? -291279 : state == 6 ? -484379 : state == 7 ? 484379 : state == 8 ? 0 : state == 9 ? -484379 : state == 10 ? 370728 : state == 11 ? -200636 : state == 12 ? 524288 : state == 13 ? -370728 : state == 14 ? 0 : state == 15 ? 370728 : state == 16 ? 524288 : state == 17 ? -370728 : state == 18 ? 524288 : state == 19 ? 0 : state == 20 ? 524288 : state == 21 ? 0 : state == 22 ? 524288 : state == 23 ? 524288 : state == 24 ? 524288 : state == 25 ? 524288 : state == 26 ? 524288 : state == 27 ? 524288 : state == 28 ? 524288 : state == 29 ? 524288 : state == 30 ? 524288 : state == 31 ? 524288 : state == 32 ? 524288 : state == 33 ? 524288 :    0;
assign wi4 =
 state == 2 ? -200636 : state == 3 ? -435930 : state == 4 ? -524288 : state == 5 ? -435930 : state == 6 ? -200636 : state == 7 ? -200636 : state == 8 ? -524288 : state == 9 ? -200636 : state == 10 ? -370728 : state == 11 ? -484379 : state == 12 ? 0 : state == 13 ? -370728 : state == 14 ? -524288 : state == 15 ? -370728 : state == 16 ? 0 : state == 17 ? -370728 : state == 18 ? 0 : state == 19 ? -524288 : state == 20 ? 0 : state == 21 ? -524288 : state == 22 ? 0 : state == 23 ? 0 : state == 24 ? 0 : state == 25 ? 0 : state == 26 ? 0 : state == 27 ? 0 : state == 28 ? 0 : state == 29 ? 0 : state == 30 ? 0 : state == 31 ? 0 : state == 32 ? 0 : state == 33 ? 0 :    0;
assign ar5 =
 state == 2 ? datar[5] : state == 3 ? datar[11] : state == 4 ? datar[17] : state == 5 ? datar[23] : state == 6 ? datar[29] : state == 7 ? datar[3] : state == 8 ? datar[9] : state == 9 ? datar[15] : state == 10 ? datar[37] : state == 11 ? datar[43] : state == 12 ? datar[1] : state == 13 ? datar[7] : state == 14 ? datar[21] : state == 15 ? datar[35] : state == 16 ? datar[49] : state == 17 ? datar[55] : state == 18 ? datar[9] : state == 19 ? datar[19] : state == 20 ? datar[33] : state == 21 ? datar[43] : state == 22 ? datar[57] : state == 23 ? datar[5] : state == 24 ? datar[17] : state == 25 ? datar[29] : state == 26 ? datar[41] : state == 27 ? datar[53] : state == 28 ? datar[2] : state == 29 ? datar[14] : state == 30 ? datar[26] : state == 31 ? datar[38] : state == 32 ? datar[50] : state == 33 ? datar[62] :    0;
assign ai5 =
 state == 2 ? datai[5] : state == 3 ? datai[11] : state == 4 ? datai[17] : state == 5 ? datai[23] : state == 6 ? datai[29] : state == 7 ? datai[3] : state == 8 ? datai[9] : state == 9 ? datai[15] : state == 10 ? datai[37] : state == 11 ? datai[43] : state == 12 ? datai[1] : state == 13 ? datai[7] : state == 14 ? datai[21] : state == 15 ? datai[35] : state == 16 ? datai[49] : state == 17 ? datai[55] : state == 18 ? datai[9] : state == 19 ? datai[19] : state == 20 ? datai[33] : state == 21 ? datai[43] : state == 22 ? datai[57] : state == 23 ? datai[5] : state == 24 ? datai[17] : state == 25 ? datai[29] : state == 26 ? datai[41] : state == 27 ? datai[53] : state == 28 ? datai[2] : state == 29 ? datai[14] : state == 30 ? datai[26] : state == 31 ? datai[38] : state == 32 ? datai[50] : state == 33 ? datai[62] :    0;
assign br5 =
 state == 2 ? datar[37] : state == 3 ? datar[43] : state == 4 ? datar[49] : state == 5 ? datar[55] : state == 6 ? datar[61] : state == 7 ? datar[19] : state == 8 ? datar[25] : state == 9 ? datar[31] : state == 10 ? datar[53] : state == 11 ? datar[59] : state == 12 ? datar[9] : state == 13 ? datar[15] : state == 14 ? datar[29] : state == 15 ? datar[43] : state == 16 ? datar[57] : state == 17 ? datar[63] : state == 18 ? datar[13] : state == 19 ? datar[23] : state == 20 ? datar[37] : state == 21 ? datar[47] : state == 22 ? datar[61] : state == 23 ? datar[7] : state == 24 ? datar[19] : state == 25 ? datar[31] : state == 26 ? datar[43] : state == 27 ? datar[55] : state == 28 ? datar[3] : state == 29 ? datar[15] : state == 30 ? datar[27] : state == 31 ? datar[39] : state == 32 ? datar[51] : state == 33 ? datar[63] :    0;
assign bi5 =
 state == 2 ? datai[37] : state == 3 ? datai[43] : state == 4 ? datai[49] : state == 5 ? datai[55] : state == 6 ? datai[61] : state == 7 ? datai[19] : state == 8 ? datai[25] : state == 9 ? datai[31] : state == 10 ? datai[53] : state == 11 ? datai[59] : state == 12 ? datai[9] : state == 13 ? datai[15] : state == 14 ? datai[29] : state == 15 ? datai[43] : state == 16 ? datai[57] : state == 17 ? datai[63] : state == 18 ? datai[13] : state == 19 ? datai[23] : state == 20 ? datai[37] : state == 21 ? datai[47] : state == 22 ? datai[61] : state == 23 ? datai[7] : state == 24 ? datai[19] : state == 25 ? datai[31] : state == 26 ? datai[43] : state == 27 ? datai[55] : state == 28 ? datai[3] : state == 29 ? datai[15] : state == 30 ? datai[27] : state == 31 ? datai[39] : state == 32 ? datai[51] : state == 33 ? datai[63] :    0;
assign wr5 =
 state == 2 ? 462381 : state == 3 ? 247148 : state == 4 ? -51389 : state == 5 ? -332605 : state == 6 ? -501712 : state == 7 ? 435930 : state == 8 ? -102284 : state == 9 ? -514214 : state == 10 ? 291279 : state == 11 ? -291279 : state == 12 ? 484379 : state == 13 ? -484379 : state == 14 ? -200636 : state == 15 ? 200636 : state == 16 ? 484379 : state == 17 ? -484379 : state == 18 ? 370728 : state == 19 ? -370728 : state == 20 ? 370728 : state == 21 ? -370728 : state == 22 ? 370728 : state == 23 ? 0 : state == 24 ? 0 : state == 25 ? 0 : state == 26 ? 0 : state == 27 ? 0 : state == 28 ? 524288 : state == 29 ? 524288 : state == 30 ? 524288 : state == 31 ? 524288 : state == 32 ? 524288 : state == 33 ? 524288 :    0;
assign wi5 =
 state == 2 ? -247148 : state == 3 ? -462381 : state == 4 ? -521763 : state == 5 ? -405280 : state == 6 ? -152193 : state == 7 ? -291279 : state == 8 ? -514214 : state == 9 ? -102284 : state == 10 ? -435930 : state == 11 ? -435930 : state == 12 ? -200636 : state == 13 ? -200636 : state == 14 ? -484379 : state == 15 ? -484379 : state == 16 ? -200636 : state == 17 ? -200636 : state == 18 ? -370728 : state == 19 ? -370728 : state == 20 ? -370728 : state == 21 ? -370728 : state == 22 ? -370728 : state == 23 ? -524288 : state == 24 ? -524288 : state == 25 ? -524288 : state == 26 ? -524288 : state == 27 ? -524288 : state == 28 ? 0 : state == 29 ? 0 : state == 30 ? 0 : state == 31 ? 0 : state == 32 ? 0 : state == 33 ? 0 :    0;
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

    assign valid_o = state == 36;
    assign full = state > 1;
    assign xr = samples == 0 ? datar[63] : datar[samples-1];
    assign xi = samples == 0 ? datai[63] : datai[samples-1];
    always @(posedge CLK) begin
        if(!RST) begin
            // reset 
            samples <= 0;
            state <= 0;
        end else begin
            case(state)
                0: begin
                    if(valid_a) begin
                        datar[samples] = ar;
                        datai[samples] = ai;
                        samples <= 1;
                        state <= 1;
                    end
                end
                1: begin
                    if(valid_a != 0) begin
                        // datar << width;
                        // datar <= datar + ar;
                        // datai << width;
                        // datai <= datai + ai;
                        datar[samples] = ar;
                        datai[samples] = ai;
                        samples <= samples + 1;
                        if(samples == 63) begin
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
datar[1] <= xr1; datai[1] <= xi1; datar[33] <= yr1; datai[33] <= yi1;
datar[2] <= xr2; datai[2] <= xi2; datar[34] <= yr2; datai[34] <= yi2;
datar[3] <= xr3; datai[3] <= xi3; datar[35] <= yr3; datai[35] <= yi3;
datar[4] <= xr4; datai[4] <= xi4; datar[36] <= yr4; datai[36] <= yi4;
datar[5] <= xr5; datai[5] <= xi5; datar[37] <= yr5; datai[37] <= yi5;
    state <= 4;
end
4: begin
datar[6] <= xr0; datai[6] <= xi0; datar[38] <= yr0; datai[38] <= yi0;
datar[7] <= xr1; datai[7] <= xi1; datar[39] <= yr1; datai[39] <= yi1;
datar[8] <= xr2; datai[8] <= xi2; datar[40] <= yr2; datai[40] <= yi2;
datar[9] <= xr3; datai[9] <= xi3; datar[41] <= yr3; datai[41] <= yi3;
datar[10] <= xr4; datai[10] <= xi4; datar[42] <= yr4; datai[42] <= yi4;
datar[11] <= xr5; datai[11] <= xi5; datar[43] <= yr5; datai[43] <= yi5;
    state <= 5;
end
5: begin
datar[12] <= xr0; datai[12] <= xi0; datar[44] <= yr0; datai[44] <= yi0;
datar[13] <= xr1; datai[13] <= xi1; datar[45] <= yr1; datai[45] <= yi1;
datar[14] <= xr2; datai[14] <= xi2; datar[46] <= yr2; datai[46] <= yi2;
datar[15] <= xr3; datai[15] <= xi3; datar[47] <= yr3; datai[47] <= yi3;
datar[16] <= xr4; datai[16] <= xi4; datar[48] <= yr4; datai[48] <= yi4;
datar[17] <= xr5; datai[17] <= xi5; datar[49] <= yr5; datai[49] <= yi5;
    state <= 6;
end
6: begin
datar[18] <= xr0; datai[18] <= xi0; datar[50] <= yr0; datai[50] <= yi0;
datar[19] <= xr1; datai[19] <= xi1; datar[51] <= yr1; datai[51] <= yi1;
datar[20] <= xr2; datai[20] <= xi2; datar[52] <= yr2; datai[52] <= yi2;
datar[21] <= xr3; datai[21] <= xi3; datar[53] <= yr3; datai[53] <= yi3;
datar[22] <= xr4; datai[22] <= xi4; datar[54] <= yr4; datai[54] <= yi4;
datar[23] <= xr5; datai[23] <= xi5; datar[55] <= yr5; datai[55] <= yi5;
    state <= 7;
end
7: begin
datar[24] <= xr0; datai[24] <= xi0; datar[56] <= yr0; datai[56] <= yi0;
datar[25] <= xr1; datai[25] <= xi1; datar[57] <= yr1; datai[57] <= yi1;
datar[26] <= xr2; datai[26] <= xi2; datar[58] <= yr2; datai[58] <= yi2;
datar[27] <= xr3; datai[27] <= xi3; datar[59] <= yr3; datai[59] <= yi3;
datar[28] <= xr4; datai[28] <= xi4; datar[60] <= yr4; datai[60] <= yi4;
datar[29] <= xr5; datai[29] <= xi5; datar[61] <= yr5; datai[61] <= yi5;
    state <= 8;
end
8: begin
datar[30] <= xr0; datai[30] <= xi0; datar[62] <= yr0; datai[62] <= yi0;
datar[31] <= xr1; datai[31] <= xi1; datar[63] <= yr1; datai[63] <= yi1;
datar[0] <= xr2; datai[0] <= xi2; datar[16] <= yr2; datai[16] <= yi2;
datar[1] <= xr3; datai[1] <= xi3; datar[17] <= yr3; datai[17] <= yi3;
datar[2] <= xr4; datai[2] <= xi4; datar[18] <= yr4; datai[18] <= yi4;
datar[3] <= xr5; datai[3] <= xi5; datar[19] <= yr5; datai[19] <= yi5;
    state <= 9;
end
9: begin
datar[4] <= xr0; datai[4] <= xi0; datar[20] <= yr0; datai[20] <= yi0;
datar[5] <= xr1; datai[5] <= xi1; datar[21] <= yr1; datai[21] <= yi1;
datar[6] <= xr2; datai[6] <= xi2; datar[22] <= yr2; datai[22] <= yi2;
datar[7] <= xr3; datai[7] <= xi3; datar[23] <= yr3; datai[23] <= yi3;
datar[8] <= xr4; datai[8] <= xi4; datar[24] <= yr4; datai[24] <= yi4;
datar[9] <= xr5; datai[9] <= xi5; datar[25] <= yr5; datai[25] <= yi5;
    state <= 10;
end
10: begin
datar[10] <= xr0; datai[10] <= xi0; datar[26] <= yr0; datai[26] <= yi0;
datar[11] <= xr1; datai[11] <= xi1; datar[27] <= yr1; datai[27] <= yi1;
datar[12] <= xr2; datai[12] <= xi2; datar[28] <= yr2; datai[28] <= yi2;
datar[13] <= xr3; datai[13] <= xi3; datar[29] <= yr3; datai[29] <= yi3;
datar[14] <= xr4; datai[14] <= xi4; datar[30] <= yr4; datai[30] <= yi4;
datar[15] <= xr5; datai[15] <= xi5; datar[31] <= yr5; datai[31] <= yi5;
    state <= 11;
end
11: begin
datar[32] <= xr0; datai[32] <= xi0; datar[48] <= yr0; datai[48] <= yi0;
datar[33] <= xr1; datai[33] <= xi1; datar[49] <= yr1; datai[49] <= yi1;
datar[34] <= xr2; datai[34] <= xi2; datar[50] <= yr2; datai[50] <= yi2;
datar[35] <= xr3; datai[35] <= xi3; datar[51] <= yr3; datai[51] <= yi3;
datar[36] <= xr4; datai[36] <= xi4; datar[52] <= yr4; datai[52] <= yi4;
datar[37] <= xr5; datai[37] <= xi5; datar[53] <= yr5; datai[53] <= yi5;
    state <= 12;
end
12: begin
datar[38] <= xr0; datai[38] <= xi0; datar[54] <= yr0; datai[54] <= yi0;
datar[39] <= xr1; datai[39] <= xi1; datar[55] <= yr1; datai[55] <= yi1;
datar[40] <= xr2; datai[40] <= xi2; datar[56] <= yr2; datai[56] <= yi2;
datar[41] <= xr3; datai[41] <= xi3; datar[57] <= yr3; datai[57] <= yi3;
datar[42] <= xr4; datai[42] <= xi4; datar[58] <= yr4; datai[58] <= yi4;
datar[43] <= xr5; datai[43] <= xi5; datar[59] <= yr5; datai[59] <= yi5;
    state <= 13;
end
13: begin
datar[44] <= xr0; datai[44] <= xi0; datar[60] <= yr0; datai[60] <= yi0;
datar[45] <= xr1; datai[45] <= xi1; datar[61] <= yr1; datai[61] <= yi1;
datar[46] <= xr2; datai[46] <= xi2; datar[62] <= yr2; datai[62] <= yi2;
datar[47] <= xr3; datai[47] <= xi3; datar[63] <= yr3; datai[63] <= yi3;
datar[0] <= xr4; datai[0] <= xi4; datar[8] <= yr4; datai[8] <= yi4;
datar[1] <= xr5; datai[1] <= xi5; datar[9] <= yr5; datai[9] <= yi5;
    state <= 14;
end
14: begin
datar[2] <= xr0; datai[2] <= xi0; datar[10] <= yr0; datai[10] <= yi0;
datar[3] <= xr1; datai[3] <= xi1; datar[11] <= yr1; datai[11] <= yi1;
datar[4] <= xr2; datai[4] <= xi2; datar[12] <= yr2; datai[12] <= yi2;
datar[5] <= xr3; datai[5] <= xi3; datar[13] <= yr3; datai[13] <= yi3;
datar[6] <= xr4; datai[6] <= xi4; datar[14] <= yr4; datai[14] <= yi4;
datar[7] <= xr5; datai[7] <= xi5; datar[15] <= yr5; datai[15] <= yi5;
    state <= 15;
end
15: begin
datar[16] <= xr0; datai[16] <= xi0; datar[24] <= yr0; datai[24] <= yi0;
datar[17] <= xr1; datai[17] <= xi1; datar[25] <= yr1; datai[25] <= yi1;
datar[18] <= xr2; datai[18] <= xi2; datar[26] <= yr2; datai[26] <= yi2;
datar[19] <= xr3; datai[19] <= xi3; datar[27] <= yr3; datai[27] <= yi3;
datar[20] <= xr4; datai[20] <= xi4; datar[28] <= yr4; datai[28] <= yi4;
datar[21] <= xr5; datai[21] <= xi5; datar[29] <= yr5; datai[29] <= yi5;
    state <= 16;
end
16: begin
datar[22] <= xr0; datai[22] <= xi0; datar[30] <= yr0; datai[30] <= yi0;
datar[23] <= xr1; datai[23] <= xi1; datar[31] <= yr1; datai[31] <= yi1;
datar[32] <= xr2; datai[32] <= xi2; datar[40] <= yr2; datai[40] <= yi2;
datar[33] <= xr3; datai[33] <= xi3; datar[41] <= yr3; datai[41] <= yi3;
datar[34] <= xr4; datai[34] <= xi4; datar[42] <= yr4; datai[42] <= yi4;
datar[35] <= xr5; datai[35] <= xi5; datar[43] <= yr5; datai[43] <= yi5;
    state <= 17;
end
17: begin
datar[36] <= xr0; datai[36] <= xi0; datar[44] <= yr0; datai[44] <= yi0;
datar[37] <= xr1; datai[37] <= xi1; datar[45] <= yr1; datai[45] <= yi1;
datar[38] <= xr2; datai[38] <= xi2; datar[46] <= yr2; datai[46] <= yi2;
datar[39] <= xr3; datai[39] <= xi3; datar[47] <= yr3; datai[47] <= yi3;
datar[48] <= xr4; datai[48] <= xi4; datar[56] <= yr4; datai[56] <= yi4;
datar[49] <= xr5; datai[49] <= xi5; datar[57] <= yr5; datai[57] <= yi5;
    state <= 18;
end
18: begin
datar[50] <= xr0; datai[50] <= xi0; datar[58] <= yr0; datai[58] <= yi0;
datar[51] <= xr1; datai[51] <= xi1; datar[59] <= yr1; datai[59] <= yi1;
datar[52] <= xr2; datai[52] <= xi2; datar[60] <= yr2; datai[60] <= yi2;
datar[53] <= xr3; datai[53] <= xi3; datar[61] <= yr3; datai[61] <= yi3;
datar[54] <= xr4; datai[54] <= xi4; datar[62] <= yr4; datai[62] <= yi4;
datar[55] <= xr5; datai[55] <= xi5; datar[63] <= yr5; datai[63] <= yi5;
    state <= 19;
end
19: begin
datar[0] <= xr0; datai[0] <= xi0; datar[4] <= yr0; datai[4] <= yi0;
datar[1] <= xr1; datai[1] <= xi1; datar[5] <= yr1; datai[5] <= yi1;
datar[2] <= xr2; datai[2] <= xi2; datar[6] <= yr2; datai[6] <= yi2;
datar[3] <= xr3; datai[3] <= xi3; datar[7] <= yr3; datai[7] <= yi3;
datar[8] <= xr4; datai[8] <= xi4; datar[12] <= yr4; datai[12] <= yi4;
datar[9] <= xr5; datai[9] <= xi5; datar[13] <= yr5; datai[13] <= yi5;
    state <= 20;
end
20: begin
datar[10] <= xr0; datai[10] <= xi0; datar[14] <= yr0; datai[14] <= yi0;
datar[11] <= xr1; datai[11] <= xi1; datar[15] <= yr1; datai[15] <= yi1;
datar[16] <= xr2; datai[16] <= xi2; datar[20] <= yr2; datai[20] <= yi2;
datar[17] <= xr3; datai[17] <= xi3; datar[21] <= yr3; datai[21] <= yi3;
datar[18] <= xr4; datai[18] <= xi4; datar[22] <= yr4; datai[22] <= yi4;
datar[19] <= xr5; datai[19] <= xi5; datar[23] <= yr5; datai[23] <= yi5;
    state <= 21;
end
21: begin
datar[24] <= xr0; datai[24] <= xi0; datar[28] <= yr0; datai[28] <= yi0;
datar[25] <= xr1; datai[25] <= xi1; datar[29] <= yr1; datai[29] <= yi1;
datar[26] <= xr2; datai[26] <= xi2; datar[30] <= yr2; datai[30] <= yi2;
datar[27] <= xr3; datai[27] <= xi3; datar[31] <= yr3; datai[31] <= yi3;
datar[32] <= xr4; datai[32] <= xi4; datar[36] <= yr4; datai[36] <= yi4;
datar[33] <= xr5; datai[33] <= xi5; datar[37] <= yr5; datai[37] <= yi5;
    state <= 22;
end
22: begin
datar[34] <= xr0; datai[34] <= xi0; datar[38] <= yr0; datai[38] <= yi0;
datar[35] <= xr1; datai[35] <= xi1; datar[39] <= yr1; datai[39] <= yi1;
datar[40] <= xr2; datai[40] <= xi2; datar[44] <= yr2; datai[44] <= yi2;
datar[41] <= xr3; datai[41] <= xi3; datar[45] <= yr3; datai[45] <= yi3;
datar[42] <= xr4; datai[42] <= xi4; datar[46] <= yr4; datai[46] <= yi4;
datar[43] <= xr5; datai[43] <= xi5; datar[47] <= yr5; datai[47] <= yi5;
    state <= 23;
end
23: begin
datar[48] <= xr0; datai[48] <= xi0; datar[52] <= yr0; datai[52] <= yi0;
datar[49] <= xr1; datai[49] <= xi1; datar[53] <= yr1; datai[53] <= yi1;
datar[50] <= xr2; datai[50] <= xi2; datar[54] <= yr2; datai[54] <= yi2;
datar[51] <= xr3; datai[51] <= xi3; datar[55] <= yr3; datai[55] <= yi3;
datar[56] <= xr4; datai[56] <= xi4; datar[60] <= yr4; datai[60] <= yi4;
datar[57] <= xr5; datai[57] <= xi5; datar[61] <= yr5; datai[61] <= yi5;
    state <= 24;
end
24: begin
datar[58] <= xr0; datai[58] <= xi0; datar[62] <= yr0; datai[62] <= yi0;
datar[59] <= xr1; datai[59] <= xi1; datar[63] <= yr1; datai[63] <= yi1;
datar[0] <= xr2; datai[0] <= xi2; datar[2] <= yr2; datai[2] <= yi2;
datar[1] <= xr3; datai[1] <= xi3; datar[3] <= yr3; datai[3] <= yi3;
datar[4] <= xr4; datai[4] <= xi4; datar[6] <= yr4; datai[6] <= yi4;
datar[5] <= xr5; datai[5] <= xi5; datar[7] <= yr5; datai[7] <= yi5;
    state <= 25;
end
25: begin
datar[8] <= xr0; datai[8] <= xi0; datar[10] <= yr0; datai[10] <= yi0;
datar[9] <= xr1; datai[9] <= xi1; datar[11] <= yr1; datai[11] <= yi1;
datar[12] <= xr2; datai[12] <= xi2; datar[14] <= yr2; datai[14] <= yi2;
datar[13] <= xr3; datai[13] <= xi3; datar[15] <= yr3; datai[15] <= yi3;
datar[16] <= xr4; datai[16] <= xi4; datar[18] <= yr4; datai[18] <= yi4;
datar[17] <= xr5; datai[17] <= xi5; datar[19] <= yr5; datai[19] <= yi5;
    state <= 26;
end
26: begin
datar[20] <= xr0; datai[20] <= xi0; datar[22] <= yr0; datai[22] <= yi0;
datar[21] <= xr1; datai[21] <= xi1; datar[23] <= yr1; datai[23] <= yi1;
datar[24] <= xr2; datai[24] <= xi2; datar[26] <= yr2; datai[26] <= yi2;
datar[25] <= xr3; datai[25] <= xi3; datar[27] <= yr3; datai[27] <= yi3;
datar[28] <= xr4; datai[28] <= xi4; datar[30] <= yr4; datai[30] <= yi4;
datar[29] <= xr5; datai[29] <= xi5; datar[31] <= yr5; datai[31] <= yi5;
    state <= 27;
end
27: begin
datar[32] <= xr0; datai[32] <= xi0; datar[34] <= yr0; datai[34] <= yi0;
datar[33] <= xr1; datai[33] <= xi1; datar[35] <= yr1; datai[35] <= yi1;
datar[36] <= xr2; datai[36] <= xi2; datar[38] <= yr2; datai[38] <= yi2;
datar[37] <= xr3; datai[37] <= xi3; datar[39] <= yr3; datai[39] <= yi3;
datar[40] <= xr4; datai[40] <= xi4; datar[42] <= yr4; datai[42] <= yi4;
datar[41] <= xr5; datai[41] <= xi5; datar[43] <= yr5; datai[43] <= yi5;
    state <= 28;
end
28: begin
datar[44] <= xr0; datai[44] <= xi0; datar[46] <= yr0; datai[46] <= yi0;
datar[45] <= xr1; datai[45] <= xi1; datar[47] <= yr1; datai[47] <= yi1;
datar[48] <= xr2; datai[48] <= xi2; datar[50] <= yr2; datai[50] <= yi2;
datar[49] <= xr3; datai[49] <= xi3; datar[51] <= yr3; datai[51] <= yi3;
datar[52] <= xr4; datai[52] <= xi4; datar[54] <= yr4; datai[54] <= yi4;
datar[53] <= xr5; datai[53] <= xi5; datar[55] <= yr5; datai[55] <= yi5;
    state <= 29;
end
29: begin
datar[56] <= xr0; datai[56] <= xi0; datar[58] <= yr0; datai[58] <= yi0;
datar[57] <= xr1; datai[57] <= xi1; datar[59] <= yr1; datai[59] <= yi1;
datar[60] <= xr2; datai[60] <= xi2; datar[62] <= yr2; datai[62] <= yi2;
datar[61] <= xr3; datai[61] <= xi3; datar[63] <= yr3; datai[63] <= yi3;
datar[0] <= xr4; datai[0] <= xi4; datar[1] <= yr4; datai[1] <= yi4;
datar[2] <= xr5; datai[2] <= xi5; datar[3] <= yr5; datai[3] <= yi5;
    state <= 30;
end
30: begin
datar[4] <= xr0; datai[4] <= xi0; datar[5] <= yr0; datai[5] <= yi0;
datar[6] <= xr1; datai[6] <= xi1; datar[7] <= yr1; datai[7] <= yi1;
datar[8] <= xr2; datai[8] <= xi2; datar[9] <= yr2; datai[9] <= yi2;
datar[10] <= xr3; datai[10] <= xi3; datar[11] <= yr3; datai[11] <= yi3;
datar[12] <= xr4; datai[12] <= xi4; datar[13] <= yr4; datai[13] <= yi4;
datar[14] <= xr5; datai[14] <= xi5; datar[15] <= yr5; datai[15] <= yi5;
    state <= 31;
end
31: begin
datar[16] <= xr0; datai[16] <= xi0; datar[17] <= yr0; datai[17] <= yi0;
datar[18] <= xr1; datai[18] <= xi1; datar[19] <= yr1; datai[19] <= yi1;
datar[20] <= xr2; datai[20] <= xi2; datar[21] <= yr2; datai[21] <= yi2;
datar[22] <= xr3; datai[22] <= xi3; datar[23] <= yr3; datai[23] <= yi3;
datar[24] <= xr4; datai[24] <= xi4; datar[25] <= yr4; datai[25] <= yi4;
datar[26] <= xr5; datai[26] <= xi5; datar[27] <= yr5; datai[27] <= yi5;
    state <= 32;
end
32: begin
datar[28] <= xr0; datai[28] <= xi0; datar[29] <= yr0; datai[29] <= yi0;
datar[30] <= xr1; datai[30] <= xi1; datar[31] <= yr1; datai[31] <= yi1;
datar[32] <= xr2; datai[32] <= xi2; datar[33] <= yr2; datai[33] <= yi2;
datar[34] <= xr3; datai[34] <= xi3; datar[35] <= yr3; datai[35] <= yi3;
datar[36] <= xr4; datai[36] <= xi4; datar[37] <= yr4; datai[37] <= yi4;
datar[38] <= xr5; datai[38] <= xi5; datar[39] <= yr5; datai[39] <= yi5;
    state <= 33;
end
33: begin
datar[40] <= xr0; datai[40] <= xi0; datar[41] <= yr0; datai[41] <= yi0;
datar[42] <= xr1; datai[42] <= xi1; datar[43] <= yr1; datai[43] <= yi1;
datar[44] <= xr2; datai[44] <= xi2; datar[45] <= yr2; datai[45] <= yi2;
datar[46] <= xr3; datai[46] <= xi3; datar[47] <= yr3; datai[47] <= yi3;
datar[48] <= xr4; datai[48] <= xi4; datar[49] <= yr4; datai[49] <= yi4;
datar[50] <= xr5; datai[50] <= xi5; datar[51] <= yr5; datai[51] <= yi5;
    state <= 34;
end
34: begin
datar[52] <= xr0; datai[52] <= xi0; datar[53] <= yr0; datai[53] <= yi0;
datar[54] <= xr1; datai[54] <= xi1; datar[55] <= yr1; datai[55] <= yi1;
datar[56] <= xr2; datai[56] <= xi2; datar[57] <= yr2; datai[57] <= yi2;
datar[58] <= xr3; datai[58] <= xi3; datar[59] <= yr3; datai[59] <= yi3;
datar[60] <= xr4; datai[60] <= xi4; datar[61] <= yr4; datai[61] <= yi4;
datar[62] <= xr5; datai[62] <= xi5; datar[63] <= yr5; datai[63] <= yi5;
    state <= 35;
end
35: begin
datar[0] <= datar[0];
datai[0] <= datai[0];
datar[32] <= datar[1];
datai[32] <= datai[1];
datar[16] <= datar[2];
datai[16] <= datai[2];
datar[48] <= datar[3];
datai[48] <= datai[3];
datar[8] <= datar[4];
datai[8] <= datai[4];
datar[40] <= datar[5];
datai[40] <= datai[5];
datar[24] <= datar[6];
datai[24] <= datai[6];
datar[56] <= datar[7];
datai[56] <= datai[7];
datar[4] <= datar[8];
datai[4] <= datai[8];
datar[36] <= datar[9];
datai[36] <= datai[9];
datar[20] <= datar[10];
datai[20] <= datai[10];
datar[52] <= datar[11];
datai[52] <= datai[11];
datar[12] <= datar[12];
datai[12] <= datai[12];
datar[44] <= datar[13];
datai[44] <= datai[13];
datar[28] <= datar[14];
datai[28] <= datai[14];
datar[60] <= datar[15];
datai[60] <= datai[15];
datar[2] <= datar[16];
datai[2] <= datai[16];
datar[34] <= datar[17];
datai[34] <= datai[17];
datar[18] <= datar[18];
datai[18] <= datai[18];
datar[50] <= datar[19];
datai[50] <= datai[19];
datar[10] <= datar[20];
datai[10] <= datai[20];
datar[42] <= datar[21];
datai[42] <= datai[21];
datar[26] <= datar[22];
datai[26] <= datai[22];
datar[58] <= datar[23];
datai[58] <= datai[23];
datar[6] <= datar[24];
datai[6] <= datai[24];
datar[38] <= datar[25];
datai[38] <= datai[25];
datar[22] <= datar[26];
datai[22] <= datai[26];
datar[54] <= datar[27];
datai[54] <= datai[27];
datar[14] <= datar[28];
datai[14] <= datai[28];
datar[46] <= datar[29];
datai[46] <= datai[29];
datar[30] <= datar[30];
datai[30] <= datai[30];
datar[62] <= datar[31];
datai[62] <= datai[31];
datar[1] <= datar[32];
datai[1] <= datai[32];
datar[33] <= datar[33];
datai[33] <= datai[33];
datar[17] <= datar[34];
datai[17] <= datai[34];
datar[49] <= datar[35];
datai[49] <= datai[35];
datar[9] <= datar[36];
datai[9] <= datai[36];
datar[41] <= datar[37];
datai[41] <= datai[37];
datar[25] <= datar[38];
datai[25] <= datai[38];
datar[57] <= datar[39];
datai[57] <= datai[39];
datar[5] <= datar[40];
datai[5] <= datai[40];
datar[37] <= datar[41];
datai[37] <= datai[41];
datar[21] <= datar[42];
datai[21] <= datai[42];
datar[53] <= datar[43];
datai[53] <= datai[43];
datar[13] <= datar[44];
datai[13] <= datai[44];
datar[45] <= datar[45];
datai[45] <= datai[45];
datar[29] <= datar[46];
datai[29] <= datai[46];
datar[61] <= datar[47];
datai[61] <= datai[47];
datar[3] <= datar[48];
datai[3] <= datai[48];
datar[35] <= datar[49];
datai[35] <= datai[49];
datar[19] <= datar[50];
datai[19] <= datai[50];
datar[51] <= datar[51];
datai[51] <= datai[51];
datar[11] <= datar[52];
datai[11] <= datai[52];
datar[43] <= datar[53];
datai[43] <= datai[53];
datar[27] <= datar[54];
datai[27] <= datai[54];
datar[59] <= datar[55];
datai[59] <= datai[55];
datar[7] <= datar[56];
datai[7] <= datai[56];
datar[39] <= datar[57];
datai[39] <= datai[57];
datar[23] <= datar[58];
datai[23] <= datai[58];
datar[55] <= datar[59];
datai[55] <= datai[59];
datar[15] <= datar[60];
datai[15] <= datai[60];
datar[47] <= datar[61];
datai[47] <= datai[61];
datar[31] <= datar[62];
datai[31] <= datai[62];
datar[63] <= datar[63];
datai[63] <= datai[63];

    state <= 36;
    samples <= 0;
end

36: begin
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
