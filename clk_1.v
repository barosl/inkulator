module clk_1(clk, rst, clk_50m);
	output clk;
	input rst;
	input clk_50m;

	reg [25:0] cnt;
	reg clk;

	always @(posedge clk_50m or posedge rst) begin
		if (rst) begin
			cnt <= 0;
			clk <= 1;

		end else begin
			cnt = cnt + 1;
			if (cnt == 25_000_000) begin
				cnt <= 0;

				clk <= ~clk;
			end
		end
	end
endmodule
