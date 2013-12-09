//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:44:38 01/20/2011 
// Design Name: 
// Module Name:    vga_i2c 
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
module vga_i2c(CLK, RST, SCL, SDA, BUSY, INST, EXEC, CHAR, READSTART, READADDR, CBAR);
	input CLK, RST, BUSY, READSTART, CBAR;
	input [6:0] READADDR;
	output SCL, EXEC;
	output [1:0] INST;
	output [7:0] CHAR;
	inout SDA;
	
	reg SCL;
	reg write;
	reg data;
	reg [7:0] CHAR;
	reg [1:0] INST;
	reg EXEC;
	reg [4:0] state, next;
	reg [7:0] DEVID, RAB, SENDDATA, readdata;
	reg [9:0] counter;
	reg [2:0] pos;
	reg [15:0] ack;
	reg [1:0] sent;
	reg [3:0] ackcnt;
	reg [2:0] cmdnum;
	reg mode; // 0 for write, 1 for read;
	reg [1:0] RS;
	reg [14:0] counter2;
	
	parameter S_ARBIT_START = 5'd0;
	parameter S_SENDDATA1 = 5'd1;
	parameter S_SENDDATA2 = 5'd2;
	parameter S_SENDDATA3 = 5'd3;
	parameter S_WAITACK1 = 5'd4;
	parameter S_WAITACK2 = 5'd5;
	parameter S_WAITACK3 = 5'd6;
	parameter S_WAITACK4 = 5'd7;
	parameter S_CMDEND = 5'd8;
	parameter S_STOP = 5'd9;
	parameter S_RESTART = 5'd10;
	parameter S_READSTART1 = 5'd11;
	parameter S_READSTART2 = 5'd12;
	parameter S_READSTART3 = 5'd13;
	parameter S_READ1 = 5'd14;
	parameter S_READ2 = 5'd15;
	parameter S_READ3 = 5'd16;
	parameter S_READ4 = 5'd17;
	parameter S_READ5 = 5'd18;
	parameter S_WAITACK5 = 5'd19;
	parameter S_SHOW = 5'd26;
	parameter S_IDLE = 5'd27;
	parameter S_WAIT1 = 5'd28;
	parameter S_WAIT2 = 5'd29;
	parameter S_LCD = 5'd30;
	parameter S_LCD2 = 5'd31;
	
	assign SDA = (write) ? data : 1'bz;
	
	always @(posedge CLK or negedge RST) begin
		if(!RST) begin
			counter2 <= 15'd0;
			RS <= 2'b10;
		end
		else begin
			if(counter2 == 15'd32767) begin
				if(READSTART && RS[1]) RS <= 2'b01;
				else if(!READSTART) RS[1] <= 1'b1;
			end
			else if(RS[0]) RS[0] <= 1'b0;
			counter2 <= counter2 + 15'd1;
		end
	end
	
	always @(posedge CLK or negedge RST) begin
		if(!RST) begin
			counter <= 10'd0;
			write <= 1'b0;
			data <= 1'b1;
			SCL <= 1'b1;
			state <= S_RESTART;
			pos <= 3'd7;
			sent <= 2'd0;
			cmdnum <= 3'd0;
			ackcnt <= 4'd0;
			mode <= 1'b0;
			DEVID <=8'b11101100;
			ack <= 16'hffff;
		end
		else begin
			case(state)
				S_RESTART: begin
					pos <= 3'd7;
					if(cmdnum == 3'd0) begin // pixel clock mode (1Ch)
						sent <= 2'd0;
						RAB <= {1'b0, 7'h1c};
						SENDDATA <= 8'b00000101;
						state <= S_ARBIT_START;
					end
					else if(cmdnum == 3'd1) begin // input data format & sync polarity (1Fh)
						sent <= 2'd1;
						RAB <= {1'b0, 7'h1f};
						SENDDATA <= 8'b10000000;
						state <= S_SENDDATA1;
					end
					else if(cmdnum == 3'd2) begin // wakeup (49h)
						sent <= 2'd1;
						RAB <= {1'b0, 7'h49};
						SENDDATA <= 8'b00000000;
						state <= S_SENDDATA1;
					end
					else if(cmdnum == 3'd3) begin // DAC enable (21h)
						sent <= 2'd1;
						RAB <= {1'b0, 7'h21};
						SENDDATA <= 8'b00001001;
						state <= S_SENDDATA1;
					end
					else if(cmdnum == 3'd4) begin // test pattern generation (48h)
						sent <= 2'd1;
						RAB <= {1'b0, 7'h48};
						SENDDATA <= {7'b0001100,CBAR};
						state <= S_SENDDATA1;
					end
				end
				S_ARBIT_START: begin
					write <= 1'b1;
					data <= 1'b0;
					next <= S_SENDDATA1;
					state <= S_WAIT1;
				end
				S_SENDDATA1: begin
					SCL <= 1'b0;
					next <= S_SENDDATA2;
					state <= S_WAIT2;
				end
				S_SENDDATA2: begin
					//write <= 1'b1;
					if(sent == 2'd0) data <= DEVID[pos];
					else if(sent == 2'd1) data <= RAB[pos];
					else data <= SENDDATA[pos];
					next <= S_SENDDATA3;
					state <= S_WAIT2;
				end
				S_SENDDATA3: begin
					SCL <= 1'b1;
					pos <= pos - 3'd1;
					if(pos == 3'd0) next <= S_WAITACK1;
					else next <= S_SENDDATA1;
					state <= S_WAIT1;
				end
				S_WAITACK1: begin
					SCL <= 1'b0;
					next <= S_WAITACK2;
					state <= S_WAIT2;
				end
				S_WAITACK2: begin
					write <= 1'b0;
					data <= 1'b0;
					next <= S_WAITACK3;
					state <= S_WAIT2;
				end
				S_WAITACK3: begin
					SCL <= 1'b1;
					next <= S_WAITACK4;
					state <= S_WAIT1;
				end
				S_WAITACK4: begin
					SCL <= 1'b0;
					write <= 1'b1;
					ack[ackcnt] <= SDA;
					sent <= sent + 2'd1;
					ackcnt <= ackcnt + 4'd1;
					pos <= 3'd7;
					if(mode == 1'b0 && sent == 2'd2) begin
						cmdnum <= cmdnum + 3'd1;
						if(cmdnum == 3'd4) next <= S_CMDEND;
						else next <= S_RESTART;
						state <= S_WAIT1;
					end
					else if(mode == 1'b1 && sent == 2'd1) begin
						next <= S_READSTART1;
						state <= S_WAIT2;
					end
					else if(mode == 1'b1 && DEVID[0]) begin
						next <= S_READ1;
						state <= S_WAIT2;
					end
					else begin
						next <= S_SENDDATA2;
						state <= S_WAIT2;
					end
				end
				S_CMDEND: begin
					SCL <= 1'b1;
					state <= S_WAIT2;
					next <= S_STOP;
				end
				S_STOP: begin
					data <= 1'b1;
					ackcnt <= 4'd0;
					pos <= 3'd7;
					state <= S_SHOW;
				end
				
				S_READSTART1: begin
					data <= 1'b1;
					state <= S_WAIT2;
					next <= S_READSTART2;
				end
				S_READSTART2: begin
					SCL <= 1'b1;
					state <= S_WAIT2;
					next <= S_READSTART3;
				end
				S_READSTART3: begin
					data <= 1'b0;
					sent <= 2'd0;
					DEVID[0] <= 1'b1;
					state <= S_WAIT2;
					next <= S_SENDDATA1;
				end
				S_READ1: begin
					write <= 1'b0;
					state <= S_WAIT2;
					next <= S_READ2;
				end
				S_READ2: begin
					SCL <= 1'b1;
					state <= S_WAIT1;
					next <= S_READ3;
				end
				S_READ3: begin
					SCL <= 1'b0;
					readdata[pos] <= SDA;
					state <= S_WAIT1;
					pos <= pos - 3'd1;
					if(pos == 3'd0) begin
						write <= 1'b1;
						data <= 1'b1;
						next <= S_READ4;
					end
					else next <= S_READ2;
				end
				S_READ4: begin
					SCL <= 1'b1;
					state <= S_WAIT1;
					next <= S_READ5;
				end
				S_READ5: begin
					SCL <= 1'b0;
					data <= 1'b0;
					pos <= 3'd7;
					state <= S_WAIT1;
					next <= S_CMDEND;
				end
				
				S_SHOW: begin
					if(mode == 1'b0) begin
						if(ack[ackcnt] == 1'b0) CHAR <= 8'h41;
						else CHAR <= 8'h4e;
						ackcnt <= ackcnt + 4'd1;
						if(ackcnt == 4'd10) next <= S_IDLE;
						else next <= S_SHOW;
					end
					else begin
						CHAR <= 8'h30 + readdata[pos];
						pos <= pos - 3'd1;
						if(pos == 3'd0) next <= S_IDLE;
						else next <= S_SHOW;
					end
					state <= S_LCD;
				end
				
				S_IDLE: begin
					if(RS[0]) begin
						DEVID[0] <= 1'b0;
						RAB <= {1'b1, READADDR};
						state <= S_ARBIT_START;
						mode <= 1'b1;
						ackcnt <= 4'd0;
						sent <= 2'd0;
						pos <= 3'd7;
					end
				end
					
				S_WAIT1: begin /* 5 us : about 170 CLK*/
					if(counter == 10'd170) begin
						state <= next;
						counter <= 10'd0;
					end
					else counter <= counter + 10'd1;
				end
				S_WAIT2: begin /* 2.5 us : about 85 CLK*/
					if(counter == 10'd85) begin
						state <= next;
						counter <= 10'd0;
					end
					else counter <= counter + 10'd1;
				end
				S_LCD: begin
					if(!BUSY) begin
						EXEC <= 1'b1;
						INST <= 2'd0;
						state <= S_LCD2;
					end
				end
				S_LCD2: begin
					EXEC <= 1'b0;
					state <= next;
				end
			endcase
		end
	end

endmodule
