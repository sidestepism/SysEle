
module sampler_sram_bridge
  (
   input            CLK,
   input            RST,
  
   input [10:0]     col,
   input [9:0]      row,
   output reg [7:0] r,
   output reg [7:0] g,
   output reg [7:0] b,

   output [21:1]    data_r_address,
   input [31:0]     data_r,
   input            data_r_empty,
   output           data_r_req
   );

   reg            state;
   wire [8:0]     next_col = col[8:0] + 9'd1;

   assign data_r_address = {row[7:0], next_col};
   assign data_r_req = state;

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          state <= 1'b0;
        else
          state <= !state;
     end

   always @(posedge CLK or negedge RST)
     begin
        if (!RST) 
          {r, g, b} <= 24'h0;
        else
          if (state) begin
             if (row[9:8] == 2'd0 && col[10:9] == 2'd0) 
               {r, g, b} <= data_r[23:0];
             else
               {r, g, b} <= 24'h0;
          end
     end

endmodule // sampler_sram_bridge
