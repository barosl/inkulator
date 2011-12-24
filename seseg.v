module seseg(seseg, num);
	output reg [6:0] seseg;
	input [3:0] num;

	always @(num) begin
		case (num)
			0: seseg = 7'b1000000;
			1: seseg = 7'b1111001;
			2: seseg = 7'b0100100;
			3: seseg = 7'b0110000;
			4: seseg = 7'b0011001;
			5: seseg = 7'b0010010;
			6: seseg = 7'b0000010;
			7: seseg = 7'b1011000;
			8: seseg = 7'b0000000;
			9: seseg = 7'b0010000;
			10: seseg = 7'b0001000;
			11: seseg = 7'b0000011;
			12: seseg = 7'b1000110;
			13: seseg = 7'b0100001;
			14: seseg = 7'b0000110;
			15: seseg = 7'b0001110;
			default: seseg = 7'b1111111;
		endcase
	end
endmodule
