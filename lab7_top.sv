`define MREAD 2'b11
`define MWRITE 2'b10
`define MNONE 2'b01

module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
    input [3:0] KEY;
    input [9:0] SW;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    wire [15:0] read_data;
    wire [8:0] mem_addr;
    wire [1:0] mem_cmd;
    wire msel, write;
    wire [7:0] read_address, write_address;
    reg [15:0] dout, write_data;
    wire [15:0] in;

    reg N, V, Z, w, s;
    wire clk, reset;

    assign clk = KEY[0];
    assign reset = ~KEY[1];

    //RAM PREPARATION
    assign read_address = mem_addr[7:0]; //Sets read address for RAM
    assign msel = (mem_addr[8:8] == 1'b0); //checkes if there is instruction in the memory. 0 is address. 1 is instruction
    assign read_data = (msel && (mem_cmd == `MREAD)) ? dout : {16{1'bz}}; //Tif we want to read and address
    assign write_address = mem_addr[7:0]; // Sets write address for RAM
    assign write = (msel && (mem_cmd == `MWRITE)); //Checks if there is an address and we want to write
    memory #(16, 8) MEM(clk, read_address, write_address, write, write_data, dout);

    cpu CPU(clk, reset, s, in, write_data, N, V, Z, w, mem_addr, mem_cmd, read_data); //s, w, N, V, Z, in, load are all relics of Lab 6

    wire out1, out2;

    comb COMB1(mem_cmd, mem_addr, 9'h140, `MREAD, out1); // 9'h140

    assign read_data[15:8] = out1 ? 8'h00 : {8{1'bz}};
    assign read_data[7:0] = out1 ? SW[7:0] : {8{1'bz}};

    comb COMB2(mem_cmd, mem_addr, 9'h100, `MWRITE, out2);

    REG #(8) output_reg(write_data[7:0], out2, clk, LEDR[7:0]);

    // assign HEX5[0] = ~Z;
    // assign HEX5[6] = ~N;
    // assign HEX5[3] = ~V;

    // sseg H0(out[3:0],   HEX0);
    // sseg H1(out[7:4],   HEX1);
    // sseg H2(out[11:8],  HEX2);
    // sseg H3(out[15:12], HEX3);
    // assign HEX4 = 7'b1111111;
    // assign {HEX5[2:1],HEX5[5:4]} = 4'b1111; // disabled
    // assign LEDR[8] = 1'b0;

    // input_iface IN(CLOCK_50, SW, ir, LEDR[7:0]);

endmodule

// module input_iface(clk, SW, ir, LEDR);
//   input clk;
//   input [9:0] SW;
//   output [15:0] ir;
//   wire sel_sw = SW[9];  
//   wire [15:0] ir_next = sel_sw ? {SW[7:0],ir[7:0]} : {ir[15:8],SW[7:0]};
//   vDFF #(16) REG(clk,ir_next,ir);
//   assign LEDR = sel_sw ? ir[7:0] : ir[15:8];  
// endmodule    

// Combinational Logic Circuits. Out enables the tri-state drive 
module comb(mem_cmd, mem_addr, addr, operation, out);
    input [1:0] mem_cmd, operation;
    input [8:0] mem_addr, addr;
    output out;

    assign out = (mem_cmd == operation) && (mem_addr == addr);
endmodule

module memory(clk, read_address, write_address, write, din, dout);

    parameter data_width = 32; //Addresses can store a custom amount of bits
    parameter addr_width = 4; //Address identifiers (binary to select the address) can be a custom amount of bits

    input clk;
    input [addr_width-1:0] read_address, write_address; //These are the addresses that we want to read and write from
    input write; //If write is 1, we want to write
    input [data_width-1:0] din; //This is the value we want to write to the register
    output [data_width-1:0] dout; //This is the value from the register we want to read from
    
    reg [data_width-1:0] dout; 
    reg [data_width-1:0] mem [2**addr_width-1:0]; //Essentially an array of arrays. mem is a directory of all addresses and their values

    initial $readmemb("data.txt", mem); //Initializes memory to the contents of the file

    always @(posedge clk) begin
        if (write) begin
            mem[write_address] <= din; //If we are writing, set the memory at the write_address to the input (delayed by 1 cycle)
        end
        dout <= mem[read_address]; //Read the value from the read address and output it (delayed by 1 cycle)
    end

endmodule

module vDFF(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;
  always @(posedge clk) begin
    Q <= D;
  end
endmodule

module sseg(in,segs);
  input [3:0] in;
  output [6:0] segs;

  `define HEX_0  7'b1000000
  `define HEX_1  7'b1111001
  `define HEX_2  7'b0100100 
  `define HEX_3  7'b0110000 
  `define HEX_4  7'b0011001 
  `define HEX_5  7'b0010010 
  `define HEX_6  7'b0000010 
  `define HEX_7  7'b1111000 
  `define HEX_8  7'b0000000 
  `define HEX_9  7'b0010000
  `define HEX_A  7'b0100000
  `define HEX_B  7'b0000011
  `define HEX_C  7'b0100111
  `define HEX_D  7'b0100001
  `define HEX_E  7'b0000100
  `define HEX_F  7'b0111101

  reg [6:0] segs;
 always @(*) begin
    case(in)
      4'd0: segs = `HEX_0;
      4'd1: segs = `HEX_1;
      4'd2: segs = `HEX_2;
      4'd3: segs = `HEX_3;
      4'd4: segs = `HEX_4;
      4'd5: segs = `HEX_5;
      4'd6: segs = `HEX_6;
      4'd7: segs = `HEX_7;
      4'd8: segs = `HEX_8;
      4'd9: segs = `HEX_9;
      4'd10: segs = `HEX_A;
      4'd11: segs = `HEX_B;
      4'd12: segs = `HEX_C;
      4'd13: segs = `HEX_D;
      4'd14: segs = `HEX_E;
      4'd15: segs = `HEX_F;
    default: segs = 7'b1111111;  
    endcase
 end

endmodule