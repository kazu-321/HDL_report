module m_rs_flipflop(input set,input reset,output q,output nq);
	assign q=~(set & nq);
	assign nq=~(reset & q);
endmodule


module m_counter( ck, res, q );
    input   ck, res;
    output  [3:0] q;
    reg     [3:0] q;

    always @( posedge ck or posedge res )
    begin
        if( res == 1'b1 )
            q <= 4'h0;
        else
            q <= q + 4'h1 ; 
    end
endmodule

