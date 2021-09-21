`timescale 1ns / 1ps

//different variables and their functions 
//opcode - this decides what operationn to perform out of 16 available instructions
//op1 - address of first operand. Going to thst address in register file gives us the output. This is 4 bit 
//op2 - address of second operand. Going to thst address in register file gives us the output. 
        //This is 8 bit and decoded depending upon 25th bit (whether to take immediate value or not)
//memory - This is actually register file. 2 Memories were created when another mem file was created. All its sequences has been initialised below
//dependency & dependency1 -  This is a flag to show whether there is a dependency or not.
//nzcv_old and nzcv - These are different flags to denote whether there is negative output(n), zero output(z), carry(c) or overflow(v). 


module pipeline(clk_in, rst, dependency1, a_to_g, dp, an);
input clk_in;
input rst;
reg [3:0]PC;
wire [6:0] temp_var;
wire clk;

//dividing the main clock so as to see the ouput on FPGA
clk_divider v1(.clock_in(clk_in), .clock_out(clk));


wire [3:0] opcode;
wire [3:0] op1;
wire [7:0] op2;
wire [3:0] dest;
reg [3:0] dest_old;
wire [3:0] nzcv;
wire [3:0] nzcv_old;
wire instr;

wire [31:0] result;
wire is_write;
wire [31:0] operand_1;
wire [31:0] operand_2;
wire dependency;
reg [31:0] result_old;
output dependency1;
output [3:0] an;
output dp;
output [6:0]a_to_g;

parameter mem_size = 32;
reg [mem_size-1:0]memory[15:0]; //THis is register not memory 

initial 
begin
//Intializing all values in memory
PC = 0;
memory[0] <= 32'h0000;
memory[1] <= 32'h0001;
memory[2] <= 32'h0002;
memory[3] <= 32'h0003;
memory[4] <= 32'h0000;
memory[5] <= 32'h0000;
memory[6] <= 32'h0007;
memory[7] <= 32'h0008;
memory[8] <= 32'h0009;
memory[9] <= 32'h000a;
memory[10] <= 32'h000b;
memory[11] <= 32'h000c;
memory[12] <= 32'h000d;
memory[13] <= 32'h000e;
memory[14] <= 32'h0015;
memory[15] = PC;
dest_old = 0;
result_old = 0;
//nzcv_old = 0;
end


//Calling different modules -  
//First Stage -IF, deocde stage 
if_decode_module first_stage(.clk(clk),
                  .PC(PC),
                  .opcode(opcode),
                  .op1(op1),
                  .op2(op2),
                  .dest(dest),
                  .nzcv(nzcv_old),
                  .instr_25(instr));


//Second Stage - Execute stage using ALU
alu_module second_stage(.opcode(opcode),
                        .op1(op1),
                        .operand_1_dep(memory[op1]),
                        .operand_2(memory[op2]),
                        .nzcv(nzcv),
                        .nzcv_old(nzcv_old[1]),
                        .dest_old(dest_old),
                        .dependency(dependency),
                        .result_old(result_old),
                        .result(result),
                        .clk(clk),
                        .is_write(is_write));
assign dependency1 = dependency;

//A part of IF decode module - decoding the destination reg. This part (extra variables creation) is done to remove dependencies.  
always @(posedge clk)
begin
dest_old = dest;
result_old = result;
end

//Third stage - Write back stage - This has been implemented here lest 2 different register files instances were created. One for read and other for write.
always @(negedge clk)
begin
memory[dest_old] = result;
    if(rst==0)    
        PC = 0;
    else
        PC = PC + 1;
end

//For bringing ON 7 segment display 
assign a_to_g = temp_var;   
seg7decimal stage (.x(result_old[15:0]), .clk(clk_in),.clr(0), .a_to_g(temp_var), .an(an), .dp(dp));
 
endmodule
