module main(swits, butts, leds, seseg0, seseg1, seseg2, clk_50m, clk_27m, clk_28_63m, td1_rst_n, lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_bl_on, vga_r, vga_g, vga_b, vga_hs, vga_vs, vga_clk, vga_blank_n, uart_rxd, uart_txd, aud_adc_lrck, aud_adc_dat, aud_dac_dat, aud_dac_lrck, aud_bck, aud_xck, i2c_sclk, i2c_sdat);
	input [17:0] swits;
	input [3:0] butts;
	output [17:0] leds;
	output [6:0] seseg0, seseg1, seseg2;
	input clk_50m, clk_27m, clk_28_63m;
	output td1_rst_n;
	inout [7:0] lcd_data;
	output lcd_rw;
	output lcd_en;
	output lcd_rs;
	output lcd_on;
	output lcd_bl_on;
	output [9:0] vga_r, vga_g, vga_b;
	output vga_hs, vga_vs, vga_clk, vga_blank_n;
	input uart_rxd;
	output uart_txd;
	input aud_adc_dat;
	output aud_dac_dat, aud_xck;
	inout aud_adc_lrck, aud_dac_lrck, aud_bck;
	output i2c_sclk;
	inout i2c_sdat;

	/* initialize */

	assign td1_rst_n = 1; /* for clk_27m */

	/* debugging output */

	wire [3:0] debug[3];

	seseg seseg_u0(seseg0, debug[0]);
	seseg seseg_u1(seseg1, debug[1]);
	seseg seseg_u2(seseg2, debug[2]);

	assign debug[1] = vga_hs;
	assign debug[2] = vga_vs;

	/* 25MHz clock */

	reg clk_25m;

	always @(posedge clk_50m or posedge rst) begin
		if (rst) begin
			clk_25m <= 0;
		end else begin
			clk_25m <= ~clk_25m;
		end
	end

	/* 18MHz clock (phase-locked loop) */

	wire clk_18m;

	pll(clk_18m, ~done, clk_27m);

	/* 1Hz clock */

	wire clk_1;

	clk_1 clk_1_u(clk_1, rst, clk_50m);

	/* VGA module */

	reg [7:0] r, g, b;
	wire [9:0] x, y;

	parameter BORDER_W = 100;

	always @(x or y) begin
		r = 0;
		g = (((x < BORDER_W) | (x >= 640-BORDER_W)) & ((y < BORDER_W) | (y >= 480-BORDER_W))) ? 255 : 0;
		b = 0;

		if ((y >= 200) & (y < 200+100)) begin
			r = 0;
			g = 0;
			b = 2 * 1024 * x / 640;
		end
	end

	vga vga_u(vga_r, vga_g, vga_b, vga_hs, vga_vs, vga_clk, vga_blank_n, x, y, rst, r, g, b, clk_25m);

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

	uart uart_u(uart_txd, uart_rxd, tx_rdy, rx_rdy, rst, tx_en, tx_data, rx_data, clk_50m);

	/* audio module */

	wire i2c_done;
	wire [15:0] smpl;

	i2c i2c_u(i2c_sclk, i2c_sdat, i2c_done, rst, clk_50m);
	aud aud_u(aud_dac_dat, aud_dac_lrck, aud_bck, rst, smpl, aud_xck);
	midi midi_u(smpl, rst, note, aud_dac_lrck);

	reg [14:0] note;
	reg [2:0] note_idx;

	always @(posedge clk_1 or posedge rst) begin
		if (rst) begin
			note_idx = 0;
		end else begin
			note_idx = (note_idx + 1) % 8;
		end
	end

	always @(note_idx) begin
		case (note_idx)
			0: note = 261;
			1: note = 293;
			2: note = 329;
			3: note = 349;
			4: note = 391;
			5: note = 440;
			6: note = 493;
			7: note = 523;
			default: note = 440;
		endcase
	end

	assign aud_xck = clk_18m;

	/* input signals */

	assign rst = ~butts[0];
	assign done = i2c_done;
endmodule
