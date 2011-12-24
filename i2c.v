module i2c(i2c_sclk, i2c_sdat, i2c_done, rst, clk_50m);
	output i2c_sclk;
	inout i2c_sdat;
	output i2c_done;
	input rst, clk_50m;

	parameter REF_CLK = 50_000_000;
	parameter I2C_CLK = 10_000;

	reg i2c_clk;
	reg [14:0] i2c_cnt;

	reg [1:0] st;
	reg [15:0] cmd;
	reg [3:0] cmd_idx;

	wire done, ack;
	reg go;
	reg [23:0] data;

	always @(posedge clk_50m or posedge rst) begin
		if (rst) begin
			i2c_clk <= 1;
			i2c_cnt <= 0;

		end else begin
			i2c_cnt = i2c_cnt + 1;
			if (i2c_cnt == REF_CLK/(I2C_CLK*2)) begin
				i2c_cnt <= 0;

				i2c_clk <= ~i2c_clk;
			end
		end
	end

	always @(posedge i2c_clk or posedge rst) begin
		if (rst) begin
			cmd_idx <= 0;

		end else if (~i2c_done) begin
			case (st)
				0: begin data <= {8'h34, cmd}; go <= 1; st <= 1; end
				1: begin if (done) begin go <= 0; st <= ack ? 0 : 2; end end
				2: begin cmd_idx <= cmd_idx + 1; st <= 0; end
			endcase
		end
	end

	parameter CMD_CNT = 10;

	always @(cmd_idx) begin
		case (cmd_idx)
			0: cmd <= 16'h0017; /* left line in (volume: 0dB) */
			1: cmd <= 16'h0217; /* right line in (volume: 0dB) */
			2: cmd <= 16'h0479; /* left headphone out (volume: 0dB) */
			3: cmd <= 16'h0679; /* right headphone out (volume: 0dB) */
			4: cmd <= 16'h08F8; /* analogue audio path */
			5: cmd <= 16'h0A06; /* digital audio path (de-emphasis: 48kHz) */
			6: cmd <= 16'h0C00; /* power down (nothing) */
			7: cmd <= 16'h0E01; /* audio format (I2S, MSB-first, left-justified, 16-bit) */
			8: cmd <= 16'h1002; /* sampling (oversampling rate: 384fs) */
			9: cmd <= 16'h1201; /* active */
			default: cmd <= 16'hxxxx;
		endcase
	end

	i2c_ctrl i2c_ctrl_u(i2c_sclk, i2c_sdat, done, ack, rst, go, data, i2c_clk);

	assign i2c_done = cmd_idx == CMD_CNT;
endmodule
