
module num2char
  (
   input        CLK,
   input        RST,

   input        start_update,
   input [31:0] error_rate,

   output reg[7:0] char,
   output reg   valid_o
   );

// assign char = 8'd0;
// assign valid_o = 1'b0;

	`define BWW 6
	`define BW 32 // data
	`define DW 10
	`define DWW 4
	`define DWB 40 // digit 
	
//	wire[`BW-1:0] error_rate;
	reg [6:0] state;
	reg [`BW+`DWB-1:0] AllReg;
	reg [`DWB-1:0] dispchar;
	wire [`BW+`DWB-1:0] tempReg;
	assign tempReg = {AllReg[`BW+`DWB-2:0], 1'b0};
	
	always @(posedge CLK) begin
		if(!RST) begin
		   // リセットする
			state <= 0;
			valid_o <= 0;
		end else begin
			if(valid_o == 0) begin
				if(state == 0) begin
					if(start_update == 1) begin
						state <= 1;
						AllReg <= {`DWB'b 0, error_rate};
					end
				end else if (state < (`BW)) begin
					AllReg <= {onedigit(tempReg), tempReg[`BW-1: 0]};
					state <= state + 1;
				end else if (state == (`BW)) begin
					state <= 0;
					valid_o <= 1;
				end
			end
			
			if(valid_o == 1) begin
				if(state < (`DWB)) begin
					case (state)
						0: 
							char <= "0" + tempReg[(`BW)+(`DWB)-1 :(`BW)+(`DWB)-4];
						1:
							char <= "0" + tempReg[(`BW)+(`DWB)-4-1 :(`BW)+(`DWB)-8];
						2:
							char <= "0" + tempReg[(`BW)+(`DWB)-8-1 :(`BW)+(`DWB)-12];
						3:
							char <= "0" + tempReg[(`BW)+(`DWB)-12-1 :(`BW)+(`DWB)-16];
						4:
							char <= "0" + tempReg[(`BW)+(`DWB)-16-1 :(`BW)+(`DWB)-20];
						5:
							char <= "0" + tempReg[(`BW)+(`DWB)-20-1 :(`BW)+(`DWB)-24];
						6:
							char <= "0" + tempReg[(`BW)+(`DWB)-24-1 :(`BW)+(`DWB)-28];
						7:
							char <= "0" + tempReg[(`BW)+(`DWB)-28-1 :(`BW)+(`DWB)-32];
						8:
							char <= "0" + tempReg[(`BW)+(`DWB)-32-1 :(`BW)+(`DWB)-36];
						9:
							char <= "0" + tempReg[(`BW)+(`DWB)-36-1 :(`BW)+(`DWB)-40];
						10:
							;
						default:
							;
					endcase
					state <= state + 1;
				end else begin
					valid_o <= 0;
				end
			end
		end
	end
	
	function [`DWB:0] onedigit;
		input [`BW+`DWB-1:0] in;
		reg [3:0] t0, t1;
		reg[`DWB-1:0] a;
		integer i;
		begin
			a = in[`BW+`DWB-1:`BW];
			onedigit = 0;
			for(i=0;i<`DW;i=i+1) begin
				onedigit = onedigit >> 4;
				t0 = a[3:0];
				a = a >> 4;
				t1 = t0 + 2'b 11;
				if(t1[3] == 1) begin
					onedigit = {t1[3:0], onedigit[`DWB-5:0]};
				end else begin
					onedigit = {t0[3:0], onedigit[`DWB-5:0]};
				end
			end
		end
	endfunction
endmodule
