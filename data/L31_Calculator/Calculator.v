// 4桁BCD加算器（最大4桁 + 4桁）
module m_calculator (
    input  [3:0] a0, a1, a2, a3,   // 1の位〜1000の位
    input  [3:0] b0, b1, b2, b3,
    output reg [3:0] s0, s1, s2, s3, s4 // 結果（最大5桁）
);

    reg [4:0] t0, t1, t2, t3;

    // 1の位
    always @(*) begin
        t0 = a0 + b0;
        if (t0 >= 10) begin
            s0 = t0 - 10;
            t1 = a1 + b1 + 1;
        end else begin
            s0 = t0;
            t1 = a1 + b1;
        end

        // 10の位
        if (t1 >= 10) begin
            s1 = t1 - 10;
            t2 = a2 + b2 + 1;
        end else begin
            s1 = t1;
            t2 = a2 + b2;
        end

        // 100の位
        if (t2 >= 10) begin
            s2 = t2 - 10;
            t3 = a3 + b3 + 1;
        end else begin
            s2 = t2;
            t3 = a3 + b3;
        end

        // 1000の位
        if (t3 >= 10) begin
            s3 = t3 - 10;
            s4 = 4'd1;
        end else begin
            s3 = t3;
            s4 = 4'd0;
        end
    end

endmodule
