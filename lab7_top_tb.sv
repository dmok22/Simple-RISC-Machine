// WARNING: This is NOT the autograder that will be used mark you.  
// Passing the checks in this file does NOT (in any way) guarantee you 
// will not lose marks when your code is run through the actual autograder.  
// You are responsible for designing your own test benches to verify you 
// match the specification given in the lab handout.

module lab7_top_tb;
  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg err;

  lab7_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);

  initial forever begin
    KEY[0] = 0; #5;
    KEY[0] = 1; #5;
  end

  initial begin
    err = 0;
    KEY[1] = 1'b0; // reset asserted
    // check if program from Figure 6 in Lab 7 handout can be found loaded in memory
    if (DUT.MEM.mem[0] !== 16'b1101000000000111) begin err = 1; $display("FAILED: mem[0] wrong; please set data.txt using Figure 6"); $stop; end
    if (DUT.MEM.mem[1] !== 16'b1101000100000010) begin err = 1; $display("FAILED: mem[1] wrong; please set data.txt using Figure 6");  end
    if (DUT.MEM.mem[2] !== 16'b1010000101001000) begin err = 1; $display("FAILED: mem[2] wrong; please set data.txt using Figure 6"); end
    if (DUT.MEM.mem[3] !== 16'b1000000101000000) begin err = 1; $display("FAILED: mem[3] wrong; please set data.txt using Figure 6"); end
    if (DUT.MEM.mem[4] !== 16'b0110000101100000) begin err = 1; $display("FAILED: mem[4] wrong; please set data.txt using Figure 6"); end
    if (DUT.MEM.mem[5] !== 16'b1110000000000000) begin err = 1; $display("FAILED: mem[4] wrong; please set data.txt using Figure 6");  end

    @(negedge KEY[0]); // wait until next falling edge of clock

    KEY[1] = 1'b1; // reset de-asserted, PC still undefined if as in Figure 4

    #10; // waiting for RST state to cause reset of PC

    // NOTE: your program counter register output should be called PC and be inside a module with instance name CPU
    if (DUT.CPU.PC !== 9'b0) begin err = 1; $display("FAILED: PC is not reset to zero.");  end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R0, 7

    if (DUT.CPU.PC !== 9'h1) begin err = 1; $display("FAILED: PC should be 1.");  end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 2 *after* executing MOV R0, 7

    if (DUT.CPU.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2."); end
    if (DUT.CPU.DP.REGFILE.R0 !== 16'h7) begin err = 1; $display("FAILED: R0 should be 7.");  end  // because MOV R0, 7 should have occurred CHANGE THIS

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 3 *after* executing MOV R1, 2

    if (DUT.CPU.PC !== 9'h3) begin err = 1; $display("FAILED: PC should be 3.");  end
    if (DUT.CPU.DP.REGFILE.R1 !== 16'h2) begin err = 1; $display("FAILED: R1 should be 2");  end //CHANGE THIS

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 4 *after* executing ADD R2, R1, R0, LSL #1

    if (DUT.CPU.PC !== 9'h4) begin err = 1; $display("FAILED: PC should be 4."); end
    if (DUT.CPU.DP.REGFILE.R2 !== 16'h10) begin err = 1; $display("%d, FAILED: R2 should be 16.", DUT.CPU.DP.REGFILE.R2 ); end
  
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 5 *after* executing STR R2, [R1]
   
    if (DUT.CPU.PC !== 9'h5) begin err = 1; $display("FAILED: PC should be 5."); end
    if (DUT.MEM.mem[DUT.CPU.DP.REGFILE.R1] !== 16'h10) begin err = 1; $display("%d, FAILED: mem[R1] wrong; looks like your STR isn't working", DUT.MEM.mem[DUT.CPU.DP.REGFILE.R1]); end


    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 6 *after* executing LDR R3, [R1]

    if (DUT.CPU.PC !== 9'h6) begin err = 1; $display("FAILED: PC should be 6."); end // wait here until PC changes;
    if (DUT.MEM.mem[DUT.CPU.DP.REGFILE.R1] !== 16'h10) begin err = 1; $display("%d, FAILED: mem[R1] wrong; looks like your STR isn't working", DUT.MEM.mem[DUT.CPU.DP.REGFILE.R1]); end //Does memory stay as is?
    if (DUT.CPU.DP.REGFILE.R3 !== 16'h10) begin err = 1; $display("%d, FAILED: R3 should be 16.", DUT.CPU.DP.REGFILE.R3 ); end // Check for Load

    // NOTE: if HALT is working, PC won't change again...
    
    if (~err) $display("INTERFACE OK");
    $stop;
  end
endmodule
