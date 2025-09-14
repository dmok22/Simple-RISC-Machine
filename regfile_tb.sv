module regfile_tb;

    reg [15:0] data_in;
    reg [2:0] writenum, readnum;
    reg write, clk;
    wire [15:0] data_out;
    reg err;

    `define select0 8'b00000001
    `define select1 8'b00000010
    `define select2 8'b00000100
    `define select3 8'b00001000
    `define select4 8'b00010000
    `define select5 8'b00100000
    `define select6 8'b01000000
    `define select7 8'b10000000
    
    regfile DUT(data_in, writenum, write,readnum,clk,data_out);

    task check_read; //Task that checks whether data_out, and decOutRead are as expected
        input [8-1:0] expected_decOutRead;
        input [16-1:0] expected_data_out;
    begin   
        if(regfile_tb.DUT.data_out !== expected_data_out) begin
            $display("ERROR ** data_out is %b, expected %b", regfile_tb.DUT.data_out, expected_data_out);
            err = 1'b1;
        end
        if(regfile_tb.DUT.decOutRead !== expected_decOutRead) begin
            $display("ERROR ** decOutRead is %b, expected %b", regfile_tb.DUT.decOutRead, expected_decOutRead);
            err = 1'b1;
        end
    end
    endtask


    task check_write; //Tasks that check if decOutWrite and the actual value written are correct
        input [7:0] selected_register;
        input [16-1:0] expected_value;
    begin
        if(regfile_tb.DUT.decOutWrite !== selected_register) begin
            $display("ERROR ** decOutWrite is %b, expected %b", regfile_tb.DUT.decOutWrite, selected_register);
            err = 1'b1;
        end
        case(selected_register)
            `select0: check_val(regfile_tb.DUT.R0, expected_value, selected_register);
            `select1: check_val(regfile_tb.DUT.R1, expected_value, selected_register);
            `select2: check_val(regfile_tb.DUT.R2, expected_value, selected_register);
            `select3: check_val(regfile_tb.DUT.R3, expected_value, selected_register);
            `select4: check_val(regfile_tb.DUT.R4, expected_value, selected_register);
            `select5: check_val(regfile_tb.DUT.R5, expected_value, selected_register);
            `select6: check_val(regfile_tb.DUT.R6, expected_value, selected_register);
            `select7: check_val(regfile_tb.DUT.R7, expected_value, selected_register);
            default: begin
                $display("ERROR, Attemped to check a register that does not exist");
                err = 1'b1;
            end
        endcase
    end
    endtask

    task check_val;
        input [16:0] register_value;
        input [16-1:0] expected_value;
        input [8-1:0] selected_register;
        if(register_value !== expected_value) begin
                    $display("ERROR ** register: %b is %b, expected %b", selected_register, register_value, expected_value);
                    err = 1'b1;
        end
    endtask

    initial begin //Alternating clock (5ps)
        clk = 0; #5;
        forever begin
            clk = 1; #5;
            clk = 0; #5;
        end      
    end

    initial begin
        err = 1'b0;

        //set data_in to 42, write to R3, read from R3
        data_in = 16'd42;
        writenum = 3'b011;
        write = 1'b1;
        readnum = 3'b011;
        #10;
        check_write(`select3, 16'd42);
        $display("Check writing to R3");
        check_read(`select3, 16'd42);
        $display("Check reading from R3");

        //set data_in to 14, write to R1, read from R1
        data_in = 16'd14;
        writenum = 3'b001;
        write = 1'b1;
        readnum = 3'b001;
        #10;
        check_write(`select1, 16'd14);
        $display("Check writing to R1");
        check_read(`select1, 16'd14);
        $display("Check writing to R1");

        //set data_in to 23, write to R2, read from R2
        data_in = 16'd23;
        writenum = 3'b010;
        write = 1'b1;
        readnum = 3'b010;
        #10;
        check_write(`select2, 16'd23);
        $display("Check writing to R2");
        check_read(`select2, 16'd23);
        $display("Check reading from R2");

        //set data_in to 420, write to R4, read from R4
        data_in = 16'd20;
        writenum = 3'b100;
        write = 1'b1;
        readnum = 3'b100;
        #10;
        check_write(`select4, 16'd20);
        $display("Check writing to R4");
        check_read(`select4, 16'd20);
        $display("Check reading from R4");
        
        //set data_in to 32, write to R5, read from R5
        data_in = 16'd32;
        writenum = 3'b101;
        write = 1'b1;
        readnum = 3'b101;
        #10;
        check_write(`select5, 16'd32);
        $display("Check writing to R5");
        check_read(`select5, 16'd32);
        $display("Check reading to R5");

        //set data_in to 11, write to R6, read from R6
        data_in = 16'd11;
        writenum = 3'b110;
        write = 1'b1;
        readnum = 3'b110;
        #10;
        check_write(`select6, 16'd11);
        $display("Check writing to R6");
        check_read(`select6, 16'd11);
        $display("Check reading to R6");

        //set data_in to 20, write to R7, read from R7
        data_in = 16'd20;
        writenum = 3'b111;
        write = 1'b1;
        readnum = 3'b111;
        #10;
        check_write(`select7, 16'd20);
        $display("Check writing to R7");   
        check_read(`select7, 16'd20);
        $display("Check reading to R7");

        //set data_in to 15, write to R7, read from R7
        data_in = 16'd15;
        writenum = 3'b111;
        write = 1'b0;
        readnum = 3'b111;
        #10;
        check_write(`select7, 16'd20);
        $display("Check non-writing to R7");   
        check_read(`select7, 16'd20);
        $display("Check reading to R7");

        //checking if error is still 0. If so, the tests passed, else they failed
        if( ~err ) $display("PASSED");
        else $display("FAILED");
        //$stop;

    end
endmodule