`timescale 1ns / 1ps

module pipeline_tb(

    );
 reg clk, rst;
 wire dependency1;
 wire dp;
// wire [15:0]result_old_trunc;
 wire [6:0] a_to_g;
 wire [3:0]an;
 initial rst = 0;
 initial clk = 0;
 always #5 
 begin
 clk = ~clk;rst=1;
 end
 pipeline zero_stage(.clk_in(clk),.rst(rst), .dependency1(dependency1), .a_to_g(a_to_g),.dp(dp), .an(an));
 
endmodule
