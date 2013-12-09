
module dual_clk
  #(parameter addr_width = 10,
    parameter data_width = 8)
  (
   input                         write_clk,
   input                         read_clk,
   
   output reg [data_width - 1:0] q,
   input [data_width - 1:0]      d,
   input [addr_width - 1:0]      write_address,
   input [addr_width - 1:0]      read_address,
   input                         we
   );

   reg [addr_width - 1:0]        read_address_reg;

   reg [data_width - 1:0]        mem [0:(1 << addr_width)-1];

   always @(posedge write_clk)
     if (we)
       mem[write_address] <= d;

   always @(posedge read_clk)
     begin
        q <= mem[read_address_reg];
        read_address_reg <= read_address;
     end
endmodule
     
   