
module ddr2_test
  (
   input              CLK,
   input              RST,

   // DDR2 IF
   input              phy_init_done,
   
   output reg         app_af_wren,
   input              app_af_afull,
   output reg [30:0]  app_af_addr,
   output reg         app_af_read,

   output reg         app_wdf_wren,
   input              app_wdf_afull,
   output reg [127:0] app_wdf_data,
   output [15:0]      app_wdf_mask_data,

   input              rd_data_valid,
   input [127:0]      rd_data_fifo_out,

   // input
   input              start,
   output             busy,
   output             write_done,
   output             error
   );

`define WS 4
   parameter s_wait_init  = `WS'd0;
   parameter s_idle       = `WS'd1;
   parameter s_test_write = `WS'd2;
   parameter s_write_done = `WS'd3;
   parameter s_test_read  = `WS'd4;
   parameter s_error      = `WS'd5;
   parameter s_keep_reading = `WS'd6;
   reg [`WS-1:0]      state;
`undef WS

   reg [31:0]         read_count;
   parameter addr_top = 31'h0200_0000 - 31'd4;
//   parameter addr_top = 31'h8000 - 31'd8;
   parameter read_count_top = (addr_top + 31'd4)/4*2;

   assign app_wdf_mask_data = 16'h0000;
   assign busy = state != s_idle;
   assign write_done = state == s_write_done;
   assign error = state == s_error;

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        state <= s_wait_init;
     end else begin
        case (state)
          s_wait_init:
            if (phy_init_done)
              state <= s_idle;

          s_idle:
            if (start)
              state <= s_test_write;

          s_test_write:
            if (app_af_addr == addr_top)
              state <= s_write_done;

          s_write_done:
            if (start)
              state <= s_test_read;

          s_test_read:
            if (rd_data_valid && rd_data_fifo_out != app_wdf_data)
              state <= s_error;
            else if (app_af_addr == addr_top)
              state <= s_keep_reading;

          s_keep_reading:
            if (read_count == read_count_top)
              state <= s_idle;

          default: ;
        endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        app_af_addr <= 31'h0;
     end else begin
        case (state)
          s_test_write:
            if (app_af_wren)
              app_af_addr <= app_af_addr + 31'd4;

          s_write_done:
            app_af_addr <= 31'h0;

          s_test_read:
            if (!app_af_afull)
              app_af_addr <= app_af_addr + 31'd4;
          
          default: ;
        endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        app_af_read <= 1'b0;
     end else begin
        case (state)
          s_idle: 
            if (start)
              app_af_read <= 1'b0;

          s_write_done:
            app_af_read <= 1'b1;

          default: ;
        endcase
     end // else: !if(!RST)

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        app_af_wren <= 1'b0;
     end else begin
        case (state)
          s_idle: 
            if (start)
              app_af_wren <= 1'b1;
            else
              app_af_wren <= 1'b0;

          s_test_write:
            if (app_af_wren)
              app_af_wren <= 1'b0;
            else begin
               if (!app_af_afull && !app_wdf_afull)
                 app_af_wren <= 1'b1;
            end

          s_write_done:
            if (start)
              app_af_wren <= 1'b1;
            else
              app_af_wren <= 1'b0;

          s_test_read:
            if (!app_af_afull)
              app_af_wren <= 1'b1;
            else
              app_af_wren <= 1'b0;

          s_keep_reading:
            app_af_wren <= 1'b0;

          default: ;
        endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        app_wdf_wren <= 1'b0;
     end else begin
        case (state)
          s_idle: 
            if (start)
              app_wdf_wren <= 1'b1;

          s_test_write:
            if (app_af_addr == addr_top)
              app_wdf_wren <= 1'b0;
            else if (!app_af_wren && (app_af_afull || app_wdf_afull))
              app_wdf_wren <= 1'b0;
            else if (!app_af_afull && !app_wdf_afull)
              app_wdf_wren <= 1'b1;
          
          default: ;
        endcase
     end

`define INIT 128'h0001_0003_0005_0007__0009_000B_000D_000F
   always @(posedge CLK or negedge RST)
     if (!RST) begin
        app_wdf_data <= `INIT;
     end else begin
        case (state)
          s_idle, s_write_done:
            app_wdf_data <= `INIT;

          s_test_write:
            if (!app_af_afull && !app_wdf_afull)
              app_wdf_data <= {app_wdf_data[126:0], app_wdf_data[127]};

          s_test_read, s_keep_reading:
            if (rd_data_valid)
              app_wdf_data <= {app_wdf_data[126:0], app_wdf_data[127]};

          default: ;
        endcase
     end
`undef INIT

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        read_count <= 32'h0;
     end else begin
        case (state)
          s_test_read, s_keep_reading: 
            if (rd_data_valid)
              read_count <= read_count + 32'h1;
          default: 
            read_count <= 32'h0;

        endcase
     end

endmodule
