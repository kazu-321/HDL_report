module my_circuit(A, B, C, Y);
    input A, B, C;
    output Y;
    
    assign Y = (A & C)
             | (A & ~B)
             | (C & ~B)
             | (~A & B & ~C);
endmodule
