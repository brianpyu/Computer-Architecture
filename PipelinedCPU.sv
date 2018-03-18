`timescale 1ns/10ps
/* Thu Phan 
	Brian Yu
	EE/CSE 469 Computer Architecture I
	Winter 2018
	Lab 3: Single Cycle CPU
*/

/*
	This is the main module for implementing the 64-bit ARM Single Cycle CPU. It can support the following
	inplementations: ADDI, ADDS, Branch, B.LT, CBZ, LDUR, LSL, LSR, MUL, STUR, and SUBS. It combines
	previous projects such as the register file and CPU, as well as given modules for the dataMemory and
	instructionMemory. 
*/
module PipelinedCPU(clk, reset);
	input logic clk, reset;
	
	// Stores the current program counter value
	logic [63:0] pc;
		
	// Stores the current instructions taken from instructionMemory
	logic [31:0] instruction;
	
	// Stores the opcode of the instruction
	logic [10:0] opcode;
	
	// These are control signals that controls multiplexors in order get choose the 
	// right data for different operations.
	logic 						SubAdd, 
									Flag, 
									Reg2Loc,
									ALUsrc, 
									MemToReg, 
									RegWrite, 
									MemRead, 
									MemWrite, 
									UncondBr, 
									Branch, 
									Mult,
									Shift;
	
	logic [1:0] 				ALUOp;
	
	logic [63:0] 				ReadData1,
									ReadData2,
									WriteData;
	
	logic [4:0] 				ReadReg1,
									ReadReg2,
									instr20_16;
	
	
	logic [2:0] 				alu_cntrl;
	
	logic [63:0] 				DAddr9,
									Imm12,
									CondAddr19,
									BrAddr26;
	
	logic [63:0] 				ALU_input1,
									ALU_input2,
									ALU_output;
					 
	logic 						ALUnegative,
									ALUzero,
									ALUoverflow,
									ALUcarry_out; // Store flags
	
	logic 						negative,
									zero,
									overflow,
									carry_out;
	
	
	
		
	logic [63:0] 				dataMemOutput,
									shifter_result,
									multiply_result,
									not_useful,
									m_alu_result,
									mult_alu_shift_data;
	
	logic [31:0] 				pipeline_instruction;
	
	
	
/**********************************************************************************************/	
	/* IF/ID PIPELINE REGISTER CONTENTS */
	logic [63:0]			IF_ID_currentPC,
								IF_ID_DAddr9,
								IF_ID_Imm12,
								IF_ID_BrAddr26,
								IF_ID_CondAddr19,
								IF_ID_RegisterRn;
								
	logic [31:0]			IF_ID_instruction;
	
/**********************************************************************************************/	



/**********************************************************************************************/	
	logic 						ID_EX_SubAdd, 
									ID_EX_Flag, 
									ID_EX_Reg2Loc,
									ID_EX_ALUsrc, 
									ID_EX_MemToReg, 
									ID_EX_RegWrite, 
									ID_EX_MemRead, 
									ID_EX_MemWrite, 
									ID_EX_UncondBr, 
									ID_EX_Branch, 
									ID_EX_Mult,
									ID_EX_Shift;
									
	logic [2:0] 				ID_EX_alu_cntrl;
	
	logic [63:0]				ID_EX_CondAddr19,
									ID_EX_BrAddr26,
									ID_EX_DAddr9,
									ID_EX_Imm12,
									ID_EX_ReadData1,
									ID_EX_ReadData2,
									ID_EX_currentPC;
									
	logic [4:0]					ID_EX_RegisterRn,
									ID_EX_RegisterRm,
									ID_EX_RegisterRd;
	
	logic [31:0] 				ID_EX_instruction;
	
/**********************************************************************************************/	



/**********************************************************************************************/
/* EX/MEM PIPELINE REGISTER CONTENTS */

	logic 						EX_MEM_SubAdd, 
									EX_MEM_Flag, 
									EX_MEM_Reg2Loc,
									EX_MEM_ALUsrc, 
									EX_MEM_MemToReg, 
									EX_MEM_RegWrite, 
									EX_MEM_MemRead, 
									EX_MEM_MemWrite, 
									EX_MEM_UncondBr, 
									EX_MEM_Branch, 
									EX_MEM_Mult,
									EX_MEM_Shift,
									EX_MEM_ALUzero,
									EX_MEM_negative,
									EX_MEM_overflow,
									EX_MEM_zero,
									EX_MEM_carry_out;
									
									
	logic [2:0] 				EX_MEM_alu_cntrl;
	
	logic [63:0]				EX_MEM_CondAddr19,
									EX_MEM_BrAddr26,
									EX_MEM_currentPC,
									EX_MEM_ReadData2,
									EX_MEM_ALU_output,
									EX_MEM_mult_alu_shift_data;
									
	logic [4:0]					EX_MEM_RegisterRn,
									EX_MEM_RegisterRm,
									EX_MEM_RegisterRd;
									
/**********************************************************************************************/		




/**********************************************************************************************/
	
	logic 						MEM_WB_SubAdd, 
									MEM_WB_Flag, 
									MEM_WB_Reg2Loc,
									MEM_WB_ALUsrc, 
									MEM_WB_MemToReg, 
									MEM_WB_RegWrite, 
									MEM_WB_MemRead, 
									MEM_WB_MemWrite, 
									MEM_WB_UncondBr, 
									MEM_WB_Branch, 
									MEM_WB_Mult,
									MEM_WB_Shift;
	logic [2:0] 				MEM_WB_alu_cntrl;
	
	logic [63:0]				MEM_WB_CondAddr19,
									MEM_WB_BrAddr26,
									MEM_WB_dataMemOutput,
									MEM_WB_mult_alu_shift_data;
									
	logic [4:0]					MEM_WB_RegisterRn,
									MEM_WB_RegisterRm,
									MEM_WB_RegisterRd;

/**********************************************************************************************/							


/**********************************************************************************************/							
/* ASSIGNMENT CASES */
	assign opcode = IF_ID_instruction[31:21];
	assign ReadReg1 = IF_ID_instruction[9:5]; // first input into Register File
	assign instr20_16 = IF_ID_instruction[20:16];
	assign alu_cntrl = {1'b0, ~ALUOp[0], ALUOp[1] & ~ALUOp[0]};
	assign DAddr9 = { {55 {IF_ID_instruction[20]}}, IF_ID_instruction[20:12] };
	assign Imm12 = { {52 {1'b0}}, IF_ID_instruction[21:10]};
	assign BrAddr26 = { { 38 {IF_ID_instruction[25]}}, IF_ID_instruction[25:0] };
	assign CondAddr19 = { {45 {IF_ID_instruction[23]}} , IF_ID_instruction[23:5] };

	genvar i;
/**********************************************************************************************/


/**********************************************************************************************/

//	logic [10:0] opcode1;
//	assign opcode1 = instruction[31:21];
//	logic 						SubAdd1, 
//									Flag1, 
//									Reg2Loc1,
//									ALUsrc1, 
//									MemToReg1, 
//									RegWrite1, 
//									MemRead1, 
//									MemWrite1, 
//									UncondBr1, 
//									Branch1, 
//									Mult1,
//									Shift1;
//									
//	logic [1:0] ALUOp1;
//	
//	control findControl1 (.clk(clk), .opcode(opcode1), .ALUzero(EX_MEM_ALUzero), .negative(EX_MEM_negative),
//							  .overflow(EX_MEM_overflow), .Flag(Flag1), .Reg2Loc(Reg2Loc1),
//							  .ALUsrc(ALUsrc1), .MemToReg(MemToReg1), .RegWrite(RegWrite1), 
//							  .MemRead(MemRead1), .MemWrite(MemWrite1), .UncondBr(UncondBr1), 
//							  .Branch(Branch1), .Mult(Mult1), .Shift(Shift1), .ALUOp(ALUOp1), .SubAdd(SubAdd1));
	
	
/*********************************************************************************************/




	
/**************************************************************************************************************************/
/* Find next pc */

	updatePC findNextPC (.clk(clk), .reset(reset), .BrAddr26(EX_MEM_BrAddr26), .CondAddr19(EX_MEM_CondAddr19),
								.UncondBr(EX_MEM_UncondBr), .Branch(EX_MEM_Branch), .pc(EX_MEM_currentPC), .final_pc(pc));

/**************************************************************************************************************************/


	
/**************************************************************************************************************************/
/* Find instruction */
	
	// get instruction and store it in the 32 bit instruction bit array
	instructmem getInstruction (.address(pc), .instruction(instruction), .clk(clk));
	
//	D_FF_32 pipelineInstr (.clk(clk), .reset(reset), .q(pipeline_instruction), .d(instruction));
	
/**************************************************************************************************************************/


	
/**************************************************************************************************************/
/* IF/ID PIPELINE REGISTER CONTENTS */
	
//	D_FF_32 passInstruction (.clk(clk), .reset(1'b0), .q(IF_ID_instruction), .d(instruction));

	assign IF_ID_instruction = instruction;
	
	D_FF_64 passCurrentPC 	(.clk(clk), .reset(reset), .q(IF_ID_currentPC), .d(pc));
//	D_FF_64 passDAddr9	 	(.clk(clk), .reset(reset), .q(IF_ID_DAddr9), .d(DAddr9));
//	D_FF_64 passImm12		 	(.clk(clk), .reset(reset), .q(IF_ID_Imm12), .d(Imm12));
//	D_FF_64 passBrAddr26  	(.clk(clk), .reset(reset), .q(IF_ID_BrAddr26), .d(BrAddr26));
//	D_FF_64 passCondAddr19	(.clk(clk), .reset(reset), .q(IF_ID_CondAddr19), .d(CondAddr19));
//	assign IF_ID_currentPC = pc;
	assign IF_ID_DAddr9 = DAddr9;
	assign IF_ID_Imm12 = Imm12;
	assign IF_ID_BrAddr26 = BrAddr26;
	assign IF_ID_CondAddr19 = CondAddr19;
						
/**************************************************************************************************************/	


/**************************************************************************************************************************/
/* Find control signals */
	
	logic Reg2zero;
	assign Reg2zero = ~|(ReadData2);
	
	control findControl (.clk(clk), .opcode(opcode), .ALUzero(Reg2zero), .negative(EX_MEM_ALUnegative),
							  .overflow(EX_MEM_ALUoverflow), .Flag(Flag), .Reg2Loc(Reg2Loc),
							  .ALUsrc(ALUsrc), .MemToReg(MemToReg), .RegWrite(RegWrite), 
							  .MemRead(MemRead), .MemWrite(MemWrite), .UncondBr(UncondBr), 
							  .Branch(Branch), .Mult(Mult), .Shift(Shift), .ALUOp(ALUOp), .SubAdd(SubAdd));

/**************************************************************************************************************************/	

	
/**************************************************************************************************************************/
/* Find input and output of registerFile */
	
	// dataMemOutput = Output from data memory.
	// mult_alu_shift_data = Output from choosing which to select: ALU output, shift output, or multiply output
	// MemToReg = Is data going to register file coming from memory or other other options
	// RegWrite = Is operation writing to register file
	// Reg2Loc = instruction[20-16] or instruction[4:0] going to read register 2?
	// ReadData1 = register read from read register 1
	// ReadData2 = 				""							2
	
	
	// Find read register 2
	generate 
		for (i = 0; i < 5; i++) begin: findReadRegister2
			mux2_1 findReadReg2 (.out(ReadReg2[i]), .i({IF_ID_instruction[i], instr20_16[i]}), .sel(Reg2Loc));
		end
	endgenerate

//	logic [63:0] dataToWrite;
//	logic [4:0] registerToWrite;
//	logic allowToWrite;
	// Find write data. Options: data mem output, alu output
	mux2_1_64 regFileWriteData (.out(WriteData), .i1(MEM_WB_dataMemOutput), .i0(MEM_WB_mult_alu_shift_data), .sel(MEM_WB_MemToReg));
	
//	D_FF_64 writeData (.clk(clk), .reset(reset), .q(WriteData), .d(dataToWrite));
//	D_FF_5 toWrite (.clk(clk), .reset(reset), .q(registerToWrite), .d(MEM_WB_RegisterRd));
//	D_FF 	  allowWrite(.clk(clk), .reset(reset), .q(allowToWrite), .d(MEM_WB_RegWrite));
	
	regfile registerFile (.clk(~clk), .ReadRegister1(ReadReg1), .ReadRegister2(ReadReg2), 
								 .WriteRegister(MEM_WB_RegisterRd), .RegWrite(MEM_WB_RegWrite),
								 .WriteData(WriteData), .ReadData1(ReadData1), .ReadData2(ReadData2));
	
/**************************************************************************************************************************/	


/**************************************************************************************************************/
/* ID/EX PIPELINE REGISTER CONTENTS */
//	logic 						ID_EX_SubAdd, 
//									ID_EX_Flag, 
//									ID_EX_Reg2Loc,
//									ID_EX_ALUsrc, 
//									ID_EX_MemToReg, 
//									ID_EX_RegWrite, 
//									ID_EX_MemRead, 
//									ID_EX_MemWrite, 
//									ID_EX_UncondBr, 
//									ID_EX_Branch, 
//									ID_EX_Mult,
//									ID_EX_Shift;
//									
//	logic [2:0] 				ID_EX_alu_cntrl;
//	
//	logic [63:0]				ID_EX_CondAddr19,
//									ID_EX_BrAddr26,
//									ID_EX_DAddr9,
//									IF_EX_Imm12,
//									ID_EX_ReadData1,
//									ID_EX_ReadData2,
//									ID_EX_currentPC;
//									
//	logic [4:0]					ID_EX_RegisterRn,
//									ID_EX_RegisterRm,
//									ID_EX_RegisterRd;
//	
//	logic [31:0] 				ID_EX_instruction;
	
	
	
	D_FF passSubAdd2 				(.clk(clk), .reset(reset), .q(ID_EX_SubAdd), .d(SubAdd));
	D_FF passFlag2 				(.clk(clk), .reset(reset), .q(ID_EX_Flag), 	.d(Flag));
	D_FF passReg2Loc2 	  		(.clk(clk), .reset(reset), .q(ID_EX_Reg2Loc), .d(Reg2Loc));
	D_FF passALUsrc2 	  			(.clk(clk), .reset(reset), .q(ID_EX_ALUsrc), .d(ALUsrc));
	D_FF passMemToReg2	  		(.clk(clk), .reset(reset), .q(ID_EX_MemToReg), .d(MemToReg));
	D_FF passRegWrite2 			(.clk(clk), .reset(reset), .q(ID_EX_RegWrite), .d(RegWrite));
	D_FF passMemRead2	   		(.clk(clk), .reset(reset), .q(ID_EX_MemRead), .d(MemRead));
	D_FF passMemWrite2	   	(.clk(clk), .reset(reset), .q(ID_EX_MemWrite), .d(MemWrite));
	D_FF passUncondBr2			(.clk(clk), .reset(reset), .q(ID_EX_UncondBr), .d(UncondBr));
	D_FF passBranch2				(.clk(clk), .reset(reset), .q(ID_EX_Branch), .d(Branch));
	D_FF passMult2					(.clk(clk), .reset(reset), .q(ID_EX_Mult), .d(Mult));
	D_FF passShift2				(.clk(clk), .reset(reset), .q(ID_EX_Shift), .d(Shift));
	
	D_FF_3 pass_alu_cntrl2		(.clk(clk), .reset(reset), .q(ID_EX_alu_cntrl), .d(alu_cntrl));
	
	D_FF_5 passRn2					(.clk(clk), .reset(reset), .q(ID_EX_RegisterRn), .d(IF_ID_instruction[9:5]));
	D_FF_5 passRm2					(.clk(clk), .reset(reset), .q(ID_EX_RegisterRm), .d(ReadReg2));
	D_FF_5 passRd2					(.clk(clk), .reset(reset), .q(ID_EX_RegisterRd), .d(IF_ID_instruction[4:0]));
	
	D_FF_64 passCondAddr19_2	(.clk(clk), .reset(reset), .q(ID_EX_CondAddr19), .d(IF_ID_CondAddr19));
	D_FF_64 passBrAddr26_2 		(.clk(clk), .reset(reset), .q(ID_EX_BrAddr26), .d(IF_ID_BrAddr26));
	D_FF_64 passDAddr9_2			(.clk(clk), .reset(reset), .q(ID_EX_DAddr9), .d(IF_ID_DAddr9));
	D_FF_64 passImm12_2			(.clk(clk), .reset(reset), .q(ID_EX_Imm12), .d(IF_ID_Imm12));
//	D_FF_64 passCurrPC_2			(.clk(clk), .reset(reset), .q(ID_EX_currentPC), .d(IF_ID_currentPC));
	
	D_FF_32 passInstruction2 	(.clk(clk), .reset(reset), .q(ID_EX_instruction), .d(IF_ID_instruction));
	
	D_FF_64 passReadData1 (.clk(clk), .reset(reset), .q(ID_EX_ReadData1), .d(ReadData1));
	D_FF_64 passReadData2 (.clk(clk), .reset(reset), .q(ID_EX_ReadData2), .d(ReadData2));
//	assign ID_EX_ReadData1 = ReadData1;
//	assign ID_EX_ReadData2 = ReadData2;
//	assign ID_EX_ALUsrc = ALUsrc;
//	assign ID_EX_SubAdd = SubAdd;
//	assign ID_EX_Flag = Flag;
//	assign ID_EX_Reg2Loc = Reg2Loc;
//	assign ID_EX_MemToReg = MemToReg;
//	assign ID_EX_RegWrite = RegWrite;
//	assign ID_EX_MemRead = MemRead;
//	assign ID_EX_MemWrite = MemWrite;
//	assign ID_EX_UncondBr = UncondBr;
//	assign ID_EX_Branch = Branch;
//	assign ID_EX_Mult = Mult;
//	assign ID_EX_Shift = Shift;
//	assign ID_EX_alu_cntrl = alu_cntrl;

	assign ID_EX_currentPC = IF_ID_currentPC;
	
/**************************************************************************************************************/


	
/**************************************************************************************************************/
/* Find forwarding unit */

	logic [1:0] 			ForwardA, ForwardB;
	logic [63:0]			ForwardB_result;
	
	ForwardingUnit findForwarding (.EX_MEM_RegWrite(EX_MEM_RegWrite), .EX_MEM_RegisterRd(EX_MEM_RegisterRd),
											 .ID_EX_RegisterRn(ID_EX_RegisterRn), .ID_EX_RegisterRm(ID_EX_RegisterRm),
											 .MEM_WB_RegWrite(MEM_WB_RegWrite), .MEM_WB_RegisterRd(MEM_WB_RegisterRd),
											 .ForwardA(ForwardA), .ForwardB(ForwardB));

	mux_64_4_1 findAluInput1 (.out(ALU_input1), .i3(64'b0), .i2(EX_MEM_mult_alu_shift_data),
															  .i1(WriteData), .i0(ID_EX_ReadData1), 
																.sel0(ForwardA[0]), .sel1(ForwardA[1]));
																
	mux_64_4_1 findAluInput2 (.out(ForwardB_result), .i3(64'b0), .i2(EX_MEM_mult_alu_shift_data),
															  .i1(WriteData), .i0(ID_EX_ReadData2),
															  .sel0(ForwardB[0]), .sel1(ForwardB[1]));
																		
	
	
/**************************************************************************************************************/



/**************************************************************************************************************/
/* Find input and output of ALU */
	
	/* 3 options in this specific ALU: 
		1. ADD: ALUOp = 00, alu_cntrl = 010
		2. SUBTRACT: ALUOp = 10, alu_cntrl = 011
		3. Pass B/(reg 2): ALUOp = 01, alu_cntrl = 000
		Simple truth table can find equations for alu_cntrl[1] and alu_cntrl[0].
		alu_cntrl[2] is always 0 in this specific single cycle CPU.
	*/
	// Determines second input into ALUSrc if opcode is LDUR, STUR, or ADDX/SUB
	logic [63:0] r1;

	mux2_1_64 findSubAdd(.out(r1), .i1(ID_EX_Imm12), .i0(ID_EX_DAddr9), .sel(ID_EX_SubAdd));
	
	// Find ALU input 2
	mux2_1_64 findAlu_input2(.out(ALU_input2), .i1(r1), .i0(ForwardB_result), .sel(ID_EX_ALUsrc));
	
	
	// Find ALU output
	alu findALUoutput (.A(ALU_input1), .B(ALU_input2), .cntrl(ID_EX_alu_cntrl), .result(ALU_output), 
							 .negative(ALUnegative), .zero(ALUzero), .overflow(ALUoverflow), .carry_out(ALUcarry_out));
	
	setFlags findFlags (.clk(clk), .reset(reset), .Flag(ID_EX_Flag), .ALUnegative(ALUnegative), 
							  .ALUoverflow(ALUoverflow), .ALUzero(ALUzero),
							  .ALUcarry_out(ALUcarry_out), .negative(negative), 
							  .overflow(overflow), .zero(zero), .carry_out(carry_out));
	
/**************************************************************************************************************************/	

/**************************************************************************************************************************/
/* Find what to put into the writeData of the RegisterFile */
	// TODO: THIS IS WRONG
	shifter s (.value(ALU_input1), .direction(~ID_EX_instruction[21]), .distance(ID_EX_instruction[15:10]), .result(shifter_result));
	mult m (.A(ALU_input1), .B(ForwardB_result), .doSigned(1'b1), .mult_low(multiply_result), .mult_high(not_useful));
	
	mux2_1_64 m_alu (.out(m_alu_result), .i1(multiply_result), .i0(ALU_output), .sel(ID_EX_Mult));
	mux2_1_64 malu_shift (.out(mult_alu_shift_data), .i1(shifter_result), .i0(m_alu_result), .sel(ID_EX_Shift));

	

/**************************************************************************************************************************/


/**************************************************************************************************************/
/* EX/MEM PIPELINE REGISTER CONTENTS */

//	logic 						EX_MEM_SubAdd, 
//									EX_MEM_Flag, 
//									EX_MEM_Reg2Loc,
//									EX_MEM_ALUsrc, 
//									EX_MEM_MemToReg, 
//									EX_MEM_RegWrite, 
//									EX_MEM_MemRead, 
//									EX_MEM_MemWrite, 
//									EX_MEM_UncondBr, 
//									EX_MEM_Branch, 
//									EX_MEM_Mult,
//									EX_MEM_Shift,
//									EX_MEM_ALUzero,
//									EX_MEM_negative,
//									EX_MEM_overflow,
//									EX_MEM_zero,
//									EX_MEM_carry_out;
//									
//									
//	logic [2:0] 				EX_MEM_alu_cntrl;
//	
//	logic [63:0]				EX_MEM_CondAddr19,
//									EX_MEM_BrAddr26,
//									EX_MEM_currentPC,
//									EX_MEM_ReadData2,
//									EX_MEM_ALU_output,
//									EX_MEM_mult_alu_shift_data;
//									
//	logic [4:0]					EX_MEM_RegisterRn,
//									EX_MEM_RegisterRm,
//									EX_MEM_RegisterRd;
									
	
	D_FF passSubAdd3 				(.clk(clk), .reset(reset), .q(EX_MEM_SubAdd), .d(ID_EX_SubAdd));
	D_FF passFlag3 				(.clk(clk), .reset(reset), .q(EX_MEM_Flag), 	.d(ID_EX_Flag));
	D_FF passReg2Loc3 	  		(.clk(clk), .reset(reset), .q(EX_MEM_Reg2Loc), .d(ID_EX_Reg2Loc));
	D_FF passALUsrc3 	  			(.clk(clk), .reset(reset), .q(EX_MEM_ALUsrc), .d(ID_EX_ALUsrc));
	D_FF passMemToReg3	  		(.clk(clk), .reset(reset), .q(EX_MEM_MemToReg), .d(ID_EX_MemToReg));
	D_FF passRegWrite3 			(.clk(clk), .reset(reset), .q(EX_MEM_RegWrite), .d(ID_EX_RegWrite));
	D_FF passMemRead3	   		(.clk(clk), .reset(reset), .q(EX_MEM_MemRead), .d(ID_EX_MemRead));
	D_FF passMemWrite3	   	(.clk(clk), .reset(reset), .q(EX_MEM_MemWrite), .d(ID_EX_MemWrite));
//	D_FF passUncondBr3			(.clk(clk), .reset(reset), .q(EX_MEM_UncondBr), .d(ID_EX_UncondBr));
//	D_FF passBranch3				(.clk(clk), .reset(reset), .q(EX_MEM_Branch), .d(ID_EX_Branch));
	D_FF passMult3					(.clk(clk), .reset(reset), .q(EX_MEM_Mult), .d(ID_EX_Mult));
	D_FF passShift3				(.clk(clk), .reset(reset), .q(EX_MEM_Shift), .d(ID_EX_Shift));
	D_FF passALUZero3				(.clk(clk), .reset(reset), .q(EX_MEM_ALUzero), .d(ALUzero));
	D_FF passNegative3			(.clk(clk), .reset(reset), .q(EX_MEM_negative), .d(negative));
	D_FF passOverflow3			(.clk(clk), .reset(reset), .q(EX_MEM_overflow), .d(overflow));
	D_FF passZero3					(.clk(clk), .reset(reset), .q(EX_MEM_zero), .d(zero));
	D_FF passCarryOut3			(.clk(clk), .reset(reset), .q(EX_MEM_carry_out), .d(carry_out));
	
	D_FF_3 pass_alu_cntrl3		(.clk(clk), .reset(reset), .q(EX_MEM_alu_cntrl), .d(ID_EX_alu_cntrl));
	
	D_FF_5 passRn3					(.clk(clk), .reset(reset), .q(EX_MEM_RegisterRn), .d(ID_EX_RegisterRn));
	D_FF_5 passRm3					(.clk(clk), .reset(reset), .q(EX_MEM_RegisterRm), .d(ID_EX_RegisterRm));
	D_FF_5 passRd3					(.clk(clk), .reset(reset), .q(EX_MEM_RegisterRd), .d(ID_EX_RegisterRd));

//	D_FF_64 passCondAddr19_3	(.clk(clk), .reset(reset), .q(EX_MEM_CondAddr19), .d(ID_EX_CondAddr19));
//	D_FF_64 passBrAddr26_3 		(.clk(clk), .reset(reset), .q(EX_MEM_BrAddr26), .d(ID_EX_BrAddr26));
//	D_FF_64 passPC_3 				(.clk(clk), .reset(reset), .q(EX_MEM_currentPC), .d(ID_EX_currentPC));
	D_FF_64 passReadData2_3 	(.clk(clk), .reset(reset), .q(EX_MEM_ReadData2), .d(ID_EX_ReadData2));
	D_FF_64 passALUoutput3		(.clk(clk), .reset(reset), .q(EX_MEM_ALU_output), .d(ALU_output));
	
	D_FF_64 passMultAluShiftData (.clk(clk), .reset(reset), .q(EX_MEM_mult_alu_shift_data), .d(mult_alu_shift_data));
	
	assign EX_MEM_currentPC = ID_EX_currentPC;
	assign EX_MEM_UncondBr = ID_EX_UncondBr;
	assign EX_MEM_Branch = ID_EX_Branch;
	assign EX_MEM_CondAddr19 = ID_EX_CondAddr19;
	assign EX_MEM_BrAddr26 = ID_EX_BrAddr26;

/**************************************************************************************************************/



/**************************************************************************************************************/	
/* Find input and output of data memory */
	datamem findInputOutputDataMem (.address(EX_MEM_ALU_output), .write_enable(EX_MEM_MemWrite), 
											  .read_enable(EX_MEM_MemRead), .write_data(EX_MEM_ReadData2), 
											  .clk(clk), .xfer_size(4'b1000), .read_data(dataMemOutput));
											  
/**************************************************************************************************************/	




/**************************************************************************************************************/
/* MEM/WB PIPELINE REGISTER CONTENTS */

//	logic 						MEM_WB_SubAdd, 
//									MEM_WB_Flag, 
//									MEM_WB_Reg2Loc,
//									MEM_WB_ALUsrc, 
//									MEM_WB_MemToReg, 
//									MEM_WB_RegWrite, 
//									MEM_WB_MemRead, 
//									MEM_WB_MemWrite, 
//									MEM_WB_UncondBr, 
//									MEM_WB_Branch, 
//									MEM_WB_Mult,
//									MEM_WB_Shift;
//	logic [2:0] 				MEM_WB_alu_cntrl;
//	
//	logic [63:0]				MEM_WB_CondAddr19,
//									MEM_WB_BrAddr26,
//									MEM_WB_dataMemOutput,
//									MEM_WB_mult_alu_shift_data;
//									
//	logic [4:0]					MEM_WB_RegisterRn,
//									MEM_WB_RegisterRm,
//									MEM_WB_RegisterRd;
	
	D_FF passSubAdd4 				(.clk(clk), .reset(reset), .q(MEM_WB_SubAdd), .d(EX_MEM_SubAdd));
	D_FF passFlag4 				(.clk(clk), .reset(reset), .q(MEM_WB_Flag), 	.d(EX_MEM_Flag));
	D_FF passReg2Loc4 	  		(.clk(clk), .reset(reset), .q(MEM_WB_Reg2Loc), .d(EX_MEM_Reg2Loc));
	D_FF passALUsrc4 	  			(.clk(clk), .reset(reset), .q(MEM_WB_ALUsrc), .d(EX_MEM_ALUsrc));
	D_FF passMemToReg4	  		(.clk(clk), .reset(reset), .q(MEM_WB_MemToReg), .d(EX_MEM_MemToReg));
	D_FF passRegWrite4 			(.clk(clk), .reset(reset), .q(MEM_WB_RegWrite), .d(EX_MEM_RegWrite));
	D_FF passMemRead4	   		(.clk(clk), .reset(reset), .q(MEM_WB_MemRead), .d(EX_MEM_MemRead));
	D_FF passMemWrite4	   	(.clk(clk), .reset(reset), .q(MEM_WB_MemWrite), .d(EX_MEM_MemWrite));
	D_FF passUncondBr4			(.clk(clk), .reset(reset), .q(MEM_WB_UncondBr), .d(EX_MEM_UncondBr));
	D_FF passBranch4				(.clk(clk), .reset(reset), .q(MEM_WB_Branch), .d(EX_MEM_Branch));
	D_FF passMult4					(.clk(clk), .reset(reset), .q(MEM_WB_Mult), .d(EX_MEM_Mult));
	D_FF passShift4				(.clk(clk), .reset(reset), .q(MEM_WB_Shift), .d(EX_MEM_Shift));
	
	D_FF_3 pass_alu_cntrl4		(.clk(clk), .reset(reset), .q(MEM_WB_alu_cntrl), .d(EX_MEM_alu_cntrl));
	
	D_FF_5 passRn4					(.clk(clk), .reset(reset), .q(MEM_WB_RegisterRn), .d(EX_MEM_RegisterRn));
	D_FF_5 passRm4					(.clk(clk), .reset(reset), .q(MEM_WB_RegisterRm), .d(EX_MEM_RegisterRm));
	D_FF_5 passRd4					(.clk(clk), .reset(reset), .q(MEM_WB_RegisterRd), .d(EX_MEM_RegisterRd));

	D_FF_64 passCondAddr19_4	(.clk(clk), .reset(reset), .q(MEM_WB_CondAddr19), .d(EX_MEM_CondAddr19));
	D_FF_64 passBrAddr26_4 		(.clk(clk), .reset(reset), .q(MEM_WB_BrAddr26), .d(EX_MEM_BrAddr26));
	D_FF_64 passMultAluShiftData4 (.clk(clk), .reset(reset), .q(MEM_WB_mult_alu_shift_data), .d(EX_MEM_mult_alu_shift_data));
	
	assign MEM_WB_dataMemOutput = dataMemOutput;
	
/**************************************************************************************************************/
	




	
endmodule



module PipelinedCPU_testbench();
	
	parameter ClockDelay = 5000;
	logic clk, reset;
//	logic [63:0] dataMemOutput;
	
	PipelinedCPU dut(.clk, .reset);
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay ) clk <= ~clk;
	end
	integer i;
	initial begin
		@(posedge clk);
		reset <= 1;
		@(posedge clk);
		reset <= 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		for(i = 0; i < 500; i++) begin
			@(posedge clk);
		end
		
		$stop;
	end


endmodule





