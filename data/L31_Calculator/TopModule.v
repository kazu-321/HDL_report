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
	wire [3:0]  out;				//押下キー(4bit)
	wire [15:0] key;				//押下キー(16bit)
	wire [7:0]  dec_pat[0:5];	//7セグ表示パターン
	wire pushed;					//打鍵検出
	reg  pushed_d;

	
	reg  [3:0] in1, in2;		// 入力値1,2
	wire [7:0] ans;			// 演算結果
	wire [3:0] ans0,ans1,ans2;	// 演算結果(2進化10進数)
	reg  stat;		// 状態変数
	
	m_prescale(CLK1, clk);	//クロック(100Hz)の生成
	m_matrix_key(clk, SW[0], KEY_ROW, KEY_COL, key, tc);	//マトリックスキーの打鍵検出
	m_dec16to4_calc(key, out, pushed);	// 16bit→4bitデコーダ(計算機仕様に変更)
	
	//初期設定
	initial begin
		stat <= 1'b0;
		in1 <= 4'h0;
		in2 <= 4'h0;
	end
	
	always @(posedge clk) begin
		pushed_d <= pushed; // pushedを遅延させる
	end
	always @(posedge clk or posedge SW[0])begin
		//SW[0]はリセット
		if(SW[0]==1'b1)begin
			stat <= 1'b0;
			in1 <= 4'h0;
			in2 <= 4'h0;
		end
		// pushの変化を検出
		else if (pushed && !pushed_d) begin
			//状態0のとき in1に値を入力 =>状態遷移
			if(stat==1'b0)begin
				in1 <= (out<=9) ? out:4'he ;
				stat <= 1'b1;
			end
			//状態1のとき in2に値を入力 =>状態遷移
			else begin
				in2 <= (out<=9) ? out:4'he ;
				stat <= 1'b0;
			end
		end
	end
	
	m_calculator c0(in1,in2,ans);	//演算回路（4bit加算器）
	
	m_bcd_decorder b0(ans, {ans2,ans1,ans0});	// 2進数8bit => ３桁の2進化10進数(BCD)に変換
	
	m_7segment s0(in1,  dec_pat[5]);		// 入力１
	m_7segment s1(4'ha, dec_pat[4]);		// +
	m_7segment s2(in2,  dec_pat[3]);		// 入力２
	m_7segment s3(4'hf, dec_pat[2]);		// =
	m_7segment s4(ans1, dec_pat[1]);		// 答え（１０の位）
	m_7segment s5(ans0, dec_pat[0]);		// 答え（１の位）

	assign LED = {7'd0, stat};	//LEDには状態変数を表示
	
	assign HEX0 = dec_pat[0];
	assign HEX1 = dec_pat[1];
	assign HEX2 = dec_pat[2];
	assign HEX3 = dec_pat[3];
	assign HEX4 = dec_pat[4];
	assign HEX5 = dec_pat[5];
	
endmodule
