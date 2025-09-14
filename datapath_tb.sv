module datapath_tb;

    reg [15:0] mdata, sximm8, sximm5;
    reg [7:0] PC;
    reg write, loada, loadb, asel, bsel, loadc, loads, clk, err;
    reg [3:0] vsel;
    reg [1:0] ALUop, shift;
    reg [2:0] writenum, readnum;
    reg Z_out, V_out, N_out;
    wire [15:0] datapath_out;
    wire [2:0] status;

    `define select0 8'b00000001
    `define select1 8'b00000010
    `define select2 8'b00000100
    `define select3 8'b00001000
    `define select4 8'b00010000
    `define select5 8'b00100000
    `define select6 8'b01000000
    `define select7 8'b10000000

    datapath DUT(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, mdata, sximm8, PC, sximm5, Z_out, V_out, N_out, datapath_out);

    task check_write;
        input [7:0] selected_register;
        input [16-1:0] expected_value;
    begin
        case(selected_register)
            `select0: check_val(datapath_tb.DUT.REGFILE.R0, expected_value, selected_register);
            `select1: check_val(datapath_tb.DUT.REGFILE.R1, expected_value, selected_register);
            `select2: check_val(datapath_tb.DUT.REGFILE.R2, expected_value, selected_register);
            `select3: check_val(datapath_tb.DUT.REGFILE.R3, expected_value, selected_register);
            `select4: check_val(datapath_tb.DUT.REGFILE.R4, expected_value, selected_register);
            `select5: check_val(datapath_tb.DUT.REGFILE.R5, expected_value, selected_register);
            `select6: check_val(datapath_tb.DUT.REGFILE.R6, expected_value, selected_register);
            `select7: check_val(datapath_tb.DUT.REGFILE.R7, expected_value, selected_register);
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

    task check_out;
        input [2:0] status;
        input [3-1:0] expected_out;
        if(status !== expected_out) begin
            $display("ERROR ** output is %b, expected %b", {Z_out, N_out, V_out}, expected_out);
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

        //-------------------------------------------------------------//
        // r3 = 42
        sximm8 = 16'd42;
        vsel = 4'b0010;
        writenum = 3'b011;
        write = 1'b1;
        #10;
        check_write(`select3, 16'd42);
        $display("Check MOV R3, #42");

        // r5 =  13
        sximm8 = 16'd13;
        vsel = 4'b0010;
        writenum = 3'b101;
        write = 1'b1;
        #10;
        check_write(`select5, 16'd13);
        $display("Check MOV R5, #13");
        
        // store r3 in b
        readnum=3'd3;
        loadb=1'd1;
        loada=1'd0;
        #10;
        // store r5 in a
        readnum=3'd5;
        loada=1'd1;
        loadb=1'd0;
        #10;
        // sum of r3 and r5 in c
        shift=2'b00;
        asel=1'b0;
        bsel=1'b0;
        ALUop=2'b00;
        loadc=1'b1;
        loads = 1'b1;
        #10;
        // sum of r3 and r5 written to r2
        writenum=3'd2;
        write=1'b1;
        vsel=4'b1000;
        #10;
        check_write(`select2, 16'd55);
        $display("Check ADD R2,R5,R3");
        check_out({Z_out, N_out, V_out}, 3'b000);
        $display("Check Z_out, N_out, V_out");
        
        // r3 is stored in B
        readnum=3'd3;
        loadb=1'b1;
        #10;
        // Sum of 0 and R3 loaded in C.
        loadb=1'b0;
        shift=2'b00;
        asel=1'b1;
        bsel=1'b0;
        ALUop=2'b00;
        loadc=1'b1;
        loads = 1'b1;
        #10;
        // Sum of R3 and R5 written to R2.
        writenum=3'd7;
        write=1'b1;
        #10;
        check_write(`select7, 16'd42);
        $display("Check MOV R7,R3");
        check_out({Z_out, N_out, V_out}, 3'b000);
        $display("Check Z_out, N_out, V_out");

        //----------------------------------------------------------//

        // r1 = 42
        sximm8 = 16'd42;
        vsel = 4'b0010;
        writenum = 3'b001;
        write = 1'b1;
        #10;
        check_write(`select1, 16'd42);
        $display("Check MOV R1, #42");

        // r4 = 13
        sximm8 = 16'd13;
        vsel = 4'b0010;
        writenum = 3'b100;
        write = 1'b1;
        #10;
        check_write(`select4, 16'd13);
        $display("Check MOV R4, #13");
        
        // store r1 in a
        readnum=3'd1;
        loadb=1'd0;
        loada=1'd1;
        #10;

        // store r4 in b
        readnum=3'd4;
        loada=1'd0;
        loadb=1'd1;
        #10;

        // difference of r1 and r4/2 in c
        shift=2'b11; //Value of R4 is right shifted (divided by 2)
        asel=1'b0;
        bsel=1'b0;
        ALUop=2'b01; //Indicates substraction
        loadc=1'b1;
        loads = 1'b1;
        #10;

        // difference of r1 and r4/2 written to r2
        writenum=3'd2;
        write=1'b1;
        vsel=4'b1000;
        #10;
        check_write(`select2, 16'd36);
        $display("Check SUB R2,R1,R4,RSL #1"); //Should be equivilant to 42-13/2 = 36 (truncated)
        check_out({Z_out, N_out, V_out}, 3'b000);
        $display("Check Z_out, N_out, V_out");

        // r2 is stored in B
        readnum=3'd2;
        loadb=1'b1;
        #10;

        // Sum of 0 and R2 loaded in C.
        loadb=1'b0;
        shift=2'b00;
        asel=1'b1;
        bsel=1'b0;
        ALUop=2'b00;
        loadc=1'b1;
        loads = 1'b1;
        #10;

        // Sum of R2 and R5 written to R7.
        writenum=3'd7;
        write=1'b1;
        #10;
        check_write(`select7, 16'd36);
        $display("Check MOV R7,R2");
        check_out({Z_out, N_out, V_out}, 3'b000);
        $display("Check Z_out, N_out, V_out");

        //checking if error is still 0. If so, the tests passed, else they failed
        if( ~err ) $display("PASSED");
        else $display("FAILED");
        // $stop;

    end

endmodule