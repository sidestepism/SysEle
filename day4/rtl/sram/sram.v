
module sram
  (
   input         CLK,
   input         RST,

   output [21:1] A,
   inout [31:0]  D,
   inout [3:0]   DP,
   output [3:0]  BW,

   output        nCE,
   output        CE2,
   output        nCE2,
   output        ADV,
   output        nWE,
   output reg    nOE,
   output        nCKE,
   output        MODE,

   input [21:1]  data_w_address,
   input [31:0]  data_w,
   output        data_w_full,
   input         data_w_we,

   input [21:1]  data_r_address,
   output [31:0] data_r,
   output reg    data_r_empty,
   input         data_r_req
   );

   reg               nOE_delay;
   reg               data_r_empty_delay;

   reg [31:0]        data_w_delay;
   reg [31:0]        D_reg_dd;
   reg [31:0]        D_reg_d;
   reg               write_delay;
   reg               write_dd;
      
   wire              write;
   wire              read;
   
   assign nCE = 1'b0;
   assign CE2 = 1'b1;
   assign nCE2 = 1'b0;
   assign nCKE = 1'b0;
   assign MODE = 1'b0;

   assign read = data_r_req;
   assign write = !data_r_req && data_w_we;

   assign D 
     = write_dd ?
        D_reg_dd :
        32'hzzzz_zzzz ;
   assign A
     = write ?
       data_w_address :
       data_r_address;
   assign nWE
     = !write;
   assign ADV
     = 1'b0;
   assign BW
     = 4'b0000;
   
   assign data_r = D;

   assign data_w_full
     = data_r_req && data_w_we;

   always @(posedge CLK or negedge RST)
     begin
        if (!RST) begin
           nOE <= 1'b1;
        end else begin
           nOE <= nOE_delay;
        end
     end // always @ (posedge CLK or negedge RST)

   always @(posedge CLK or negedge RST)
     begin
        if (!RST) begin
           data_r_empty <= 1'b1;
        end else begin
           data_r_empty <= data_r_empty_delay;
        end
     end

   always @(posedge CLK or negedge RST)
     if (!RST) 
       nOE_delay <= 1'b1;
     else begin
        if (data_r_req)
          nOE_delay <= 1'b0;
        else
          nOE_delay <= 1'b1;
     end

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          data_r_empty_delay <= 1'b1;
        else begin
           if (data_r_req)
             data_r_empty_delay <= 1'b0;
           else
             data_r_empty_delay <= 1'b1;
        end
     end // always @ (posedge CLK or negedge RST)

   always @(posedge CLK or negedge RST)
     begin
        if (!RST) begin
           D_reg_dd <= 32'h00;
           D_reg_d  <= 32'h00;
           write_dd <= 1'b0;
           write_delay <= 1'b0;
        end else begin
           D_reg_dd <= D_reg_d;
           D_reg_d  <= data_w;
           write_dd <= write_delay;
           write_delay <= write;
        end
     end

endmodule // sram
   
