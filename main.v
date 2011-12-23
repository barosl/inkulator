module main(swits, butts, leds, seseg0, seseg1, seseg2, clk_50m, lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_bl_on, vga_r, vga_g, vga_b, vga_hs, vga_vs, vga_clk, vga_blank, vga_sync);
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

	/* Debugging output */

	reg [3:0] num;

	always @(posedge rst) begin
		num <= 0;
	end

	seseg u_seseg0(seseg0, num);
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

	/* Input signals */

	assign rst = ~butts[0];
endmodule
