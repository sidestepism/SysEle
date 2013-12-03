`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    Tue Dec  3 13:59:29 2013
// Design Name: 
// Module Name:    netlist_1_EMPTY
//////////////////////////////////////////////////////////////////////////////////
module netlist_1_EMPTY(LCD_DATA, col, char, CLK, RST, RS, RW, EN, row, we, update, busy);
  inout  [3:0] LCD_DATA;
  input [3:0] col;
  input [7:0] char;
  input CLK;
  input RST;
  output RS;
  output RW;
  output EN;
  input row;
  input we;
  input update;
  output busy;


endmodule
