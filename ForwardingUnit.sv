module ForwardingUnit(EX_MEM_RegWrite, EX_MEM_RegisterRd, ID_EX_RegisterRn, ID_EX_RegisterRm,
							 MEM_WB_RegWrite, MEM_WB_RegisterRd, ForwardA, ForwardB);

	input logic EX_MEM_RegWrite, MEM_WB_RegWrite;
	input logic [4:0] EX_MEM_RegisterRd, ID_EX_RegisterRn, ID_EX_RegisterRm, MEM_WB_RegisterRd;
	output logic [1:0] ForwardA, ForwardB;
	
	
	always_comb begin
		if(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 5'd31) && (EX_MEM_RegisterRd == ID_EX_RegisterRn))
			ForwardA = 2'b10;
		else if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 5'd31) && (~(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 5'd31)
																							&& (EX_MEM_RegisterRd == ID_EX_RegisterRn)))
										 && (MEM_WB_RegisterRd == ID_EX_RegisterRn))
			ForwardA = 2'b01;
		else
			ForwardA = 2'b00;
	end
		
	always_comb begin
		if(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 5'd31) && (EX_MEM_RegisterRd == ID_EX_RegisterRm))
			ForwardB = 2'b10;
		else if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 5'd31) && (~(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 5'd31)
																							&& (EX_MEM_RegisterRd == ID_EX_RegisterRm)))
										 && (MEM_WB_RegisterRd == ID_EX_RegisterRm))
			ForwardB = 2'b01;
		else
			ForwardB = 2'b00;
	end
		
endmodule
