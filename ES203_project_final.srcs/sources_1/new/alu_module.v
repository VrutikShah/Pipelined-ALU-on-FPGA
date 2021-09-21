`define AND 4'd0    //Logic AND
`define EOR 4'd1    //Logic XOR 
`define SUB 4'd2    //SUBTRACT
`define RSB 4'd3    //REVERSE SUBTRACT
`define ADD 4'd4    // ADD
`define ADC 4'd5    //ADD WITH CARRY
`define SBC 4'd6    //SUBTRACT WITH CARRY
`define RSC 4'd7    // REVERSE SUBTRACT WITH CARRY
`define TST 4'd8    //AND WITHOUT WRITEBACK
`define TEQ 4'd9    //XOR WITHOUT WRITEBACK
`define CMP 4'd10   //SAME AS SUB, NO WRITE BACK
`define CMN 4'd11   //ADD WITHOUT write back
`define ORR 4'd12   // LOGIC OR 
`define MOV 4'd13   //OPERAND 1 IGNORED OPERAND 2 COPIED
`define BIC 4'd14   //BIT CLEAR
`define MVN 4'd15   // SHIFT OPERATION ADDED DURING POSTER PRESENTATION 



module alu_module(
opcode,
op1,
operand_1_dep,
operand_2,
nzcv,
nzcv_old,
dest_old,
dependency,
result_old,
result,
clk,
is_write
    );
    
    parameter n = 32;
    input [3:0] opcode;
    input [3:0]op1;
    input nzcv_old;               
    input [31:0] operand_1_dep;
    input [31:0] operand_2;
    input clk;
    input [31:0]result_old;
    input [3:0]dest_old;
    reg [31:0] operand_1;
    output reg dependency;
    
    output reg [31:0] result;
    output reg [3:0] nzcv;
    output reg is_write; 
    
    
    // INITIALIZING ALL VARIABLES
    initial 
    begin
    is_write = 1;
    nzcv = 0;
    operand_1 = 0;
    end
    
    reg cin;
    reg cout;

    always@(negedge clk)
    begin
    nzcv = nzcv_old;
    
    
    // LOGIC FOR REMOVING DEPENDENCY
    if(op1==dest_old)
        begin
        dependency=1;
        operand_1 = result_old;
        end    
    else
        begin
        dependency=0;
        operand_1 = operand_1_dep;
        end
    case(opcode)
    
    //LOGIC AND
    `AND: 
    begin
        result = operand_1 & operand_2;
        if(result == 0) nzcv[2] = 1;    
        is_write = 1;
    end
    
    //XOR
    `EOR: 
    begin
        result = operand_1 ^ operand_2;
        if(result == 0) nzcv[2] = 1;    
        is_write = 1;
    end     
    
    //SUBTRACTION OPERATION
    `SUB:   
        begin
            if(result[31] == 1) 	nzcv[3] = 1;
            if(result == 0) nzcv[2] = 1;
            is_write = 1;
            result[31:0] = operand_1[31:0] - operand_2[31:0];
        end
    
    `RSB: 
    begin
       if(result[31] == 1) 	nzcv[3] = 1;
        nzcv[1] = cout;
        nzcv[0] = cin^cout;
        if(result[31] == 1) 	nzcv[3] = 1;
        if(result == 0) nzcv[2] = 1;
        is_write = 1;
        result[31:0] = operand_2[31:0] - operand_1[31:0];
    end
    
    `ADD: begin  
        {cin, result[30:0]} = operand_1[30:0]+operand_2[30:0];
        {cout, result[31]} = operand_1[31]+operand_2[31]+cin;
        nzcv[1] = cout; //carry output 
        nzcv[0] = cout^cin;
	   if(result[31] == 1) 	nzcv[3] = 1;
        if(result == 0) nzcv[2] = 1;
        is_write = 1;
        end
    
    //result = op1 +op2 +c
    `ADC: begin  
        {cin, result[30:0]} = operand_1[30:0]+operand_2[30:0] + nzcv_old;
        {cout, result[31]} = operand_1[31]+operand_2[31]+cin;
        nzcv[1] = cout; //carry output 
        nzcv[0] = cout^cin;
        if(result[31] == 1) 	nzcv[3] = 1;
        if(result == 0) nzcv[2] = 1;
        is_write = 1;
        end
    
    `SBC: begin
    {cin, result[30:0]} = operand_1[30:0]+ ~operand_2[30:0]+nzcv_old-1; 
    {cout, result[31]} = cin+ operand_1[31]+ ~operand_2[31];
	nzcv[1]  = cout;	//carry flag
	nzcv[0] = cin^cout;
    if(result[31] == 1) 	nzcv[3] = 1;
    if(result == 0) nzcv[2] = 1;
    is_write = 1;
    end
    
    `RSC: begin
        {cin, result[30:0]} = operand_2[30:0]+ ~operand_1[30:0]+nzcv_old-1; 
	   {cout, result[31]} = cin+ operand_2[31]+ ~operand_1[31];
        nzcv[1]  = cout;	//carry flag
        nzcv[0] = cin^cout;
        if(result[31] == 1) nzcv[3] = 1; 
        if(result == 0) nzcv[2] = 1;
        is_write = 1;
    end
    
    //Same as AND but we do not Write it Back
    `TST:
    begin
     result = operand_1 & operand_2;
    if(result == 0) nzcv[2] = 1;     
    is_write = 0;

    end
     
    //Same as EOR but we do not Write it back
    `TEQ: 
    begin
    result = operand_1 ^ operand_2;
    is_write = 0;
    end
    
    //Same as SUB but we do not Write back in Registers
    `CMP:  begin
        result = ~operand_2; //Check it - if it is safe to use a single variable for calculation, otherwise naya variable bana le
        {cin, result[30:0]} = operand_1[30:0]+operand_2[30:0];
        {cout, result[31]} = operand_1[31]+operand_2[31]+cin;
        nzcv[1] = cout; //carry output 
        nzcv[0] = cout^cin;
        is_write = 0;
        end
    
    //Same as Add but we do not Write back in Registers
    `CMN: begin  
        {cin, result[30:0]} = operand_1[30:0]+operand_2[30:0];
        {cout, result[31]} = operand_1[31]+operand_2[31]+cin;
        nzcv[1] = cout; //carry output 
        nzcv[0] = cout^cin;
        is_write = 0;
        end
    //OR Operation
    `ORR: 
    begin
    result = operand_1 | operand_2;
if(result == 0) nzcv[2] = 1;
    is_write = 1;
    end
    
    //Operand 1 is ignored and Operand 2 is moved forward
    `MOV: 
    begin
    result = operand_2;
if(result == 0) nzcv[2] = 1;
    is_write = 1;
    end
    
    //OUTPUT = operand_1 & (~op2)
    `BIC: 
    begin
    result = operand_1 & (~operand_2);
if(result == 0) nzcv[2] = 1;
    is_write = 1;
    end
    
    //Move the negation of op2
    `MVN: 
    begin
    result = operand_2*2;
    end 
    endcase
    end
        
endmodule
