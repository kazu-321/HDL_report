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
	input 		     [9:0]		SW,
	
	//////////// Matrix Key ///////////
	input            [3:0]     KEY_ROW,
	output           [3:0]     KEY_COL

	);
	wire clk;
	wire [3:0]  wq;			//押下キー(4bit)
	wire [15:0] key;			//押下キー(16bit)
	wire [7:0]  dec_pat0;	//7セグ表示パターン
	wire pushed;				//打鍵検出

	
	m_prescale(CLK1, clk);	//100Hz
	
	m_matrix_key(clk, SW[0], KEY_ROW, KEY_COL, key, tc);	//マトリックスキーの打鍵検出
	
	m_dec16to4(key, wq, pushed);	// 押下キーを4bit出力
	
	m_mat7segment(wq, pushed, dec_pat0);	//押下キーに応じた7セグ表示

	assign LED = {6'd0,wq};
	assign HEX0=dec_pat0;
	assign HEX1=8'hff;
	assign HEX2=8'hff;
	assign HEX3=8'hff;
	assign HEX4=8'hff;
	assign HEX5=8'hff;
	
endmodule
