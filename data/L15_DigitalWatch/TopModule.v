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
	wire [7:0] w_hour;//時間の値(BCD)
	wire [7:0] w_min;	//分の値(BCD)
	wire [7:0] w_sec;	//秒の値(BCD)
	wire clk1s;			//1秒のクロック
	wire w_key0,w_key1,w_mode;
	wire mset_btn,sset_btn,mode;
	assign mset_btn=~w_key0;
	assign hset_btn=~w_key1;
	m_chattering m0(CLK1,BTN[0],w_key0);
	m_chattering m1(CLK1,BTN[1],w_key1);
	m_chattering m2(CLK1,SW[0],w_mode);
	
	m_1s_clk clk0(CLK1,clk1s);	//1秒のクロック
	
	m_digital_watch t0(clk1s,w_mode,hset_btn,mset_btn,w_hour,w_min,w_sec);
	
	assign LED=10'h0;
	m_seven_segment #(1) u0(w_sec[3:0],HEX0);
	m_seven_segment #(1) u1(w_sec[7:4],HEX1);
	m_seven_segment #(0) u2(w_min[3:0],HEX2);
	m_seven_segment #(1) u3(w_min[7:4],HEX3);
	m_seven_segment #(0) u4(w_hour[3:0],HEX4);
	m_seven_segment #(1) u5(w_hour[7:4],HEX5);
	
endmodule
