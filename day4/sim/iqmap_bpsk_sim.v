module iqmap_bpsk_sim;

   reg 	CLK,RST;

   reg 	ce;
   
   reg 	valid_i;
   reg [127:0] reader_data;
   wire        reader_en;
   
   wire signed [10:0] xr;
   wire signed [10:0] xi;
   wire        valid_o;
   
   wire        valid_raw;
   wire        raw;

   iqmap_bpsk iqmap_bpsk (
			  .CLK(CLK),
			  .RST(RST),
			  .ce(ce),
			  .valid_i(valid_i),
			  .reader_data(reader_data),
			  .reader_en(reader_en),
			  .xr(xr),
			  .xi(xi),
			  .valid_o(valid_o),
			  .valid_raw(valid_raw),
			  .raw(raw)
			  );

//registors for error check   
   reg [2:0] xr_check;
   reg [2:0] xi_check;
   reg [256:0] raw_check;
   reg [127:0] xr_cnt;
   reg [127:0] xi_cnt;  
   reg [127:0] raw_cnt;
   reg [2:0]   state;

//data input
   always @(posedge CLK)
     if(reader_en == 1 && state < 4)begin
	case(state)
	  0:begin
	     reader_data <= 'b01010101;
	     state <= state +1;
	  end
	  1:begin
	     reader_data <= 'b11111111;
	     state <= state +1;
	  end
	  2:begin
	     if(xr_cnt != 4) xr_check <= xr_check+1;
 	     if(xi_cnt != 0) xi_check <= xi_check+1;
	     if(raw_cnt != 4) raw_check <= raw_check+1;
	     valid_i <= 0;	     
	     state <= state +1;
	  end
	  3:begin
	     reader_data <= 'b11111111;
	     state <= state +1;
	  end
	  4:begin
	     if(xr_cnt != 8) xr_check <= xr_check+1;
 	     if(xi_cnt != 0) xi_check <= xi_check+1;
	     if(raw_cnt != 8) raw_check <= raw_check+1;
	     state <= state +1;
	  end	   
	  default:;
	endcase
     end // if (reader_en == 1)

//count xr and xi output
   always @(posedge CLK)
     if(valid_o == 1 && xr > 11'sd0) xr_cnt <= xr_cnt+1;
   
   always @(posedge CLK)
     if(valid_o == 1 && xi > 11'sd0) xi_cnt <= xi_cnt+1;
   
   
//count raw output 
   always @(posedge CLK)
     if(valid_raw == 1 && raw > 11'sd0) raw_cnt <= raw_cnt+1;

   initial begin
      CLK <= 0;
      RST <= 1;
      ce <= 0;
                  
      valid_i <= 0;
      reader_data <= 0;

      state <= 0;
      xr_cnt <= 0;
      xi_cnt <= 0;
      raw_cnt <= 0;
      xr_check <= 0;
      xi_check <= 0;
      raw_check <= 0;
      
      #25 RST <=0;
      #100 RST <= 1;
      ce <= 1;
      
      #100 valid_i <= 1;
            
      #10000
      $display("\n\n\n----  ERROR CHECK  ----------------\n");
      $display("xr error : %2x",xr_check);
      $display("xi error : %2x",xi_check);
      $display("raw error : %2x",raw_check);
      $display("\n\n\n----  END OF ERROR CHECK  ---------\n\n");
      $finish;
      
      
   end // initial begin

   always #10 CLK <= ~CLK;   
   
   
endmodule // iqmap_bpsk_sim

       