module TopModule(
    input            CLK1,
    input            CLK2,
    output     [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    input      [1:0] BTN,
    output     [9:0] LED,
    input      [9:0] SW,
    input      [3:0] KEY_ROW,
    output     [3:0] KEY_COL
);

    /* ===== Clock & Key ===== */
    wire clk;
    wire [3:0] key_val;
    wire [15:0] key_raw;
    wire pushed;
    reg  pushed_d;

    m_prescale      u0 (CLK1, clk);
    m_matrix_key    u1 (clk, SW[0], KEY_ROW, KEY_COL, key_raw);
    m_dec16to4_calc u2 (key_raw, key_val, pushed);

    always @(posedge clk)
        pushed_d <= pushed;

    /* ===== State ===== */
    reg [1:0] state;   // 0:num1 1:num2 2:result
    reg [1:0] op;      // 00:+ 01:- 10:* 11:/

    /* ===== Input BCD ===== */
    reg [3:0] num1 [0:5];
    reg [3:0] num2 [0:5];
    reg [2:0] len1, len2;

    /* ===== Binary ===== */
    reg [19:0] bin1, bin2;
    reg [39:0] bin_ans;

    /* ===== Result BCD ===== */
    reg [3:0] bcd_ans [0:12];
    reg [39:0] tmp;

    /* ===== Scroll Result ==== */
    reg [7:0] cnt;
    reg scroll_tick;
    reg [3:0] scroll_pos;  // 0～12

    always @(posedge clk or posedge SW[0]) begin
        if (SW[0]) begin
            cnt <= 0;
            scroll_tick <= 1'b0;
            scroll_pos <= 4'd7;
        end
        else if(state == 2) begin
            if (cnt == 8'd30) begin
                cnt <= 0;
                scroll_tick <= 1'b1;
            end
            else begin
                cnt <= cnt + 1'b1;
                scroll_tick <= 1'b0;
            end
            if (scroll_tick) begin
                scroll_tick <= 1'b0;
                if (scroll_pos == 0)
                    scroll_pos <= 4'd12;
                else
                    scroll_pos <= scroll_pos - 1'b1;
            end
        end
        else begin
            cnt <= 0;
            scroll_tick <= 1'b0;
            scroll_pos <= 4'd7;
        end
    end

    /* ===== Reset & Input ===== */
    always @(posedge clk or posedge SW[0]) begin
        if (SW[0]) begin
            state <= 0;
            op    <= 0;
            len1  <= 0;
            len2  <= 0;
            bin_ans <= 0;

            num1[0]<=0; num1[1]<=0; num1[2]<=0;
            num1[3]<=0; num1[4]<=0; num1[5]<=0;
            num2[0]<=0; num2[1]<=0; num2[2]<=0;
            num2[3]<=0; num2[4]<=0; num2[5]<=0;
        end
        else if (pushed && !pushed_d) begin
            if (key_val <= 9) begin
                if (state==0 && len1<6) begin
                    num1[5] <= num1[4];
                    num1[4] <= num1[3];
                    num1[3] <= num1[2];
                    num1[2] <= num1[1];
                    num1[1] <= num1[0];
                    num1[0] <= key_val;
                    len1 <= len1 + 1'b1;
                end
                else if (state==1 && len2<6) begin
                    num2[5] <= num2[4];
                    num2[4] <= num2[3];
                    num2[3] <= num2[2];
                    num2[2] <= num2[1];
                    num2[1] <= num2[0];
                    num2[0] <= key_val;
                    len2 <= len2 + 1'b1;
                end
            end
            else begin
                case (key_val)
                    4'hA: begin op<=2'b00; state<=1; len2<=0; end
                    4'hB: begin op<=2'b01; state<=1; len2<=0; end
                    4'hC: begin op<=2'b10; state<=1; len2<=0; end
                    4'hD: begin op<=2'b11; state<=1; len2<=0; end
                    4'hE: begin
                        state <= 0;
                        op    <= 0;
                        len1  <= 0;
                        len2  <= 0;
                        bin_ans <= 0;

                        num1[0]<=0; num1[1]<=0; num1[2]<=0;
                        num1[3]<=0; num1[4]<=0; num1[5]<=0;
                        num2[0]<=0; num2[1]<=0; num2[2]<=0;
                        num2[3]<=0; num2[4]<=0; num2[5]<=0;
                    end
                    4'hF: begin
                        state <= 2;
                        case (op)
                            2'b00: bin_ans <= bin1 + bin2;
                            2'b01: bin_ans <= (bin1>=bin2)?(bin1-bin2):0;
                            2'b10: bin_ans <= bin1 * bin2;
                            2'b11: bin_ans <= (bin2!=0)?(bin1/bin2):0;
                        endcase
                    end
                endcase
            end
        end
    end

    /* ===== BCD -> BIN ===== */
    always @(*) begin
        bin1 =
            (((((num1[5]*10 + num1[4])*10 + num1[3])*10
              + num1[2])*10 + num1[1])*10 + num1[0]);

        bin2 =
            (((((num2[5]*10 + num2[4])*10 + num2[3])*10
              + num2[2])*10 + num2[1])*10 + num2[0]);
    end

    /* ===== BIN -> BCD（10進分解） ===== */
    always @(*) begin
        tmp = bin_ans;

        bcd_ans[0]  = tmp % 10;  tmp = tmp / 10;
        bcd_ans[1]  = tmp % 10;  tmp = tmp / 10;
        bcd_ans[2]  = tmp % 10;  tmp = tmp / 10;
        bcd_ans[3]  = tmp % 10;  tmp = tmp / 10;
        bcd_ans[4]  = tmp % 10;  tmp = tmp / 10;
        bcd_ans[5]  = tmp % 10;  tmp = tmp / 10;
        bcd_ans[6]  = tmp % 10;  tmp = tmp / 10;
        bcd_ans[7]  = tmp % 10;  tmp = tmp / 10;
        bcd_ans[8]  = tmp % 10;  tmp = tmp / 10;
        bcd_ans[9]  = tmp % 10;  tmp = tmp / 10;
        bcd_ans[10] = tmp % 10;  tmp = tmp / 10;
        bcd_ans[11] = tmp % 10;
        bcd_ans[12] = 4'hF; // Blank
    end

    /* ===== Display select ===== */
    reg  [3:0] d0, d1, d2, d3, d4, d5;

    always @(*) begin
        d0 = 4'hF;
        d1 = 4'hF;
        d2 = 4'hF;
        d3 = 4'hF;
        d4 = 4'hF;
        d5 = 4'hF;
        if (state < 2) begin
            if (state == 0) begin
                d0 = (len1>0)?num1[0]:4'hf;
                d1 = (len1>1)?num1[1]:4'hf;
                d2 = (len1>2)?num1[2]:4'hf;
                d3 = (len1>3)?num1[3]:4'hf;
                d4 = (len1>4)?num1[4]:4'hf;
                d5 = (len1>5)?num1[5]:4'hf;
            end
            else if (state == 1) begin
                d0 = (len2>0)?num2[0]:4'hf;
                d1 = (len2>1)?num2[1]:4'hf;
                d2 = (len2>2)?num2[2]:4'hf;
                d3 = (len2>3)?num2[3]:4'hf;
                d4 = (len2>4)?num2[4]:4'hf;
                d5 = (len2>5)?num2[5]:4'hf;
            end
        end
        else if (state == 2) begin
            d0 = bcd_ans[(scroll_pos+0)%13];
            d1 = bcd_ans[(scroll_pos+1)%13];
            d2 = bcd_ans[(scroll_pos+2)%13];
            d3 = bcd_ans[(scroll_pos+3)%13];
            d4 = bcd_ans[(scroll_pos+4)%13];
            d5 = bcd_ans[(scroll_pos+5)%13];
            //d5 = scroll_pos;
        end
    end

    /* ===== 7seg ===== */
    m_7segment s0(d0, HEX0);
    m_7segment s1(d1, HEX1);
    m_7segment s2(d2, HEX2);
    m_7segment s3(d3, HEX3);
    m_7segment s4(d4, HEX4);
    m_7segment s5(d5, HEX5);

    assign LED = {5'd0, scroll_tick, op, state};

endmodule
