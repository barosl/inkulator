module vga(vga_r, vga_g, vga_b, vga_hs, vga_vs, vga_clk, vga_blank, x, y, rst, r, g, b, clk_25m);
	output [9:0] vga_r, vga_g, vga_b;
	output vga_hs, vga_vs, vga_clk, vga_blank;
	output reg [9:0] x, y;
	input rst;
	input [7:0] r, g, b;
	input clk_25m;

	parameter H_ACT = 640;
	parameter H_FRNT = 16;
	parameter H_SYNC = 96;
	parameter H_BCK = 48;

	parameter V_ACT = 480;
	parameter V_FRNT = 11;
	parameter V_SYNC = 2;
	parameter V_BCK = 31;

	reg [9:0] h_cnt;
	reg [9:0] v_cnt;

	always @(posedge clk_25m or posedge rst) begin
		if (rst) begin
			h_cnt <= 0;
			v_cnt <= 0;

			x <= 0;
			y <= 0;
		end else begin
			h_cnt <= h_cnt + 1;
			x <= x + 1;
			if (h_cnt == H_ACT+H_FRNT+H_SYNC+H_BCK) begin
				h_cnt <= 0;
				v_cnt <= v_cnt + 1;

				x <= 0;
				y <= y + 1;
			end

			if (v_cnt == V_ACT+V_FRNT+V_SYNC+V_BCK) begin
				v_cnt <= 0;

				y <= 0;
			end
		end
	end

	assign vga_r = {r, 2'b00};
	assign vga_g = {g, 2'b00};
	assign vga_b = {b, 2'b00};
	assign vga_hs = ~((h_cnt >= H_ACT+H_FRNT) & (h_cnt < H_ACT+H_FRNT+H_SYNC));
	assign vga_vs = ~((v_cnt >= V_ACT+V_FRNT) & (v_cnt < V_ACT+V_FRNT+V_SYNC));
	assign vga_clk = ~clk_25m;
	assign vga_blank = (h_cnt < H_ACT) & (v_cnt < 480);
endmodule
