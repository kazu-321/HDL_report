module m_seven_segment(input [3:0] idat,output [7:0] odat);

    function [7:0] LedHex;
      input [3:0] num;
      begin
         case (num)
           4'h0:        LedHex = 8'b11000000;  // 0
           4'h1:        LedHex = 8'b11111001;  // 1
           4'h2:        LedHex = 8'b10100100;  // 2
           4'h3:        LedHex = 8'b10110000;  // 3
           4'h4:        LedHex = 8'b10011001;  // 4
           4'h5:        LedHex = 8'b10010010;  // 5
           4'h6:        LedHex = 8'b10000010;  // 6
           4'h7:        LedHex = 8'b11111000;  // 7
           4'h8:        LedHex = 8'b10000000;  // 8
           4'h9:        LedHex = 8'b10011000;  // 9
			  4'ha:        LedHex = 8'b10001000;  // A
			  4'hb:        LedHex = 8'b10000011;  // b
			  4'hc:        LedHex = 8'b11000110;  // C
			  4'hd:        LedHex = 8'b10100001;  // d
			  4'he:        LedHex = 8'b10000110;  // E
			  4'hf:        LedHex = 8'b10001110;  // F
           default:     LedHex = 8'b11111111;  // LED OFF
         endcase
      end 
    endfunction
	
    assign odat = LedHex(idat);

endmodule
