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
	wire [3:0]  num;        //
	wire [15:0] key;			//押下キー(16bit)
	reg [3:0] rdata0, rdata1, rdata2, rdata3, rdata4, rdata5;
	wire pushed;				//打鍵検出
	reg  pushed_d; 

	
	m_prescale(CLK1, clk);	//100Hz
	
	m_matrix_key(clk, SW[0], KEY_ROW, KEY_COL, key, tc);	//マトリックスキーの打鍵検出
	
	m_dec16to4(key, wq, pushed);	// 押下キーを4bit出力
	
	m_convert_num(wq, num);
	
	always @(posedge clk) begin
		 pushed_d <= pushed;
	end

	always @(posedge clk) begin
		 if (!pushed_d && pushed) begin
			  rdata5 <= rdata4;
			  rdata4 <= rdata3;
			  rdata3 <= rdata2;
			  rdata2 <= rdata1;
			  rdata1 <= rdata0;
			  rdata0 <= num;     // 最新データ
		 end
	end

	wire [7:0] dec0, dec1, dec2, dec3, dec4, dec5;

	m_7segment u0 (rdata0, dec0);
	m_7segment u1 (rdata1, dec1);
	m_7segment u2 (rdata2, dec2);
	m_7segment u3 (rdata3, dec3);
	m_7segment u4 (rdata4, dec4);
	m_7segment u5 (rdata5, dec5);


	assign LED = {6'd0,wq};
	assign HEX0 = dec0;
	assign HEX1 = dec1;
	assign HEX2 = dec2;
	assign HEX3 = dec3;
	assign HEX4 = dec4;
	assign HEX5 = dec5;

	
endmodule
