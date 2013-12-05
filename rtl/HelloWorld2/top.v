
//`define SIMULATION

module sysele
  (
   // Global 100MHz clock
   input         CLK,
   input         CLK_33MHZ_FPGA,
   
   // Reset signal, active low
   input         nRST,

   // North, East, South, West and Center buttons
   // Active High
   input         BTN_N,
   input         BTN_E,
   input         BTN_S,
   input         BTN_W,
   input         BTN_C,

   // DIP Switches
   input [7:0]   DIP,

   // North, East, South, West and Center LEDs
   // Active High
   output        LED_N,
   output        LED_E,
   output        LED_S,
   output        LED_W,
   output        LED_C,

   // LEDs
   output [7:0]  LED,

   // LCD driver
   inout [3:0]  LCDDATA,
   output        RS,
   output        RW,
   output        EN
   );

   // ==================================================
   // WIRES
   // ==================================================
   // --------------------------------------------------
   // CLOCKS
   // --------------------------------------------------
   wire          clk40;
   wire          clk80_2;
   wire          clk240;

   // --------------------------------------------------
   // PLLS
   // --------------------------------------------------
   wire          locked, locked1, locked2;
   wire          rstgen;

   // --------------------------------------------------
   // LCD
   // --------------------------------------------------
   wire [7:0] lcd_char;
   wire [3:0] lcd_col;
   wire       lcd_row;
   wire       lcd_we;
   wire       lcd_busy;
   wire       lcd_update;

   wire       lcd_start;

   // ==================================================
   // INSTANCES AND ASSIGNMENTS
   // ==================================================
   // **************************************************
   // CLOCK GENERATORS
   // **************************************************
   // --------------------------------------------------
   // PLLS
   // --------------------------------------------------
`ifndef SIMULATION
   pll pll(
           .CLKIN1_IN(CLK),
           .RST_IN(!nRST),
           .CLKOUT0_OUT(clk40),
           .CLKOUT1_OUT(),
           .CLKOUT2_OUT(),
           .CLKOUT3_OUT(clk80_2),
           .CLKOUT4_OUT(),
           .LOCKED_OUT(locked1));

   pll2 pll2(
             .CLKIN1_IN(clk80_2),
             .RST_IN(!locked1),
             .CLKOUT0_OUT(clk240),
             .CLKOUT1_OUT(),
             .CLKOUT2_OUT(),
             .LOCKED_OUT(locked2));

`endif

   rstgen rstmod(.CLK(clk40),
                 .nRST(nRST),
                 .locked(locked),
                 .rstgen(rstgen));

   assign locked = locked1 & locked2;

   // **************************************************
   // misc
   // **************************************************
   // --------------------------------------------------
   // LEDS AND SWITCHES
   // --------------------------------------------------
   assign LED = 8'h00;
   assign LED_N = 1'b0;
   assign LED_E = 1'b0;
   assign LED_W = 1'b0;
   assign LED_S = 1'b0;
   assign LED_C = 1'b0;

   // --------------------------------------------------
   // LCD
   // --------------------------------------------------
   lcd lcd_inst
     (.CLK(clk240),
      .RST(rstgen),

      .LCD_DATA(LCDDATA),
      .RS(RS),
      .RW(RW),
      .EN(EN),

      .row(lcd_row),
      .col(lcd_col),
      .char(lcd_char),
      .we(lcd_we),

      .busy(lcd_busy),

      .update(lcd_update)
      );
   
   num2char_test num2char_test_inst
     (
      .CLK(clk240),
      .RST(rstgen),

      .update(lcd_update),
      .lcd_row(lcd_row),
      .lcd_col(lcd_col),
      .lcd_char(lcd_char),
      .lcd_we(lcd_we),

      .lcd_busy(lcd_busy),
      .start(lcd_start),

      .valid_i(lcd_ber_valid_i),
      .sent_data(ber_sent_data),
      .recv_data(ber_recv_data),
      .number_of_bits(number_of_bits)
      );
   
   switch sw_btn_e3
     (.CLK(clk240),
      .RST(rstgen),

      .sw(BTN_E),

      .pos(lcd_start),
      .neg(),
      .d());

endmodule // sysele
