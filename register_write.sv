// This module is used to write to one register
module register_write (clk, reset, enable, writeData, writeReg);
	// reset represents if the data should be reset in the register or not
	// It is usually off unless the user is trying to write into register 31. 
	// This case is handled in the main module
	input logic reset;
	// enable represents whether writing is active or not
	input logic clk, enable;
	// writeData represents the data that should be written into the register
	input logic [63:0] writeData;
	// writeReg represents the output of what is in the register
	output logic [63:0] writeReg;
	
	genvar i;
	
	// Writes to all the 64 bits in the register with D_FF
	generate
		for (i = 0; i < 64; i++) begin : eachDff
			//D_FF dff_ (enable & clk, reset, writeReg[i], writeData[i]);
			D_FF_en write (.clk, .enable(enable), .reset(1'b0), .output_q(writeReg[i]), .q(writeReg[i]), .d(writeData[i]));
		end
	endgenerate
	
endmodule


module register_write_testbench(); 
	logic enable;
	logic [63:0] writeData, writeReg;
	logic clk;
	register_write dut (clk, enable, writeData, writeReg); 
	
	// Set up the clock. 
	parameter CLOCK_PERIOD=100; 
	initial begin 
		clk <= 0; 
		forever #(CLOCK_PERIOD/2) clk <= ~clk; 
	end 

	// Set up the inputs to the design. Each line is a clock cycle. 
	initial begin 
																									@(posedge clk);
		writeData = 64'b001;																	@(posedge clk);																								
		enable = 1'b1;																			@(posedge clk);
		enable = 1'b0;																			@(posedge clk);
																									@(posedge clk);
		writeData = 64'b11110;																@(posedge clk);
		enable = 1'b1;																			@(posedge clk);
		enable = 1'b0;																			@(posedge clk);
																									@(posedge clk); 
																									@(posedge clk);
	  $stop;
	end
endmodule
