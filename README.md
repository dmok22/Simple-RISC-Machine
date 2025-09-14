# RISC Machine FPGA Board

A pipelined, superscalar processor with UBC CPEN211 Simple-Risc-Machine ISA

## Features
* Five-stage pipeline with comprehensive hazard control
* Synthesizable on Quartus with Cyclone-V FPGA
* Build-in branch prediction support, default static branch predictor
* Superscaler design, issue two instructions per cycle
* Separate Instruction-Memory and Data-Memory to resolve conflict and minimize bubbles

## Instruction Set Architecture

SRM ISA has 17 instructions for data processing, memory operation and branch control. Detailed encodings are listed below: 
Build
Simple RISC-Machine is developed with Quartus Prime 18.1 and ModelSim 10.5b.

It is tested with Cyclone-V FPGA on DE1-SoC. Other Verilog software tools and FPGAs may also work, but you may have to modify the top module and pin assignments.


<img width="695" height="805" alt="image" src="https://github.com/user-attachments/assets/1027f401-7d0a-4810-a70a-5313280f01a6" />

## Files
* Alu - Arithmetic Logic Unit
  * Performs arithmetic and logical operations such as addition, subtraction, AND, OR, XOR, comparisons, etc.
* CPU
  * Contains:
    * Datapath connection
    * Control signals from the instruction decoder.
    * Interface to memory (instruction/data).
* Datapath
  *  Describes data flows between registers, ALU, shifter, memory
* Regfile
  * Implement CPU's register bank
* shifter
  * Performs bit shifts and rotations

## Build process
1. Add all .sv files to your project.
2. Use lab7_top as your top module.
3. Create or modify data.txt to initialize system RAM.
   
## Memories
SRM ISA requires 16bit memory data bitwidth and 9bit address space. The memory mapping are shown below:

Address	Function	Note
0x000~0x0ff	Internal RAM	Initialize with data.txt
0x100~0x1ff	Peripherals	Access via LDR and STR
When compiled, both I.M. and D.M. will be initialzed with data.txt. System reset will reset the program counter to 0x00 and your program will start from there. I.M. will stay unchanged while the CPU is running. All LDR/STR instructions are directed to D.M.

You may add your custom Peripherals to the bus. Important: consecutive memory access are not guaranteed volatile. If volatile behavior is essential, insert at least one other instruction (such as NOP) between two LDR/STR.








