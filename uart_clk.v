module uart_clk(tx_clk, rx_clk, rst, clk_50m);
	output reg tx_clk, rx_clk;
	input rst, clk_50m;

	reg [8:0] cnt;

	parameter CLKS_PER_BIT = 434; /* (1./115200)/(1./50/1000/1000) */

	always @(posedge clk_50m or posedge rst) begin
		if (rst) begin
			cnt <= 0;
			tx_clk <= 0;
			rx_clk <= 0;

		end else begin
			cnt = (cnt + 1) % CLKS_PER_BIT;

			if ((cnt == 0) | (cnt == CLKS_PER_BIT/2)) tx_clk = ~tx_clk;
			if ((cnt == 0) | (cnt == CLKS_PER_BIT/4) | (cnt == CLKS_PER_BIT/2) | (cnt == CLKS_PER_BIT*3/4)) rx_clk = ~rx_clk;
		end
	end
endmodule
