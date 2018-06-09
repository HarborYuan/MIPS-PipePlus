`include "./alu_def.v"
module ALU(C,A,B,ALUOp);
	input  [31:0] 		A;
	input  [31:0]		B;
	input  [3:0]		ALUOp;	
	output reg[31:0]	C;

	initial
	begin
		C = 0;
	end
	
	always@(A or B or ALUOp)
	begin
		case (ALUOp)
			`ALU_ADD : C = A + B;
			`ALU_SUB : C = A - B;
			`ALU_SLT : C = $signed(A) < $signed(B) ? 1 : 0;
    		`ALU_SLTU: C = A < B ? 1 : 0;
			`ALU_XOR : C = A ^ B;
			`ALU_AND : C = A & B;
			`ALU_OR  : C = A | B;
			`ALU_NOR : C = ~(A | B);
			`ALU_LUI : C = {B[15:0] , 16'd0};
			`ALU_SLL : C = B << A[4:0];
			`ALU_SRL : C = B >> A[4:0];
			`ALU_SRA : C = (B >> A[4:0]) | ({32{B[31]}}<<(6'd32-{1'b0,A[4:0]}));
		endcase
	end
endmodule