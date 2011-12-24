module pll(clk_18m, rst, clk_28m);
	output clk_18m;
	input rst, clk_28m;

	altpll altpll_u(.clk(clk_18m), .areset(rst), .inclk(clk_28m));

	defparam
		altpll_u.clk0_divide_by = 3,
		altpll_u.clk0_multiply_by = 2,

		altpll_u.operation_mode = "NORMAL",
//		altpll_u.inclk0_input_frequency = 20000; /* 50MHz */
		altpll_u.inclk0_input_frequency = 37037; /* 27MHz */
endmodule
