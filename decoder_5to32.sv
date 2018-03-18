`timescale 1ns/10ps

// This is a 5 to 32 decoder that is used in this lab to determine which register to write to
module decoder_5to32 (enable, input_select, output_select);
	input logic enable;
	input logic [4:0] input_select;
	output logic [31:0] output_select;
	
	logic [1:0] sel;
	decoder_1to2 findSel (.enable(enable), .input_select(input_select[4]), .output_select(sel));
	decoder_4to16 output_31to16 (input_select[3:0], sel[1], output_select[31:16]);
	decoder_4to16 output_15to0 (input_select[3:0], sel[0], output_select[15:0]);
	
endmodule

// 4 to 16 decoder that is made by the 2:4 decoder
module decoder_4to16 (input_select, enable, output_select);	
	input logic enable;
	input logic [3:0] input_select;
	output logic [15:0] output_select;
	
	logic [3:0] first_select;
	
	decoder_2to4 firstDecoder(input_select[3:2], enable, first_select);
	
	decoder_2to4 output_15to12 (input_select[1:0], first_select[3], output_select[15:12]);
	decoder_2to4 output_11to8 (input_select[1:0], first_select[2], output_select[11:8]);
	decoder_2to4 output_7to4 (input_select[1:0], first_select[1], output_select[7:4]);
	decoder_2to4 output_3to0 (input_select[1:0], first_select[0], output_select[3:0]);
	
endmodule

// 2 to 4 decoder
module decoder_2to4 (input_select, enable, output_select);
	input logic enable;
	input logic [1:0] input_select;
	output logic [3:0] output_select;
	
	logic [1:0] sel;
	
	decoder_1to2 findSel (.enable(enable), .input_select(input_select[1]), .output_select(sel));
	decoder_1to2 result0 (.enable(sel[0]), .input_select(input_select[0]), .output_select(output_select[1:0]));
	decoder_1to2 result1 (.enable(sel[1]), .input_select(input_select[0]), .output_select(output_select[3:2]));
	
endmodule


module decoder_1to2 (enable, input_select, output_select);
	input logic enable;
	input logic input_select;
	output logic [1:0] output_select;
	
	logic not_input;
	not(not_input, input_select);
	
	and result1 (output_select[1], input_select, enable);
	and result0 (output_select[0], not_input, enable);
endmodule

module decoder_5to32_testbench(); 
	logic [4:0] input_select;
	logic [31:0] output_select;
	logic clk;
	decoder_5to32 dut (input_select, output_select); 
	
	// Set up the clock. 
	parameter CLOCK_PERIOD=100; 
	initial begin 
		clk <= 0; 
		forever #(CLOCK_PERIOD/2) clk <= ~clk; 
	end 

	// Set up the inputs to the design. Each line is a clock cycle. 
	initial begin 
																									@(posedge clk);
		input_select = 5'b00000;															@(posedge clk);
		input_select = 5'b00001;															@(posedge clk);
		input_select = 5'b11000;															@(posedge clk);
		input_select = 5'b11111;															@(posedge clk);
																									@(posedge clk); 
																									@(posedge clk);
	  $stop;
	end
endmodule
