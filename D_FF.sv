`timescale 1ns/10ps
module D_FF (clk, reset, q, d);
	output reg q;
	input d, reset, clk;
	
	always_ff @(posedge clk) begin
		if(reset)
			q <= 0;
		else
			q <= d;
	end
endmodule



module D_FF_en (clk, enable, reset, q, d);
	input logic clk, enable, d, reset;
	output logic q;
	
	logic out;
	mux2_1 findResult (.out(out), .i({d, q}), .sel(enable));
	D_FF update (.clk(clk), .reset(reset), .q(q), .d(out));
	
endmodule

module D_FF_3 (clk, reset, q, d);
	input logic clk, reset;
	input logic [2:0] d;
	output logic [2:0] q;
	
	genvar i;
	generate
		for(i = 0; i < 3; i++) begin: findResult
			D_FF update (.clk(clk), .reset(reset), .q(q[i]), .d(d[i]));
		end
	endgenerate
	
endmodule


module D_FF_5 (clk, reset, q, d);
	input logic clk, reset;
	input logic [4:0] d;
	output logic [4:0] q;
	
	genvar i;
	generate
		for(i = 0; i < 5; i++) begin: findResult
			D_FF update (.clk(clk), .reset(reset), .q(q[i]), .d(d[i]));
		end
	endgenerate
	
endmodule

module D_FF_32 (clk, reset, q, d);
	input logic clk, reset;
	input logic [31:0] d;
	output logic [31:0] q;
	
	genvar i;
	generate
		for(i = 0; i < 32; i++) begin: findResult
			D_FF update (.clk(clk), .reset(reset), .q(q[i]), .d(d[i]));
		end
	endgenerate
	
endmodule

module D_FF_64 (clk, reset, q, d);
	input logic clk, reset;
	input logic [63:0] d;
	output logic [63:0] q;
	
	genvar i;
	generate
		for(i = 0; i < 64; i++) begin: findResult
			D_FF update (.clk(clk), .reset(reset), .q(q[i]), .d(d[i]));
		end
	endgenerate
endmodule

module D_FF_en_64 (clk, enable, reset, q, d);
	input logic clk, enable, reset;
	input logic [63:0] d;
	output logic [63:0] q;
	
	genvar i;
	generate
		for(i = 0; i < 64; i++) begin: findResult
			D_FF_en update (.clk(clk), .enable(enable), .reset(reset), .q(q[i]), .d(d[i]));
		end
	endgenerate
endmodule


