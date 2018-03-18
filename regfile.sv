/* Thu Phan 
	Brian Yu
	EE/CSE 469 Computer Architecture I
	Winter 2018
*/

// This is the main module of lab 1. It builds a register file that allows user to write into and read data from
module regfile (clk, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, WriteData, ReadData1, ReadData2);

	input logic clk;
	// write_enable represents whether or not writing mode is enabled
	input logic RegWrite;
	
	// writeReg = register number to write to
	// ReadRegister2 and ReadRegister1 is the desired register number to read
	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister; // register selection number in binary
	
	// WriteData = data to write into the desired register. 
	input logic [63:0] WriteData;
	
	// The two outputs that indicates the data in the registers that the user wants to read
	output logic [63:0] ReadData1, ReadData2;
	
	logic [31:0] [63:0] register_file; // 32 64-bit registers
	
	// Output to the decoder that decides which register to write to
	logic [31:0] writeSelect;
	
	// Takes writReg as a parameter to determine which line of register to write to
	decoder_5to32 selectToWrite (.enable(RegWrite), .input_select(WriteRegister), .output_select(writeSelect));
	
	assign register_file[31] = 64'b0;
	
	genvar i;
	generate
		for(i = 0; i < 31; i++) begin: updateReg
			D_FF_en_64 updateRegFile (.clk(clk), .enable(writeSelect[i]), .reset(1'b0), .q(register_file[i]), .d(WriteData));
		end
	endgenerate
	
	// Pick which register to output from address ReadRegister1
	MUX_64_32to1 findData1 (.out(ReadData1), .i31(register_file[31]), .i30(register_file[30]), .i29(register_file[29]),
											.i28(register_file[28]), .i27(register_file[27]), .i26(register_file[26]),
											.i25(register_file[25]), .i24(register_file[24]), .i23(register_file[23]),
											.i22(register_file[22]), .i21(register_file[21]), .i20(register_file[20]),
											.i19(register_file[19]), .i18(register_file[18]), .i17(register_file[17]),
											.i16(register_file[16]), .i15(register_file[15]), .i14(register_file[14]),
											.i13(register_file[13]), .i12(register_file[12]), .i11(register_file[11]),
											.i10(register_file[10]), .i9(register_file[9]), 	.i8(register_file[8]),
											.i7(register_file[7]),	  .i6(register_file[6]), 	.i5(register_file[5]),
											.i4(register_file[4]),   .i3(register_file[3]),   .i2(register_file[2]),
											.i1(register_file[1]),   .i0(register_file[0]), 	.sel(ReadRegister1));
											
		// Pick which register to output from address ReadRegister1
	MUX_64_32to1 findData2 (.out(ReadData2), .i31(register_file[31]), .i30(register_file[30]), .i29(register_file[29]),
											.i28(register_file[28]), .i27(register_file[27]), .i26(register_file[26]),
											.i25(register_file[25]), .i24(register_file[24]), .i23(register_file[23]),
											.i22(register_file[22]), .i21(register_file[21]), .i20(register_file[20]),
											.i19(register_file[19]), .i18(register_file[18]), .i17(register_file[17]),
											.i16(register_file[16]), .i15(register_file[15]), .i14(register_file[14]),
											.i13(register_file[13]), .i12(register_file[12]), .i11(register_file[11]),
											.i10(register_file[10]), .i9(register_file[9]), 	.i8(register_file[8]),
											.i7(register_file[7]),	  .i6(register_file[6]), 	.i5(register_file[5]),
											.i4(register_file[4]),   .i3(register_file[3]),   .i2(register_file[2]),
											.i1(register_file[1]),   .i0(register_file[0]), 	.sel(ReadRegister2));
	
endmodule



// Test bench for Register file
`timescale 1ns/10ps

module regstim(); 		

	parameter ClockDelay = 5000;

	logic	[4:0] 	ReadRegister1, ReadRegister2, WriteRegister;
	logic [63:0]	WriteData;
	logic 			RegWrite, clk;
	logic [63:0]	ReadData1, ReadData2;

	integer i;

	// Your register file MUST be named "regfile".
	// Also you must make sure that the port declarations
	// match up with the module instance in this stimulus file.
	regfile dut (.ReadData1, .ReadData2, .WriteData, 
					 .ReadRegister1, .ReadRegister2, .WriteRegister,
					 .RegWrite, .clk);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	initial begin
		// Try to write the value 0xA0 into register 31.
		// Register 31 should always be at the value of 0.
		RegWrite <= 5'd0;
		ReadRegister1 <= 5'd0;
		ReadRegister2 <= 5'd0;
		WriteRegister <= 5'd31;
		WriteData <= 64'h00000000000000A0;
		@(posedge clk);
		
		$display("%t Attempting overwrite of register 31, which should always be 0", $time);
		RegWrite <= 1;
		@(posedge clk);

		// Write a value into each  register.
		$display("%t Writing pattern to all registers.", $time);
		for (i=0; i<31; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000010204080001;
			@(posedge clk);
			
			RegWrite <= 1;
			@(posedge clk);
		end

		// Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000000000000100+i;
			@(posedge clk);
		end
		$stop;
	end
endmodule
