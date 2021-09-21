# Pipelined-ALU-on-FPGA
Programming a pipelined ALU on a ARM Cortex M4 Basys3 board 

PIPELINED ALU IMPLEMENTATION
PROJECT 
We have implemented a 3 stage pipeline, which includes the 
1. Instruction fetch stage
2. Arithmetic and Logic stage
3. Memory Write-back stage
It aims at increasing the throughput of the system, which without pipelining takes 15 clock cycles for executing 5 instructions, while only 9 clock cycles with pipelining. 
We have used the ARM7TDMI instruction set architecture in the implementation.
MODULES
The project includes three main modules:
1. pipeline.v  - the main module which controls the Program counter and invokes the rest of the modules.
2. if_decode_module.v - the module takes the 32-bit instruction and decodes it, according to the encoding scheme used (according to ARM7TDMI ISA).
3. alu_module.v - the module executes the operation on the operands provided and generates the result
Other modules:
1. clk_divider.v - the module slows down the clock at which the FPGA performs so that the output is perceptible to the human eye.
2. seg7decimal.v - it maps the hexadecimal output to the 7 segment display on the FPGA
3. pipeline_tb.v - the module provided a set of inputs to the pipeline module to simulate the output and performance. 
ARM7TDMI
* The instructions are 32-bit long and are encoded according to the scheme of the ARM7TDMI ISA. 
* The memory for instructions and data is implemented with arrays - there are 
16 memory registers, in the register file and so the opcode is of 4 bits.
* The data is 32 bit long. 
* The reference to the ISA - http://vision.gel.ulaval.ca/~jflalonde/cours/1001/h17/docs/arm-instructionset.pdf


FUNCTIONING OF THE MODULES:
PIPELINE STAGE
* It controls the program counter 
* When reset is triggered, PC goes to 0
* Otherwise, PC is incremented on every clock tick
* It picks the instruction and invokes the If_decode stage with it
* It receives the decoded instruction and passes to the ALU module for execution.
* It receives the result from the ALU stage and writes it back to the memory on the clock tick
* Note: The memory write-back stage is not implemented as a separate module but it is invoked on the clock tick and so it behaves like a separate module in the pipeline.
* The dependencies - the cases when the data is being read from and written in the same register, ambiguity may arise 
* To tackle the problem, we have implemented a dependency detector, which accordingly decides the value to be passed to the ALU stage and the write-back stage writes at the negative edge of the clock while the reading operation is performed at the positive edge. 


IF_DECODE STAGE
* It takes the 32-bit long instruction and breaks it down into pieces. 
* It then assigns the values to the respective variables which are then passed to the pipeline module.
  





ALU STAGE
* It takes the operands and the opcode value from the pipeline module
* It then checks whether the operand 2 is an immediate value or taken from a register
* It checks whether the instruction has a dependency or not, and accordingly passes the value read from the register or directly from the processed output of the ALU module of the last instruction. 
* It can perform the following 16 operations on the operands:
1. AND - bitwise AND operation
2. EOR - bitwise exclusive OR operation
3. SUB - arithmetic subtraction operation
4. RSB - reverse subtract operation (i.e. operand 2 - operand 1)
5. ADD - addition operation
6. ADC - addition operation with a carry bit
7. SBC - subtraction operation with a borrow bit
8. RSC - reverse subtract with the borrow bit
9. TST - set condition codes on AND operation, i.e. it would be performed conditionally
10. TEQ - set condition codes on EOR operation, i.e. it would be performed conditionally
11. CMP - set condition codes on subtraction operation, i.e. it would be performed conditionally
12. CMN - set condition codes on addition operation, i.e. it would be performed conditionally
13.  ORR - bitwise OR operation
14. MOV - returns the second operand
15. BIC - operand 1 AND (not operand 2)
16. MVN - returns the negation of operand 2
* It then updates the nzcv flag - (negative, zero, carry generated, overflow) 
* It also maintains an is_write flag which determines, whether the result is to be written in the memory or not. 


Write Back Stage: 
* This is responsible for the memory write operation 
* After the completion of the calculation stage - ALU execution
* To ensure unambiguity (When an update and read instructions are executed simultaneously)
1. Read at the negative edge of the clock 
2. Write at the positive edge of the clock