module aud(aud_data, aud_lrck, aud_bck, rst, smpl, clk);
	output aud_data;
	output reg aud_lrck;
	output reg aud_bck;
	input rst;
	input [15:0] smpl;
	input clk;

	parameter REF_CLK = 18_432_000; /* 18.432MHz */
	parameter SMPL_RATE = 48000;
	parameter SMPL_SIZE = 16;
	parameter CHANS = 2;

	reg [7:0] lrck_cnt;
	reg [2:0] bck_cnt;
	reg [3:0] smpl_bit;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			lrck_cnt <= 0;
			aud_lrck <= 0;

		end else begin
			lrck_cnt = lrck_cnt + 1;
			if (lrck_cnt == REF_CLK/(SMPL_RATE*2)) begin
				lrck_cnt <= 0;

				aud_lrck <= ~aud_lrck;
			end
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			bck_cnt <= 0;
			aud_bck <= 0;

		end else begin
			bck_cnt = bck_cnt + 1;
			if (bck_cnt == REF_CLK/(SMPL_RATE*SMPL_SIZE*CHANS*2)) begin
				bck_cnt <= 0;

				aud_bck <= ~aud_bck;
			end
		end
	end

	always @(negedge aud_bck or posedge rst) begin
		if (rst) begin
			smpl_bit <= 0;

		end else begin
			smpl_bit <= smpl_bit + 1;
		end
	end

	assign aud_data = smpl[~smpl_bit];
endmodule
