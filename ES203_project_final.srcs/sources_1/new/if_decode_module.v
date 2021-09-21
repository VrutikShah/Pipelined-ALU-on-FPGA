`timescale 1ns / 1ps

module if_decode_module(clk, PC, opcode, op1, op2, dest, nzcv, instr_25);

parameter no_instr = 4; //total number of instructions is 2^no_instr = 16
parameter instr_size = 32; //nUMBER OF BIT INSTRUCTION - 32 BITS

input clk;
input [no_instr-1:0]PC;
 
reg [instr_size-1:0]instr;
reg [instr_size-1:0]instr_set[15:0]; 

output reg [3:0]opcode;
output reg [3:0]op1;
output reg [7:0]op2;
output reg [3:0]dest;
output reg [3:0]nzcv;
output reg instr_25;


initial begin
//                cond_00_I_opcode_0_op1_dest_op2
instr_set[0] = 32'b0000_00_1_1111_0_0000_0100_000000000001;  // R[4] = R[1]>>1 = 2 Shift the value present in operand 2 to left by 1 digit

instr_set[1] = 32'b0000_00_1_0100_0_0010_1110_000000000011;  //R[14] = R[2] + R[3] = 2+3 = 5

instr_set[2] = 32'b0000_00_1_0100_0_0100_1101_000000000101;  // answer = 2

instr_set[3] = 32'b0000_00_1_0010_0_0111_1011_000000000011;  // answer = 5

instr_set[4] = 32'b0000_00_1_0100_0_0101_1100_000000000010;  // answer = 2

instr_set[5] = 32'b0000_00_1_0010_1_0110_0100_000000000101;  // answer = 7


// Instruction set has been coded till this point only. After this instruction set are copy of 5th instruction
instr_set[6] = 32'b0000_00_1_0010_1_0110_0100_000000000101; 

instr_set[7] = 32'b0000_00_1_0010_1_0110_0100_000000000101;

instr_set[8] = 32'b0000_00_1_0010_1_0110_0100_000000000101;

instr_set[9] = 32'b0000_00_1_0010_1_0110_0100_000000000101;

instr_set[10] = 32'b0000_00_1_0010_1_0110_0100_000000000101;

instr_set[11] = 32'b0000_00_1_0010_1_0110_0100_000000000101;

instr_set[12] = 32'b0000_00_1_0010_1_0110_0100_000000000101;

instr_set[13] = 32'b0000_00_1_0010_1_0110_0100_000000000101;

instr_set[14] = 32'b0000_00_1_0010_1_0110_0100_000000000101;

instr_set[15] = 32'b0000_00_1_0010_1_0110_0100_000000000101;

//INITIALIZING ALL VARIABLES TO AVOID X AS OUTPUT
instr = 0;
opcode = 0;
op1 = 0;
op2 = 0;
dest = 0;
nzcv = 0;
instr_25 = 0;
end
//Decoding the instruction opcode, op1, op2, dest as per ARM7TDMI instruction set
always @(negedge clk)
begin 
    instr = instr_set[PC];
    nzcv = instr[31:28]; 
    instr_25 = instr[25];
    opcode = instr[24:21];
    op1 = instr[19:16];
    dest = instr[15:12]; //ALL of these values are the address of the registers where these values are stored and not the values themselves.
        if(instr[25]==0) //Checking whether the second operand is immediate value or not
        begin
            //shift = instr[11:8];
            op2 = instr[7:0]; //This is not the address and rather the value directly
        end
        else
        begin
            //shift = 4'b1111;  //If shift is 15, then it is not the immediate value and rather the address of the register 
            op2 = instr[3:0];                
        end         
end
endmodule
