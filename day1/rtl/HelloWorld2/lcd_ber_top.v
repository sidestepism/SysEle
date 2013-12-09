
module lcd_ber_top
  (
   input        CLK,
   input        RST,

   output       update,
   output       lcd_row, 
   output [3:0] lcd_col,
   output [7:0] lcd_char,
   output       lcd_we,

   input        lcd_busy,
   input        start,

   input        valid_i,
   input [7:0]  sent_data,
   input [7:0]  recv_data,
   input [3:0]  number_of_bits 
   );

   wire         ber_valid_o;
   wire [31:0]  error_rate;

   wire         start_update;
   wire [7:0]   char;
   wire         n2c_valid_o;

   assign start_update = start;

   ber ber_inst
     (
      .CLK(CLK),
      .RST(RST),

      .valid_i(valid_i),
      .sent_data(sent_data),
      .recv_data(recv_data),
      .number_of_bits(number_of_bits),

      .valid_o(ber_valid_o),
      .error_rate(error_rate)
      );

   num2char num2char_inst
     (
      .CLK(CLK),
      .RST(RST),

      .start_update(start_update),
      .error_rate(error_rate),

      .char(char),
      .valid_o(n2c_valid_o)
      );

   lcd_control lcd_control_inst
     (
      .CLK(CLK),
      .RST(RST),

      .start_update(start_update),
      .lcd_row(lcd_row), 
      .lcd_col(lcd_col),
      .lcd_char(lcd_char),
      .lcd_we(lcd_we),

      .lcd_busy(lcd_busy),

      .valid_i(n2c_valid_o),
      .update(update),
      .char(char)
      );
   
endmodule // lcd_test

   
