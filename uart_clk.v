module uart_clk(tx_clk, rx_clk, rst, clk_50m);
	output reg tx_clk, rx_clk;
	input rst, clk_50m;

	parameter CLKS_PER_BIT = 434; /* (1./115200)/(1./50/1000/1000) */

	reg [8:0] cnt;

	always @(posedge clk_50m or posedge rst) begin
		if (rst) begin
			cnt <= 0;
			tx_clk <= 1;
			rx_clk <= 1;

		end else begin
			cnt = (cnt + 1) % CLKS_PER_BIT;

			if ((cnt == 0) | (cnt == CLKS_PER_BIT/2)) tx_clk <= ~tx_clk;

			/* 16x oversampling */
			if (cnt % (CLKS_PER_BIT/32) == 0) rx_clk <= ~rx_clk;
		end
	end
endmodule
