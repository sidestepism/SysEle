module iqdemap_bpsk_sim;

   reg 	CLK,RST;

   reg 	ce;
   
   reg 	valid_i;
   reg signed [10:0] ar;
   reg signed [10:0] ai;

   wire 	      valid_o;   
   wire [127:0]       writer_data;
   
   wire        valid_raw;
   wire        raw;

   iqdemap_bpsk iqmap_bpsk (
			    .CLK(CLK),
			    .RST(RST),
			    .ce(ce),
			    .valid_i(valid_i),
			    .ar(ar),
			    .ai(ai),
			    .valid_o(valid_o),			    
			    .writer_data(writer_data),
			    .valid_raw(valid_raw),
			    .raw(raw)
			  );

//registors for error check   
   reg [127:0] ar_cnt;
   reg [127:0] ai_cnt;  
   reg [127:0] raw_cnt;
   reg [2:0]   state;
   reg signed [10:0] ar_data [0:7];
   reg [7:0]   data_cnt;
   reg 	       valid_ctrl;
      
//valid_i controll
   always @(posedge CLK)
     if(valid_ctrl == 1)
       valid_i <= 1;
        
//data input
   always @(posedge CLK)
     if(valid_ctrl == 1 || valid_i ==1)begin
	if(data_cnt < 8)begin
	   ar <= ar_data[data_cnt];
	   ai <= 0;
	   data_cnt <= data_cnt+1;
	end
	else if(data_cnt < 128)begin
	   ar <= -11'sd1;
	   ai <= 0;
	   data_cnt <= data_cnt+1;
	end
	else valid_i <= 0;
     end
   
//count ar output
   always @(posedge CLK)
     if(valid_o == 1) ar_cnt <= writer_data;
   
//count raw output 
   always @(posedge CLK)
     if(valid_raw == 1 && raw > 11'sd0) raw_cnt <= raw_cnt+1;

   initial begin
      CLK <= 0;
      RST <= 1;
      ce <= 0;
                  
      valid_i <= 0;
   
      state <= 0;
      ar_cnt <= 0;
      ai_cnt <= 0;
      raw_cnt <= 0;
      data_cnt <= 0;
      valid_ctrl <= 0;
            
      ar_data[0] <= 11'sd1;
      ar_data[1] <= -11'sd1;
      ar_data[2] <= 11'sd1;
      ar_data[3] <= -11'sd1;
      ar_data[4] <= 11'sd1;
      ar_data[5] <= -11'sd1;
      ar_data[6] <= 11'sd1;
      ar_data[7] <= -11'sd1;
      
      #20 RST <=0;
      #110 RST <= 1;
      ce <= 1;
      
      #200 valid_ctrl <= 1;
      #20 valid_ctrl <= 0;
                  
      #10000
      $display("\n\n\n----  ERROR CHECK  ----------------\n");
      $display("ar error : %2x",ar_cnt-'b01010101);
      $display("ai rror : %2x",ai_cnt-0);
      $display("raw error : %2x",raw_cnt-4);
      $display("\n\n\n----  END OF ERROR CHECK  ---------\n\n");
      $finish;
      
      
   end // initial begin

   always #10 CLK <= ~CLK;   
   
   
endmodule // iqdemap_bpsk_sim

       