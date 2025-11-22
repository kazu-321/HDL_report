module m_RSFF( S, R, Q, QB );
    input S, R;
    output Q, QB;
	 
    assign Q = ~(~S & QB);
    assign QB = ~(~R & Q);
	 
endmodule

module m_DFF( CK, D, Q );
    input CK, D;
    output Q;
    reg Q;
	 
    always @( posedge CK )
        Q <= D;
		  
endmodule

module m_JKFF ( CK, J, K, Q, RB );
	input CK, J, K, RB;
	output Q;
	reg Q;
	always @( posedge CK or negedge RB )
	begin
		if( RB == 1'b0 )
			Q <= 1'b0;
		else
			case( {J,K} )
				2'b00: Q <= Q;
				2'b01: Q <= 1'b0;
				2'b10: Q <= 1'b1;
				2'b11: Q <= ~Q;
			endcase
	end
endmodule