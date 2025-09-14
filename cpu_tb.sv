`timescale 1 ps/ 1 ps

module cpu_tb();

    reg clk, reset, s, load, err;
    reg [15:0] in;
    wire [15:0] out;
    wire N, V, Z, w;
    wire [15:0] read_data;
    wire [15:0] write_data;
    wire [8:0] mem_addr;
    wire [1:0] mem_cmd;

    assign read_data = in;

    cpu DUT(clk, reset, s, in, write_data, N, V, Z, w, mem_addr, mem_cmd, read_data);

    task check_output;
        input [15:0] expected_out;
    begin
        if(cpu_tb.DUT.write_data !== expected_out) begin
            $display("ERROR ** out is %b, expected %b", cpu_tb.DUT.write_data, expected_out);
            err = 1'b1;
        end
    end
    endtask

    task check_flags;
        input expected_N;
        input expected_V;
        input expected_Z;
    begin
        if(cpu_tb.DUT.N !== expected_N) begin
            $display("ERROR ** N is %b, expected %b", cpu_tb.DUT.N, expected_N);
            err = 1'b1;
        end
        if(cpu_tb.DUT.V !== expected_V) begin
            $display("ERROR ** V is %b, expected %b", cpu_tb.DUT.V, expected_V);
            err = 1'b1;
        end
        if(cpu_tb.DUT.Z !== expected_Z) begin
            $display("ERROR ** Z is %b, expected %b", cpu_tb.DUT.Z, expected_Z);
            err = 1'b1;
        end
    end
    endtask

    task check_register;
        input [3:0] register;
        input [15:0] register_value;
        input [15:0] expected_value;
    begin
        if (register_value !== expected_value) begin
            err = 1;
            $display("ERROR ** register %d is %b, expected %b", register, register_value, expected_value);
        end
    end
    endtask

    initial begin
        clk = 0; #5;
        forever begin
        clk = 1; #5;
        clk = 0; #5;
        end
    end

    initial begin
        err = 0;
        reset = 1; s = 0; load = 0; in = 16'b0;
        #10;
        reset = 0; 
        #10;

        //MOV R7 #10
        in = 16'b1101011100001010;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd7, cpu_tb.DUT.DP.REGFILE.R7, 16'd10);
        $display("Check MOV R7, #10");


        //MOV R0 #-4
        in = 16'b1101000011111100;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd0, cpu_tb.DUT.DP.REGFILE.R0, 16'b1111111111111100);
        $display("Check MOV R0, #-4");

        //ADD R1 R7 R0
        in = 16'b1010011100100000;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        //check_outputs(16'd6, 3'b0);
        check_register(3'd1, cpu_tb.DUT.DP.REGFILE.R1, 16'd6);
        check_output(16'd6);
        $display("Check ADD R1, R7, R0");

        //MOV R4 R0
        in = 16'b1100000010000000;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd4, cpu_tb.DUT.DP.REGFILE.R4, 16'b1111111111111100);
        check_output(16'b1111111111111100);
        $display("Check MOV R4 R0");

        //ADD R2 R7 R4 LSL #2
        in = 16'b1010011101001100;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        //check_outputs(16'd6, 3'b0);
        check_register(3'd2, cpu_tb.DUT.DP.REGFILE.R2, 16'd2);
        check_output(16'd2);
        $display("Check ADD R2 R7 R4 LSL #2");

        //ADD R3 R1 R7 LSR #1
        in = 16'b1010000101110111;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        //check_outputs(16'd6, 3'b0);
        check_register(3'd3, cpu_tb.DUT.DP.REGFILE.R3, 16'd11);
        check_output(16'd11);
        $display("Check ADD R3 R1 R7 LSR #1");

        //MOV R4 R3 LSR #1
        in = 16'b1100000010010011;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd4, cpu_tb.DUT.DP.REGFILE.R4, 16'd5);
        check_output(16'd5);
        $display("Check MOV R4 R3 LSR #1");

        //MVN R5 R4
        in = 16'b1011100010100100;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd5, cpu_tb.DUT.DP.REGFILE.R5, 16'b1111111111111010);
        check_output(16'b1111111111111010);
        $display("Check MVN R5 R4");

        //MVN R4 R5
        in = 16'b1011100010000101;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd4, cpu_tb.DUT.DP.REGFILE.R4, 16'd5);
        check_output(16'd5);
        $display("Check MVN R4 R5");

        //MVN R6 R5 Tests if MVN value actually updates a new register (since R4 is already used)
        in = 16'b1011100011000101;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd6, cpu_tb.DUT.DP.REGFILE.R6, 16'd5);
        check_output(16'd5);
        $display("Check MVN R6 R5");

        //CMP R4 R3 (5 - 11 = -6)
        in = 16'b1010110000000011;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd4, cpu_tb.DUT.DP.REGFILE.R4, 16'd5); //Ensures R4 doesnt change
        check_register(3'd3, cpu_tb.DUT.DP.REGFILE.R3, 16'd11); //Ensures R3 doesnt change
        check_output(16'b1111111111111010);
        //check_output(16'd5); //Disabled since output will change now (helps to view result of subtraction for De1 demo)
        check_flags(1'b1, 1'b0, 1'b0);
        $display("Check CMP R4 R3");

        //CMP R4 R4 (5 - 5 = 0)
        in = 16'b1010110000000100;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd4, cpu_tb.DUT.DP.REGFILE.R4, 16'd5); //Ensures R4 doesnt change
        check_register(3'd3, cpu_tb.DUT.DP.REGFILE.R3, 16'd11); //Ensures R4 doesnt change
        check_output(16'd0);
        //check_output(16'd5); //Disabled since output will change now (helps to view result of subtraction for De1 demo)
        check_flags(1'b0, 1'b0, 1'b1);
        $display("Check CMP R4 R4");

        //MOV R4 #127
        in = 16'b1101010001111111;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd4, cpu_tb.DUT.DP.REGFILE.R4, 16'd127);
        $display("Check MOV R4 #127");

        //MOV R4 R4 LSL #1
        in = 16'b1100000010001100;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd4, cpu_tb.DUT.DP.REGFILE.R4, 16'd254);
        $display("Check MOV R4 #127 LSL #1");

        //MVN R5 R4 LSL #1   Sets up another number for overflow
        in = 16'b1011100010101100;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd4, cpu_tb.DUT.DP.REGFILE.R4, 16'd254); //ensure R4 hasnt changed
        check_register(3'd5, cpu_tb.DUT.DP.REGFILE.R5, 16'b1111111000000011); //Ensure R5 is -509
        $display("Check MVN R5 R4 LSL #2");

        //MOV R4 #127
        in = 16'b1101010001111111;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd4, cpu_tb.DUT.DP.REGFILE.R4, 16'd127);
        $display("Check MOV R4 #127 RESET");

        //MOV R4 R4 LSL #6 (do it a bunch)
        in = 16'b1100000010001100;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd4, cpu_tb.DUT.DP.REGFILE.R4, 16'd254);

        in = 16'b1100000010001100;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        in = 16'b1100000010001100;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        check_register(3'd4, cpu_tb.DUT.DP.REGFILE.R4, 16'd508);

        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        in = 16'b1100000010001100;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        check_register(3'd4, cpu_tb.DUT.DP.REGFILE.R4, 16'd1016);

        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        in = 16'b1100000010001100;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        check_register(3'd4, cpu_tb.DUT.DP.REGFILE.R4, 16'd2032);

        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd4, cpu_tb.DUT.DP.REGFILE.R4, 16'd4064);

        in = 16'b1100000010001100;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd4, cpu_tb.DUT.DP.REGFILE.R4, 16'd8128);

        in = 16'b1100000010001100;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_register(3'd4, cpu_tb.DUT.DP.REGFILE.R4, 16'd16256);

        $display("Check MOV R5 LSL #7");

        //CMP R5 R4 LSL 1
        in = 16'b1010110100001100;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        // posedge w; // wait for w to go high again
        #10;
        check_output(16'b111111100000011);
        check_flags(1'b0, 1'b1, 1'b0);
        $display("Check CMP R5 R4 LSR 2 OVERFLOW");


        //checking if error is still 0. If so, the tests passed, else they failed
        if( ~err ) $display("PASSED");
        else $display("FAILED");
        $stop;

    end

endmodule