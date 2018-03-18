`timescale 1ns/10ps
// This is a 32:1 multiplexer used to read data from the register file
module mux32_1(out, i, sel);
	// out represents the output of the multiplexer
	output logic out;
	// i represents the 32 inputs into the mux
	input logic [31:0] i;
	// sel represents the select input that selects which of the 32 inputs to output
	input logic [4:0] sel;

	logic v0, v1;

	mux16_1 m0(.out(v0), .i(i[15:0]), .sel0(sel[0]), .sel1(sel[1]), .sel2(sel[2]), .sel3(sel[3]));
	mux16_1 m1(.out(v1), .i(i[31:16]), .sel0(sel[0]), .sel1(sel[1]), .sel2(sel[2]), .sel3(sel[3]));
	mux2_1 m (.out(out), .i({v1, v0}), .sel(sel[4]));
	 
endmodule
	
module mux2_1_64 (out, i1, i0, sel);
	input logic sel;
	input logic[63:0] i1, i0;
	output logic [63:0] out;
	
	genvar i;
	generate
		for(i = 0; i < 64; i++) begin: findResult
			mux2_1 find (.out(out[i]), .i({i1[i], i0[i]}), .sel(sel));
		end
	endgenerate
endmodule

module MUX_64_32to1(out, i31, i30, i29, i28, i27, i26, i25, i24, i23, i22, i21, i20, i19, i18, i17, i16,
						  i15, i14, i13, i12, i11, i10, i9, i8, i7, i6, i5, i4, i3, i2, i1, i0, sel);
		
		output logic [63:0] out;
		input logic [63:0] i31, i30, i29, i28, i27, i26, i25, i24, i23, i22, i21, i20, i19, i18, i17, i16,
								 i15, i14, i13, i12, i11, i10, i9, i8, i7, i6, i5, i4, i3, i2, i1, i0;
		input logic [4:0] sel;
		
		
		genvar i;
		generate
			for(i = 0; i < 64; i++) begin: findOut
				mux32_1 findResult (.out(out[i]), .i({ i31[i], i30[i], i29[i], i28[i], i27[i], i26[i], i25[i], i24[i], i23[i], i22[i], i21[i], i20[i],
													i19[i], i18[i], i17[i], i16[i], i15[i], i14[i], i13[i], i12[i], i11[i], i10[i], i9[i], i8[i],
													i7[i], i6[i], i5[i], i4[i], i3[i], i2[i], i1[i], i0[i] }), .sel(sel));
			end		
		endgenerate
					  
endmodule

module mux16_1(out, i, sel0, sel1, sel2, sel3);
 output logic out;
 input logic [15:0] i;
 input logic sel0, sel1, sel2, sel3;

 logic v0, v1;

 mux8_1 m0(.out(v0), .i(i[7:0]), .sel0(sel0), .sel1(sel1), .sel2(sel2));
 mux8_1 m1(.out(v1), .i(i[15:8]), .sel0(sel0), .sel1(sel1), .sel2(sel2));
 mux2_1 m (.out(out), .i({v1, v0}), .sel(sel3));
endmodule

module mux16_1_testbench();
 logic [15:0] i;
 logic sel0, sel1, sel2, sel3;
 logic out;

 mux16_1 dut (.out, .i, .sel0, .sel1, .sel2, .sel3);

 integer j;
 initial begin
	for(j = 0; j < (2**20); j++) begin
		{sel3, sel2, sel1, sel0, i} = j; #10;
	end
 end

endmodule 

module mux8_1(out, i, sel0, sel1, sel2);
 output logic out;
 input logic [7:0] i;
 input logic sel0, sel1, sel2;

 logic v0, v1;

 mux4_1 m0(.out(v0), .i(i[3:0]), .sel0(sel0), .sel1(sel1));
 mux4_1 m1(.out(v1), .i(i[7:4]), .sel0(sel0), .sel1(sel1));
 mux2_1 m (.out(out), .i({v1, v0}), .sel(sel2));
endmodule

module mux8_1_testbench();
 logic [7:0] i;
 logic sel0, sel1, sel2;
 logic out;

 mux8_1 dut (.out, .i, .sel0, .sel1, .sel2);

 integer j;
 initial begin
	for(j=0; j<(2**11); j++) begin
		{sel2, sel1, sel0, i} = j; #10;
	end
 end
endmodule 

// TODO: Have Brian check
module mux_64_4_1 (out, i3, i2, i1, i0, sel0, sel1);
	output logic [63:0] out;
	input logic [63:0] i3, i2, i1, i0;
	input logic sel0, sel1;
	
	genvar i;
	generate
		for(i = 0; i < 64; i++) begin: findResult
			mux4_1 find (.out(out[i]), .i({i3[i], i2[i], i1[i], i0[i]}), .sel0(sel0), .sel1(sel1));
		end
	endgenerate
	
endmodule



module mux4_1(out, i, sel0, sel1);
 output logic out;
 input logic [3:0] i;
 input logic sel0, sel1;

 logic v0, v1;

 mux2_1 m0(.out(v0), .i(i[1:0]), .sel(sel0));
 mux2_1 m1(.out(v1), .i(i[3:2]), .sel(sel0));
 mux2_1 m (.out(out), .i({v1, v0}), .sel(sel1));
endmodule

module mux4_1_testbench();
 logic [3:0] i;
 logic sel0, sel1;
 logic out;

 mux4_1 dut (.out, .i, .sel0, .sel1);

 integer j;
 initial begin
	for (j = 0; j < (2**6); j++) begin
		{sel1, sel0, i} = j; #10;
	end
 end
endmodule 

module mux2_1(out, i, sel);
 output logic out;
 input logic [1:0] i;
 input logic sel;

 and mux1 (temp1, i[1], sel);
 and mux2 (temp2, i[0], ~sel);
 or add (out, temp1, temp2);
endmodule

module mux2_1_testbench();
 logic [1:0]i;
 logic sel;
 logic out;

 mux2_1 dut (.out, .i, .sel);

 
 integer j;
	initial begin
		for(j=0; j<(2**3); j++) begin
			{sel, i} = j; #10;
		end
	end
 
endmodule 