
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
    output [width-1:0] xi
    );
    
    reg state[7:0];
    // 0 = idle, 1 = input, 2 = output, 3 = 
    reg samples;

    reg[width-1:0] datar[0:63];
    reg[width-1:0] datai[0:63];
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

    assign valid_o = state == 130;
    assign xr = datar[samples];
    assign xi = datai[samples];
    assign full = 1;

    always @(posedge CLK) begin
        if(!RST) begin
            // reset 
            samples <= 0;
            state <= 0;

            // sintable[0] = 0;
            // sintable[1] = 1644455;
            // sintable[2] = 3273072;
            // sintable[3] = 4870169;
            // sintable[4] = 6420363;
            // sintable[5] = 7908725;
            // sintable[6] = 9320922;
            // sintable[7] = 10643353;
            // sintable[8] = 11863283;
            // sintable[9] = 12968963;
            // sintable[10] = 13949745;
            // sintable[11] = 14796184;
            // sintable[12] = 15500126;
            // sintable[13] = 16054795;
            // sintable[14] = 16454846;
            // sintable[15] = 16696429;
            // sintable[16] = 16777216;
            // どうせ上書きされるので処理中
            // datar[0] <= 0;
            // datai[0] <= 0;
        end else begin
            case(state)
                0: begin
                    if(valid_a) begin
                        datar[samples] = ar;
                        datar[samples] = ai;
                        samples = 1;
                        state = 1;
                    end
                end
                1: begin
                    if(valid_a) begin
                        // datar << width;
                        // datar <= datar + ar;
                        // datai << width;
                        // datai <= datai + ai;
                        datar[samples] = ar;
                        datar[samples] = ai;
                        samples <= samples + 1;
                        state <= state + 1;
                        if(samples == 64) begin
                            state = 2;
                            samples = 0;
                        end
                    end
                end
                2: begin
                    datar[xk(0)] <= datar[0] + (datar[32] * 16777216 - datai[32] * 0) <<< 24;
                    datai[xk(0)] <= datai[0] + (datar[32] * 0 + datai[32] * 16777216) <<< 24;
                    datar[xk(0)] <= datar[0] - (datar[32] * 16777216 + datai[32] * 0) <<< 24;
                    datai[xk(0)] <= datai[0] - (datar[32] * 0 - datai[32] * 16777216) <<< 24;
                    datar[xk(16)] <= datar[16] + (datar[48] * 13995945 - datai[48] * 9251404) <<< 24;
                    datai[xk(16)] <= datai[16] + (datar[48] * 9251404 + datai[48] * 13995945) <<< 24;
                    state = 3
                end
                3: begin
                    datar[xk(16)] <= datar[16] - (datar[48] * 13995945 + datai[48] * 9251404) <<< 24;
                    datai[xk(16)] <= datai[16] - (datar[48] * 9251404 - datai[48] * 13995945) <<< 24;
                    datar[xk(8)] <= datar[8] + (datar[40] * 16777216 - datai[40] * 0) <<< 24;
                    datai[xk(8)] <= datai[8] + (datar[40] * 0 + datai[40] * 16777216) <<< 24;
                    datar[xk(8)] <= datar[8] - (datar[40] * 16777216 + datai[40] * 0) <<< 24;
                    datai[xk(8)] <= datai[8] - (datar[40] * 0 - datai[40] * 16777216) <<< 24;
                    state = 4
                end
                4: begin
                    datar[xk(24)] <= datar[24] + (datar[56] * 13995945 - datai[56] * 9251404) <<< 24;
                    datai[xk(24)] <= datai[24] + (datar[56] * 9251404 + datai[56] * 13995945) <<< 24;
                    datar[xk(24)] <= datar[24] - (datar[56] * 13995945 + datai[56] * 9251404) <<< 24;
                    datai[xk(24)] <= datai[24] - (datar[56] * 9251404 - datai[56] * 13995945) <<< 24;
                    datar[xk(4)] <= datar[4] + (datar[36] * 16777216 - datai[36] * 0) <<< 24;
                    datai[xk(4)] <= datai[4] + (datar[36] * 0 + datai[36] * 16777216) <<< 24;
                    state = 5
                end
                5: begin
                    datar[xk(4)] <= datar[4] - (datar[36] * 16777216 + datai[36] * 0) <<< 24;
                    datai[xk(4)] <= datai[4] - (datar[36] * 0 - datai[36] * 16777216) <<< 24;
                    datar[xk(20)] <= datar[20] + (datar[52] * 13995945 - datai[52] * 9251404) <<< 24;
                    datai[xk(20)] <= datai[20] + (datar[52] * 9251404 + datai[52] * 13995945) <<< 24;
                    datar[xk(20)] <= datar[20] - (datar[52] * 13995945 + datai[52] * 9251404) <<< 24;
                    datai[xk(20)] <= datai[20] - (datar[52] * 9251404 - datai[52] * 13995945) <<< 24;
                    state = 6
                end
                6: begin
                    datar[xk(12)] <= datar[12] + (datar[44] * 16777216 - datai[44] * 0) <<< 24;
                    datai[xk(12)] <= datai[12] + (datar[44] * 0 + datai[44] * 16777216) <<< 24;
                    datar[xk(12)] <= datar[12] - (datar[44] * 16777216 + datai[44] * 0) <<< 24;
                    datai[xk(12)] <= datai[12] - (datar[44] * 0 - datai[44] * 16777216) <<< 24;
                    datar[xk(28)] <= datar[28] + (datar[60] * 13995945 - datai[60] * 9251404) <<< 24;
                    datai[xk(28)] <= datai[28] + (datar[60] * 9251404 + datai[60] * 13995945) <<< 24;
                    state = 7
                end
                7: begin
                    datar[xk(28)] <= datar[28] - (datar[60] * 13995945 + datai[60] * 9251404) <<< 24;
                    datai[xk(28)] <= datai[28] - (datar[60] * 9251404 - datai[60] * 13995945) <<< 24;
                    datar[xk(2)] <= datar[2] + (datar[34] * 16777216 - datai[34] * 0) <<< 24;
                    datai[xk(2)] <= datai[2] + (datar[34] * 0 + datai[34] * 16777216) <<< 24;
                    datar[xk(2)] <= datar[2] - (datar[34] * 16777216 + datai[34] * 0) <<< 24;
                    datai[xk(2)] <= datai[2] - (datar[34] * 0 - datai[34] * 16777216) <<< 24;
                    state = 8
                end
                8: begin
                    datar[xk(18)] <= datar[18] + (datar[50] * 13995945 - datai[50] * 9251404) <<< 24;
                    datai[xk(18)] <= datai[18] + (datar[50] * 9251404 + datai[50] * 13995945) <<< 24;
                    datar[xk(18)] <= datar[18] - (datar[50] * 13995945 + datai[50] * 9251404) <<< 24;
                    datai[xk(18)] <= datai[18] - (datar[50] * 9251404 - datai[50] * 13995945) <<< 24;
                    datar[xk(10)] <= datar[10] + (datar[42] * 16777216 - datai[42] * 0) <<< 24;
                    datai[xk(10)] <= datai[10] + (datar[42] * 0 + datai[42] * 16777216) <<< 24;
                    state = 9
                end
                9: begin
                    datar[xk(10)] <= datar[10] - (datar[42] * 16777216 + datai[42] * 0) <<< 24;
                    datai[xk(10)] <= datai[10] - (datar[42] * 0 - datai[42] * 16777216) <<< 24;
                    datar[xk(26)] <= datar[26] + (datar[58] * 13995945 - datai[58] * 9251404) <<< 24;
                    datai[xk(26)] <= datai[26] + (datar[58] * 9251404 + datai[58] * 13995945) <<< 24;
                    datar[xk(26)] <= datar[26] - (datar[58] * 13995945 + datai[58] * 9251404) <<< 24;
                    datai[xk(26)] <= datai[26] - (datar[58] * 9251404 - datai[58] * 13995945) <<< 24;
                    state = 10
                end
                10: begin
                    datar[xk(6)] <= datar[6] + (datar[38] * 16777216 - datai[38] * 0) <<< 24;
                    datai[xk(6)] <= datai[6] + (datar[38] * 0 + datai[38] * 16777216) <<< 24;
                    datar[xk(6)] <= datar[6] - (datar[38] * 16777216 + datai[38] * 0) <<< 24;
                    datai[xk(6)] <= datai[6] - (datar[38] * 0 - datai[38] * 16777216) <<< 24;
                    datar[xk(22)] <= datar[22] + (datar[54] * 13995945 - datai[54] * 9251404) <<< 24;
                    datai[xk(22)] <= datai[22] + (datar[54] * 9251404 + datai[54] * 13995945) <<< 24;
                    state = 11
                end
                11: begin
                    datar[xk(22)] <= datar[22] - (datar[54] * 13995945 + datai[54] * 9251404) <<< 24;
                    datai[xk(22)] <= datai[22] - (datar[54] * 9251404 - datai[54] * 13995945) <<< 24;
                    datar[xk(14)] <= datar[14] + (datar[46] * 16777216 - datai[46] * 0) <<< 24;
                    datai[xk(14)] <= datai[14] + (datar[46] * 0 + datai[46] * 16777216) <<< 24;
                    datar[xk(14)] <= datar[14] - (datar[46] * 16777216 + datai[46] * 0) <<< 24;
                    datai[xk(14)] <= datai[14] - (datar[46] * 0 - datai[46] * 16777216) <<< 24;
                    state = 12
                end
                12: begin
                    datar[xk(30)] <= datar[30] + (datar[62] * 13995945 - datai[62] * 9251404) <<< 24;
                    datai[xk(30)] <= datai[30] + (datar[62] * 9251404 + datai[62] * 13995945) <<< 24;
                    datar[xk(30)] <= datar[30] - (datar[62] * 13995945 + datai[62] * 9251404) <<< 24;
                    datai[xk(30)] <= datai[30] - (datar[62] * 9251404 - datai[62] * 13995945) <<< 24;
                    datar[xk(1)] <= datar[1] + (datar[33] * 16777216 - datai[33] * 0) <<< 24;
                    datai[xk(1)] <= datai[1] + (datar[33] * 0 + datai[33] * 16777216) <<< 24;
                    state = 13
                end
                13: begin
                    datar[xk(1)] <= datar[1] - (datar[33] * 16777216 + datai[33] * 0) <<< 24;
                    datai[xk(1)] <= datai[1] - (datar[33] * 0 - datai[33] * 16777216) <<< 24;
                    datar[xk(17)] <= datar[17] + (datar[49] * 13995945 - datai[49] * 9251404) <<< 24;
                    datai[xk(17)] <= datai[17] + (datar[49] * 9251404 + datai[49] * 13995945) <<< 24;
                    datar[xk(17)] <= datar[17] - (datar[49] * 13995945 + datai[49] * 9251404) <<< 24;
                    datai[xk(17)] <= datai[17] - (datar[49] * 9251404 - datai[49] * 13995945) <<< 24;
                    state = 14
                end
                14: begin
                    datar[xk(9)] <= datar[9] + (datar[41] * 16777216 - datai[41] * 0) <<< 24;
                    datai[xk(9)] <= datai[9] + (datar[41] * 0 + datai[41] * 16777216) <<< 24;
                    datar[xk(9)] <= datar[9] - (datar[41] * 16777216 + datai[41] * 0) <<< 24;
                    datai[xk(9)] <= datai[9] - (datar[41] * 0 - datai[41] * 16777216) <<< 24;
                    datar[xk(25)] <= datar[25] + (datar[57] * 13995945 - datai[57] * 9251404) <<< 24;
                    datai[xk(25)] <= datai[25] + (datar[57] * 9251404 + datai[57] * 13995945) <<< 24;
                    state = 15
                end
                15: begin
                    datar[xk(25)] <= datar[25] - (datar[57] * 13995945 + datai[57] * 9251404) <<< 24;
                    datai[xk(25)] <= datai[25] - (datar[57] * 9251404 - datai[57] * 13995945) <<< 24;
                    datar[xk(5)] <= datar[5] + (datar[37] * 16777216 - datai[37] * 0) <<< 24;
                    datai[xk(5)] <= datai[5] + (datar[37] * 0 + datai[37] * 16777216) <<< 24;
                    datar[xk(5)] <= datar[5] - (datar[37] * 16777216 + datai[37] * 0) <<< 24;
                    datai[xk(5)] <= datai[5] - (datar[37] * 0 - datai[37] * 16777216) <<< 24;
                    state = 16
                end
                16: begin
                    datar[xk(21)] <= datar[21] + (datar[53] * 13995945 - datai[53] * 9251404) <<< 24;
                    datai[xk(21)] <= datai[21] + (datar[53] * 9251404 + datai[53] * 13995945) <<< 24;
                    datar[xk(21)] <= datar[21] - (datar[53] * 13995945 + datai[53] * 9251404) <<< 24;
                    datai[xk(21)] <= datai[21] - (datar[53] * 9251404 - datai[53] * 13995945) <<< 24;
                    datar[xk(13)] <= datar[13] + (datar[45] * 16777216 - datai[45] * 0) <<< 24;
                    datai[xk(13)] <= datai[13] + (datar[45] * 0 + datai[45] * 16777216) <<< 24;
                    state = 17
                end
                17: begin
                    datar[xk(13)] <= datar[13] - (datar[45] * 16777216 + datai[45] * 0) <<< 24;
                    datai[xk(13)] <= datai[13] - (datar[45] * 0 - datai[45] * 16777216) <<< 24;
                    datar[xk(29)] <= datar[29] + (datar[61] * 13995945 - datai[61] * 9251404) <<< 24;
                    datai[xk(29)] <= datai[29] + (datar[61] * 9251404 + datai[61] * 13995945) <<< 24;
                    datar[xk(29)] <= datar[29] - (datar[61] * 13995945 + datai[61] * 9251404) <<< 24;
                    datai[xk(29)] <= datai[29] - (datar[61] * 9251404 - datai[61] * 13995945) <<< 24;
                    state = 18
                end
                18: begin
                    datar[xk(3)] <= datar[3] + (datar[35] * 16777216 - datai[35] * 0) <<< 24;
                    datai[xk(3)] <= datai[3] + (datar[35] * 0 + datai[35] * 16777216) <<< 24;
                    datar[xk(3)] <= datar[3] - (datar[35] * 16777216 + datai[35] * 0) <<< 24;
                    datai[xk(3)] <= datai[3] - (datar[35] * 0 - datai[35] * 16777216) <<< 24;
                    datar[xk(19)] <= datar[19] + (datar[51] * 13995945 - datai[51] * 9251404) <<< 24;
                    datai[xk(19)] <= datai[19] + (datar[51] * 9251404 + datai[51] * 13995945) <<< 24;
                    state = 19
                end
                19: begin
                    datar[xk(19)] <= datar[19] - (datar[51] * 13995945 + datai[51] * 9251404) <<< 24;
                    datai[xk(19)] <= datai[19] - (datar[51] * 9251404 - datai[51] * 13995945) <<< 24;
                    datar[xk(11)] <= datar[11] + (datar[43] * 16777216 - datai[43] * 0) <<< 24;
                    datai[xk(11)] <= datai[11] + (datar[43] * 0 + datai[43] * 16777216) <<< 24;
                    datar[xk(11)] <= datar[11] - (datar[43] * 16777216 + datai[43] * 0) <<< 24;
                    datai[xk(11)] <= datai[11] - (datar[43] * 0 - datai[43] * 16777216) <<< 24;
                    state = 20
                end
                20: begin
                    datar[xk(27)] <= datar[27] + (datar[59] * 13995945 - datai[59] * 9251404) <<< 24;
                    datai[xk(27)] <= datai[27] + (datar[59] * 9251404 + datai[59] * 13995945) <<< 24;
                    datar[xk(27)] <= datar[27] - (datar[59] * 13995945 + datai[59] * 9251404) <<< 24;
                    datai[xk(27)] <= datai[27] - (datar[59] * 9251404 - datai[59] * 13995945) <<< 24;
                    datar[xk(7)] <= datar[7] + (datar[39] * 16777216 - datai[39] * 0) <<< 24;
                    datai[xk(7)] <= datai[7] + (datar[39] * 0 + datai[39] * 16777216) <<< 24;
                    state = 21
                end
                21: begin
                    datar[xk(7)] <= datar[7] - (datar[39] * 16777216 + datai[39] * 0) <<< 24;
                    datai[xk(7)] <= datai[7] - (datar[39] * 0 - datai[39] * 16777216) <<< 24;
                    datar[xk(23)] <= datar[23] + (datar[55] * 13995945 - datai[55] * 9251404) <<< 24;
                    datai[xk(23)] <= datai[23] + (datar[55] * 9251404 + datai[55] * 13995945) <<< 24;
                    datar[xk(23)] <= datar[23] - (datar[55] * 13995945 + datai[55] * 9251404) <<< 24;
                    datai[xk(23)] <= datai[23] - (datar[55] * 9251404 - datai[55] * 13995945) <<< 24;
                    state = 22
                end
                22: begin
                    datar[xk(15)] <= datar[15] + (datar[47] * 16777216 - datai[47] * 0) <<< 24;
                    datai[xk(15)] <= datai[15] + (datar[47] * 0 + datai[47] * 16777216) <<< 24;
                    datar[xk(15)] <= datar[15] - (datar[47] * 16777216 + datai[47] * 0) <<< 24;
                    datai[xk(15)] <= datai[15] - (datar[47] * 0 - datai[47] * 16777216) <<< 24;
                    datar[xk(31)] <= datar[31] + (datar[63] * 13995945 - datai[63] * 9251404) <<< 24;
                    datai[xk(31)] <= datai[31] + (datar[63] * 9251404 + datai[63] * 13995945) <<< 24;
                    state = 23
                end
                23: begin
                    datar[xk(31)] <= datar[31] - (datar[63] * 13995945 + datai[63] * 9251404) <<< 24;
                    datai[xk(31)] <= datai[31] - (datar[63] * 9251404 - datai[63] * 13995945) <<< 24;
                    datar[xk(0)] <= datar[0] + (datar[16] * 16777216 - datai[16] * 0) <<< 24;
                    datai[xk(0)] <= datai[0] + (datar[16] * 0 + datai[16] * 16777216) <<< 24;
                    datar[xk(0)] <= datar[0] - (datar[16] * 16777216 + datai[16] * 0) <<< 24;
                    datai[xk(0)] <= datai[0] - (datar[16] * 0 - datai[16] * 16777216) <<< 24;
                    state = 24
                end
                24: begin
                    datar[xk(32)] <= datar[32] + (datar[48] * -16066860 - datai[48] * -4830217) <<< 24;
                    datai[xk(32)] <= datai[32] + (datar[48] * -4830217 + datai[48] * -16066860) <<< 24;
                    datar[xk(32)] <= datar[32] - (datar[48] * -16066860 + datai[48] * -4830217) <<< 24;
                    datai[xk(32)] <= datai[32] - (datar[48] * -4830217 - datai[48] * -16066860) <<< 24;
                    datar[xk(8)] <= datar[8] + (datar[24] * 13995945 - datai[24] * 9251404) <<< 24;
                    datai[xk(8)] <= datai[8] + (datar[24] * 9251404 + datai[24] * 13995945) <<< 24;
                    state = 25
                end
                25: begin
                    datar[xk(8)] <= datar[8] - (datar[24] * 13995945 + datai[24] * 9251404) <<< 24;
                    datai[xk(8)] <= datai[8] - (datar[24] * 9251404 - datai[24] * 13995945) <<< 24;
                    datar[xk(40)] <= datar[40] + (datar[56] * -10739840 - datai[56] * -12889175) <<< 24;
                    datai[xk(40)] <= datai[40] + (datar[56] * -12889175 + datai[56] * -10739840) <<< 24;
                    datar[xk(40)] <= datar[40] - (datar[56] * -10739840 + datai[56] * -12889175) <<< 24;
                    datai[xk(40)] <= datai[40] - (datar[56] * -12889175 - datai[56] * -10739840) <<< 24;
                    state = 26
                end
                26: begin
                    datar[xk(4)] <= datar[4] + (datar[20] * 16777216 - datai[20] * 0) <<< 24;
                    datai[xk(4)] <= datai[4] + (datar[20] * 0 + datai[20] * 16777216) <<< 24;
                    datar[xk(4)] <= datar[4] - (datar[20] * 16777216 + datai[20] * 0) <<< 24;
                    datai[xk(4)] <= datai[4] - (datar[20] * 0 - datai[20] * 16777216) <<< 24;
                    datar[xk(36)] <= datar[36] + (datar[52] * -16066860 - datai[52] * -4830217) <<< 24;
                    datai[xk(36)] <= datai[36] + (datar[52] * -4830217 + datai[52] * -16066860) <<< 24;
                    state = 27
                end
                27: begin
                    datar[xk(36)] <= datar[36] - (datar[52] * -16066860 + datai[52] * -4830217) <<< 24;
                    datai[xk(36)] <= datai[36] - (datar[52] * -4830217 - datai[52] * -16066860) <<< 24;
                    datar[xk(12)] <= datar[12] + (datar[28] * 13995945 - datai[28] * 9251404) <<< 24;
                    datai[xk(12)] <= datai[12] + (datar[28] * 9251404 + datai[28] * 13995945) <<< 24;
                    datar[xk(12)] <= datar[12] - (datar[28] * 13995945 + datai[28] * 9251404) <<< 24;
                    datai[xk(12)] <= datai[12] - (datar[28] * 9251404 - datai[28] * 13995945) <<< 24;
                    state = 28
                end
                28: begin
                    datar[xk(44)] <= datar[44] + (datar[60] * -10739840 - datai[60] * -12889175) <<< 24;
                    datai[xk(44)] <= datai[44] + (datar[60] * -12889175 + datai[60] * -10739840) <<< 24;
                    datar[xk(44)] <= datar[44] - (datar[60] * -10739840 + datai[60] * -12889175) <<< 24;
                    datai[xk(44)] <= datai[44] - (datar[60] * -12889175 - datai[60] * -10739840) <<< 24;
                    datar[xk(2)] <= datar[2] + (datar[18] * 16777216 - datai[18] * 0) <<< 24;
                    datai[xk(2)] <= datai[2] + (datar[18] * 0 + datai[18] * 16777216) <<< 24;
                    state = 29
                end
                29: begin
                    datar[xk(2)] <= datar[2] - (datar[18] * 16777216 + datai[18] * 0) <<< 24;
                    datai[xk(2)] <= datai[2] - (datar[18] * 0 - datai[18] * 16777216) <<< 24;
                    datar[xk(34)] <= datar[34] + (datar[50] * -16066860 - datai[50] * -4830217) <<< 24;
                    datai[xk(34)] <= datai[34] + (datar[50] * -4830217 + datai[50] * -16066860) <<< 24;
                    datar[xk(34)] <= datar[34] - (datar[50] * -16066860 + datai[50] * -4830217) <<< 24;
                    datai[xk(34)] <= datai[34] - (datar[50] * -4830217 - datai[50] * -16066860) <<< 24;
                    state = 30
                end
                30: begin
                    datar[xk(10)] <= datar[10] + (datar[26] * 13995945 - datai[26] * 9251404) <<< 24;
                    datai[xk(10)] <= datai[10] + (datar[26] * 9251404 + datai[26] * 13995945) <<< 24;
                    datar[xk(10)] <= datar[10] - (datar[26] * 13995945 + datai[26] * 9251404) <<< 24;
                    datai[xk(10)] <= datai[10] - (datar[26] * 9251404 - datai[26] * 13995945) <<< 24;
                    datar[xk(42)] <= datar[42] + (datar[58] * -10739840 - datai[58] * -12889175) <<< 24;
                    datai[xk(42)] <= datai[42] + (datar[58] * -12889175 + datai[58] * -10739840) <<< 24;
                    state = 31
                end
                31: begin
                    datar[xk(42)] <= datar[42] - (datar[58] * -10739840 + datai[58] * -12889175) <<< 24;
                    datai[xk(42)] <= datai[42] - (datar[58] * -12889175 - datai[58] * -10739840) <<< 24;
                    datar[xk(6)] <= datar[6] + (datar[22] * 16777216 - datai[22] * 0) <<< 24;
                    datai[xk(6)] <= datai[6] + (datar[22] * 0 + datai[22] * 16777216) <<< 24;
                    datar[xk(6)] <= datar[6] - (datar[22] * 16777216 + datai[22] * 0) <<< 24;
                    datai[xk(6)] <= datai[6] - (datar[22] * 0 - datai[22] * 16777216) <<< 24;
                    state = 32
                end
                32: begin
                    datar[xk(38)] <= datar[38] + (datar[54] * -16066860 - datai[54] * -4830217) <<< 24;
                    datai[xk(38)] <= datai[38] + (datar[54] * -4830217 + datai[54] * -16066860) <<< 24;
                    datar[xk(38)] <= datar[38] - (datar[54] * -16066860 + datai[54] * -4830217) <<< 24;
                    datai[xk(38)] <= datai[38] - (datar[54] * -4830217 - datai[54] * -16066860) <<< 24;
                    datar[xk(14)] <= datar[14] + (datar[30] * 13995945 - datai[30] * 9251404) <<< 24;
                    datai[xk(14)] <= datai[14] + (datar[30] * 9251404 + datai[30] * 13995945) <<< 24;
                    state = 33
                end
                33: begin
                    datar[xk(14)] <= datar[14] - (datar[30] * 13995945 + datai[30] * 9251404) <<< 24;
                    datai[xk(14)] <= datai[14] - (datar[30] * 9251404 - datai[30] * 13995945) <<< 24;
                    datar[xk(46)] <= datar[46] + (datar[62] * -10739840 - datai[62] * -12889175) <<< 24;
                    datai[xk(46)] <= datai[46] + (datar[62] * -12889175 + datai[62] * -10739840) <<< 24;
                    datar[xk(46)] <= datar[46] - (datar[62] * -10739840 + datai[62] * -12889175) <<< 24;
                    datai[xk(46)] <= datai[46] - (datar[62] * -12889175 - datai[62] * -10739840) <<< 24;
                    state = 34
                end
                34: begin
                    datar[xk(1)] <= datar[1] + (datar[17] * 16777216 - datai[17] * 0) <<< 24;
                    datai[xk(1)] <= datai[1] + (datar[17] * 0 + datai[17] * 16777216) <<< 24;
                    datar[xk(1)] <= datar[1] - (datar[17] * 16777216 + datai[17] * 0) <<< 24;
                    datai[xk(1)] <= datai[1] - (datar[17] * 0 - datai[17] * 16777216) <<< 24;
                    datar[xk(33)] <= datar[33] + (datar[49] * -16066860 - datai[49] * -4830217) <<< 24;
                    datai[xk(33)] <= datai[33] + (datar[49] * -4830217 + datai[49] * -16066860) <<< 24;
                    state = 35
                end
                35: begin
                    datar[xk(33)] <= datar[33] - (datar[49] * -16066860 + datai[49] * -4830217) <<< 24;
                    datai[xk(33)] <= datai[33] - (datar[49] * -4830217 - datai[49] * -16066860) <<< 24;
                    datar[xk(9)] <= datar[9] + (datar[25] * 13995945 - datai[25] * 9251404) <<< 24;
                    datai[xk(9)] <= datai[9] + (datar[25] * 9251404 + datai[25] * 13995945) <<< 24;
                    datar[xk(9)] <= datar[9] - (datar[25] * 13995945 + datai[25] * 9251404) <<< 24;
                    datai[xk(9)] <= datai[9] - (datar[25] * 9251404 - datai[25] * 13995945) <<< 24;
                    state = 36
                end
                36: begin
                    datar[xk(41)] <= datar[41] + (datar[57] * -10739840 - datai[57] * -12889175) <<< 24;
                    datai[xk(41)] <= datai[41] + (datar[57] * -12889175 + datai[57] * -10739840) <<< 24;
                    datar[xk(41)] <= datar[41] - (datar[57] * -10739840 + datai[57] * -12889175) <<< 24;
                    datai[xk(41)] <= datai[41] - (datar[57] * -12889175 - datai[57] * -10739840) <<< 24;
                    datar[xk(5)] <= datar[5] + (datar[21] * 16777216 - datai[21] * 0) <<< 24;
                    datai[xk(5)] <= datai[5] + (datar[21] * 0 + datai[21] * 16777216) <<< 24;
                    state = 37
                end
                37: begin
                    datar[xk(5)] <= datar[5] - (datar[21] * 16777216 + datai[21] * 0) <<< 24;
                    datai[xk(5)] <= datai[5] - (datar[21] * 0 - datai[21] * 16777216) <<< 24;
                    datar[xk(37)] <= datar[37] + (datar[53] * -16066860 - datai[53] * -4830217) <<< 24;
                    datai[xk(37)] <= datai[37] + (datar[53] * -4830217 + datai[53] * -16066860) <<< 24;
                    datar[xk(37)] <= datar[37] - (datar[53] * -16066860 + datai[53] * -4830217) <<< 24;
                    datai[xk(37)] <= datai[37] - (datar[53] * -4830217 - datai[53] * -16066860) <<< 24;
                    state = 38
                end
                38: begin
                    datar[xk(13)] <= datar[13] + (datar[29] * 13995945 - datai[29] * 9251404) <<< 24;
                    datai[xk(13)] <= datai[13] + (datar[29] * 9251404 + datai[29] * 13995945) <<< 24;
                    datar[xk(13)] <= datar[13] - (datar[29] * 13995945 + datai[29] * 9251404) <<< 24;
                    datai[xk(13)] <= datai[13] - (datar[29] * 9251404 - datai[29] * 13995945) <<< 24;
                    datar[xk(45)] <= datar[45] + (datar[61] * -10739840 - datai[61] * -12889175) <<< 24;
                    datai[xk(45)] <= datai[45] + (datar[61] * -12889175 + datai[61] * -10739840) <<< 24;
                    state = 39
                end
                39: begin
                    datar[xk(45)] <= datar[45] - (datar[61] * -10739840 + datai[61] * -12889175) <<< 24;
                    datai[xk(45)] <= datai[45] - (datar[61] * -12889175 - datai[61] * -10739840) <<< 24;
                    datar[xk(3)] <= datar[3] + (datar[19] * 16777216 - datai[19] * 0) <<< 24;
                    datai[xk(3)] <= datai[3] + (datar[19] * 0 + datai[19] * 16777216) <<< 24;
                    datar[xk(3)] <= datar[3] - (datar[19] * 16777216 + datai[19] * 0) <<< 24;
                    datai[xk(3)] <= datai[3] - (datar[19] * 0 - datai[19] * 16777216) <<< 24;
                    state = 40
                end
                40: begin
                    datar[xk(35)] <= datar[35] + (datar[51] * -16066860 - datai[51] * -4830217) <<< 24;
                    datai[xk(35)] <= datai[35] + (datar[51] * -4830217 + datai[51] * -16066860) <<< 24;
                    datar[xk(35)] <= datar[35] - (datar[51] * -16066860 + datai[51] * -4830217) <<< 24;
                    datai[xk(35)] <= datai[35] - (datar[51] * -4830217 - datai[51] * -16066860) <<< 24;
                    datar[xk(11)] <= datar[11] + (datar[27] * 13995945 - datai[27] * 9251404) <<< 24;
                    datai[xk(11)] <= datai[11] + (datar[27] * 9251404 + datai[27] * 13995945) <<< 24;
                    state = 41
                end
                41: begin
                    datar[xk(11)] <= datar[11] - (datar[27] * 13995945 + datai[27] * 9251404) <<< 24;
                    datai[xk(11)] <= datai[11] - (datar[27] * 9251404 - datai[27] * 13995945) <<< 24;
                    datar[xk(43)] <= datar[43] + (datar[59] * -10739840 - datai[59] * -12889175) <<< 24;
                    datai[xk(43)] <= datai[43] + (datar[59] * -12889175 + datai[59] * -10739840) <<< 24;
                    datar[xk(43)] <= datar[43] - (datar[59] * -10739840 + datai[59] * -12889175) <<< 24;
                    datai[xk(43)] <= datai[43] - (datar[59] * -12889175 - datai[59] * -10739840) <<< 24;
                    state = 42
                end
                42: begin
                    datar[xk(7)] <= datar[7] + (datar[23] * 16777216 - datai[23] * 0) <<< 24;
                    datai[xk(7)] <= datai[7] + (datar[23] * 0 + datai[23] * 16777216) <<< 24;
                    datar[xk(7)] <= datar[7] - (datar[23] * 16777216 + datai[23] * 0) <<< 24;
                    datai[xk(7)] <= datai[7] - (datar[23] * 0 - datai[23] * 16777216) <<< 24;
                    datar[xk(39)] <= datar[39] + (datar[55] * -16066860 - datai[55] * -4830217) <<< 24;
                    datai[xk(39)] <= datai[39] + (datar[55] * -4830217 + datai[55] * -16066860) <<< 24;
                    state = 43
                end
                43: begin
                    datar[xk(39)] <= datar[39] - (datar[55] * -16066860 + datai[55] * -4830217) <<< 24;
                    datai[xk(39)] <= datai[39] - (datar[55] * -4830217 - datai[55] * -16066860) <<< 24;
                    datar[xk(15)] <= datar[15] + (datar[31] * 13995945 - datai[31] * 9251404) <<< 24;
                    datai[xk(15)] <= datai[15] + (datar[31] * 9251404 + datai[31] * 13995945) <<< 24;
                    datar[xk(15)] <= datar[15] - (datar[31] * 13995945 + datai[31] * 9251404) <<< 24;
                    datai[xk(15)] <= datai[15] - (datar[31] * 9251404 - datai[31] * 13995945) <<< 24;
                    state = 44
                end
                44: begin
                    datar[xk(47)] <= datar[47] + (datar[63] * -10739840 - datai[63] * -12889175) <<< 24;
                    datai[xk(47)] <= datai[47] + (datar[63] * -12889175 + datai[63] * -10739840) <<< 24;
                    datar[xk(47)] <= datar[47] - (datar[63] * -10739840 + datai[63] * -12889175) <<< 24;
                    datai[xk(47)] <= datai[47] - (datar[63] * -12889175 - datai[63] * -10739840) <<< 24;
                    datar[xk(0)] <= datar[0] + (datar[8] * 16777216 - datai[8] * 0) <<< 24;
                    datai[xk(0)] <= datai[0] + (datar[8] * 0 + datai[8] * 16777216) <<< 24;
                    state = 45
                end
                45: begin
                    datar[xk(0)] <= datar[0] - (datar[8] * 16777216 + datai[8] * 0) <<< 24;
                    datai[xk(0)] <= datai[0] - (datar[8] * 0 - datai[8] * 16777216) <<< 24;
                    datar[xk(32)] <= datar[32] + (datar[40] * -2441086 - datai[40] * 16598677) <<< 24;
                    datai[xk(32)] <= datai[32] + (datar[40] * 16598677 + datai[40] * -2441086) <<< 24;
                    datar[xk(32)] <= datar[32] - (datar[40] * -2441086 + datai[40] * 16598677) <<< 24;
                    datai[xk(32)] <= datai[32] - (datar[40] * 16598677 - datai[40] * -2441086) <<< 24;
                    state = 46
                end
                46: begin
                    datar[xk(16)] <= datar[16] + (datar[24] * -16066860 - datai[24] * -4830217) <<< 24;
                    datai[xk(16)] <= datai[16] + (datar[24] * -4830217 + datai[24] * -16066860) <<< 24;
                    datar[xk(16)] <= datar[16] - (datar[24] * -16066860 + datai[24] * -4830217) <<< 24;
                    datai[xk(16)] <= datai[16] - (datar[24] * -4830217 - datai[24] * -16066860) <<< 24;
                    datar[xk(48)] <= datar[48] + (datar[56] * 7116542 - datai[56] * -15193084) <<< 24;
                    datai[xk(48)] <= datai[48] + (datar[56] * -15193084 + datai[56] * 7116542) <<< 24;
                    state = 47
                end
                47: begin
                    datar[xk(48)] <= datar[48] - (datar[56] * 7116542 + datai[56] * -15193084) <<< 24;
                    datai[xk(48)] <= datai[48] - (datar[56] * -15193084 - datai[56] * 7116542) <<< 24;
                    datar[xk(4)] <= datar[4] + (datar[12] * 13995945 - datai[12] * 9251404) <<< 24;
                    datai[xk(4)] <= datai[4] + (datar[12] * 9251404 + datai[12] * 13995945) <<< 24;
                    datar[xk(4)] <= datar[4] - (datar[12] * 13995945 + datai[12] * 9251404) <<< 24;
                    datai[xk(4)] <= datai[4] - (datar[12] * 9251404 - datai[12] * 13995945) <<< 24;
                    state = 48
                end
                48: begin
                    datar[xk(36)] <= datar[36] + (datar[44] * -11189364 - datai[44] * 12500924) <<< 24;
                    datai[xk(36)] <= datai[36] + (datar[44] * 12500924 + datai[44] * -11189364) <<< 24;
                    datar[xk(36)] <= datar[36] - (datar[44] * -11189364 + datai[44] * 12500924) <<< 24;
                    datai[xk(36)] <= datai[36] - (datar[44] * 12500924 - datai[44] * -11189364) <<< 24;
                    datar[xk(20)] <= datar[20] + (datar[28] * -10739840 - datai[28] * -12889175) <<< 24;
                    datai[xk(20)] <= datai[20] + (datar[28] * -12889175 + datai[28] * -10739840) <<< 24;
                    state = 49
                end
                49: begin
                    datar[xk(20)] <= datar[20] - (datar[28] * -10739840 + datai[28] * -12889175) <<< 24;
                    datai[xk(20)] <= datai[20] - (datar[28] * -12889175 - datai[28] * -10739840) <<< 24;
                    datar[xk(52)] <= datar[52] + (datar[60] * 14314658 - datai[60] * -8750174) <<< 24;
                    datai[xk(52)] <= datai[52] + (datar[60] * -8750174 + datai[60] * 14314658) <<< 24;
                    datar[xk(52)] <= datar[52] - (datar[60] * 14314658 + datai[60] * -8750174) <<< 24;
                    datai[xk(52)] <= datai[52] - (datar[60] * -8750174 - datai[60] * 14314658) <<< 24;
                    state = 50
                end
                50: begin
                    datar[xk(2)] <= datar[2] + (datar[10] * 16777216 - datai[10] * 0) <<< 24;
                    datai[xk(2)] <= datai[2] + (datar[10] * 0 + datai[10] * 16777216) <<< 24;
                    datar[xk(2)] <= datar[2] - (datar[10] * 16777216 + datai[10] * 0) <<< 24;
                    datai[xk(2)] <= datai[2] - (datar[10] * 0 - datai[10] * 16777216) <<< 24;
                    datar[xk(34)] <= datar[34] + (datar[42] * -2441086 - datai[42] * 16598677) <<< 24;
                    datai[xk(34)] <= datai[34] + (datar[42] * 16598677 + datai[42] * -2441086) <<< 24;
                    state = 51
                end
                51: begin
                    datar[xk(34)] <= datar[34] - (datar[42] * -2441086 + datai[42] * 16598677) <<< 24;
                    datai[xk(34)] <= datai[34] - (datar[42] * 16598677 - datai[42] * -2441086) <<< 24;
                    datar[xk(18)] <= datar[18] + (datar[26] * -16066860 - datai[26] * -4830217) <<< 24;
                    datai[xk(18)] <= datai[18] + (datar[26] * -4830217 + datai[26] * -16066860) <<< 24;
                    datar[xk(18)] <= datar[18] - (datar[26] * -16066860 + datai[26] * -4830217) <<< 24;
                    datai[xk(18)] <= datai[18] - (datar[26] * -4830217 - datai[26] * -16066860) <<< 24;
                    state = 52
                end
                52: begin
                    datar[xk(50)] <= datar[50] + (datar[58] * 7116542 - datai[58] * -15193084) <<< 24;
                    datai[xk(50)] <= datai[50] + (datar[58] * -15193084 + datai[58] * 7116542) <<< 24;
                    datar[xk(50)] <= datar[50] - (datar[58] * 7116542 + datai[58] * -15193084) <<< 24;
                    datai[xk(50)] <= datai[50] - (datar[58] * -15193084 - datai[58] * 7116542) <<< 24;
                    datar[xk(6)] <= datar[6] + (datar[14] * 13995945 - datai[14] * 9251404) <<< 24;
                    datai[xk(6)] <= datai[6] + (datar[14] * 9251404 + datai[14] * 13995945) <<< 24;
                    state = 53
                end
                53: begin
                    datar[xk(6)] <= datar[6] - (datar[14] * 13995945 + datai[14] * 9251404) <<< 24;
                    datai[xk(6)] <= datai[6] - (datar[14] * 9251404 - datai[14] * 13995945) <<< 24;
                    datar[xk(38)] <= datar[38] + (datar[46] * -11189364 - datai[46] * 12500924) <<< 24;
                    datai[xk(38)] <= datai[38] + (datar[46] * 12500924 + datai[46] * -11189364) <<< 24;
                    datar[xk(38)] <= datar[38] - (datar[46] * -11189364 + datai[46] * 12500924) <<< 24;
                    datai[xk(38)] <= datai[38] - (datar[46] * 12500924 - datai[46] * -11189364) <<< 24;
                    state = 54
                end
                54: begin
                    datar[xk(22)] <= datar[22] + (datar[30] * -10739840 - datai[30] * -12889175) <<< 24;
                    datai[xk(22)] <= datai[22] + (datar[30] * -12889175 + datai[30] * -10739840) <<< 24;
                    datar[xk(22)] <= datar[22] - (datar[30] * -10739840 + datai[30] * -12889175) <<< 24;
                    datai[xk(22)] <= datai[22] - (datar[30] * -12889175 - datai[30] * -10739840) <<< 24;
                    datar[xk(54)] <= datar[54] + (datar[62] * 14314658 - datai[62] * -8750174) <<< 24;
                    datai[xk(54)] <= datai[54] + (datar[62] * -8750174 + datai[62] * 14314658) <<< 24;
                    state = 55
                end
                55: begin
                    datar[xk(54)] <= datar[54] - (datar[62] * 14314658 + datai[62] * -8750174) <<< 24;
                    datai[xk(54)] <= datai[54] - (datar[62] * -8750174 - datai[62] * 14314658) <<< 24;
                    datar[xk(1)] <= datar[1] + (datar[9] * 16777216 - datai[9] * 0) <<< 24;
                    datai[xk(1)] <= datai[1] + (datar[9] * 0 + datai[9] * 16777216) <<< 24;
                    datar[xk(1)] <= datar[1] - (datar[9] * 16777216 + datai[9] * 0) <<< 24;
                    datai[xk(1)] <= datai[1] - (datar[9] * 0 - datai[9] * 16777216) <<< 24;
                    state = 56
                end
                56: begin
                    datar[xk(33)] <= datar[33] + (datar[41] * -2441086 - datai[41] * 16598677) <<< 24;
                    datai[xk(33)] <= datai[33] + (datar[41] * 16598677 + datai[41] * -2441086) <<< 24;
                    datar[xk(33)] <= datar[33] - (datar[41] * -2441086 + datai[41] * 16598677) <<< 24;
                    datai[xk(33)] <= datai[33] - (datar[41] * 16598677 - datai[41] * -2441086) <<< 24;
                    datar[xk(17)] <= datar[17] + (datar[25] * -16066860 - datai[25] * -4830217) <<< 24;
                    datai[xk(17)] <= datai[17] + (datar[25] * -4830217 + datai[25] * -16066860) <<< 24;
                    state = 57
                end
                57: begin
                    datar[xk(17)] <= datar[17] - (datar[25] * -16066860 + datai[25] * -4830217) <<< 24;
                    datai[xk(17)] <= datai[17] - (datar[25] * -4830217 - datai[25] * -16066860) <<< 24;
                    datar[xk(49)] <= datar[49] + (datar[57] * 7116542 - datai[57] * -15193084) <<< 24;
                    datai[xk(49)] <= datai[49] + (datar[57] * -15193084 + datai[57] * 7116542) <<< 24;
                    datar[xk(49)] <= datar[49] - (datar[57] * 7116542 + datai[57] * -15193084) <<< 24;
                    datai[xk(49)] <= datai[49] - (datar[57] * -15193084 - datai[57] * 7116542) <<< 24;
                    state = 58
                end
                58: begin
                    datar[xk(5)] <= datar[5] + (datar[13] * 13995945 - datai[13] * 9251404) <<< 24;
                    datai[xk(5)] <= datai[5] + (datar[13] * 9251404 + datai[13] * 13995945) <<< 24;
                    datar[xk(5)] <= datar[5] - (datar[13] * 13995945 + datai[13] * 9251404) <<< 24;
                    datai[xk(5)] <= datai[5] - (datar[13] * 9251404 - datai[13] * 13995945) <<< 24;
                    datar[xk(37)] <= datar[37] + (datar[45] * -11189364 - datai[45] * 12500924) <<< 24;
                    datai[xk(37)] <= datai[37] + (datar[45] * 12500924 + datai[45] * -11189364) <<< 24;
                    state = 59
                end
                59: begin
                    datar[xk(37)] <= datar[37] - (datar[45] * -11189364 + datai[45] * 12500924) <<< 24;
                    datai[xk(37)] <= datai[37] - (datar[45] * 12500924 - datai[45] * -11189364) <<< 24;
                    datar[xk(21)] <= datar[21] + (datar[29] * -10739840 - datai[29] * -12889175) <<< 24;
                    datai[xk(21)] <= datai[21] + (datar[29] * -12889175 + datai[29] * -10739840) <<< 24;
                    datar[xk(21)] <= datar[21] - (datar[29] * -10739840 + datai[29] * -12889175) <<< 24;
                    datai[xk(21)] <= datai[21] - (datar[29] * -12889175 - datai[29] * -10739840) <<< 24;
                    state = 60
                end
                60: begin
                    datar[xk(53)] <= datar[53] + (datar[61] * 14314658 - datai[61] * -8750174) <<< 24;
                    datai[xk(53)] <= datai[53] + (datar[61] * -8750174 + datai[61] * 14314658) <<< 24;
                    datar[xk(53)] <= datar[53] - (datar[61] * 14314658 + datai[61] * -8750174) <<< 24;
                    datai[xk(53)] <= datai[53] - (datar[61] * -8750174 - datai[61] * 14314658) <<< 24;
                    datar[xk(3)] <= datar[3] + (datar[11] * 16777216 - datai[11] * 0) <<< 24;
                    datai[xk(3)] <= datai[3] + (datar[11] * 0 + datai[11] * 16777216) <<< 24;
                    state = 61
                end
                61: begin
                    datar[xk(3)] <= datar[3] - (datar[11] * 16777216 + datai[11] * 0) <<< 24;
                    datai[xk(3)] <= datai[3] - (datar[11] * 0 - datai[11] * 16777216) <<< 24;
                    datar[xk(35)] <= datar[35] + (datar[43] * -2441086 - datai[43] * 16598677) <<< 24;
                    datai[xk(35)] <= datai[35] + (datar[43] * 16598677 + datai[43] * -2441086) <<< 24;
                    datar[xk(35)] <= datar[35] - (datar[43] * -2441086 + datai[43] * 16598677) <<< 24;
                    datai[xk(35)] <= datai[35] - (datar[43] * 16598677 - datai[43] * -2441086) <<< 24;
                    state = 62
                end
                62: begin
                    datar[xk(19)] <= datar[19] + (datar[27] * -16066860 - datai[27] * -4830217) <<< 24;
                    datai[xk(19)] <= datai[19] + (datar[27] * -4830217 + datai[27] * -16066860) <<< 24;
                    datar[xk(19)] <= datar[19] - (datar[27] * -16066860 + datai[27] * -4830217) <<< 24;
                    datai[xk(19)] <= datai[19] - (datar[27] * -4830217 - datai[27] * -16066860) <<< 24;
                    datar[xk(51)] <= datar[51] + (datar[59] * 7116542 - datai[59] * -15193084) <<< 24;
                    datai[xk(51)] <= datai[51] + (datar[59] * -15193084 + datai[59] * 7116542) <<< 24;
                    state = 63
                end
                63: begin
                    datar[xk(51)] <= datar[51] - (datar[59] * 7116542 + datai[59] * -15193084) <<< 24;
                    datai[xk(51)] <= datai[51] - (datar[59] * -15193084 - datai[59] * 7116542) <<< 24;
                    datar[xk(7)] <= datar[7] + (datar[15] * 13995945 - datai[15] * 9251404) <<< 24;
                    datai[xk(7)] <= datai[7] + (datar[15] * 9251404 + datai[15] * 13995945) <<< 24;
                    datar[xk(7)] <= datar[7] - (datar[15] * 13995945 + datai[15] * 9251404) <<< 24;
                    datai[xk(7)] <= datai[7] - (datar[15] * 9251404 - datai[15] * 13995945) <<< 24;
                    state = 64
                end
                64: begin
                    datar[xk(39)] <= datar[39] + (datar[47] * -11189364 - datai[47] * 12500924) <<< 24;
                    datai[xk(39)] <= datai[39] + (datar[47] * 12500924 + datai[47] * -11189364) <<< 24;
                    datar[xk(39)] <= datar[39] - (datar[47] * -11189364 + datai[47] * 12500924) <<< 24;
                    datai[xk(39)] <= datai[39] - (datar[47] * 12500924 - datai[47] * -11189364) <<< 24;
                    datar[xk(23)] <= datar[23] + (datar[31] * -10739840 - datai[31] * -12889175) <<< 24;
                    datai[xk(23)] <= datai[23] + (datar[31] * -12889175 + datai[31] * -10739840) <<< 24;
                    state = 65
                end
                65: begin
                    datar[xk(23)] <= datar[23] - (datar[31] * -10739840 + datai[31] * -12889175) <<< 24;
                    datai[xk(23)] <= datai[23] - (datar[31] * -12889175 - datai[31] * -10739840) <<< 24;
                    datar[xk(55)] <= datar[55] + (datar[63] * 14314658 - datai[63] * -8750174) <<< 24;
                    datai[xk(55)] <= datai[55] + (datar[63] * -8750174 + datai[63] * 14314658) <<< 24;
                    datar[xk(55)] <= datar[55] - (datar[63] * 14314658 + datai[63] * -8750174) <<< 24;
                    datai[xk(55)] <= datai[55] - (datar[63] * -8750174 - datai[63] * 14314658) <<< 24;
                    state = 66
                end
                66: begin
                    datar[xk(0)] <= datar[0] + (datar[4] * 16777216 - datai[4] * 0) <<< 24;
                    datai[xk(0)] <= datai[0] + (datar[4] * 0 + datai[4] * 16777216) <<< 24;
                    datar[xk(0)] <= datar[0] - (datar[4] * 16777216 + datai[4] * 0) <<< 24;
                    datai[xk(0)] <= datai[0] - (datar[4] * 0 - datai[4] * 16777216) <<< 24;
                    datar[xk(32)] <= datar[32] + (datar[36] * -10966321 - datai[36] * -12697039) <<< 24;
                    datai[xk(32)] <= datai[32] + (datar[36] * -12697039 + datai[36] * -10966321) <<< 24;
                    state = 67
                end
                67: begin
                    datar[xk(32)] <= datar[32] - (datar[36] * -10966321 + datai[36] * -12697039) <<< 24;
                    datai[xk(32)] <= datai[32] - (datar[36] * -12697039 - datai[36] * -10966321) <<< 24;
                    datar[xk(16)] <= datar[16] + (datar[20] * -2441086 - datai[20] * 16598677) <<< 24;
                    datai[xk(16)] <= datai[16] + (datar[20] * 16598677 + datai[20] * -2441086) <<< 24;
                    datar[xk(16)] <= datar[16] - (datar[20] * -2441086 + datai[20] * 16598677) <<< 24;
                    datai[xk(16)] <= datai[16] - (datar[20] * 16598677 - datai[20] * -2441086) <<< 24;
                    state = 68
                end
                68: begin
                    datar[xk(48)] <= datar[48] + (datar[52] * 14157520 - datai[52] * -9002200) <<< 24;
                    datai[xk(48)] <= datai[48] + (datar[52] * -9002200 + datai[52] * 14157520) <<< 24;
                    datar[xk(48)] <= datar[48] - (datar[52] * 14157520 + datai[52] * -9002200) <<< 24;
                    datai[xk(48)] <= datai[48] - (datar[52] * -9002200 - datai[52] * 14157520) <<< 24;
                    datar[xk(8)] <= datar[8] + (datar[12] * -16066860 - datai[12] * -4830217) <<< 24;
                    datai[xk(8)] <= datai[8] + (datar[12] * -4830217 + datai[12] * -16066860) <<< 24;
                    state = 69
                end
                69: begin
                    datar[xk(8)] <= datar[8] - (datar[12] * -16066860 + datai[12] * -4830217) <<< 24;
                    datai[xk(8)] <= datai[8] - (datar[12] * -4830217 - datai[12] * -16066860) <<< 24;
                    datar[xk(40)] <= datar[40] + (datar[44] * 6846480 - datai[44] * 15316679) <<< 24;
                    datai[xk(40)] <= datai[40] + (datar[44] * 15316679 + datai[44] * 6846480) <<< 24;
                    datar[xk(40)] <= datar[40] - (datar[44] * 6846480 + datai[44] * 15316679) <<< 24;
                    datai[xk(40)] <= datai[40] - (datar[44] * 15316679 - datai[44] * 6846480) <<< 24;
                    state = 70
                end
                70: begin
                    datar[xk(24)] <= datar[24] + (datar[28] * 7116542 - datai[28] * -15193084) <<< 24;
                    datai[xk(24)] <= datai[24] + (datar[28] * -15193084 + datai[28] * 7116542) <<< 24;
                    datar[xk(24)] <= datar[24] - (datar[28] * 7116542 + datai[28] * -15193084) <<< 24;
                    datai[xk(24)] <= datai[24] - (datar[28] * -15193084 - datai[28] * 7116542) <<< 24;
                    datar[xk(56)] <= datar[56] + (datar[60] * -16149847 - datai[60] * 4545044) <<< 24;
                    datai[xk(56)] <= datai[56] + (datar[60] * 4545044 + datai[60] * -16149847) <<< 24;
                    state = 71
                end
                71: begin
                    datar[xk(56)] <= datar[56] - (datar[60] * -16149847 + datai[60] * 4545044) <<< 24;
                    datai[xk(56)] <= datai[56] - (datar[60] * 4545044 - datai[60] * -16149847) <<< 24;
                    datar[xk(2)] <= datar[2] + (datar[6] * 13995945 - datai[6] * 9251404) <<< 24;
                    datai[xk(2)] <= datai[2] + (datar[6] * 9251404 + datai[6] * 13995945) <<< 24;
                    datar[xk(2)] <= datar[2] - (datar[6] * 13995945 + datai[6] * 9251404) <<< 24;
                    datai[xk(2)] <= datai[2] - (datar[6] * 9251404 - datai[6] * 13995945) <<< 24;
                    state = 72
                end
                72: begin
                    datar[xk(34)] <= datar[34] + (datar[38] * -2146875 - datai[38] * -16639289) <<< 24;
                    datai[xk(34)] <= datai[34] + (datar[38] * -16639289 + datai[38] * -2146875) <<< 24;
                    datar[xk(34)] <= datar[34] - (datar[38] * -2146875 + datai[38] * -16639289) <<< 24;
                    datai[xk(34)] <= datai[34] - (datar[38] * -16639289 - datai[38] * -2146875) <<< 24;
                    datar[xk(18)] <= datar[18] + (datar[22] * -11189364 - datai[22] * 12500924) <<< 24;
                    datai[xk(18)] <= datai[18] + (datar[22] * 12500924 + datai[22] * -11189364) <<< 24;
                    state = 73
                end
                73: begin
                    datar[xk(18)] <= datar[18] - (datar[22] * -11189364 + datai[22] * 12500924) <<< 24;
                    datai[xk(18)] <= datai[18] - (datar[22] * 12500924 - datai[22] * -11189364) <<< 24;
                    datar[xk(50)] <= datar[50] + (datar[54] * 16774587 - datai[54] * 296989) <<< 24;
                    datai[xk(50)] <= datai[50] + (datar[54] * 296989 + datai[54] * 16774587) <<< 24;
                    datar[xk(50)] <= datar[50] - (datar[54] * 16774587 + datai[54] * 296989) <<< 24;
                    datai[xk(50)] <= datai[50] - (datar[54] * 296989 - datai[54] * 16774587) <<< 24;
                    state = 74
                end
                74: begin
                    datar[xk(10)] <= datar[10] + (datar[14] * -10739840 - datai[14] * -12889175) <<< 24;
                    datai[xk(10)] <= datai[10] + (datar[14] * -12889175 + datai[14] * -10739840) <<< 24;
                    datar[xk(10)] <= datar[10] - (datar[14] * -10739840 + datai[14] * -12889175) <<< 24;
                    datai[xk(10)] <= datai[10] - (datar[14] * -12889175 - datai[14] * -10739840) <<< 24;
                    datar[xk(42)] <= datar[42] + (datar[46] * -2734532 - datai[46] * 16552864) <<< 24;
                    datai[xk(42)] <= datai[42] + (datar[46] * 16552864 + datai[46] * -2734532) <<< 24;
                    state = 75
                end
                75: begin
                    datar[xk(42)] <= datar[42] - (datar[46] * -2734532 + datai[46] * 16552864) <<< 24;
                    datai[xk(42)] <= datai[42] - (datar[46] * 16552864 - datai[46] * -2734532) <<< 24;
                    datar[xk(26)] <= datar[26] + (datar[30] * 14314658 - datai[30] * -8750174) <<< 24;
                    datai[xk(26)] <= datai[26] + (datar[30] * -8750174 + datai[30] * 14314658) <<< 24;
                    datar[xk(26)] <= datar[26] - (datar[30] * 14314658 + datai[30] * -8750174) <<< 24;
                    datai[xk(26)] <= datai[26] - (datar[30] * -8750174 - datai[30] * 14314658) <<< 24;
                    state = 76
                end
                76: begin
                    datar[xk(58)] <= datar[58] + (datar[62] * -15978839 - datai[62] * -5113874) <<< 24;
                    datai[xk(58)] <= datai[58] + (datar[62] * -5113874 + datai[62] * -15978839) <<< 24;
                    datar[xk(58)] <= datar[58] - (datar[62] * -15978839 + datai[62] * -5113874) <<< 24;
                    datai[xk(58)] <= datai[58] - (datar[62] * -5113874 - datai[62] * -15978839) <<< 24;
                    datar[xk(1)] <= datar[1] + (datar[5] * 16777216 - datai[5] * 0) <<< 24;
                    datai[xk(1)] <= datai[1] + (datar[5] * 0 + datai[5] * 16777216) <<< 24;
                    state = 77
                end
                77: begin
                    datar[xk(1)] <= datar[1] - (datar[5] * 16777216 + datai[5] * 0) <<< 24;
                    datai[xk(1)] <= datai[1] - (datar[5] * 0 - datai[5] * 16777216) <<< 24;
                    datar[xk(33)] <= datar[33] + (datar[37] * -10966321 - datai[37] * -12697039) <<< 24;
                    datai[xk(33)] <= datai[33] + (datar[37] * -12697039 + datai[37] * -10966321) <<< 24;
                    datar[xk(33)] <= datar[33] - (datar[37] * -10966321 + datai[37] * -12697039) <<< 24;
                    datai[xk(33)] <= datai[33] - (datar[37] * -12697039 - datai[37] * -10966321) <<< 24;
                    state = 78
                end
                78: begin
                    datar[xk(17)] <= datar[17] + (datar[21] * -2441086 - datai[21] * 16598677) <<< 24;
                    datai[xk(17)] <= datai[17] + (datar[21] * 16598677 + datai[21] * -2441086) <<< 24;
                    datar[xk(17)] <= datar[17] - (datar[21] * -2441086 + datai[21] * 16598677) <<< 24;
                    datai[xk(17)] <= datai[17] - (datar[21] * 16598677 - datai[21] * -2441086) <<< 24;
                    datar[xk(49)] <= datar[49] + (datar[53] * 14157520 - datai[53] * -9002200) <<< 24;
                    datai[xk(49)] <= datai[49] + (datar[53] * -9002200 + datai[53] * 14157520) <<< 24;
                    state = 79
                end
                79: begin
                    datar[xk(49)] <= datar[49] - (datar[53] * 14157520 + datai[53] * -9002200) <<< 24;
                    datai[xk(49)] <= datai[49] - (datar[53] * -9002200 - datai[53] * 14157520) <<< 24;
                    datar[xk(9)] <= datar[9] + (datar[13] * -16066860 - datai[13] * -4830217) <<< 24;
                    datai[xk(9)] <= datai[9] + (datar[13] * -4830217 + datai[13] * -16066860) <<< 24;
                    datar[xk(9)] <= datar[9] - (datar[13] * -16066860 + datai[13] * -4830217) <<< 24;
                    datai[xk(9)] <= datai[9] - (datar[13] * -4830217 - datai[13] * -16066860) <<< 24;
                    state = 80
                end
                80: begin
                    datar[xk(41)] <= datar[41] + (datar[45] * 6846480 - datai[45] * 15316679) <<< 24;
                    datai[xk(41)] <= datai[41] + (datar[45] * 15316679 + datai[45] * 6846480) <<< 24;
                    datar[xk(41)] <= datar[41] - (datar[45] * 6846480 + datai[45] * 15316679) <<< 24;
                    datai[xk(41)] <= datai[41] - (datar[45] * 15316679 - datai[45] * 6846480) <<< 24;
                    datar[xk(25)] <= datar[25] + (datar[29] * 7116542 - datai[29] * -15193084) <<< 24;
                    datai[xk(25)] <= datai[25] + (datar[29] * -15193084 + datai[29] * 7116542) <<< 24;
                    state = 81
                end
                81: begin
                    datar[xk(25)] <= datar[25] - (datar[29] * 7116542 + datai[29] * -15193084) <<< 24;
                    datai[xk(25)] <= datai[25] - (datar[29] * -15193084 - datai[29] * 7116542) <<< 24;
                    datar[xk(57)] <= datar[57] + (datar[61] * -16149847 - datai[61] * 4545044) <<< 24;
                    datai[xk(57)] <= datai[57] + (datar[61] * 4545044 + datai[61] * -16149847) <<< 24;
                    datar[xk(57)] <= datar[57] - (datar[61] * -16149847 + datai[61] * 4545044) <<< 24;
                    datai[xk(57)] <= datai[57] - (datar[61] * 4545044 - datai[61] * -16149847) <<< 24;
                    state = 82
                end
                82: begin
                    datar[xk(3)] <= datar[3] + (datar[7] * 13995945 - datai[7] * 9251404) <<< 24;
                    datai[xk(3)] <= datai[3] + (datar[7] * 9251404 + datai[7] * 13995945) <<< 24;
                    datar[xk(3)] <= datar[3] - (datar[7] * 13995945 + datai[7] * 9251404) <<< 24;
                    datai[xk(3)] <= datai[3] - (datar[7] * 9251404 - datai[7] * 13995945) <<< 24;
                    datar[xk(35)] <= datar[35] + (datar[39] * -2146875 - datai[39] * -16639289) <<< 24;
                    datai[xk(35)] <= datai[35] + (datar[39] * -16639289 + datai[39] * -2146875) <<< 24;
                    state = 83
                end
                83: begin
                    datar[xk(35)] <= datar[35] - (datar[39] * -2146875 + datai[39] * -16639289) <<< 24;
                    datai[xk(35)] <= datai[35] - (datar[39] * -16639289 - datai[39] * -2146875) <<< 24;
                    datar[xk(19)] <= datar[19] + (datar[23] * -11189364 - datai[23] * 12500924) <<< 24;
                    datai[xk(19)] <= datai[19] + (datar[23] * 12500924 + datai[23] * -11189364) <<< 24;
                    datar[xk(19)] <= datar[19] - (datar[23] * -11189364 + datai[23] * 12500924) <<< 24;
                    datai[xk(19)] <= datai[19] - (datar[23] * 12500924 - datai[23] * -11189364) <<< 24;
                    state = 84
                end
                84: begin
                    datar[xk(51)] <= datar[51] + (datar[55] * 16774587 - datai[55] * 296989) <<< 24;
                    datai[xk(51)] <= datai[51] + (datar[55] * 296989 + datai[55] * 16774587) <<< 24;
                    datar[xk(51)] <= datar[51] - (datar[55] * 16774587 + datai[55] * 296989) <<< 24;
                    datai[xk(51)] <= datai[51] - (datar[55] * 296989 - datai[55] * 16774587) <<< 24;
                    datar[xk(11)] <= datar[11] + (datar[15] * -10739840 - datai[15] * -12889175) <<< 24;
                    datai[xk(11)] <= datai[11] + (datar[15] * -12889175 + datai[15] * -10739840) <<< 24;
                    state = 85
                end
                85: begin
                    datar[xk(11)] <= datar[11] - (datar[15] * -10739840 + datai[15] * -12889175) <<< 24;
                    datai[xk(11)] <= datai[11] - (datar[15] * -12889175 - datai[15] * -10739840) <<< 24;
                    datar[xk(43)] <= datar[43] + (datar[47] * -2734532 - datai[47] * 16552864) <<< 24;
                    datai[xk(43)] <= datai[43] + (datar[47] * 16552864 + datai[47] * -2734532) <<< 24;
                    datar[xk(43)] <= datar[43] - (datar[47] * -2734532 + datai[47] * 16552864) <<< 24;
                    datai[xk(43)] <= datai[43] - (datar[47] * 16552864 - datai[47] * -2734532) <<< 24;
                    state = 86
                end
                86: begin
                    datar[xk(27)] <= datar[27] + (datar[31] * 14314658 - datai[31] * -8750174) <<< 24;
                    datai[xk(27)] <= datai[27] + (datar[31] * -8750174 + datai[31] * 14314658) <<< 24;
                    datar[xk(27)] <= datar[27] - (datar[31] * 14314658 + datai[31] * -8750174) <<< 24;
                    datai[xk(27)] <= datai[27] - (datar[31] * -8750174 - datai[31] * 14314658) <<< 24;
                    datar[xk(59)] <= datar[59] + (datar[63] * -15978839 - datai[63] * -5113874) <<< 24;
                    datai[xk(59)] <= datai[59] + (datar[63] * -5113874 + datai[63] * -15978839) <<< 24;
                    state = 87
                end
                87: begin
                    datar[xk(59)] <= datar[59] - (datar[63] * -15978839 + datai[63] * -5113874) <<< 24;
                    datai[xk(59)] <= datai[59] - (datar[63] * -5113874 - datai[63] * -15978839) <<< 24;
                    datar[xk(0)] <= datar[0] + (datar[2] * 16777216 - datai[2] * 0) <<< 24;
                    datai[xk(0)] <= datai[0] + (datar[2] * 0 + datai[2] * 16777216) <<< 24;
                    datar[xk(0)] <= datar[0] - (datar[2] * 16777216 + datai[2] * 0) <<< 24;
                    datai[xk(0)] <= datai[0] - (datar[2] * 0 - datai[2] * 16777216) <<< 24;
                    state = 88
                end
                88: begin
                    datar[xk(32)] <= datar[32] + (datar[34] * -6981786 - datai[34] * 15255479) <<< 24;
                    datai[xk(32)] <= datai[32] + (datar[34] * 15255479 + datai[34] * -6981786) <<< 24;
                    datar[xk(32)] <= datar[32] - (datar[34] * -6981786 + datai[34] * 15255479) <<< 24;
                    datai[xk(32)] <= datai[32] - (datar[34] * 15255479 - datai[34] * -6981786) <<< 24;
                    datar[xk(16)] <= datar[16] + (datar[18] * -10966321 - datai[18] * -12697039) <<< 24;
                    datai[xk(16)] <= datai[16] + (datar[18] * -12697039 + datai[18] * -10966321) <<< 24;
                    state = 89
                end
                89: begin
                    datar[xk(16)] <= datar[16] - (datar[18] * -10966321 + datai[18] * -12697039) <<< 24;
                    datai[xk(16)] <= datai[16] - (datar[18] * -12697039 - datai[18] * -10966321) <<< 24;
                    datar[xk(48)] <= datar[48] + (datar[50] * 16108984 - datai[50] * -4687815) <<< 24;
                    datai[xk(48)] <= datai[48] + (datar[50] * -4687815 + datai[50] * 16108984) <<< 24;
                    datar[xk(48)] <= datar[48] - (datar[50] * 16108984 + datai[50] * -4687815) <<< 24;
                    datai[xk(48)] <= datai[48] - (datar[50] * -4687815 - datai[50] * 16108984) <<< 24;
                    state = 90
                end
                90: begin
                    datar[xk(8)] <= datar[8] + (datar[10] * -2441086 - datai[10] * 16598677) <<< 24;
                    datai[xk(8)] <= datai[8] + (datar[10] * 16598677 + datai[10] * -2441086) <<< 24;
                    datar[xk(8)] <= datar[8] - (datar[10] * -2441086 + datai[10] * 16598677) <<< 24;
                    datai[xk(8)] <= datai[8] - (datar[10] * 16598677 - datai[10] * -2441086) <<< 24;
                    datar[xk(40)] <= datar[40] + (datar[42] * -14077285 - datai[42] * -9127160) <<< 24;
                    datai[xk(40)] <= datai[40] + (datar[42] * -9127160 + datai[42] * -14077285) <<< 24;
                    state = 91
                end
                91: begin
                    datar[xk(40)] <= datar[40] - (datar[42] * -14077285 + datai[42] * -9127160) <<< 24;
                    datai[xk(40)] <= datai[40] - (datar[42] * -9127160 - datai[42] * -14077285) <<< 24;
                    datar[xk(24)] <= datar[24] + (datar[26] * 14157520 - datai[26] * -9002200) <<< 24;
                    datai[xk(24)] <= datai[24] + (datar[26] * -9002200 + datai[26] * 14157520) <<< 24;
                    datar[xk(24)] <= datar[24] - (datar[26] * 14157520 + datai[26] * -9002200) <<< 24;
                    datai[xk(24)] <= datai[24] - (datar[26] * -9002200 - datai[26] * 14157520) <<< 24;
                    state = 92
                end
                92: begin
                    datar[xk(56)] <= datar[56] + (datar[58] * 2294069 - datai[58] * 16619633) <<< 24;
                    datai[xk(56)] <= datai[56] + (datar[58] * 16619633 + datai[58] * 2294069) <<< 24;
                    datar[xk(56)] <= datar[56] - (datar[58] * 2294069 + datai[58] * 16619633) <<< 24;
                    datai[xk(56)] <= datai[56] - (datar[58] * 16619633 - datai[58] * 2294069) <<< 24;
                    datar[xk(4)] <= datar[4] + (datar[6] * -16066860 - datai[6] * -4830217) <<< 24;
                    datai[xk(4)] <= datai[4] + (datar[6] * -4830217 + datai[6] * -16066860) <<< 24;
                    state = 93
                end
                93: begin
                    datar[xk(4)] <= datar[4] - (datar[6] * -16066860 + datai[6] * -4830217) <<< 24;
                    datai[xk(4)] <= datai[4] - (datar[6] * -4830217 - datai[6] * -16066860) <<< 24;
                    datar[xk(36)] <= datar[36] + (datar[38] * 11078276 - datai[38] * -12599476) <<< 24;
                    datai[xk(36)] <= datai[36] + (datar[38] * -12599476 + datai[38] * 11078276) <<< 24;
                    datar[xk(36)] <= datar[36] - (datar[38] * 11078276 + datai[38] * -12599476) <<< 24;
                    datai[xk(36)] <= datai[36] - (datar[38] * -12599476 - datai[38] * 11078276) <<< 24;
                    state = 94
                end
                94: begin
                    datar[xk(20)] <= datar[20] + (datar[22] * 6846480 - datai[22] * 15316679) <<< 24;
                    datai[xk(20)] <= datai[20] + (datar[22] * 15316679 + datai[22] * 6846480) <<< 24;
                    datar[xk(20)] <= datar[20] - (datar[22] * 6846480 + datai[22] * 15316679) <<< 24;
                    datai[xk(20)] <= datai[20] - (datar[22] * 15316679 - datai[22] * 6846480) <<< 24;
                    datar[xk(52)] <= datar[52] + (datar[54] * -16776559 - datai[54] * -148501) <<< 24;
                    datai[xk(52)] <= datai[52] + (datar[54] * -148501 + datai[54] * -16776559) <<< 24;
                    state = 95
                end
                95: begin
                    datar[xk(52)] <= datar[52] - (datar[54] * -16776559 + datai[54] * -148501) <<< 24;
                    datai[xk(52)] <= datai[52] - (datar[54] * -148501 - datai[54] * -16776559) <<< 24;
                    datar[xk(12)] <= datar[12] + (datar[14] * 7116542 - datai[14] * -15193084) <<< 24;
                    datai[xk(12)] <= datai[12] + (datar[14] * -15193084 + datai[14] * 7116542) <<< 24;
                    datar[xk(12)] <= datar[12] - (datar[14] * 7116542 + datai[14] * -15193084) <<< 24;
                    datai[xk(12)] <= datai[12] - (datar[14] * -15193084 - datai[14] * 7116542) <<< 24;
                    state = 96
                end
                96: begin
                    datar[xk(44)] <= datar[44] + (datar[46] * 10853505 - datai[46] * 12793607) <<< 24;
                    datai[xk(44)] <= datai[44] + (datar[46] * 12793607 + datai[46] * 10853505) <<< 24;
                    datar[xk(44)] <= datar[44] - (datar[46] * 10853505 + datai[46] * 12793607) <<< 24;
                    datai[xk(44)] <= datai[44] - (datar[46] * 12793607 - datai[46] * 10853505) <<< 24;
                    datar[xk(28)] <= datar[28] + (datar[30] * -16149847 - datai[30] * 4545044) <<< 24;
                    datai[xk(28)] <= datai[28] + (datar[30] * 4545044 + datai[30] * -16149847) <<< 24;
                    state = 97
                end
                97: begin
                    datar[xk(28)] <= datar[28] - (datar[30] * -16149847 + datai[30] * 4545044) <<< 24;
                    datai[xk(28)] <= datai[28] - (datar[30] * 4545044 - datai[30] * -16149847) <<< 24;
                    datar[xk(60)] <= datar[60] + (datar[62] * 2587909 - datai[62] * -16576420) <<< 24;
                    datai[xk(60)] <= datai[60] + (datar[62] * -16576420 + datai[62] * 2587909) <<< 24;
                    datar[xk(60)] <= datar[60] - (datar[62] * 2587909 + datai[62] * -16576420) <<< 24;
                    datai[xk(60)] <= datai[60] - (datar[62] * -16576420 - datai[62] * 2587909) <<< 24;
                    state = 98
                end
                98: begin
                    datar[xk(1)] <= datar[1] + (datar[3] * 13995945 - datai[3] * 9251404) <<< 24;
                    datai[xk(1)] <= datai[1] + (datar[3] * 9251404 + datai[3] * 13995945) <<< 24;
                    datar[xk(1)] <= datar[1] - (datar[3] * 13995945 + datai[3] * 9251404) <<< 24;
                    datai[xk(1)] <= datai[1] - (datar[3] * 9251404 - datai[3] * 13995945) <<< 24;
                    datar[xk(33)] <= datar[33] + (datar[35] * -14236647 - datai[35] * 8876534) <<< 24;
                    datai[xk(33)] <= datai[33] + (datar[35] * 8876534 + datai[35] * -14236647) <<< 24;
                    state = 99
                end
                99: begin
                    datar[xk(33)] <= datar[33] - (datar[35] * -14236647 + datai[35] * 8876534) <<< 24;
                    datai[xk(33)] <= datai[33] - (datar[35] * 8876534 - datai[35] * -14236647) <<< 24;
                    datar[xk(17)] <= datar[17] + (datar[19] * -2146875 - datai[19] * -16639289) <<< 24;
                    datai[xk(17)] <= datai[17] + (datar[19] * -16639289 + datai[19] * -2146875) <<< 24;
                    datar[xk(17)] <= datar[17] - (datar[19] * -2146875 + datai[19] * -16639289) <<< 24;
                    datai[xk(17)] <= datai[17] - (datar[19] * -16639289 - datai[19] * -2146875) <<< 24;
                    state = 100
                end
                100: begin
                    datar[xk(49)] <= datar[49] + (datar[51] * 16023476 - datai[51] * 4972239) <<< 24;
                    datai[xk(49)] <= datai[49] + (datar[51] * 4972239 + datai[51] * 16023476) <<< 24;
                    datar[xk(49)] <= datar[49] - (datar[51] * 16023476 + datai[51] * 4972239) <<< 24;
                    datai[xk(49)] <= datai[49] - (datar[51] * 4972239 - datai[51] * 16023476) <<< 24;
                    datar[xk(9)] <= datar[9] + (datar[11] * -11189364 - datai[11] * 12500924) <<< 24;
                    datai[xk(9)] <= datai[9] + (datar[11] * 12500924 + datai[11] * -11189364) <<< 24;
                    state = 101
                end
                101: begin
                    datar[xk(9)] <= datar[9] - (datar[11] * -11189364 + datai[11] * 12500924) <<< 24;
                    datai[xk(9)] <= datai[9] - (datar[11] * 12500924 - datai[11] * -11189364) <<< 24;
                    datar[xk(41)] <= datar[41] + (datar[43] * -6710641 - datai[43] * -15376680) <<< 24;
                    datai[xk(41)] <= datai[41] + (datar[43] * -15376680 + datai[43] * -6710641) <<< 24;
                    datar[xk(41)] <= datar[41] - (datar[43] * -6710641 + datai[43] * -15376680) <<< 24;
                    datai[xk(41)] <= datai[41] - (datar[43] * -15376680 - datai[43] * -6710641) <<< 24;
                    state = 102
                end
                102: begin
                    datar[xk(25)] <= datar[25] + (datar[27] * 16774587 - datai[27] * 296989) <<< 24;
                    datai[xk(25)] <= datai[25] + (datar[27] * 296989 + datai[27] * 16774587) <<< 24;
                    datar[xk(25)] <= datar[25] - (datar[27] * 16774587 + datai[27] * 296989) <<< 24;
                    datai[xk(25)] <= datai[25] - (datar[27] * 296989 - datai[27] * 16774587) <<< 24;
                    datar[xk(57)] <= datar[57] + (datar[59] * -7250743 - datai[59] * 15129497) <<< 24;
                    datai[xk(57)] <= datai[57] + (datar[59] * 15129497 + datai[59] * -7250743) <<< 24;
                    state = 103
                end
                103: begin
                    datar[xk(57)] <= datar[57] - (datar[59] * -7250743 + datai[59] * 15129497) <<< 24;
                    datai[xk(57)] <= datai[57] - (datar[59] * 15129497 - datai[59] * -7250743) <<< 24;
                    datar[xk(5)] <= datar[5] + (datar[7] * -10739840 - datai[7] * -12889175) <<< 24;
                    datai[xk(5)] <= datai[5] + (datar[7] * -12889175 + datai[7] * -10739840) <<< 24;
                    datar[xk(5)] <= datar[5] - (datar[7] * -10739840 + datai[7] * -12889175) <<< 24;
                    datai[xk(5)] <= datai[5] - (datar[7] * -12889175 - datai[7] * -10739840) <<< 24;
                    state = 104
                end
                104: begin
                    datar[xk(37)] <= datar[37] + (datar[39] * 16189443 - datai[39] * -4401920) <<< 24;
                    datai[xk(37)] <= datai[37] + (datar[39] * -4401920 + datai[39] * 16189443) <<< 24;
                    datar[xk(37)] <= datar[37] - (datar[39] * 16189443 + datai[39] * -4401920) <<< 24;
                    datai[xk(37)] <= datai[37] - (datar[39] * -4401920 - datai[39] * 16189443) <<< 24;
                    datar[xk(21)] <= datar[21] + (datar[23] * -2734532 - datai[23] * 16552864) <<< 24;
                    datai[xk(21)] <= datai[21] + (datar[23] * 16552864 + datai[23] * -2734532) <<< 24;
                    state = 105
                end
                105: begin
                    datar[xk(21)] <= datar[21] - (datar[23] * -2734532 + datai[23] * 16552864) <<< 24;
                    datai[xk(21)] <= datai[21] - (datar[23] * 16552864 - datai[23] * -2734532) <<< 24;
                    datar[xk(53)] <= datar[53] + (datar[55] * -13913511 - datai[55] * -9374925) <<< 24;
                    datai[xk(53)] <= datai[53] + (datar[55] * -9374925 + datai[55] * -13913511) <<< 24;
                    datar[xk(53)] <= datar[53] - (datar[55] * -13913511 + datai[55] * -9374925) <<< 24;
                    datai[xk(53)] <= datai[53] - (datar[55] * -9374925 - datai[55] * -13913511) <<< 24;
                    state = 106
                end
                106: begin
                    datar[xk(13)] <= datar[13] + (datar[15] * 14314658 - datai[15] * -8750174) <<< 24;
                    datai[xk(13)] <= datai[13] + (datar[15] * -8750174 + datai[15] * 14314658) <<< 24;
                    datar[xk(13)] <= datar[13] - (datar[15] * 14314658 + datai[15] * -8750174) <<< 24;
                    datai[xk(13)] <= datai[13] - (datar[15] * -8750174 - datai[15] * 14314658) <<< 24;
                    datar[xk(45)] <= datar[45] + (datar[47] * 1999510 - datai[47] * 16657638) <<< 24;
                    datai[xk(45)] <= datai[45] + (datar[47] * 16657638 + datai[47] * 1999510) <<< 24;
                    state = 107
                end
                107: begin
                    datar[xk(45)] <= datar[45] - (datar[47] * 1999510 + datai[47] * 16657638) <<< 24;
                    datai[xk(45)] <= datai[45] - (datar[47] * 16657638 - datai[47] * 1999510) <<< 24;
                    datar[xk(29)] <= datar[29] + (datar[31] * -15978839 - datai[31] * -5113874) <<< 24;
                    datai[xk(29)] <= datai[29] + (datar[31] * -5113874 + datai[31] * -15978839) <<< 24;
                    datar[xk(29)] <= datar[29] - (datar[31] * -15978839 + datai[31] * -5113874) <<< 24;
                    datai[xk(29)] <= datai[29] - (datar[31] * -5113874 - datai[31] * -15978839) <<< 24;
                    state = 108
                end
                108: begin
                    datar[xk(61)] <= datar[61] + (datar[63] * 11299575 - datai[63] * -12401395) <<< 24;
                    datai[xk(61)] <= datai[61] + (datar[63] * -12401395 + datai[63] * 11299575) <<< 24;
                    datar[xk(61)] <= datar[61] - (datar[63] * 11299575 + datai[63] * -12401395) <<< 24;
                    datai[xk(61)] <= datai[61] - (datar[63] * -12401395 - datai[63] * 11299575) <<< 24;
                    datar[xk(0)] <= datar[0] + (datar[1] * 16777216 - datai[1] * 0) <<< 24;
                    datai[xk(0)] <= datai[0] + (datar[1] * 0 + datai[1] * 16777216) <<< 24;
                    state = 109
                end
                109: begin
                    datar[xk(0)] <= datar[0] - (datar[1] * 16777216 + datai[1] * 0) <<< 24;
                    datai[xk(0)] <= datai[0] - (datar[1] * 0 - datai[1] * 16777216) <<< 24;
                    datar[xk(32)] <= datar[32] + (datar[33] * 9064768 - datai[33] * 14117540) <<< 24;
                    datai[xk(32)] <= datai[32] + (datar[33] * 14117540 + datai[33] * 9064768) <<< 24;
                    datar[xk(32)] <= datar[32] - (datar[33] * 9064768 + datai[33] * 14117540) <<< 24;
                    datai[xk(32)] <= datai[32] - (datar[33] * 14117540 - datai[33] * 9064768) <<< 24;
                    state = 110
                end
                110: begin
                    datar[xk(16)] <= datar[16] + (datar[17] * -6981786 - datai[17] * 15255479) <<< 24;
                    datai[xk(16)] <= datai[16] + (datar[17] * 15255479 + datai[17] * -6981786) <<< 24;
                    datar[xk(16)] <= datar[16] - (datar[17] * -6981786 + datai[17] * 15255479) <<< 24;
                    datai[xk(16)] <= datai[16] - (datar[17] * 15255479 - datai[17] * -6981786) <<< 24;
                    datar[xk(48)] <= datar[48] + (datar[49] * -16609318 - datai[49] * 2367600) <<< 24;
                    datai[xk(48)] <= datai[48] + (datar[49] * 2367600 + datai[49] * -16609318) <<< 24;
                    state = 111
                end
                111: begin
                    datar[xk(48)] <= datar[48] - (datar[49] * -16609318 + datai[49] * 2367600) <<< 24;
                    datai[xk(48)] <= datai[48] - (datar[49] * 2367600 - datai[49] * -16609318) <<< 24;
                    datar[xk(8)] <= datar[8] + (datar[9] * -10966321 - datai[9] * -12697039) <<< 24;
                    datai[xk(8)] <= datai[8] + (datar[9] * -12697039 + datai[9] * -10966321) <<< 24;
                    datar[xk(8)] <= datar[8] - (datar[9] * -10966321 + datai[9] * -12697039) <<< 24;
                    datai[xk(8)] <= datai[8] - (datar[9] * -12697039 - datai[9] * -10966321) <<< 24;
                    state = 112
                end
                112: begin
                    datar[xk(40)] <= datar[40] + (datar[41] * 4759061 - datai[41] * -16088080) <<< 24;
                    datai[xk(40)] <= datai[40] + (datar[41] * -16088080 + datai[41] * 4759061) <<< 24;
                    datar[xk(40)] <= datar[40] - (datar[41] * 4759061 + datai[41] * -16088080) <<< 24;
                    datai[xk(40)] <= datai[40] - (datar[41] * -16088080 - datai[41] * 4759061) <<< 24;
                    datar[xk(24)] <= datar[24] + (datar[25] * 16108984 - datai[25] * -4687815) <<< 24;
                    datai[xk(24)] <= datai[24] + (datar[25] * -4687815 + datai[25] * 16108984) <<< 24;
                    state = 113
                end
                113: begin
                    datar[xk(24)] <= datar[24] - (datar[25] * 16108984 + datai[25] * -4687815) <<< 24;
                    datai[xk(24)] <= datai[24] - (datar[25] * -4687815 - datai[25] * 16108984) <<< 24;
                    datar[xk(56)] <= datar[56] + (datar[57] * 12648380 - datai[57] * 11022406) <<< 24;
                    datai[xk(56)] <= datai[56] + (datar[57] * 11022406 + datai[57] * 12648380) <<< 24;
                    datar[xk(56)] <= datar[56] - (datar[57] * 12648380 + datai[57] * 11022406) <<< 24;
                    datai[xk(56)] <= datai[56] - (datar[57] * 11022406 - datai[57] * 12648380) <<< 24;
                    state = 114
                end
                114: begin
                    datar[xk(4)] <= datar[4] + (datar[5] * -2441086 - datai[5] * 16598677) <<< 24;
                    datai[xk(4)] <= datai[4] + (datar[5] * 16598677 + datai[5] * -2441086) <<< 24;
                    datar[xk(4)] <= datar[4] - (datar[5] * -2441086 + datai[5] * 16598677) <<< 24;
                    datai[xk(4)] <= datai[4] - (datar[5] * 16598677 - datai[5] * -2441086) <<< 24;
                    datar[xk(36)] <= datar[36] + (datar[37] * -15286230 - datai[37] * 6914200) <<< 24;
                    datai[xk(36)] <= datai[36] + (datar[37] * 6914200 + datai[37] * -15286230) <<< 24;
                    state = 115
                end
                115: begin
                    datar[xk(36)] <= datar[36] - (datar[37] * -15286230 + datai[37] * 6914200) <<< 24;
                    datai[xk(36)] <= datai[36] - (datar[37] * 6914200 - datai[37] * -15286230) <<< 24;
                    datar[xk(20)] <= datar[20] + (datar[21] * -14077285 - datai[21] * -9127160) <<< 24;
                    datai[xk(20)] <= datai[20] + (datar[21] * -9127160 + datai[21] * -14077285) <<< 24;
                    datar[xk(20)] <= datar[20] - (datar[21] * -14077285 + datai[21] * -9127160) <<< 24;
                    datai[xk(20)] <= datai[20] - (datar[21] * -9127160 - datai[21] * -14077285) <<< 24;
                    state = 116
                end
                116: begin
                    datar[xk(52)] <= datar[52] + (datar[53] * 74250 - datai[53] * -16777052) <<< 24;
                    datai[xk(52)] <= datai[52] + (datar[53] * -16777052 + datai[53] * 74250) <<< 24;
                    datar[xk(52)] <= datar[52] - (datar[53] * 74250 + datai[53] * -16777052) <<< 24;
                    datai[xk(52)] <= datai[52] - (datar[53] * -16777052 - datai[53] * 74250) <<< 24;
                    datar[xk(12)] <= datar[12] + (datar[13] * 14157520 - datai[13] * -9002200) <<< 24;
                    datai[xk(12)] <= datai[12] + (datar[13] * -9002200 + datai[13] * 14157520) <<< 24;
                    state = 117
                end
                117: begin
                    datar[xk(12)] <= datar[12] - (datar[13] * 14157520 + datai[13] * -9002200) <<< 24;
                    datai[xk(12)] <= datai[12] - (datar[13] * -9002200 - datai[13] * 14157520) <<< 24;
                    datar[xk(44)] <= datar[44] + (datar[45] * 15224430 - datai[45] * 7049233) <<< 24;
                    datai[xk(44)] <= datai[44] + (datar[45] * 7049233 + datai[45] * 15224430) <<< 24;
                    datar[xk(44)] <= datar[44] - (datar[45] * 15224430 + datai[45] * 7049233) <<< 24;
                    datai[xk(44)] <= datai[44] - (datar[45] * 7049233 - datai[45] * 15224430) <<< 24;
                    state = 118
                end
                118: begin
                    datar[xk(28)] <= datar[28] + (datar[29] * 2294069 - datai[29] * 16619633) <<< 24;
                    datai[xk(28)] <= datai[28] + (datar[29] * 16619633 + datai[29] * 2294069) <<< 24;
                    datar[xk(28)] <= datar[28] - (datar[29] * 2294069 + datai[29] * 16619633) <<< 24;
                    datai[xk(28)] <= datai[28] - (datar[29] * 16619633 - datai[29] * 2294069) <<< 24;
                    datar[xk(60)] <= datar[60] + (datar[61] * -12745449 - datai[61] * 10910019) <<< 24;
                    datai[xk(60)] <= datai[60] + (datar[61] * 10910019 + datai[61] * -12745449) <<< 24;
                    state = 119
                end
                119: begin
                    datar[xk(60)] <= datar[60] - (datar[61] * -12745449 + datai[61] * 10910019) <<< 24;
                    datai[xk(60)] <= datai[60] - (datar[61] * 10910019 - datai[61] * -12745449) <<< 24;
                    datar[xk(2)] <= datar[2] + (datar[3] * -16066860 - datai[3] * -4830217) <<< 24;
                    datai[xk(2)] <= datai[2] + (datar[3] * -4830217 + datai[3] * -16066860) <<< 24;
                    datar[xk(2)] <= datar[2] - (datar[3] * -16066860 + datai[3] * -4830217) <<< 24;
                    datai[xk(2)] <= datai[2] - (datar[3] * -4830217 - datai[3] * -16066860) <<< 24;
                    state = 120
                end
                120: begin
                    datar[xk(34)] <= datar[34] + (datar[35] * -4616475 - datai[35] * -16129574) <<< 24;
                    datai[xk(34)] <= datai[34] + (datar[35] * -16129574 + datai[35] * -4616475) <<< 24;
                    datar[xk(34)] <= datar[34] - (datar[35] * -4616475 + datai[35] * -16129574) <<< 24;
                    datai[xk(34)] <= datai[34] - (datar[35] * -16129574 - datai[35] * -4616475) <<< 24;
                    datar[xk(18)] <= datar[18] + (datar[19] * 11078276 - datai[19] * -12599476) <<< 24;
                    datai[xk(18)] <= datai[18] + (datar[19] * -12599476 + datai[19] * 11078276) <<< 24;
                    state = 121
                end
                121: begin
                    datar[xk(18)] <= datar[18] - (datar[19] * 11078276 + datai[19] * -12599476) <<< 24;
                    datai[xk(18)] <= datai[18] - (datar[19] * -12599476 - datai[19] * 11078276) <<< 24;
                    datar[xk(50)] <= datar[50] + (datar[51] * 16587710 - datai[51] * 2514522) <<< 24;
                    datai[xk(50)] <= datai[50] + (datar[51] * 2514522 + datai[51] * 16587710) <<< 24;
                    datar[xk(50)] <= datar[50] - (datar[51] * 16587710 + datai[51] * 2514522) <<< 24;
                    datai[xk(50)] <= datai[50] - (datar[51] * 2514522 - datai[51] * 16587710) <<< 24;
                    state = 122
                end
                122: begin
                    datar[xk(10)] <= datar[10] + (datar[11] * 6846480 - datai[11] * 15316679) <<< 24;
                    datai[xk(10)] <= datai[10] + (datar[11] * 15316679 + datai[11] * 6846480) <<< 24;
                    datar[xk(10)] <= datar[10] - (datar[11] * 6846480 + datai[11] * 15316679) <<< 24;
                    datai[xk(10)] <= datai[10] - (datar[11] * 15316679 - datai[11] * 6846480) <<< 24;
                    datar[xk(42)] <= datar[42] + (datar[43] * -9189373 - datai[43] * 14036752) <<< 24;
                    datai[xk(42)] <= datai[42] + (datar[43] * 14036752 + datai[43] * -9189373) <<< 24;
                    state = 123
                end
                123: begin
                    datar[xk(42)] <= datar[42] - (datar[43] * -9189373 + datai[43] * 14036752) <<< 24;
                    datai[xk(42)] <= datai[42] - (datar[43] * 14036752 - datai[43] * -9189373) <<< 24;
                    datar[xk(26)] <= datar[26] + (datar[27] * -16776559 - datai[27] * -148501) <<< 24;
                    datai[xk(26)] <= datai[26] + (datar[27] * -148501 + datai[27] * -16776559) <<< 24;
                    datar[xk(26)] <= datar[26] - (datar[27] * -16776559 + datai[27] * -148501) <<< 24;
                    datai[xk(26)] <= datai[26] - (datar[27] * -148501 - datai[27] * -16776559) <<< 24;
                    state = 124
                end
                124: begin
                    datar[xk(58)] <= datar[58] + (datar[59] * -8939455 - datai[59] * -14197223) <<< 24;
                    datai[xk(58)] <= datai[58] + (datar[59] * -14197223 + datai[59] * -8939455) <<< 24;
                    datar[xk(58)] <= datar[58] - (datar[59] * -8939455 + datai[59] * -14197223) <<< 24;
                    datai[xk(58)] <= datai[58] - (datar[59] * -14197223 - datai[59] * -8939455) <<< 24;
                    datar[xk(6)] <= datar[6] + (datar[7] * 7116542 - datai[7] * -15193084) <<< 24;
                    datai[xk(6)] <= datai[6] + (datar[7] * -15193084 + datai[7] * 7116542) <<< 24;
                    state = 125
                end
                125: begin
                    datar[xk(6)] <= datar[6] - (datar[7] * 7116542 + datai[7] * -15193084) <<< 24;
                    datai[xk(6)] <= datai[6] - (datar[7] * -15193084 - datai[7] * 7116542) <<< 24;
                    datar[xk(38)] <= datar[38] + (datar[39] * 16629623 - datai[39] * -2220494) <<< 24;
                    datai[xk(38)] <= datai[38] + (datar[39] * -2220494 + datai[39] * 16629623) <<< 24;
                    datar[xk(38)] <= datar[38] - (datar[39] * 16629623 + datai[39] * -2220494) <<< 24;
                    datai[xk(38)] <= datai[38] - (datar[39] * -2220494 - datai[39] * 16629623) <<< 24;
                    state = 126
                end
                126: begin
                    datar[xk(22)] <= datar[22] + (datar[23] * 10853505 - datai[23] * 12793607) <<< 24;
                    datai[xk(22)] <= datai[22] + (datar[23] * 12793607 + datai[23] * 10853505) <<< 24;
                    datar[xk(22)] <= datar[22] - (datar[23] * 10853505 + datai[23] * 12793607) <<< 24;
                    datai[xk(22)] <= datai[22] - (datar[23] * 12793607 - datai[23] * 10853505) <<< 24;
                    datar[xk(54)] <= datar[54] + (datar[55] * -4901276 - datai[55] * 16045325) <<< 24;
                    datai[xk(54)] <= datai[54] + (datar[55] * 16045325 + datai[55] * -4901276) <<< 24;
                    state = 127
                end
                127: begin
                    datar[xk(54)] <= datar[54] - (datar[55] * -4901276 + datai[55] * 16045325) <<< 24;
                    datai[xk(54)] <= datai[54] - (datar[55] * 16045325 - datai[55] * -4901276) <<< 24;
                    datar[xk(14)] <= datar[14] + (datar[15] * -16149847 - datai[15] * 4545044) <<< 24;
                    datai[xk(14)] <= datai[14] + (datar[15] * 4545044 + datai[15] * -16149847) <<< 24;
                    datar[xk(14)] <= datar[14] - (datar[15] * -16149847 + datai[15] * 4545044) <<< 24;
                    datai[xk(14)] <= datai[14] - (datar[15] * 4545044 - datai[15] * -16149847) <<< 24;
                    state = 128
                end
                128: begin
                    datar[xk(46)] <= datar[46] + (datar[47] * -12550323 - datai[47] * -11133930) <<< 24;
                    datai[xk(46)] <= datai[46] + (datar[47] * -11133930 + datai[47] * -12550323) <<< 24;
                    datar[xk(46)] <= datar[46] - (datar[47] * -12550323 + datai[47] * -11133930) <<< 24;
                    datai[xk(46)] <= datai[46] - (datar[47] * -11133930 - datai[47] * -12550323) <<< 24;
                    datar[xk(30)] <= datar[30] + (datar[31] * 2587909 - datai[31] * -16576420) <<< 24;
                    datai[xk(30)] <= datai[30] + (datar[31] * -16576420 + datai[31] * 2587909) <<< 24;
                    state = 129
                end
                129: begin
                    datar[xk(30)] <= datar[30] - (datar[31] * 2587909 + datai[31] * -16576420) <<< 24;
                    datai[xk(30)] <= datai[30] - (datar[31] * -16576420 - datai[31] * 2587909) <<< 24;
                    datar[xk(62)] <= datar[62] + (datar[63] * 15346830 - datai[63] * -6778627) <<< 24;
                    datai[xk(62)] <= datai[62] + (datar[63] * -6778627 + datai[63] * 15346830) <<< 24;
                    datar[xk(62)] <= datar[62] - (datar[63] * 15346830 + datai[63] * -6778627) <<< 24;
                    datai[xk(62)] <= datai[62] - (datar[63] * -6778627 - datai[63] * 15346830) <<< 24;
                    state = 130
                end
                130: begin
                    samples = samples + 1
                    if(samples == 64) begin
                        state = 0;
                        samples = 0;
                    end
                end
            endcase
        end
    end
endmodule
