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
	


    // ------------------------
    // 100ms クロック生成（m_prescale5M を使用）
    // ------------------------
    wire clk_100ms;
    m_prescale5M u0(CLK1, clk_100ms);

    // ------------------------
    // 1秒パルス用カウンタ（100ms×10 = 1秒）
    // ------------------------
    wire clk_1s;
    reg [3:0] cnt_100ms;
    always @(posedge clk_100ms) begin
        if (SW[9]) begin
            cnt_100ms <= cnt_100ms; // 設定モードで停止
        end else begin
            if (cnt_100ms == 4'd9) cnt_100ms <= 0;
            else cnt_100ms <= cnt_100ms + 1;
        end
    end
    assign clk_1s = (cnt_100ms == 4'd9) && !SW[9];

    // ------------------------
    // m_time_set 出力（manual_up/down + LED）
    // ------------------------
    wire manual_up_sec, manual_down_sec;
    wire manual_up_min, manual_down_min;
    wire manual_up_hr, manual_down_hr;

    wire [3:0] milli_sec;
    assign milli_sec = cnt_100ms;

    m_time_set u_set(
        .clk(clk_100ms),
        .mode(SW[9]),
        .set_sec(SW[0]),
        .set_min(SW[1]),
        .set_hr(SW[2]),
        .btn_up(BTN[0]),
        .btn_down(BTN[1]),
        .manual_up_sec(manual_up_sec),
        .manual_down_sec(manual_down_sec),
        .manual_up_min(manual_up_min),
        .manual_down_min(manual_down_min),
        .manual_up_hr(manual_up_hr),
        .manual_down_hr(manual_down_hr),
        .milli_sec(milli_sec),
        .led_out(LED)
    );

    // ------------------------
    // 共通カウンタ（手動+自動）
    // ------------------------
    wire [3:0] sec0, sec1, min0, min1, hr0, hr1;
    wire clk_sec0, clk_sec1, clk_min0, clk_min1, clk_hr;

    // 秒
    m_10_counter_manual c_sec0(
        .clk(clk_1s),
        .stop(SW[8]),
        .manual_up(manual_up_sec),
        .manual_down(manual_down_sec),
        .q(sec0),
        .c(clk_sec0)
    );

    m_6_counter_manual c_sec1(
        .clk(clk_sec0),
        .stop(SW[8]),
        .manual_up(manual_up_sec),
        .manual_down(manual_down_sec),
        .q(sec1),
        .c(clk_sec1)
    );

    // 分
    m_10_counter_manual c_min0(
        .clk(clk_sec1),
        .stop(SW[8]),
        .manual_up(manual_up_min),
        .manual_down(manual_down_min),
        .q(min0),
        .c(clk_min0)
    );

    m_6_counter_manual c_min1(
        .clk(clk_min0),
        .stop(SW[8]),
        .manual_up(manual_up_min),
        .manual_down(manual_down_min),
        .q(min1),
        .c(clk_min1)
    );

    // 時
    m_24_counter_manual c_hr(
        .clk(clk_min1),
        .stop(SW[8]),
        .manual_up(manual_up_hr),
        .manual_down(manual_down_hr),
        .q0(hr0),
        .q1(hr1)
    );

    // ------------------------
    // 7セグメント表示
    // ------------------------
    m_seven_segment u2(sec0, HEX0);
    m_seven_segment u3(sec1, HEX1);
    m_seven_segment u4(min0, HEX2);
    m_seven_segment u5(min1, HEX3);
    m_seven_segment u6(hr0, HEX4);
    m_seven_segment u7(hr1, HEX5);

	 
endmodule
