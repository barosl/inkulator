module vga(vga_r, vga_g, vga_b, vga_hs, vga_vs, vga_clk, vga_blank, x, y, rst, r, g, b, clk_25m);
	output [9:0] vga_r, vga_g, vga_b;
	output vga_hs, vga_vs, vga_clk, vga_blank;

	output reg [9:0] x, y;
	input rst;
	input [7:0] r, g, b;
	input clk_25m;

	reg [9:0] h_cnt;
	reg [9:0] v_cnt;

	parameter h_act = 640;
	parameter h_frnt = 16;
	parameter h_sync = 96;
	parameter h_bck = 48;

	parameter v_act = 480;
	parameter v_frnt = 11;
	parameter v_sync = 2;
	parameter v_bck = 31;

	always @(posedge clk_25m or posedge rst) begin
		if (rst) begin
			h_cnt <= 0;
			v_cnt <= 0;

			x <= 0;
			y <= 0;
		end else begin
			h_cnt <= h_cnt + 1;
			x <= x + 1;
			if (h_cnt == h_act+h_frnt+h_sync+h_bck) begin
				h_cnt <= 0;
				v_cnt <= v_cnt + 1;

				x <= 0;
				y <= y + 1;
			end

			if (v_cnt == v_act+v_frnt+v_sync+v_bck) begin
				v_cnt <= 0;

				y <= 0;
			end
		end
	end

	assign vga_r = {r, 2'b00};
	assign vga_g = {g, 2'b00};
	assign vga_b = {b, 2'b00};
	assign vga_hs = ~((h_cnt >= h_act+h_frnt) & (h_cnt < h_act+h_frnt+h_sync));
	assign vga_vs = ~((v_cnt >= v_act+v_frnt) & (v_cnt < v_act+v_frnt+v_sync));
	assign vga_clk = ~clk_25m;
	assign vga_blank = (h_cnt < h_act) & (v_cnt < 480);
endmodule
