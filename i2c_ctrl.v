module i2c_ctrl(i2c_sclk, i2c_sdat, done, ack, rst, go, data, clk);
	output i2c_sclk;
	inout i2c_sdat;
	output reg done;
	output ack;
	input rst, go;
	input [23:0] data;
	input clk;

	reg sclk;
	reg sdat;
	reg [23:0] data0;
	reg [5:0] st;
	reg [2:0] acks;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			sclk <= 1;
			sdat <= 1;
			st <= 0;
			done <= 1;

		end else begin
			case (st)
				/* reset */
				0: begin sclk <= 1; sdat <= 1; done = 0; end

				/* start */
				1: begin sdat <= 0; data0 = data; end
				2: sclk <= 0;

				/* slave address */
				3: sdat <= data0[23];
				4: sdat <= data0[22];
				5: sdat <= data0[21];
				6: sdat <= data0[20];
				7: sdat <= data0[19];
				8: sdat <= data0[18];
				9: sdat <= data0[17];
				10: sdat <= data0[16];
				11: sdat <= 1;

				/* register address */
				12: begin sdat <= data0[15]; acks[0] <= i2c_sdat; end
				13: sdat <= data0[14];
				14: sdat <= data0[13];
				15: sdat <= data0[12];
				16: sdat <= data0[11];
				17: sdat <= data0[10];
				18: sdat <= data0[9];
				19: sdat <= data0[8];
				20: sdat <= 1;

				/* data */
				21: begin sdat <= data0[7]; acks[1] <= i2c_sdat; end
				22: sdat <= data0[6];
				23: sdat <= data0[5];
				24: sdat <= data0[4];
				25: sdat <= data0[3];
				26: sdat <= data0[2];
				27: sdat <= data0[1];
				28: sdat <= data0[0];
				29: sdat <= 1;

				/* stop */
				30: begin sdat <= 0; sclk <= 0; acks[2] <= i2c_sdat; end
				31: sclk <= 1;
				32: begin sdat <= 1; done <= 1; end
			endcase

			if (go) st = (st + 1) % 33;
		end
	end

	assign i2c_sclk = ((st >= 4) & (st <= 30)) ? ~clk : sclk;
	assign i2c_sdat = sdat ? 1'bz : 0;
	assign ack = |acks;
endmodule
