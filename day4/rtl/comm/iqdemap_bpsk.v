
module iqdemap_bpsk 
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
 output              raw
 );

reg[7:0] bytes;
reg[127:0] data;
reg valid_output;

reg[2:0] state;

assign valid_o = valid_output;
assign valid_raw = 0;
assign writer_data = data;

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
            state <= 1;
            bytes <= 0;
            valid_output <= 0;
         end
      end
      if(state == 1) begin
        //decode
        data = (data << 1) + (ar > 0);
        bytes = bytes + 1;
        if(bytes == 128) begin
           state <= 2;
        end
      end else if(state == 2) begin
         // output
         valid_output <= 1;
         state <= 0;
      end else begin
      end
   end
end
endmodule