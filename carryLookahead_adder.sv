`timescale 1ns/10ps
/* Thu Phan 
	Brian Yu
	EE/CSE 469 Computer Architecture I
	Winter 2018
	Lab 2: 64 bit ARM ALU
*/
// This is a submodule that performs the adder function of the ALU using the carry lookahead method
// which is more efficient in terms of delay time than ripple carry adder.
// Subtract: states whether to do a + b or a - b
// a & b: the two 64 bit operands
// sum: result of adding/subtracting a and b
// Cout: holds the carry_out of the adder
// overflow: tells whether or not there is an overflow
module carryLookahead_adder(subtract, a, b, sum, Cout, overflow);
	input logic subtract;
	input logic [63:0] a, b;
	output logic [63:0] sum;
	output logic Cout, overflow;
	
	logic [64:0] cin;
	logic [63:0] final_b;
	assign Cout = cin[64];
	
	assign overflow = cin[63] ^ Cout;

	genvar i;
	generate
		for (i = 0; i < 64; i++) begin : findB
			mux2_1 neg (.out(final_b[i]), .i({~(b[i]), b[i]}), .sel(subtract));
		end
	endgenerate
	
	mux2_1 findCin0 (.out(cin[0]), .i({1'b1, 1'b0}), .sel(subtract));
	
	
	// To implement the carry lookahead adder, we follow the formula on page A-39
	// ci + 1 = gi + pi * ci, where gi = ai * bi and pi = ai + bi
	// the first carry in is based on whether or not we are subtracting or adding.
	// If it is subtraction then cin[0] = 1, and it's 0 otherwise.
	// The last cin[64] is the carry out of the carry lookehead adder
	genvar j;
	generate
		logic [63:0] g;
		logic [63:0] p;
		for (j = 0; j < 64; j++) begin: add
			assign g[j] = a[j] & final_b[j];
			assign p[j] = a[j] | final_b[j];
			assign cin[j + 1] = g[j] | (p[j] & cin[j]);
		end
	endgenerate
	
	genvar k;
	generate
		for (k = 0; k < 64; k++) begin: findSum
			assign sum[k] = a[k] ^ final_b[k] ^ cin[k];
		end
	endgenerate
endmodule

module carrylookahead_adder_testbench(); 
	logic [63:0] a, b;
	logic [63:0] sum;
	logic Cout, subtract, overflow;
	carryLookahead_adder dut (subtract, a, b, sum, Cout, overflow); 
	
//	// Set up the clock. 
//	parameter CLOCK_PERIOD=100; 
//	initial begin 
//		clk <= 0; 
//		forever #(CLOCK_PERIOD/2) clk <= ~clk; 
//	end 

	// Set up the inputs to the design. Each line is a clock cycle. 
	initial begin 
																									#10;
		subtract = 0; a = 64'b111110000; b = 64'b0010101;							#10;
																									#10;
		subtract = 1;																			#10;
																									#10;
	  $stop;
	end
endmodule
