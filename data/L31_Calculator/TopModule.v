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
    wire tc;
    reg  pushed_d;

    m_prescale      u0 (CLK1, clk);
    m_matrix_key    u1 (clk, SW[0], KEY_ROW, KEY_COL, key_raw, tc);
    m_dec16to4_calc u2 (key_raw, key_val, pushed);

    always @(posedge clk) pushed_d <= pushed;

    /* ===== State ===== */
    // state: 0=num1 1=num2 2=result
    reg [1:0] state;
    // op: 00:+ 01:- 10:* 11:/
    reg [1:0] op;

    /* ===== Input BCD ===== */
    reg [3:0] num1 [0:5];
    reg [3:0] num2 [0:5];
    reg [2:0] len1, len2;

    /* ===== Binary ===== */
    reg [19:0] bin1, bin2;
    reg [39:0] bin_ans;

    /* ===== Result BCD ===== */
    reg [3:0] bcd_ans [0:11];

    /* ===== Reset & Input ===== */
    integer i;
    always @(posedge clk or posedge SW[0]) begin
        if (SW[0]) begin
            state <= 0;
            op    <= 0;
            len1  <= 0;
            len2  <= 0;
            bin_ans <= 0;
            for (i=0;i<6;i=i+1) begin
                num1[i] <= 0;
                num2[i] <= 0;
            end
        end
        else if (pushed && !pushed_d) begin
            if (key_val <= 9) begin
                if (state==0 && len1<6) begin
                    num1[len1] <= key_val;
                    len1 <= len1 + 1;
                end
                else if (state==1 && len2<6) begin
                    num2[len2] <= key_val;
                    len2 <= len2 + 1;
                end
            end
            else begin
                case (key_val)
                    4'hA: begin op<=2'b00; state<=1; len2<=0; end // +
                    4'hB: begin op<=2'b01; state<=1; len2<=0; end // -
                    4'hC: begin op<=2'b10; state<=1; len2<=0; end // *
                    4'hD: begin op<=2'b11; state<=1; len2<=0; end // /
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
        bin1 = 0;
        for (i=len1-1;i>=0;i=i-1)
            bin1 = bin1*10 + num1[i];

        bin2 = 0;
        for (i=len2-1;i>=0;i=i-1)
            bin2 = bin2*10 + num2[i];
    end

    /* ===== BIN -> BCD (Double Dabble) ===== */
    integer j;
    reg [95:0] work;
    always @(*) begin
        work = 0;
        work[39:0] = bin_ans;
        for (i=0;i<40;i=i+1) begin
            for (j=0;j<12;j=j+1)
                if (work[40+j*4 +:4] >= 5)
                    work[40+j*4 +:4] = work[40+j*4 +:4] + 3;
            work = work << 1;
        end
        for (i=0;i<12;i=i+1)
            bcd_ans[i] = work[40+i*4 +:4];
    end

    /* ===== Scroll ===== */
    reg [25:0] cnt;
    reg [3:0] disp_idx;

    always @(posedge clk or posedge SW[0]) begin
        if (SW[0]) begin
            cnt <= 0;
            disp_idx <= 0;
        end
        else if (cnt == 26'd25_000_000) begin
            cnt <= 0;
            disp_idx <= (disp_idx==11)?0:disp_idx+1;
        end
        else cnt <= cnt + 1;
    end

    /* ===== Display source ===== */
    wire [3:0] disp_bcd [0:11];
    genvar g;
    generate
        for (g=0;g<12;g=g+1) begin: DISPSEL
            assign disp_bcd[g] =
                (state==2) ? bcd_ans[g] :
                (state==1 && g<6) ? num2[g] :
                (state==0 && g<6) ? num1[g] :
                4'd0;
        end
    endgenerate

    /* ===== 7seg ===== */
    wire [7:0] dec_pat [0:5];
    m_7segment s0(disp_bcd[disp_idx+0], dec_pat[0]);
    m_7segment s1(disp_bcd[disp_idx+1], dec_pat[1]);
    m_7segment s2(disp_bcd[disp_idx+2], dec_pat[2]);
    m_7segment s3(disp_bcd[disp_idx+3], dec_pat[3]);
    m_7segment s4(disp_bcd[disp_idx+4], dec_pat[4]);
    m_7segment s5(disp_bcd[disp_idx+5], dec_pat[5]);

    assign HEX0 = dec_pat[0];
    assign HEX1 = dec_pat[1];
    assign HEX2 = dec_pat[2];
    assign HEX3 = dec_pat[3];
    assign HEX4 = dec_pat[4];
    assign HEX5 = dec_pat[5];

    assign LED = {6'd0, op, state};

endmodule
