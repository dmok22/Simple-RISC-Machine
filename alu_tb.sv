module ALU_tb;
    reg [15:0] Ain, Bin;
    reg [1:0] ALUop;
    wire [15:0] out;
    wire Z, N, V;
    reg err;

    ALU DUT(Ain,Bin,ALUop,out,Z, N, V);

    task my_checker;
        input [15:0] expected_out;
    begin
        if(ALU_tb.DUT.out !== expected_out) begin
            $display("ERROR ** out is %b, expected %b", ALU_tb.DUT.out, expected_out);
            err = 1'b1;
        end
    end
    endtask

    task check_out;
        input expected_Z;
        input expected_N;
        input expected_V;
    begin
        if(ALU_tb.DUT.Z !== expected_Z || ALU_tb.DUT.N !== expected_N || ALU_tb.DUT.V !== expected_V) begin
            $display("ERROR ** status is %b, expected %b", {ALU_tb.DUT.Z,ALU_tb.DUT.N,ALU_tb.DUT.V}, {expected_Z,expected_N,expected_V});
            err = 1'b1;
        end
    end
    endtask
        

    initial begin
        err = 1'b0;
        // Check nonzero by setting Ain 5, Bin 3, ALUop 00
        Ain = 16'd5;
        Bin = 16'd3;
        ALUop = 2'b00;
        #10;
        my_checker(16'd8);
        $display("checking out ALUop 00");
        check_out(1'b0, 1'b0, 1'b0);
        $display("checking out is nonzero");

        // Check nonzero by setting Ain 5, Bin 3, ALUop 01
        ALUop = 2'b01;
        #10;
        my_checker(16'd2);
        $display("checking out ALUop 01");
        check_out(1'b0, 1'b0, 1'b0);
        $display("checking out is nonzero");

        // Check nonzero by setting Ain 5, Bin 3, ALUop 10
        ALUop = 2'b10;
        #10;
        my_checker(16'b0000000000000001);
        $display("checking out ALUop 10");
        check_out(1'b0, 1'b0, 1'b0);
        $display("checking out is nonzero");

        // Check nonzero by setting Ain 5, Bin 3, ALUop 11
        ALUop = 2'b11;
        #10;
        my_checker(16'b1111111111111100);
        $display("checking out ALUop 11");
        check_out(1'b0, 1'b1, 1'b0);
        $display("checking out is nonzero");

        // Check zero by setting Ain 0, Bin 0, ALUop 00
        Ain = 16'd0;
        Bin = 16'd0;
        ALUop = 2'b00;
        #10;
        my_checker(16'd0);
        $display("checking out ALUop 00");
        check_out(1'b1, 1'b0, 1'b0);
        $display("checking out is zero");

        // Check zero by setting Ain -1, Bin -1, ALUop 01
        Ain = -16'd1;
        Bin = -16'd1;
        ALUop = 2'b01;
        #10;
        my_checker(-16'd0);
        $display("checking out ALUop 01");
        check_out(1'b1, 1'b0, 1'b0);
        $display("checking out is nonzero");

        // Check zero by setting Ain -200, Bin -400, ALUop 00
        Ain = -16'd200;
        Bin = -16'd400;
        ALUop = 2'b00;
        #10;
        my_checker(-16'd600);
        $display("checking out ALUop 00");
        check_out(1'b0, 1'b1, 1'b0);
        $display("checking out is negative");
        
        // Check zero by setting Ain 400, Bin -400, ALUop 00
        Ain = 16'd400;
        Bin = -16'd400;
        ALUop = 2'b00;
        #10;
        my_checker(-16'd0);
        $display("checking out ALUop 10");
        check_out(1'b1, 1'b0, 1'b0);
        $display("checking out is zero");

        // Check zero by setting Ain 16'b1111111111111111, Bin -16'b0000000000000000, ALUop 10
        Ain = 16'b1111111111111111;
        Bin = -16'b0000000000000000;
        ALUop = 2'b10;
        #10;
        my_checker(-16'd0);
        $display("checking out ALUop 10");
        check_out(1'b1, 1'b0, 1'b0);
        $display("checking out is zero");

        // Check negative by setting Ain 16'b1111111111111111, Bin 16'b0000000000000001, ALUop 11
        Bin = 16'b0000000000000001; 
        ALUop = 2'b11;
        #10;
        my_checker(16'b1111111111111110);
        $display("checking out ALUop 10");
        check_out(1'b0, 1'b1, 1'b0);
        $display("checking out is negative");

        // Check negative and overflow by setting Ain 16'b0111111111111111, Bin 16'b1011111111111111, ALUop 01
        Ain = 16'b0111111111111111; //32767
        Bin = 16'b1011111111111111; //-16385
        ALUop = 2'b01;
        #10;
        check_out(1'b0, 1'b1, 1'b1);
        my_checker(16'b1100000000000000); //-16384
        $display("checking out is negative and overflow");

        // Check overflow by setting Ain 16'b1011111111111111, Bin 16'b0111111111111111, ALUop 01
        Ain = 16'b1011111111111111; //-16385
        Bin = 16'b0111111111111111; //32767
        ALUop = 2'b01;
        #10;
        check_out(1'b0, 1'b0, 1'b1); 
        my_checker(16'd16384); //16384
        $display("checking out is positive and overflow");

        // Check nonzero by setting Ain 5000, Bin 3000, ALUop 01
        Ain = 16'd5000;
        Bin = 16'd3000; 
        ALUop = 2'b01;
        #10;
        check_out(1'b0, 1'b0, 1'b0); 
        my_checker(16'd2000); 
        $display("checking out is positive and no overflow");

        // Check overflow by setting Ain 16'b1000000001000100, Bin 2000, ALUop 01
        Ain = 16'b1000000001000100; //-32700
        Bin = 16'd2000; 
        ALUop = 2'b01;
        #10;
        check_out(1'b0, 1'b0, 1'b1); 
        my_checker(16'd30836); 
        $display("checking out is positive and overflow");

        // Check negative by setting Ain 5000, Bin 16'b1110000011000000, ALUop 01
        Ain = 16'd5000;
        Bin = 16'b1110000011000000; 
        ALUop = 2'b01;
        #10;
        check_out(1'b0, 1'b0, 1'b0); 
        $display("checking out is negative and no overflow");

        
        Ain = 16'd32767;
        Bin = 16'd0; 
        ALUop = 2'b01;
        #10;
        check_out(1'b0, 1'b0, 1'b0); 
        $display("checking out is positive and no overflow");

        Ain = 16'b1000000000000000; //-32768
        Bin = 16'd0; 
        ALUop = 2'b01;
        #10;
        check_out(1'b0, 1'b1, 1'b0); 
        $display("checking out is negative and no overflow");

        Ain = 16'b1000000000000000; //-32768 edge case
        Bin = 16'd1; 
        ALUop = 2'b01;
        #10;
        check_out(1'b0, 1'b0, 1'b1); 
        $display("checking out is positive and overflow");

        Ain = 16'd1;
        Bin = 16'd32767; //Edge case
        ALUop = 2'b01;
        #10;
        check_out(1'b0, 1'b1, 1'b0); 
        $display("checking out is negative and no overflow");

        
        

        //checking if error is still 0. If so, the tests passed, else they failed
        if( ~err ) $display("PASSED");
        else $display("FAILED");
        //$stop;
        
    end
endmodule