// 1/50000000 PreScaler (for 50 MHz input -> 1 Hz)
module m_prescale50M(input clk, output c_out);
	reg [25:0] cnt;
	wire wcout;
	
	assign wcout = (cnt == 26'd49999999) ? 1'b1 : 1'b0;
	assign c_out = wcout;
	
	always @(posedge clk) begin
		if (wcout)
			cnt <= 26'd0;
		else
			cnt <= cnt + 26'd1;
	end
endmodule

// 1/5000000 PreScaler (for 50 MHz input -> 10 Hz)
module m_prescale5M(input clk,output c_out);
	reg [22:0] cnt;
	wire wcout;
	
	assign wcout=(cnt==23'd4999999) ? 1'b1 : 1'b0;
	assign c_out=wcout;
	
	always @(posedge clk) begin
		if(wcout==1'b1)
			cnt=0;
		else
			cnt=cnt+1;
	end
endmodule

module m_prescale_50M_60Hz(input clk,output c_out);
	reg [20:0] cnt;
	wire wcout;
	
	assign wcout=(cnt==21'd833333) ? 1'b1 : 1'b0;
	assign c_out=wcout;
	
	always @(posedge clk) begin
		if(wcout==1'b1)
			cnt=0;
		else
			cnt=cnt+1;
	end
endmodule

module m_prescale_50M_3600Hz(input clk, output c_out);
	reg [16:0] cnt;
	wire wcout;
	
	assign wcout=(cnt==17'd138888) ? 1'b1 : 1'b0;
	assign c_out=wcout;
	
	always @(posedge clk) begin
		if(wcout==1'b1)
			cnt=0;
		else
			cnt=cnt+1;
	end
endmodule

module m_timer_decoder(input [3:0] dcnt, output [9:0] wsec);
	assign wsec[0]=(dcnt==4'd0) ? 1'b1 : 1'b0;
	assign wsec[1]=(dcnt==4'd1) ? 1'b1 : 1'b0;
	assign wsec[2]=(dcnt==4'd2) ? 1'b1 : 1'b0;
	assign wsec[3]=(dcnt==4'd3) ? 1'b1 : 1'b0;
	assign wsec[4]=(dcnt==4'd4) ? 1'b1 : 1'b0;
	assign wsec[5]=(dcnt==4'd5) ? 1'b1 : 1'b0;
	assign wsec[6]=(dcnt==4'd6) ? 1'b1 : 1'b0;
	assign wsec[7]=(dcnt==4'd7) ? 1'b1 : 1'b0;
	assign wsec[8]=(dcnt==4'd8) ? 1'b1 : 1'b0;
	assign wsec[9]=(dcnt==4'd9) ? 1'b1 : 1'b0;
endmodule
