module uart(uart_txd, uart_rxd, tx_rdy, rx_rdy, rst, tx_en, tx_data, rx_data, clk_50m);
	output reg uart_txd;
	input uart_rxd;
	output tx_rdy;
	output reg rx_rdy;
	input rst;
	input tx_en;
	input [7:0] tx_data;
	output reg [7:0] rx_data;
	input clk_50m;

	parameter DATA_BW = 8;

	reg [3:0] tx_st;
	reg [7:0] tx_data0;
	reg [4:0] rx_st;

	always @(posedge tx_clk or posedge rst) begin
		if (rst) begin
			tx_st <= 0;
			uart_txd <= 1;

		end else if (tx_st) begin
			case (tx_st)
				DATA_BW+1: uart_txd <= 1;
				default: uart_txd <= tx_data0[tx_st-1];
			endcase

			tx_st = (tx_st+1) % (DATA_BW+2);

		end else if (tx_en) begin
			tx_data0 <= tx_data;
			tx_st <= 1;

			uart_txd <= 0;
		end
	end

	always @(posedge rx_clk or posedge rst) begin
		if (rst) begin
			rx_st <= 0;
			rx_rdy = 0;

		end else if (rx_st) begin
			casex (rx_st)
				1:;
				DATA_BW*2+2: if (uart_rxd == 1) rx_rdy = 1;
				2'bx0: rx_data[rx_st/2-1] <= uart_rxd;
			endcase

			rx_st = (rx_st+1) % (DATA_BW*2+3);

		end else begin
			rx_rdy = 0;

			if (uart_rxd == 0) begin
				rx_st = 1;
			end
		end
	end

	uart_clk uart_clk_u(tx_clk, rx_clk, rst, clk_50m);

	assign tx_rdy = !tx_st;
endmodule
