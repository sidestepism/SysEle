
module iqmap_16qam
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
   output [3:0]  raw
   );

   // 0: idle
   // (1: reading)
   // 2: output
	
   reg[3:0] state;
   wire[127:0] data;
   reg[7:0] bytes;
   reg valid_output;

   reg[131:0] zerodata;
   assign data = zerodata[131:4];

   assign reader_en = (valid_output == 0);
   assign valid_o = (valid_output == 1);
   assign valid_raw = (valid_output == 1);

   // 3: data[127]
   // 2: data[126]
   // 1: data[125]
   // 0: data[124]

   // -1024: 100 0000 0000
   // -342 : 110 1010 1010
   // 341  : 001 0101 0101
   // 1023 : 011 1111 1111

   assign xi = 
      data[126] ? 
       ( data[124] ? -342 : -1024) :
       ( data[124] ?  341 :  1023) ;
   assign xr =
      data[127] ? 
       ( data[125] ? -342 : -1024) :
       ( data[125] ?  341 :  1023) ;


   assign raw = data[127:124];

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
            zerodata = zerodata << 4;
            bytes = bytes + 4;

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
