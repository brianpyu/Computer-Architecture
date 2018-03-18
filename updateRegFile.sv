`timescale 1ns/10ps
module updateRegFile (clk, instruction, dataMemOutput, mult_alu_shift_data, MemToReg, RegWrite, Reg2Loc, ReadData1, ReadData2);
	input logic clk, MemToReg, RegWrite, Reg2Loc;
	input logic [63:0] dataMemOutput;
	input logic [63:0] mult_alu_shift_data;
	input logic [31:0] instruction;
	output logic [63:0] ReadData1;
	output logic [63:0] ReadData2;
	
	logic [4:0] ReadReg1;
	logic [4:0] ReadReg2;
	logic [4:0] instr20_16;
	logic [63:0] WriteData;
	
	assign ReadReg1 = instruction[9:5]; // first input into Register File
	assign instr20_16 = instruction[20:16];

	
	// Find read register 2
	genvar i;
	generate 
		for (i = 0; i < 5; i++) begin: findReadRegister2
			mux2_1 findReadReg2 (.out(ReadReg2[i]), .i({instruction[i], instr20_16[i]}), .sel(Reg2Loc));
		end
	endgenerate
		
	// Find write data. Options: data mem output, alu output
	mux2_1_64 regFileWriteData (.out(WriteData), .i1(dataMemOutput), .i0(mult_alu_shift_data), .sel(MemToReg));
	
	regfile registerFile (.clk(clk), .ReadRegister1(ReadReg1), .ReadRegister2(ReadReg2), .WriteRegister(instruction[4:0]), .RegWrite(RegWrite),
					 .WriteData(WriteData), .ReadData1(ReadData1), .ReadData2(ReadData2));
endmodule
