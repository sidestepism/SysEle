
module lcd_test
  (
   input        CLK,
   input        RST,

   output       update,
   output       lcd_row, 
   output [3:0] lcd_col,
   output [7:0] lcd_char,
   output       lcd_we,

   input        lcd_busy,
   input        start
   );

`define SW 4
   parameter s_wait_init = `SW'd0;
   parameter s_h         = `SW'd1;
   parameter s_e         = `SW'd2;
   parameter s_l1        = `SW'd3;
   parameter s_l2        = `SW'd4;
   parameter s_o1        = `SW'd5;
   parameter s_w         = `SW'd6;
   parameter s_o2        = `SW'd7;
   parameter s_r         = `SW'd8;
   parameter s_l3        = `SW'd9;
   parameter s_d         = `SW'd10;
   parameter s_update    = `SW'd11;
   parameter s_idle      = `SW'd12;

   reg [`SW-1:0] state;
`undef SW

   assign lcd_char = state == s_h ? "H" :
                     state == s_e ? "E":
                     state == s_l1 || state == s_l2 || state == s_l3 ? "L" :
                     state == s_o1 || state == s_o2 ? "O" :
                     state == s_w ? "W" :
                     state == s_r ? "R" :
                     state == s_d ? "D" :
                     8'h0;
   assign lcd_we   = state != s_wait_init && state != s_idle && state != s_update;
   assign lcd_row  = !(state == s_h
                       || state == s_e
                       || state == s_l1
                       || state == s_l2
                       || state == s_o1);
   assign update = state == s_update;
   assign lcd_col = 
                    state == s_h?  3'd0 : 
                    state == s_e?  3'd1 : 
                    state == s_l1? 3'd2 : 
                    state == s_l2? 3'd3 : 
                    state == s_o1? 3'd4 : 
                    state == s_w?  3'd2 : 
                    state == s_o2? 3'd3 : 
                    state == s_r?  3'd4 : 
                    state == s_l3? 3'd5 : 
                    state == s_d?  3'd6 :
                    3'h0;
                       
   always @(posedge CLK or negedge RST)
     if (!RST) begin
        state <= s_wait_init;
     end else begin
        case (state)
          s_wait_init: 
            if (!lcd_busy)
              state <= s_idle;

          s_idle:
            if (start)
              state <= s_h;

          s_h:
            state <= s_e;

          s_e:
            state <= s_l1;
          
          s_l1:
            state <= s_l2;
          
          s_l2:
            state <= s_o1;
          
          s_o1:
            state <= s_w;
          
          s_w:
            state <= s_o2;
          
          s_o2:
            state <= s_r;
          
          s_r:
            state <= s_l3;

          s_l3:
            state <= s_d;
          
          s_d:
            state <= s_update;
          
          s_update:
            if (!lcd_busy)
              state <= s_idle;
          
          default: ;
        endcase
     end

endmodule // lcd_test

   
