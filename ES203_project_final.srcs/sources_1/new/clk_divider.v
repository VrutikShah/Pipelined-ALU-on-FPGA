`timescale 1ns / 1ps
module clk_divider(clock_in,clock_out);
input clock_in;
output reg clock_out;

//A counter to divide slow down the clock.
reg[26:0] counter=27'd0; 
reg temp_clk = 0;
always @(posedge clock_in)
begin
    if(counter[26]==1)
        begin
        temp_clk = ~temp_clk;
        counter <= 27'd0;
        end
    else
        counter <= counter + 27'd1;
    clock_out = temp_clk;
end
endmodule
