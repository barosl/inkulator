module main(swits, butts, leds, seseg0, seseg1, seseg2, clk_50m, lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_bl_on, vga_r, vga_g, vga_b, vga_hs, vga_vs, vga_clk, vga_blank, vga_sync, uart_rxd, uart_txd);
	input [17:0] swits;
	input [3:0] butts;
	output [17:0] leds;
	output [6:0] seseg0, seseg1, seseg2;
	input clk_50m;
	inout [7:0] lcd_data;
	output lcd_rw;
	output lcd_en;
	output lcd_rs;
	output lcd_on;
	output lcd_bl_on;
	output [9:0] vga_r, vga_g, vga_b;
	output vga_hs, vga_vs;
	output vga_clk, vga_blank, vga_sync;
	input uart_rxd;
	output uart_txd;

	/* Debugging output */

	wire [3:0] debug;

	seseg u_seseg0(seseg0, debug);
	seseg u_seseg1(seseg1, vga_hs);
	seseg u_seseg2(seseg2, vga_vs);

	/* 25MHz clock */

	reg clk_25m;

	always @(posedge clk_50m or posedge rst) begin
		if (rst) begin
			clk_25m <= 0;
		end else begin
			clk_25m <= ~clk_25m;
		end
	end

	/* VGA module */

	reg [7:0] r, g, b;
	wire [9:0] x, y;

	parameter border_w = 100;

	always @(x or y) begin
		r = 0;
		g = (((x < border_w) | (x >= 640-border_w)) & ((y < border_w) | (y >= 480-border_w))) ? 255 : 0;
		b = 0;

		if ((y >= 200) & (y < 200+100)) begin
			r = 0;
			g = 0;
			b = 2 * 1024 * x / 640;
		end
	end

	vga u_vga(vga_r, vga_g, vga_b, vga_hs, vga_vs, vga_clk, vga_blank, x, y, rst, r, g, b, clk_25m);

	/* UART module */

	wire tx_rdy, rx_rdy;
	reg tx_en;
	reg [7:0] tx_data;
	wire [7:0] rx_data;

	reg [3:0] i;
	reg [1:0] st;
	reg [7:0] text[14:0];

	always @(posedge clk_50m or posedge rst) begin
		if (rst) begin
			i <= 0;
			st <= 0;

			text[0] <= "H";
			text[1] <= "e";
			text[2] <= "l";
			text[3] <= "l";
			text[4] <= "o";
			text[5] <= ",";
			text[6] <= " ";
			text[7] <= "w";
			text[8] <= "o";
			text[9] <= "r";
			text[10] <= "l";
			text[11] <= "d";
			text[12] <= "!";
			text[13] <= "\r";
			text[14] <= "\n";

		end else begin
			case (st)
				0:
					if (tx_rdy) begin
						if (i < 14+1) begin
							tx_en <= 1;
							tx_data <= text[i];
							i <= i + 1;
							st <= 1;
						end else if (rx_rdy) begin
							tx_en <= 1;
							tx_data <= rx_data;
							st <= 1;
						end
					end
				1: if (~tx_rdy) begin tx_en <= 0; st <= 0; end
			endcase
		end
	end

	uart u_uart(uart_txd, uart_rxd, tx_rdy, rx_rdy, rst, tx_en, tx_data, rx_data, clk_50m);

	/* Input signals */

	assign rst = ~butts[0];
endmodule
