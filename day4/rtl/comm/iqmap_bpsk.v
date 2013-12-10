
module iqmap_bpsk
  (
   input         CLK,
   input         RST,

   input         ce,
   
   input         valid_i,
   input [127:0] reader_data,
   output        reader_en,

   output [10:0] xr,
   output [10:0] xi,
   output        valid_o,

   output        valid_raw,
   output        raw
   );
	
   reg[3:0] state;
   wire[127:0] data;
   reg[7:0] bytes;
   reg valid_output;

   reg[128:0] zerodata;
   assign data = zerodata[128:1];

   // 0: idle
   // (1: reading)
   // 2: output

   assign reader_en = (valid_output == 0);
   assign valid_o = (valid_output == 1);
   assign valid_raw = (valid_output == 1);

   assign xr = (data[127] == 1) ? 1023 : -1024;
   assign xi = 0;
   assign raw = data[127];


   always @(posedge CLK) begin
      if(!RST) begin
         // reset 
         zerodata <= 0;
         valid_output <= 0;
         state <= 0;
      end else begin
         if(state == 0) begin
            zerodata <= 0;
            valid_output <= 0;
            // idle
            if(valid_i == 1) begin
               zerodata <= reader_data;
               state <= 2;
               bytes <= 0;
            end
         end else if (state == 1) begin
            // nothing
         end else if (state == 2) begin
            // output
            valid_output <= 1;
            zerodata = zerodata << 1;
            bytes = bytes + 1;

            if (bytes >= 128) begin
               // end
               state = 0;
            end
         end else begin
            valid_output <= 0;
            state <= 0;
         end
      end
   end


endmodule
