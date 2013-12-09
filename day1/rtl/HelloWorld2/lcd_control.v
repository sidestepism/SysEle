
module lcd_control
  (
   input        CLK,
   input        RST,

   output       update,
   output       lcd_row, 
   output [3:0] lcd_col,
   output reg [7:0] lcd_char,
   output       lcd_we,

   input        lcd_busy,

   input        valid_i,
   input        start_update,
   input [7:0]  char
   );

`define SW 4
   parameter s_wait_init = `SW'd0;
   parameter s_num       = `SW'd1;
   parameter s_update    = `SW'd11;
   parameter s_idle      = `SW'd12;
   reg [`SW-1:0] state;
`undef SW

	reg [39:0] num_char;

//   assign lcd_char = state == s_h ? "H" :
//                     state == s_e ? "E":
//                     state == s_l1 || state == s_l2 || state == s_l3 ? "L" :
//                     state == s_o1 || state == s_o2 ? "O" :
//                     state == s_w ? "W" :
//                     state == s_r ? "R" :
//                     state == s_d ? "D" :
//                     8'h0;
   assign lcd_we   = state != s_wait_init && state != s_idle && state != s_update;
   assign lcd_row  = 0;
   assign update = state == s_update;
	reg[3:0] output_col;
	assign lcd_col  = output_col - 1;
//   assign lcd_col = 
//                    state == s_h?  3'd0 : 
//                    state == s_e?  3'd1 : 
//                    state == s_l1? 3'd2 : 
//                    state == s_l2? 3'd3 : 
//                    state == s_o1? 3'd4 : 
//                    state == s_w?  3'd2 : 
//                    state == s_o2? 3'd3 : 
//                    state == s_r?  3'd4 : 
//                    state == s_l3? 3'd5 : 
//                    state == s_d?  3'd6 :
//                    3'h0;
   

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        state <= s_wait_init;
		  output_col <= 0;
     end else begin
        case (state)
          s_wait_init: 
            if (!lcd_busy)
              state <= s_idle;
          s_idle:
				begin 
					if (start_update) begin
						output_col <= 0;
						state <= s_num;
					end
				end
          s_num:
				begin
//					if (lcd_col < 10) begin
//						lcd_char <= "0";
//						lcd_col <= lcd_col + 1;
//					end else begin
//						state <= s_update;
//					end
					if (valid_i == 1) begin
						if(output_col < 10 + 1) begin
							lcd_char <= char;
							output_col <= output_col + 1;
						end else begin
							state <= s_update;
						end
					end
				end
          s_update:
            if (!lcd_busy)
              state <= s_idle;          
          default: ;
        endcase
     end

endmodule
