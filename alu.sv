module ALU(Ain,Bin,ALUop,out,Z,N,V);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output N, V, Z;
    output [15:0] out;
    
    reg [15:0] out;
    reg V;
    
    assign Z = (out == 16'd0); //Assigns the Z output if the output is all zeroes
    assign N = (out[15] == 1'b1); //Sets N to 1 if ALUout is negative

    always_comb begin //Operation block that performs associated operations (00 is addition, 01 is subtraction, 10 is & and 11 is not)
        case(ALUop)
            2'b00: begin 
                out = Ain + Bin;
                //V = (Ain[15] & Bin[15] & ~out[15]) | (~Ain[15] & ~Bin[15] & out[15]); (shouldnt be updated for ADD)
                V = 1'b0;
            end
            2'b01: begin 
                out = Ain - Bin;
                V = (~Ain[15] & Bin[15] & out[15]) | (Ain[15] & ~Bin[15] & ~out[15]); //Positive - Negative can never be negative and Negative - Positive can never be positive
            end
            2'b10: begin
                 out = Ain & Bin;
                 V = 1'b0;
            end
            2'b11: begin 
                out = ~Bin;
                V = 1'b0;
            end
            default: out = 16'd0;
        endcase
    end

    //2 Cases for subtraction resulting in overflow
        //positive - larger negative = positive that is too large (and positive)  
        //negative - positve = negative that is too large (and negative)

    




endmodule