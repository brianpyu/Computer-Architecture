`timescale 1ns/10ps
/* Thu Phan 
	Brian Yu
	EE/CSE 469 Computer Architecture I
	Winter 2018
	Lab 2: 64 bit ARM ALU
*/
/* The ALU has a control port that selects which operation to perform on two 
	64 bit numbers: XOR, OR, AND, ADD, SUBTRACT, or return the second operand (B).
	It also reports back information about the result such as whether or not it has carry out,
	overflow, if it's zero or negative. 
	The module does all computations for all 6 options of operation and the cntrl signal decides
	which result to output.
*/

// This is the main module for the ALU
// A and B: 64 bit input port that represents 2's complement binary numbers
// cntrl: 3 bit control input that decides which operation to perform
// result: Result of operation on A and B
// negative: whether result is negative or not
// zero: whether result is 0 or not
// overflow: whether there is overflow
// carry_out: whether there is a carry out
module alu (A, B, cntrl, result, negative, zero, overflow, carry_out);
	input logic		[63:0]	A, B;
	input logic		[2:0]		cntrl;
	output logic	[63:0]	result;
	output logic				negative, zero, overflow, carry_out;
	
	// the 6 logics below are used to intermediate steps and to store the result of 
	// adding or subtracting the two operands. 
	logic [63:0] subtract_result;
	logic subtract_Cout;
	logic subtract_overflow;

	logic [63:0] add_result;
	logic add_Cout;
	logic add_overflow;
	
	// Finds resulting 64 bit;
	carryLookahead_adder subtract(.subtract(1'b1), .a(A), .b(B), .sum(subtract_result), .Cout(subtract_Cout), .overflow(subtract_overflow));
	carryLookahead_adder add(.subtract(1'b0), .a(A), .b(B), .sum(add_result), .Cout(add_Cout), .overflow(add_overflow));
	
	// find overflow based on whether or not subtract or add operation was selected. The deciding factor is based on
	// cntrl[0] since cntrl for add is 010 and for subtract it is 011. If cntrl[0] = 0, then add is the one to output and vice versa.
	// The reason why the other bits of cntrl is not considered is because the value of overflow and carry_out is unimportant for
	// other operations.
	mux2_1 pickOverflow (.out(overflow), .i({subtract_overflow, add_overflow}), .sel(cntrl[0]));	
	// find carry out
	mux2_1 pickCarryOut (.out(carry_out), .i({subtract_Cout, add_Cout}), .sel(cntrl[0]));
	
	
	// find zero. Module size64_zero does an or operation on all 64 bits of result and finds whether or not the result is zero
	//size64_zero findZero (.i(result), .out(zero));
	assign zero = ~|(result); 
	
	// find negative. Negative is decided on the most significant bit of the two's complement number.
	assign negative = result[63];
	
	
	// find XOR operation result
	logic [63:0] xor_result;
	genvar i;
	generate 
		for (i = 0; i < 64; i++) begin: findxorOp
			assign xor_result[i] = A[i] ^ B[i];
		end
	endgenerate
	
	
	// find OR operation result
	logic [63:0] or_result;
	genvar j;
	generate 
		for (j = 0; j < 64; j++) begin: findOrOp
			assign or_result[j] = A[j] | B[j];
		end
	endgenerate
	
	
	// Find AND operation result
	logic [63:0] and_result;
	genvar k;
	generate 
		for (k = 0; k < 64; k++) begin: findAndOp
			assign and_result[k] = A[k] & B[k];
		end
	endgenerate
	
	// Control selects which type of operation result to output
	// the eight bit input is [0, xor_result, or_result, and_result, subtract_result, add_result, 0, B];
	// If the cntrl is selected on 111 or 001, since there are not operations for these, the output is selected to be 0.
	genvar m;
	generate
		for (m = 0; m < 64; m++) begin: findResult
			mux8_1 result (.out(result[m]), .i({1'b0, xor_result[m], or_result[m], and_result[m], subtract_result[m], add_result[m], 1'b0, B[m]}),
								.sel0(cntrl[0]), .sel1(cntrl[1]), .sel2(cntrl[2]));
		end
	endgenerate
	
endmodule




// Test bench for ALU
`timescale 1ns/10ps

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B	// 0					value of overflow and carry_out unimportant
// 010:			result = A + B // 2
// 011:			result = A - B // 3
// 100:			result = bitwise A & B // 4		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B	// 5  	value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	// 6  value of overflow and carry_out unimportant

module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out ;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);
	logic [63:0] test_result;

	integer i;
	logic [63:0] test_val;
	initial begin
	
		// Test pass B
		$display("%t testing PASS_B operations", $time);
		cntrl = ALU_PASS_B;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		// Test addition operation 
		$display("%t testing addition", $time);
		cntrl = ALU_ADD;
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		
		// Test AND operation
		$display("%t testing and operation", $time);
		cntrl = ALU_AND;
		A = (2**64) - 1;	B = (2**64) - 1;
		#(delay);
		assert(result == ((2**64) - 1) && negative == 1 && zero == 0);
		
		A = 64'b0;	B = (2**64) - 1;
		#(delay);
		assert(result == 64'b0 && negative == 0 && zero == (result == 64'b0));

		A = $random(); B = $random();
		test_result = A & B;
		#(delay);
		assert(result == test_result);
		
		// Test OR operation
		$display("%t testing or operation", $time);
		cntrl = ALU_OR;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			test_result = A | B;
			#(delay);
			assert(result == test_result);
		end
		
		// Test XOR operation
		$display("%t tesing XOR operation", $time);
		cntrl = ALU_XOR;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			test_result = A ^ B;
			#(delay);
			assert(result == test_result);
		end
		
		$display("%t testing addition(1+1)", $time);
		cntrl = ALU_ADD;
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		
		$display("%t testing addition(big+big)", $time);
		cntrl = ALU_ADD;
		A = (2**62); B = (2**62);
		#(delay);
		assert(result == (2**63) && overflow == 1 && negative == 1 && zero == 0);
		
		$display("%t testing addition(1+-1)", $time);
		cntrl = ALU_ADD;
		A = 64'h0000000000000001; B = 64'hFFFFFFFFFFFFFFFF;
		#(delay);
		assert(result == 64'h0 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 1);
		
		$display("%t testing addition(-1+1)", $time);
		cntrl = ALU_ADD;
		B = 64'h0000000000000001; A = 64'hFFFFFFFFFFFFFFFF;
		#(delay);
		assert(result == 64'h0 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 1);
		
		$display("%t testing addition(-1+-1)", $time);
		cntrl = ALU_ADD;
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF;
		#(delay);
		assert(result == 64'hFFFFFFFFFFFFFFFE && carry_out == 1 && overflow == 0 && negative == 1 && zero == 0);
		
		$display("%t testing addition(-big+-big)", $time);
		cntrl = ALU_ADD;
		A = (2**63); B = (2**63);
		#(delay);
		assert(result == 64'h0 && carry_out == 1 && overflow == 1 && negative == 0 && zero == 1);
		
		$display("%t testing subtraction", $time);
		cntrl = ALU_SUBTRACT;
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 1);
		
		$display("%t testing AND", $time);
		cntrl = ALU_AND;
		A = 64'hA0A0A0A0A0A0A0A0; B = 64'hA0A0A0A0A0A0A0A0;
		#(delay);
		assert(result == 64'hA0A0A0A0A0A0A0A0 && negative == 1 && zero == 0);
		
		$display("%t testing AND", $time);
		cntrl = ALU_AND;
		A = 64'hAAAAAAAAAAAAAAAA; B = 64'h5555555555555555;
		#(delay);
		assert(result == 64'h0 && negative == 0 && zero == 1);
		
		$display("%t testing OR", $time);
		cntrl = ALU_OR;
		A = 64'hAAAAAAAAAAAAAAAA; B = 64'h5555555555555555;
		#(delay);
		assert(result == 64'hFFFFFFFFFFFFFFFF && negative == 1 && zero == 0);

		$display("%t testing XOR", $time);
		cntrl = ALU_XOR;
		A = 64'hAAAAAAAAAAAAAAAA; B = 64'h5555555555555555;
		#(delay);
		assert(result == 64'hFFFFFFFFFFFFFFFF && negative == 1 && zero == 0);	
		
	end

endmodule
