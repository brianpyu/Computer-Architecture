//`timescale 1ns/10ps
//module updatePC(clk, reset, BrAddr26, CondAddr19, UncondBr, Branch, pc, final_pc);
//	input logic clk ,reset, UncondBr, Branch;
////	input logic [31:0] instruction;
//	input logic [63:0] pc, BrAddr26, CondAddr19;
//	output logic [63:0] final_pc;
//	
//	logic [63:0] uncondBr_constant;
//	mux2_1_64 findSubAdd(.out(uncondBr_constant), .i1(BrAddr26), .i0(CondAddr19), .sel(UncondBr));
//	
//	logic [63:0] uncondBr_constant_shift;
//	shifter shift_uncondBr (.value(uncondBr_constant), .direction(1'b0), .distance(6'b000010), .result(uncondBr_constant_shift));
//	
//	
//	logic [63:0] findRightOne;
//	mux2_1_64 findBranch (.out(findRightOne), .i1(uncondBr_constant_shift), .i0(64'b100), .sel(Branch));
//	
//	logic [63:0] result;
//	logic negative0, zero0, overflow0, carry_out0;
//	alu addUpdate (.A(pc), .B(findRightOne), .cntrl(3'b010), .result(result), 
//						.negative(negative0), .zero(zero0), .overflow(overflow0), .carry_out(carry_out0));
//	
//	D_FF_64 update_pc (.clk(clk), .reset(reset), .q(final_pc), .d(result));
//	
//endmodule





`timescale 1ns/10ps
module updatePC(clk, reset, BrAddr26, CondAddr19, UncondBr, Branch, pc, final_pc);
	input logic clk ,reset, UncondBr, Branch;
//	input logic [31:0] instruction;
	input logic [63:0] pc, BrAddr26, CondAddr19;
	output logic [63:0] final_pc;
	
	logic [63:0] uncondBr_constant;
	mux2_1_64 findSubAdd(.out(uncondBr_constant), .i1(BrAddr26), .i0(CondAddr19), .sel(UncondBr));
	
	logic [63:0] uncondBr_constant_shift;
	shifter shift_uncondBr (.value(uncondBr_constant), .direction(1'b0), .distance(6'b000010), .result(uncondBr_constant_shift));
	
	
	logic [63:0] pc_plus_4;
	logic negative0, zero0, overflow0, carry_out0;
	alu branch_Untaken (.A(final_pc), .B(64'b100), .cntrl(3'b010), .result(pc_plus_4),
							  .negative(negative0), .zero(zero0), .overflow(overflow0), .carry_out(carry_out0));
									
	
	logic [63:0] pc_branch;
	logic negative1, zero1, overflow1, carry_out1;
	alu uncond_untaken (.A(pc), .B(uncondBr_constant_shift), .cntrl(3'b010), .result(pc_branch),
						 .negative(negative1), .zero(zero1), .overflow(overflow1), .carry_out(carry_out1));
	
	
	logic [63:0] result;
	mux2_1_64 find_pc (.out(result), .i1(pc_branch), .i0(pc_plus_4), .sel(Branch));
	
	D_FF_64 update_pc (.clk(clk), .reset(reset), .q(final_pc), .d(result));
	
endmodule

