`timescale 1ns/10ps
module D_FF_en (clk, enable, reset, output_q, q, d);
	input logic clk, enable, d, q, reset;
	output logic output_q;
	logic q_;
	
	D_FF findOption1 (.clk(clk), .reset(reset), .q(q_), .d(d));
	
	mux2_1 findResult (.out(output_q), .i({q_, q}), .sel(enable));
endmodule

