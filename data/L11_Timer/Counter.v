module m_10_counter_manual(
    input clk,
    input stop,
    input manual_up,
    input manual_down,
    output reg [3:0] q,
    output reg c
);
    reg [3:0] cnt = 4'd0;

    always @(posedge clk) begin
        if (stop) begin
            // 設定モード中は自動カウント停止
            c <= 0;
            cnt <= cnt;
        end else begin
            c <= 0;
            // 自動カウント
            if (!manual_up && !manual_down) begin
                if (cnt == 4'd9) begin
                    cnt <= 0;
                    c <= 1;
                end else begin
                    cnt <= cnt + 1;
                end
            end else begin
					// 手動カウント
					if (manual_up) begin
						 if (cnt == 4'd9) cnt <= 0;
						 else cnt <= cnt + 1;
					end
					if (manual_down) begin
						 if (cnt == 0) cnt <= 9;
						 else cnt <= cnt - 1;
					end
				end
        end
        q <= cnt;
    end
endmodule

module m_6_counter_manual(
    input clk,
    input stop,
    input manual_up,
    input manual_down,
    output reg [2:0] q,
    output reg c
);
    reg [2:0] cnt = 3'd0;

    always @(posedge clk) begin
        if (stop) begin
            c <= 0;
            cnt <= cnt;
        end else begin
            c <= 0;
            // 自動カウント
            if (!manual_up && !manual_down) begin
                if (cnt == 3'd5) begin
                    cnt <= 0;
                    c <= 1;
                end else begin
                    cnt <= cnt + 1;
                end
            end else begin
					// 手動カウント
					if (manual_up) begin
						 if (cnt == 3'd5) cnt <= 0;
						 else cnt <= cnt + 1;
					end
					if (manual_down) begin
						 if (cnt == 0) cnt <= 5;
						 else cnt <= cnt - 1;
					end
				end
        end
        q <= cnt;
    end
endmodule

module m_24_counter_manual(
    input clk,
    input stop,
    input manual_up,
    input manual_down,
    output reg [3:0] q0, // units
    output reg [3:0] q1  // tens
);
    reg [4:0] cnt = 5'd0;

    always @(posedge clk) begin
        if (stop) begin
            cnt <= cnt; // 設定モード中は停止
        end else begin
            // 自動カウント
            if (!manual_up && !manual_down) begin
                if (cnt == 5'd23) cnt <= 0;
                else cnt <= cnt + 1;
            end
            // 手動カウント
            if (manual_up) begin
                if (cnt == 23) cnt <= 0;
                else cnt <= cnt + 1;
            end
            if (manual_down) begin
                if (cnt == 0) cnt <= 23;
                else cnt <= cnt - 1;
            end
        end
        q1 <= cnt / 10; // tens
        q0 <= cnt % 10; // units
    end
endmodule


module m_time_set(
    input clk,
    input mode,       // SW[9]
    input set_sec,    // SW[0]
    input set_min,    // SW[1]
    input set_hr,     // SW[2]
    input btn_up,     // BTN[0]
    input btn_down,   // BTN[1]
    input [3:0] milli_sec, // 100msカウント表示

    output reg manual_up_sec,
    output reg manual_down_sec,
    output reg manual_up_min,
    output reg manual_down_min,
    output reg manual_up_hr,
    output reg manual_down_hr,

    output reg [9:0] led_out
);

    // ------------------------
    // 長押しカウンタ
    // ------------------------
    reg [4:0] up_cnt;
    reg [4:0] down_cnt;
    parameter LONG_PRESS = 5'd5; // 適宜調整
    
    // m_timer_decoder インスタンス
    wire [9:0] timer_led;
    m_timer_decoder u_decoder(milli_sec, timer_led);

    always @(posedge clk) begin
        if (mode) begin
            // 設定モード
            led_out[0] <= set_sec;
            led_out[1] <= set_min;
            led_out[2] <= set_hr;
            led_out[9] <= 1'b1;        // 光らせる

            // デバッグ用LED[3-8]
            led_out[3] <= btn_up;            // BTN[0] 押下
            led_out[4] <= btn_down;          // BTN[1] 押下
            led_out[5] <= (up_cnt == LONG_PRESS);      // BTN[0] 長押し判定中
            led_out[6] <= (down_cnt == LONG_PRESS);    // BTN[1] 長押し判定中
            led_out[7] <= mode;              // 設定モード中
            led_out[8] <= set_sec | set_min | set_hr; // SW[0-2] 選択フラグ

            // led_out[8:3] <= led_out[8:3];    // その他の LED[3-8] はこのまま

            // BTN長押し判定
            if (btn_up) begin
                up_cnt <= 0;
            end else begin
                if (up_cnt < LONG_PRESS) up_cnt <= up_cnt + 1;
					 else up_cnt <= LONG_PRESS;
            end

            if (btn_down) begin
                down_cnt <= 0;
            end else begin
                if (down_cnt < LONG_PRESS) down_cnt <= down_cnt + 1;
					 else down_cnt <= LONG_PRESS;
            end

            manual_up_sec  <= set_sec  & ((up_cnt == LONG_PRESS) | (up_cnt == 1));
            manual_down_sec<= set_sec  & (down_cnt == LONG_PRESS);
            manual_up_min  <= set_min  & (up_cnt == LONG_PRESS);
            manual_down_min<= set_min  & (down_cnt == LONG_PRESS);
            manual_up_hr   <= set_hr   & (up_cnt == LONG_PRESS);
            manual_down_hr <= set_hr   & (down_cnt == LONG_PRESS);

        end else begin
            // 通常モード：0.1秒カウントをデコードして LED[0-9] に表示
            led_out <= timer_led;

            manual_up_sec  <= 0;
            manual_down_sec<= 0;
            manual_up_min  <= 0;
            manual_down_min<= 0;
            manual_up_hr   <= 0;
            manual_down_hr <= 0;

            up_cnt <= 0;
            down_cnt <= 0;
        end
    end
endmodule


