
module iqdemap_qpsk 
(
 input               CLK,
 input               RST,

 input               ce,

 input               valid_i,
 input signed [10:0] ar,
 input signed [10:0] ai,

 output              valid_o,
 output [127:0]      writer_data,

 output              valid_raw,
 output [1:0]        raw
 );

reg[7:0] bytes;
reg[127:0] data;
reg valid_output;

reg[2:0] state;

assign valid_o = valid_output;
assign valid_raw = 0;
assign writer_data = data;

assign raw = !ar[10] * 2 + ai[10];

   // -1024: 100 0000 0000 | a10 d10
   // -342 : 110 1010 1010 | a11 d11
   // 341  : 001 0101 0101 | a00 d01
   // 1023 : 011 1111 1111 | a01 d00
   // assign xr = 
   //    data[125] ? 
   //     ( data[127] ? -342 : -1024) :
   //     ( data[127] ?  341 :  1023) ;
   // assign xi =
   //    data[124] ? 
   //     ( data[126] ? -342 : -1024) :
   //     ( data[126] ?  341 :  1023) ;

always @(posedge CLK) begin
   if (!RST) begin
      state <= 0;
      bytes <= 0;
      data = 0;
      valid_output <= 0;
   end else begin
      if(state == 0) begin
         valid_output <= 0;
         if(valid_i) begin
            state = 1;
            bytes <= 2;
            valid_output <= 0;
            data = (data << 2) + raw;
         end
      end else if(state == 1) begin
        //decode
        data = (data << 2) + raw;
        bytes = bytes + 2;
        if(bytes == 128) begin
           valid_output <= 1;
           state <= 0;
        end
      end
   end
end
endmodule