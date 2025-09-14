module datapath (clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, mdata, sximm8, PC, sximm5, Z_out, N_out, V_out, datapath_out);

    input [15:0] mdata, sximm8, sximm5;
    input [7:0] PC;
    input [2:0] writenum, readnum;
    input [1:0] ALUop, shift;
    input [3:0] vsel;
    input write, loada, loadb, asel, bsel, loadc, loads, clk;
    
    output [15:0] datapath_out;
    output reg Z_out, N_out, V_out;

    reg [15:0] data_in, in, Ain, Bin;
    reg [2:0] writenum,readnum;
    reg write, clk;
    reg [1:0] shift, ALUop;
    reg [15:0] data_out, sout, outa, out, sximm5;
    reg Z, V, N;

    Mux4 data_in_mux(mdata, sximm8, {8'b0, PC}, datapath_out, vsel, data_in); //4 input mux that decides the input to the register file depending on vsel 
    //We really only care about sximm8 (which is new incoming data) or data_out which is data from a previous register
    
    regfile REGFILE(data_in,writenum,write,readnum,clk,data_out); //Register file that has 8 registers (16 bits each)

    REG rA(data_out, loada, clk, outa); // load-enable register A
    REG rB(data_out, loadb, clk, in);// load-enable register B
    shifter U1(in, shift, sout);// Shifter module
    
    assign Ain = asel ? 16'b0 : outa; //Assigns Ain to 0 or outa depending on asel
    assign Bin = bsel ? sximm5 : sout; //Assigns Bin to datapath_in[4:0] and rest 0s or sout depending on bsel

    ALU U2(Ain,Bin,ALUop,out,Z,N,V); // ALU which performs basic arithmetic operations
    
    REG rC(out, loadc, clk, datapath_out);

    REG #(1) statusZ(Z, loads, clk, Z_out); // Zero Flag
    REG #(1) statusN(N, loads, clk, N_out); // Negative Flag
    REG #(1) statusV(V, loads, clk, V_out); // Overflow Flag

endmodule

module Mux4(a0, a1, a2, a3, s, out); //4 input Mux with one hot select
    parameter k = 16; //input and output bit width
    input [k-1:0] a0, a1, a2, a3; //potential inputs
    input [4-1:0] s; //one hot select (4 bits wide) CHANGE THIS CHANGE CHANGEF !!!!
    output [k-1:0] out;
    reg [k-1:0] out;

    // Performs Mux operation (select0 is out = a0, select1 is out = a1, etc.)
    always @(*) begin
        case(s)
            4'b0001: out = a0;
            4'b0010: out = a1;
            4'b0100: out = a2;
            4'b1000: out = a3;
            default: out = 16'bxxxxxxxxxxxxxxxx;
        endcase
    end 
endmodule