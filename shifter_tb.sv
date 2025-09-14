module shifter_tb;

    reg [15:0] in;
    reg [1:0] shift;
    wire [15:0] sout;
    reg err;

    shifter DUT(in, shift, sout);

    task my_checker;
        input [15:0] expected_out;
    begin
        if(shifter_tb.DUT.sout !== expected_out) begin
            $display("ERROR ** out is %b, expected %b", shifter_tb.DUT.sout, expected_out);
            err = 1'b1;
        end
    end
    endtask

    initial begin
        err = 1'b0;
        // set in = 61183, same as output
        in = 16'b1111000011001111;
        shift = 2'b00;
        #10;
        my_checker(16'b1111000011001111);
        $display("checking shift 00 on 61183");

        // output shift left
        shift = 2'b01;
        #10;
        my_checker(16'b1110000110011110);
        $display("checking shift 01 on 61183");
        // output shift right
        shift = 2'b10;
        #10;
        my_checker(16'b0111100001100111);
        $display("checking shift 10 on 61183");
        // output shift right, copy B[15]
        shift = 2'b11;
        #10;
        my_checker(16'b1111100001100111);
        $display("checking shift 11 on 61183");
        // set in = 41, output same as input
        in = 16'd41;
        shift = 2'b00;
        #10;
        my_checker(16'd41);
        $display("checking shift 00 on 41");
        // output shift left
        shift = 2'b01;
        #10;
        my_checker(16'd82);
        $display("checking shift 01 on 41");
        // output shift right
        shift = 2'b10;
        #10;
        my_checker(16'd20);
        $display("checking shift 10 on 41");
        // output shift left, copy B[15]
        shift = 2'b11;
        #10;
        my_checker(16'b0000000000010100);
        $display("checking shift 11 on 41");
        // input 32781, output same as input
        in = 16'd32781;
        shift = 2'b00;
        #10;
        my_checker(16'b1000000000001101);
        $display("checking shift 00 on 32781");
        // output shift left
        shift = 2'b01;
        #10;
        my_checker(16'd65562);
        $display("checking shift 01 on 32781");
        // output shift right
        shift = 2'b10;
        #10;
        my_checker(16'd16390);
        $display("checking shift 10 on 32781");
        // output shift left, copy B[15]
        shift = 2'b11;
        #10;
        my_checker(16'b1100000000000110);
        $display("checking shift 11 on 32781");

        //checking if error is still 0. If so, the tests passed, else they failed
        if( ~err ) $display("PASSED");
        else $display("FAILED");
        //$stop;
    end

endmodule