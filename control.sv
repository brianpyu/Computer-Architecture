`timescale 1ns/10ps

module control (clk, opcode, ALUzero, negative, overflow, Flag, Reg2Loc, ALUsrc, MemToReg,
					 RegWrite, MemRead, MemWrite, UncondBr, Branch, Mult, Shift, ALUOp, SubAdd);
	input logic clk, negative, overflow, ALUzero;
	input logic [10:0] opcode;
	output logic [1:0] ALUOp;
	output logic Flag, Reg2Loc, ALUsrc, MemToReg, RegWrite, MemRead, MemWrite, UncondBr, Branch, Mult, Shift, SubAdd;
	
	logic [13:0] cntrl;
	
	always_comb begin
		casex(opcode)
			11'b1001000100X: cntrl = 14'b10x101x0x00000; // ADDI	// R-format
			11'b10101011000: cntrl = 14'bx10001x0x00000; // ADDS	// R-format
			11'b000101xxxxx: cntrl = 14'bx0xxx0x011xxxx; // B imm26
			11'b01010100xxx: begin
								  cntrl[13:5] = 8'bx0xxx0x00; // B.LT
								  cntrl[4] = negative ^ overflow;
								  cntrl[3:0] = 4'bxxxx;
								  end
			11'b10110100xxx: begin
								  cntrl[13:5] = 8'bx010x0x00; // CBZ
								  cntrl[4] = ALUzero;
								  cntrl[3:0] = 4'b01xx;
								  end
			11'b11111000010: cntrl = 14'b00x11110x00000; // LDUR
			11'b11010011011: cntrl = 14'bx00001x0x000x1; // LSL
			11'b11010011010: cntrl = 14'bx00001x0x000x1; // LSR
			11'b10011011000: cntrl = 14'bx00001x0x0xx10; // MUL
			11'b11111000000: cntrl = 14'b0011x001x00000; // STUR
			11'b11101011000: cntrl = 14'b110001x0x01000; // SUBS
			default: cntrl = 14'bx;
		endcase
	end
	
	assign SubAdd = cntrl[13];
	assign Flag = cntrl[12];
	assign Reg2Loc = cntrl[11];
	assign ALUsrc = cntrl[10];
	assign MemToReg = cntrl[9];
	assign RegWrite = cntrl[8];
	assign MemRead = cntrl[7];
	assign MemWrite = cntrl[6];
	assign UncondBr = cntrl[5];
	assign Branch = cntrl[4];
	assign ALUOp = cntrl[3:2];
	assign Mult = cntrl[1];
	assign Shift = cntrl[0];
	
endmodule
