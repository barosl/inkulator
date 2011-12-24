module midi(smpl, rst, freq, clk);
	output [15:0] smpl;
	input rst;
	input [14:0] freq;
	input clk;

	reg [15:0] ramp;

	always @(negedge clk or posedge rst) begin
		if (rst) begin
			ramp <= 0;
		end else begin
			ramp <= ramp + freq;
		end
	end

	midi_fnt midi_fnt_u(smpl, ramp[15:10]);
endmodule
