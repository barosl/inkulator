module uart(uart_txd, uart_rxd, tx_rdy, rx_rdy, rst, tx_en, tx_data, rx_data, clk_50m);
	output reg uart_txd;
	input uart_rxd;
	output tx_rdy, rx_rdy;
	input rst;
	input tx_en;
	input [7:0] tx_data;
	output [7:0] rx_data;
	input clk_50m;

	parameter TX_CLKS = 434; /* (1./115200)/(1./50/1000/1000) */
	parameter TX_DATA_BW = 8;

	reg [8:0] tx_clks;
	reg [3:0] tx_st;
	reg [7:0] tx_data0;

	always @(posedge clk_50m or posedge rst) begin
		if (rst) begin
			tx_clks <= 0;
			tx_st <= 0;
			uart_txd <= 1;

		end else if (tx_st) begin
			tx_clks = tx_clks + 1;
			if (tx_clks == TX_CLKS) begin
				tx_clks = 0;

				case (tx_st)
					1: uart_txd <= 1;
					2: uart_txd <= 0;
					3+TX_DATA_BW: uart_txd <= 1;
					default: uart_txd <= tx_data0[tx_st-3];
				endcase

				tx_st = (tx_st+1) % (4+TX_DATA_BW);
			end

		end else if (tx_en) begin
			tx_data0 <= tx_data;
			tx_st <= 1;
		end
	end

	assign tx_rdy = !tx_st;
	assign rx_rdy = 0;
endmodule
