
module fps30
  (
   input      CLK,
   input      RST,

   input      start,
   input      stop,
   output reg frame
   );

   parameter max_counter = 32'd2424242;
 
   reg [31:0] counter;
   reg        started;
   
   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          started <= 1'b0;
        else begin
           if (start)
             started <= 1'b1;
           else if (stop)
             started <= 1'b0;
        end
     end

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          counter <= 32'h0;
        else begin
           if (started) begin
              if (counter == max_counter)
                counter <= 32'h0;
              else
                counter <= counter + 32'd1;
           end else
             counter <= 32'h0;
        end                 
     end
     
   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          frame <= 1'b0;
        else begin
          if (counter == max_counter)
            frame <= 1'b1;
          else
            frame <= 1'b0;
        end
     end

endmodule // fps30
 