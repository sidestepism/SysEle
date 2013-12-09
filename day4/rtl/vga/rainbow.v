//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:11:17 01/24/2011 
// Design Name: 
// Module Name:    rainbow 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module rainbow(CLK, RST, ROW, COL, R, G, B);
	input CLK, RST;
	input signed [9:0] ROW;
	input signed [10:0] COL;
	output [7:0] R, G, B;
/*
	assign R = (COL > 11'd300 && COL <= 11'd500 && ROW > 10'd200 && ROW <= 10'd400) ? 8'h80 : 8'h00;
	assign G = (COL > 11'd300 && COL <= 11'd500 && ROW > 10'd200 && ROW <= 10'd400) ? 8'h80 : 8'h00;
	assign B = (COL > 11'd300 && COL <= 11'd500 && ROW > 10'd200 && ROW <= 10'd400) ? 8'h80 : 8'h00;
*/

	reg [7:0] R, G, B;
	reg signed [9:0] xpos, ypos;
	
	wire [19:0] r2;
	
	always @(posedge CLK or negedge RST) begin
		if(!RST) begin
			R <= 8'hfe;
			G <= 8'h00;
			B <= 8'h00;
			xpos <= 10'd400;
			ypos <= 10'd300;
		end
		else begin
				if(COL == 11'd0) begin
					R <= 8'hfe;
					G <= 8'h00;
					B <= 8'h00;
				end
				else if(COL < 128) G <= G + 8'd2;
				else if(COL < 255) R <= R - 8'd2;
				else if(COL < 382) B <= B + 8'd2;
				else if(COL < 509) G <= G - 8'd2;
				else if(COL < 636) R <= R + 8'd2;
				else if(COL < 763) B <= B - 8'd2;
				else G <= G + 8'd2;
		end
	end

endmodule
