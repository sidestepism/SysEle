module top;
   reg CLK;
   reg RST;

   reg lcd_busy;
   reg start;

   wire update;
   wire lcd_row;
   wire [3:0] lcd_col;
   wire [7:0] lcd_char;
   wire       lcd_we;
   
   num2char num2char_init (
                           .CLK(CLK), .RST(RST),
                           .lcd_busy(lcd_busy), .start(start),
                           .update(update), .lcd_row(lcd_row),
                           .lcd_col(lcd_col), .lcd_char(lcd_char),
                           .lcd_we(lcd_we)
                           );
   

initial begin
   CLK=0;
   RST=1;
   start = 0;
   lcd_busy = 0;
   #25 RST = 0;
   #100 RST = 1;
   #100 start=1;
   #10000 $finish;
end

	always #10 CLK = ~CLK;
endmodule


`define BWW 6
`define BW 32
`define DW 10
`define DWW 4
`define DWB 40
module ber 
  #(parameter number_of_bits = 8)
  (CLK, RST, update, lcd_row, lcd_col, lcd_char, lcd_we, lcd_busy, start, valid_i, sent_data, recv_data, error_rate );
   input        CLK, RST;

   output      update, lcd_row;
   output [3:0] lcd_col;
   output  [7:0] lcd_char;
   output      lcd_we;
   output [`BW-1:0] error_rate;
   input        lcd_busy;
   input        start;

   input valid_i;
   input [number_of_bits-1:0] sent_data, recv_data;

   integer	cnt;

   reg      update, lcd_row;
   reg [3:0] lcd_col;
   reg  [7:0] lcd_char;
   reg      lcd_we;

   reg  disp_start;
	
   reg [`BW-1:0]  error_rate;
   reg [`BW-1:0]  error_cnt;
//   assign error_rate = `BW'd 298765432102;

   reg [`BWW:0] state;
   reg [`BW+`DWB-1:0] AllReg;
   reg [`DWB-1:0] char, dispchar;
   wire [`BW+`DWB-1:0] tempReg;
   assign tempReg = {AllReg[`BW+`DWB-2:0],1'b0};

   reg [`DWW-1:0] lstate;
   reg  charready;

   always @(posedge CLK) begin
	if(!RST) begin
		cnt <= 0;
		error_cnt <= 0;
		disp_start <= 0;
	end else begin
//////////////////////////////////////////////////// Fill this part
//////////////////////////////////////////////////// Fill this part
//////////////////////////////////////////////////// Fill this part
		cnt <= cnt + 1;
        end

   end

   always @(posedge CLK) begin
	if(!RST) begin
		lstate <= 0;
		update <= 0;
		lcd_we <= 0;
	end else begin
		if( lstate == 0 ) begin
			update <= 0;
			if( !(lcd_busy) ) lstate <= 1;
		end else if( lstate ==1 ) begin
			if( charready == 1 ) begin
				lcd_we <= 1;
				lcd_row <= 0;
				lcd_col <= `DW-1;
				lcd_char <= "0"+char[3:0];
				dispchar <= {4'b0, char[`DWB-1:4]};
				lstate <= lstate + 1;
			end
		end else if( lstate <= `DW ) begin
				lcd_col <= lcd_col -1;
				lcd_char <= "0"+dispchar[3:0];
				dispchar <= {4'b0, dispchar[`DWB-1:4]};
				lstate <= lstate + 1;
		end else if( lstate == `DW+1 ) begin
			lcd_we <= 0;
			update <= 1;
			lstate <= 0;
		end
	end
   end
   always @(posedge CLK) begin
	if(!RST) begin
		state <= 0;
		charready<=0;
	end else begin
		if( state == 0 ) begin
			if( start == 1 ) begin
				state <= 1;
				AllReg <= {`DWB'b 0,error_rate};
			end
		end else if( state <(`BW) )begin
			AllReg <= {onedigit(tempReg) , tempReg[`BW-1:0]};
			state <= state+1;
		end else if( state == (`BW) ) begin
			char <= tempReg[`BW+`DWB-1:`BW];
			state <= state+1;
			charready <= 1;
		end else if( update == 1 ) begin
			state <= 0;
			charready <= 0;
		end
		
	end

   end
   function [`DWB-1:0] onedigit;
	input [`BW+`DWB-1:0] in;
	reg [3:0] t1;
	reg [3:0] t0;
	reg	f;
	reg [`DWB-1:0] a;

	integer i;

	begin
	f=0;
	a = in[`BW+`DWB-1:`BW];
	onedigit = 0;
	for( i=0; i<`DW; i=i+1 ) begin
		onedigit = onedigit >> 4;
		t0 = a[3:0];
		a = a >> 4;
		t1 = t0 + 2'b 11;
		if( t1[3] == 1 )begin
			onedigit = {t1[3:0],onedigit[`DWB-5:0]};
		end else begin
			onedigit = {t0[3:0],onedigit[`DWB-5:0]};
		end
	end
	end
   endfunction
endmodule
