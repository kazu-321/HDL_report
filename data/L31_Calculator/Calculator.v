//演算回路（bit加算器）
module m_calculator(in1, in2, out);
	input	 [3:0] in1,in2;
	output [7:0] out;
	
	assign out = in1 + in2;
	
endmodule
