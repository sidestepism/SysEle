//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:44:47 01/24/2011 
// Design Name: 
// Module Name:    pixel_sampler 
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
module pixel_sampler(CLK, RST, HIN, VIN, RIN, GIN, BIN, ACTIN, HOUT, VOUT, DOUT, ACTOUT);
	input CLK, RST, HIN, VIN, ACTIN;
	input [7:0] RIN, GIN, BIN;
	output HOUT, VOUT, ACTOUT;
	output [11:0] DOUT;
	reg HOUT, VOUT, ACTOUT;
	reg [11:0] DOUT;
	reg state;
	
	always @(posedge CLK or negedge RST) begin
		if(!RST) begin
			state <= 0;
		end
		else begin
			HOUT <= HIN;
			VOUT <= VIN;
			ACTOUT <= ACTIN;
			if(!state) begin
				DOUT <= {GIN[3:0],BIN};
				state <= 1'b1;
			end
			else begin
				DOUT <= {RIN,GIN[7:4]};
				state <= 1'b0;
			end
		end
	end

endmodule
