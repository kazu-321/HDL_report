//1秒のクロック生成
module m_1s_clk(input clk,output clk1s);
	reg [24:0] cnt;
	reg r1s;
	wire wcout;
	
	assign wcout=(cnt==25'd24999999) ? 1'b1 : 1'b0;
	assign clk1s=r1s;
	always @(posedge clk) begin
		if(wcout==1'b1) begin
			cnt=0;
			r1s=~r1s;
		end
		else begin
			cnt=cnt+1;
		end
	end
		
endmodule	


//デジタルウォッチモジュール
module m_digital_watch(
	input clk,				//1秒周期のクロック
	input mode,				//0:時間表示	1:時間のセット
	input hset_sw,			//時間設定
	input mset_sw,			//分設定
	output [7:0] hour,	//BCD2桁の時間
	output [7:0] min,		//BCD2桁の分
	output [7:0] sec		//BCD2桁の秒
	);
	wire r_run;
	wire [5:0] carry;
	wire carry_sm,carry_mh;	//秒桁上げ、分桁上げのキャリー
	wire n_reset,clk_m,clk_h;
	
	assign clk_m=(mode==1'b1) ? mset_sw : (clk & r_run);
	assign clk_h=(mode==1'b1) ? hset_sw : (clk & r_run);
	assign n_reset=~mode;
	assign carry_sm=(mode==1'b1) ? 1'b1 : carry[1];
	assign carry_mh=(mode==1'b1) ? 1'b1 : carry[3];
	m_rs_flipflop r0(~mset_sw,~mode,r_run);
	
	m_universal_counter #(9) u0(clk  ,n_reset,r_run   ,carry[0],sec[3:0]);		//1sec
	m_universal_counter #(5) u1(clk  ,n_reset,carry[0],carry[1],sec[7:4]);		//10sec
	m_universal_counter #(9) u2(clk_m,1'h1   ,carry_sm,carry[2],min[3:0]);		//1min
	m_universal_counter #(5) u3(clk_m,1'h1   ,carry[2],carry[3],min[7:4]);		//10min
	m_24h_counter            u4(clk_h,1'h1   ,carry_mh,carry[4],hour    );		//hour

endmodule
