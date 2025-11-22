module TopModule(
	//////////// CLOCK //////////
	input 		          		CLK1,
	input 		          		CLK2,
	//////////// SEG7 //////////
	output		     [7:0]		HEX0,
	output		     [7:0]		HEX1,
	output		     [7:0]		HEX2,
	output		     [7:0]		HEX3,
	output		     [7:0]		HEX4,
	output		     [7:0]		HEX5,
	//////////// Push Button //////////
	input 		     [1:0]		BTN,
	//////////// LED //////////
	output		     [9:0]		LED,
	//////////// SW //////////
	input 		     [9:0]		SW

	);
	wire clk, res, wnq;
	wire [3:0] wq;
	wire [7:0] hex;
	
	m_rs_flipflop u1(BTN[0], BTN[1], clk, wnq);	//clock
	
	assign res = SW[0];			//reset
	
	m_counter(clk, res, wq);	//counter
	
	m_seven_segment u2(wq, hex);
	
	assign LED={6'h0,wq};
	assign HEX0=hex;
	assign HEX1=8'hff;
	assign HEX2=8'hff;
	assign HEX3=8'hff;
	assign HEX4=8'hff;
	assign HEX5=8'hff;
	
endmodule
