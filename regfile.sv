module regfile(data_in,writenum,write,readnum,clk,data_out);
    input [15:0] data_in;
    input [2:0] writenum, readnum;
    input write, clk;
    output [15:0] data_out;

    wire [2:0] writenum, readnum;
    
    `define select0 8'b00000001
    `define select1 8'b00000010
    `define select2 8'b00000100
    `define select3 8'b00001000
    `define select4 8'b00010000
    `define select5 8'b00100000
    `define select6 8'b01000000
    `define select7 8'b10000000

    reg [7:0] decOutWrite; //Stores the output of 3:8 Decoder for writing
    Dec #(3,8) dec38write(writenum,decOutWrite); // Decodes the writenum

    wire load0,load1,load2,load3,load4,load5,load6,load7;
    
    //something that converts decOut into a load value
    // AND gate for each load from write and decOutWrite
    assign load0 = write & decOutWrite[0];
    assign load1 = write & decOutWrite[1];
    assign load2 = write & decOutWrite[2];
    assign load3 = write & decOutWrite[3];
    assign load4 = write & decOutWrite[4];
    assign load5 = write & decOutWrite[5];
    assign load6 = write & decOutWrite[6];
    assign load7 = write & decOutWrite[7];

    wire [16-1:0] R0,R1,R2,R3,R4,R5,R6,R7;
    REG loadR0(data_in, load0, clk, R0);
    REG loadR1(data_in, load1, clk, R1);
    REG loadR2(data_in, load2, clk, R2);
    REG loadR3(data_in, load3, clk, R3);
    REG loadR4(data_in, load4, clk, R4);
    REG loadR5(data_in, load5, clk, R5);
    REG loadR6(data_in, load6, clk, R6);
    REG loadR7(data_in, load7, clk, R7);
    
    reg [7:0] decOutRead; //Stores the output of 3:8 Decoder for reading
    Dec #(3,8) dec38read(readnum,decOutRead);
    Mux8 #(16) muxOut(R0,R1,R2,R3,R4,R5,R6,R7,decOutRead,data_out);

endmodule
// 3:8 Decoder Module
module Dec(in, out);
    parameter n = 3; //input bit width
    parameter m = 8; //output bit width
    input [n-1:0] in;
    output [m-1:0] out;
    wire [m-1:0] out = 1<<in;
endmodule

module Mux8(a0, a1, a2, a3, a4, a5, a6, a7, s, out); //8 input Mux with one hot select
    parameter k = 16; //input and output bit width
    input [k-1:0] a0, a1, a2, a3, a4, a5, a6, a7;
    input [8-1:0] s; //one hot select
    output [k-1:0] out;
    reg [k-1:0] out;

    // Performs Mux operation (select0 is out = a0, select1 is out = a1, etc.)
    always @(*) begin
        case(s)
            `select0: out = a0;
            `select1: out = a1;
            `select2: out = a2;
            `select3: out = a3;
            `select4: out = a4;
            `select5: out = a5;
            `select6: out = a6;
            `select7: out = a7;
            default: out = 16'd0;
        endcase
    end 
endmodule

/*
module vDFF(clk,D,Q);
  parameter n=16;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;

  always @(posedge clk)
    Q <= D;
endmodule
*/

// Register with Load Enable
// Combines a 2 input mux with D Flip Flop
module REG(in, load, clk, out);
    parameter k = 16;
    input [k-1:0] in;
    input clk, load;
    output [k-1:0] out;
    wire [k-1:0] D;
    reg [k-1:0] out;

    always @(posedge clk) begin
         out <= load ? in : out;
    end

    // assign D = load ? in : out; //Assigns the output only if the corresponding load is high
    // vDFF #(k) regDFF(clk, D, out); //Assigns the register to D value on clk edge

endmodule