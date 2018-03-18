`timescale 1ns/10ps
module setFlags(clk, reset, Flag, ALUnegative, ALUoverflow, ALUzero, ALUcarry_out, negative, overflow, zero, carry_out);
	input logic clk, reset, Flag, ALUnegative, ALUoverflow, ALUzero, ALUcarry_out;
	output logic negative, overflow, zero, carry_out;
	
	D_FF_en findNeg (.clk(clk), .enable(Flag), .reset(reset), .q(negative), .d(ALUnegative));
	D_FF_en findOverflow (.clk(clk), .enable(Flag), .reset(reset), .q(overflow), .d(ALUoverflow));
	D_FF_en findZero (.clk(clk), .enable(Flag), .reset(reset), .q(zero), .d(ALUzero));
	D_FF_en findCarryOut (.clk(clk), .enable(Flag), .reset(reset), .q(carry_out), .d(ALUcarry_out));
	
endmodule
