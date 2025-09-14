module shifter(in,shift,sout);
    input [15:0] in;
    input [1:0] shift;
    output [15:0] sout;

    reg [15:0] sout;

    always_comb begin //Performs shifting operations. (00 is no shift, 01 is left shift, 10 is right shift, 11 is rightshift whilst holding MSB)
        case(shift)
            2'b00: sout = in;
            2'b01: sout = in << 1;
            2'b10: sout = in >> 1;
            2'b11: begin
                sout = in >> 1;
                sout[15] = in[15];
            end
            default: sout = 16'd0;
        endcase
    end
endmodule