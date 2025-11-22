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

	wire [7:0] input_0, input_1, output_0, output_1;
	wire [3:0] sum;
	wire co;
	
	m_seven_segment u0(SW[3:0], input_0);
	m_seven_segment u1(SW[7:4], input_1);
	
	add4 u2(SW[3:0], SW[7:4], 1'b0, sum, co);
	
	m_seven_segment u3(sum, output_0);
	m_seven_segment u4(co, output_1);
	
	assign LED={6'h0,SW[7:0]};
	assign HEX0=output_0;
	assign HEX1=output_1;
	assign HEX2=input_0;
	assign HEX3=input_1;
	assign HEX4=8'hff;
	assign HEX5=8'hff;
	
endmodule
