`define selectRn 3'b001
`define selectRd 3'b010
`define selectRm 3'b100
`define selectmdata 4'b0001
`define selectsximm8 4'b0010
`define selectPC 4'b0100
`define selectC 4'b1000
`define MREAD 2'b11
`define MWRITE 2'b10
`define MNONE 2'b01

module cpu(clk, reset, s, in, write_data, N, V, Z, w, mem_addr, mem_cmd, read_data); //s, in, N, V, Z, w are unused (relics from lab 6)
    input clk, reset, s;
    input [15:0] in, read_data;
    output [1:0] mem_cmd;
    output [8:0] mem_addr;
    output [15:0] write_data;
    output N, V, Z, w;

    assign N = 1'b0;
    assign V = 1'b0;
    assign Z = 1'b0;
    assign w = 1'b0; //UNUSED FOR THIS LAB

    reg [15:0] sximm5, sximm8, iout;
    reg [8:0] PC;
    reg [3:0] vsel;
    reg [2:0] nsel, opcode, writenum, readnum;
    reg [1:0] op, ALUop, shift;
    reg asel, bsel, loada, loadb, loads, loadc, write;
    wire [8:0] next_pc;
    wire reset_pc, addr_sel;
    wire load_pc, clear_pc, load_ir, load_addr;
    wire [8:0] out_data_addr;

    REG #(16) instruction_reg(read_data, load_ir, clk, iout); //This is the Instruction Register using our load-enable register from lab 5 

    instruction_dec ID(iout, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);

    datapath DP(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, read_data, sximm8, PC[7:0], sximm5, Z, N, V, write_data);

    state_machine SM(clk, reset, opcode, op, nsel, w, loada, loadb, asel, bsel, loads, loadc, vsel, write, reset_pc, load_pc, mem_cmd, addr_sel, load_ir, load_addr);

    //PROGRAM COUNTER SECTION
    REG #(9) program_counter(next_pc, load_pc, clk, PC); //Program Counter load-enabled register //YEAH IDK IF PC should be the same as PCout???
    assign next_pc = reset_pc ? 9'd0 : PC + 9'd1; //PC will either reset or increment by 1

    //DATA ADDRESS SECTION
    REG #(9) data_address(write_data[8:0], load_addr, clk, out_data_addr); 
    assign mem_addr = addr_sel ? PC : out_data_addr;

endmodule

module instruction_dec(in, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum); //This is the Instruction Decoder (figure 8)
    input [15:0] in;
    input [2:0] nsel;
    output [1:0] ALUop, shift, op;
    output [2:0] readnum, writenum, opcode;
    output [15:0] sximm5, sximm8;

    reg [2:0] readnum, writenum;

    assign opcode = in[15:13];
    assign op = in[12:11];
    assign ALUop = in[12:11];

    
    assign sximm5 = (in[4] == 1'b1) ? {11'b11111111111, in[4:0]} : {11'b00000000000, in[4:0]}; //Sign extends imm5 depending on MSB
    assign sximm8 = (in[7] == 1'b1) ? {8'b11111111, in[7:0]} : {8'b00000000, in[7:0]}; //Sign extends imm8 depending on MSB (COULD MAKE THESE MODULES IDK ???)

    assign shift = in[4:3];

    always @(*) begin //Decoder for read/write num 

        case(nsel) 
            `selectRn: begin //Sets writenum and readnum to Rn which is in[]
                readnum = in[10:8];
                writenum = in[10:8];
            end
            `selectRd: begin //Rd
                readnum = in[7:5];
                writenum = in[7:5];
            end
            `selectRm: begin //Rm
                readnum = in[2:0];
                writenum = in[2:0];
            end
            default: begin
                readnum = 3'bxxx;
                writenum = 3'bxxx;
            end
        endcase

    end 
endmodule

module state_machine(clk, reset, opcode, op, nsel, w, loada, loadb, asel, bsel, loads, loadc, vsel, write, reset_pc, load_pc, mem_cmd, addr_sel, load_ir, load_addr);
    input reset, clk;
    input [2:0] opcode;
    input [1:0] op;
    output [2:0] nsel;
    output [3:0] vsel;
    output w, loada, loadb, loadc, loads, write, asel, bsel;
   
    //New I/O for lab7
    output reset_pc, load_pc, addr_sel, load_ir;
    output [1:0] mem_cmd;
    output load_addr;

    `define SW 5
    `define SRST 5'b00000 // RST
    `define Sdec 5'b00001 //Decode
    `define SWI 5'b00010 //WriteImm
    `define SRA 5'b00011 //ReadA
    `define SRB 5'b00100 //ReadB
    `define SALU 5'b00101 //ALU
    `define SWR 5'b00110 //Write
    `define SIF1 5'b00111 //IF1
    `define SIF2 5'b01000 //IF2
    `define SUPC 5'b01001 //Update PC
    `define SHALT 5'b01010 //HALT

    //Memory States
    `define SMEM0 5'b01011 //Read R[Rn] to A
    `define SMEM1 5'b01100 //ALU: R[Rn] + sx(im5)
    `define SMEM2 5'b01101 //Write to Data Address REG (This is the memory address that the value will be either read from or written to)

    `define SLDR3 5'b01110 //Read RAM from Data Address
    `define SLDR4 5'b01111 //Write RAM data into R[Rd]
    `define SLDR5 5'b10000 //Stall

    `define SSTR3 5'b10001 //Read R[Rd] to B
    `define SSTR4 5'b10010 //ALU: essentially a null state so R[Rd] can be sent to datapath_out
    `define SSTR5 5'b10011 //Write datapath_out value to RAM from Data Address (essentially writes R[Rd] to memory address R[Rn])
    `define SSTR6 5'b10100 //STALL

    reg [`SW-1:0] present_state, state_next_reset, state_next;
    reg [(`SW+21)-1:0] next;
    
    vDFF #(`SW) STATE(clk, state_next_reset, present_state); //Sets the present_state to next_state_reset at rising clk edge 

    assign state_next_reset = reset ? `SRST : state_next; //Sets the actual state_next to IF1 stage if user hasn't set 'reset' to true

    always @(*) begin //For this step each case will check present_state, op, opcode and will assign state_next nsel, load... (other controls for datapath)

        casex( {present_state, opcode, op} )

            //RST stage
            {`SRST, 5'bxxxxx}: next = {`SIF1, 14'b00000000000000, 7'b1100000}; //Goes to IF1 state 

            //IF1 Stage
            {`SIF1, 5'bxxxxx}: next = {`SIF2, 14'b00000000000000, 5'b00100, `MREAD}; //Goes to IF2 state read the instruction from memory

            //IF2 Stage
            {`SIF2, 5'bxxxxx}: next = {`SUPC, 14'b00000000000000, 5'b00110, `MREAD}; //Goes to update PC state load the instruction into the instruction register

            //Update PC stage
            {`SUPC, 5'bxxxxx}: next = {`Sdec, 14'b00000000000000, 7'b0100000}; //Goes to decode state

            //Decoder stage (choose based on instructions)
            {`Sdec, 5'b11010}: next = {`SWI, 14'b00000000000000, 7'b0000000}; //MOV immediate value
            {`Sdec, 5'b11000}: next = {`SRB, 14'b00000000000000, 7'b0000000}; //MOV RB value to nsel
            {`Sdec, 5'b10100}: next = {`SRA, 14'b00000000000000, 7'b0000000}; //ADD RA and RB v2alues to nsel
            {`Sdec, 5'b10101}: next = {`SRA, 14'b00000000000000, 7'b0000000}; //CMP RA and RB values
            {`Sdec, 5'b10110}: next = {`SRA, 14'b00000000000000, 7'b0000000}; //AND RA and RB values to nsel
            {`Sdec, 5'b10111}: next = {`SRB, 14'b00000000000000, 7'b0000000}; //NOT RA and RB values to nsel
            {`Sdec, 5'b01100}: next = {`SMEM0, 14'b00000000000000, 7'b0000000}; //LDR
            {`Sdec, 5'b10000}: next = {`SMEM0, 14'b00000000000000, 7'b0000000}; // STR
            {`Sdec, 5'b111xx}: next = {`SHALT, 14'b00000000000000, 7'b0000000}; //

            //Register Read Stage
            {`SRA, 5'bxxxxx}: next = {`SRB, 11'b10000000000,`selectRn, 7'b0000000}; //Read A (next state is Read B read from Rn, write is off)
            {`SRB, 5'bxxxxx}: next = {`SALU, 11'b01000000000, `selectRm, 7'b0000000}; //Read B (next state is ALU and write is off)

            //Execute Stage
            {`SALU, 5'b11000}: next = {`SWR, 14'b00100100000000, 7'b0000000}; //ALU operation that only uses RB (MOV Reg)
            {`SALU, 5'b10111}: next = {`SWR, 14'b00100100000000, 7'b0000000}; //ALU operation that only uses RB (MVN)
            {`SALU, 5'b10101}: next = {`SIF1, 14'b00001100000000, 7'b0000000}; //ALU operations for (CMP)
            {`SALU, 5'bxxxxx}: next = {`SWR, 14'b00000100000000, 7'b0000000}; //ALU operations that use RA and RB (AND and ADD)

            //Writeback stage
            {`SWR, 5'bxxxxx}: next = {`SIF1, 7'b0000001, `selectC, `selectRd, 7'b0000000}; //Write calculated value
            {`SWI, 5'bxxxxx}: next = {`SIF1, 7'b0000001, `selectsximm8, `selectRn, 7'b0000000}; //Write Intermediate Value
            
            //Common LDR and STR states (Read A, ALU, Write Data Address)
            {`SMEM0, 5'bxxxxx}: next = {`SMEM1, 11'b10000000000,`selectRn, 7'b0000000}; //Read Rn to A
            {`SMEM1, 5'bxxxxx}: next = {`SMEM2, 14'b00010100000000, 7'b0000000}; //ALU (bsel = 1) correct input format signed 5
            {`SMEM2, 5'b01100}: next = {`SLDR3, 14'b00000000000000, 7'b0000100}; //Write to Data Address + Transition to LDR substates
            {`SMEM2, 5'b10000}: next = {`SSTR3, 14'b00000000000000, 7'b0000100}; //Write to Data Address + Transition to STR substates
            
            //Unique states for LDR
            {`SLDR3, 5'bxxxxx}: next = {`SLDR4, 14'b00000000000000, 5'b00000, `MREAD}; //Read RAM at Data Address (port is mdata)
            {`SLDR4, 5'bxxxxx}: next = {`SLDR5, 14'b00000000000000, 7'b0000000}; //STALL STATE Delay for 1 cycle
            {`SLDR5, 5'bxxxxx}: next = {`SIF1, 11'b00000010001, `selectRd, 5'b00000, `MREAD}; //Write RAM (mdata) data into R[Rd] (MIGHT NEED TO STILL HAVE MREAD)
            // Write to Register

            //Unique states for STR
            {`SSTR3, 5'bxxxxx}: next = {`SSTR4, 11'b01000000000, `selectRd, 7'b0000000}; //Read R[Rd] to B STR  
            {`SSTR4, 5'bxxxxx}: next = {`SSTR5, 14'b00100100000000, 7'b0000000}; //ALU: essentially a null state so R[Rd] can be sent to datapath_out
            {`SSTR5, 5'bxxxxx}: next = {`SSTR6, 14'b00000000000000, 5'b00000, `MWRITE}; //Write datapath_out value to RAM from Data Address (essentially writes R[Rd] to memory address R[Rn])
            // storing Register
            {`SSTR6, 5'bxxxxx}: next = {`SIF1,  14'b00000000000000, 7'b0000000}; //STALL STATE delay for 1 cycle
 
            //Halt Stage
            {`SHALT, 5'bxxxxx}: next = {`SHALT, 7'b0000001, 14'b0}; //STOP

            default: next = {26'bxxxxxxxxxxxxxxxxxxxxxxxxxx};
        endcase
    end 

    assign {state_next, loada, loadb, asel, bsel, loads, loadc, write, vsel, nsel, reset_pc, load_pc, addr_sel, load_ir, load_addr, mem_cmd} = next;
    
    // assign w = (present_state == `SIF1) ? 1'b1 : 1'b0;
    
    

    
endmodule

