`define HFRONT   11'd39
`define HBACK    11'd87
`define HWIDTH   11'd127
`define HFRONT   11'd39
`define HACTIVE  11'd799
`define VFRONT   10'd0
`define VBACK    10'd23
`define VWIDTH   10'd2
`define VACTIVE  10'd599

module sync(hsync,vsync,col,row,active,vnotactive,hstart,vstart,CLK,RST);
	input CLK,RST;
	output hsync,vsync;
	reg	[13:0] hclock;
	reg [12:0] vclock;
	output [10:0] col;
	output [9:0]  row;
	output active;
	output vnotactive;
	output hstart;
	output vstart;
	assign hsync  = hclock[11];
	assign vsync  = vclock[10];
	assign active = hclock[12] & vclock[11];
	assign vnotactive = !vclock[11];
	assign col    = hclock[10:0];
	assign row    = vclock[9:0];
	assign   hstart = ( hclock == {3'b101, `HBACK} );
	assign   vstart = ( vclock == {3'b101, `VBACK} );
/*
 * Horizontal timing
 */
	always @(posedge CLK)
	begin
		if(!RST)
		begin
			hclock <= 0;
		end //RST
		else
		begin
			casex(hclock)
				{3'bxx0,`HWIDTH } : hclock <= {3'b101,11'b0};
				{3'b101,`HBACK  } : hclock <= {3'b011,11'b0};
				{3'bx11,`HACTIVE} : hclock <= {3'b001,11'b0};
				{3'b001,`HFRONT } : hclock <= {3'b100,11'b0};

				default:
					hclock <= {hclock[13:11],hclock[10:0] + 11'b1};
			endcase
		end
	end
/*
 *  Vertical timing
 */
	always @(posedge CLK)
	begin
		if(!RST)
		begin
			vclock <= 0;
		end //RST
		else if(hstart)
		begin
			casex(vclock)
				{3'bxx0,`VWIDTH } : vclock <= {3'b101,10'b0};
				{3'b101,`VBACK  } : vclock <= {3'b011,10'b0};
				{3'bx11,`VACTIVE} : vclock <= {3'b001,10'b0};
				{3'b001,`VFRONT } : vclock <= {3'b100,10'b0};

				default:
					vclock <= {vclock[12:10],vclock[9:0] + 10'b1};
			endcase
		end
	end
endmodule
