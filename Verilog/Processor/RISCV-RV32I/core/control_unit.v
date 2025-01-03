module control_unit (
	input [31:0] inst,
	output reg [3:0] alu_func,
	output reg [1:0] csr_alu_func,
	output reg ctrl_imm, L, B, J, w_csr, wmem, wb, mem_sign, ctrl_branch_addr, ctrl_src1,
	output reg [1:0] mem_len,
	output ecall, ebreak, mret, illegal_instr
);
	// Signal declaration
	wire [6:0] opcode;
	wire [2:0] funct3;
	wire [6:0] funct7;
	//
	reg illegal_op;
	//
	assign opcode = inst[6:0];
	assign funct3 = inst[14:12];
	assign funct7 = inst[31:25];
	always @(*) begin
		illegal_op = 1'b1;
		ctrl_imm = 1'b0;
		L = 1'b0;
		B = 1'b0;
		J = 1'b0;
		w_csr = 1'b0;
		wmem = 1'b0;
		wb = 1'b0;
		mem_len = 2'b00;
		mem_sign = 1'b0;
		ctrl_branch_addr = 1'b0;
		ctrl_src1 = 1'b0; // 1 ~ pc, 0 ~ data
		alu_func = 4'b0000;
		csr_alu_func = 2'd0;
		casez (opcode)
			7'b1100011: begin //BEQ, BNE, BLT, BGE, BLTU, BGEU
				illegal_op = 1'b0;
				ctrl_imm = 1'b1;
				B = 1'b1;
				ctrl_branch_addr = 1'b1;
				case (funct3)
					3'b000: alu_func = 4'b1010; //BEQ
					3'b001: alu_func = 4'b1011; //BNE
					3'b100: alu_func = 4'b0110; //BLT
					3'b101: alu_func = 4'b1101; //BGE
					3'b110: alu_func = 4'b0101; //BLTU
					3'b111: alu_func = 4'b1100; //BGEU
				endcase
			end 
			7'b0110111: begin //LUI
				illegal_op = 1'b0;
				ctrl_imm = 1'b1;
				wb = 1'b1;
				alu_func = 4'b1111;
			end
			7'b0010111: begin //AUIPC
				illegal_op = 1'b0;
				ctrl_imm = 1'b1;
				wb = 1'b1;
				ctrl_src1 = 1'b1;
			end
			7'b110?111: begin //JAL, JALR
				illegal_op = 1'b0;
				ctrl_imm = 1'b1;
				wb = 1'b1;
				J = 1'b1;
				case (opcode[3])
					1'b1: ctrl_branch_addr = 1'b1; //JAL
				endcase
				ctrl_src1 = 1'b1;
				alu_func = 4'b1110;
			end
			7'b0000011: begin //LB, LH, LW, LBU, LHU
				illegal_op = 1'b0;
				ctrl_imm = 1'b1;
				L = 1'b1;
				wb = 1'b1;
				case(funct3)
					3'b000: begin mem_sign = 1'b1; mem_len = 2'd0; end //LB
					3'b001: begin mem_sign = 1'b1; mem_len = 2'd1; end //LH
					3'b010:	begin mem_sign = 1'b1; mem_len = 2'd2; end //LW
					3'b100: begin mem_len = 2'd0; end //LBU
					3'b101: begin mem_len = 2'd1; end //LHU
				endcase
			end
			7'b0100011: begin //SB, SH, SW
				illegal_op = 1'b0;
				ctrl_imm = 1'b1;
				wmem = 1'b1;
				case(funct3)
					3'b000: mem_len = 2'b00; //SB
					3'b001: mem_len = 2'b01; //SH
					3'b010: mem_len = 2'b10; //SW
				endcase
			end
			7'b0?10011: begin //ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI, ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
				illegal_op = 1'b0;
				case (opcode[5])
					1'b0: ctrl_imm = 1'b1;  
				endcase
				wb = 1'b1;
				case(funct3)
					3'b000: begin //ADD, ADDI, SUB
						if(opcode[5]) //see if it is an add or a subtract
							alu_func = {3'b0,funct7[5]}; //ADD, SUB
						else
							alu_func = 4'b0; //ADDI
					end
					3'b001: alu_func = 4'b0111; //SLL, SLLI
					3'b010: alu_func = 4'b0110; //SLT, SLTI
					3'b011: alu_func = 4'b0101; //SLTU, SLTIU
					3'b100: alu_func = 4'b0010; //XOR, XORI
					3'b101: begin //SRA, SRAI, SRL, SRLI
						if(funct7[5])
							alu_func = 4'b1001; //SRA, SRAI
						else
							alu_func = 4'b1000; //SRL, SRLI
					end
					3'b110: alu_func = 4'b0011; //OR, ORI
					3'b111:	alu_func = 4'b0100; //AND, ANDI
				endcase
			end
			7'b1110011: begin //CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI
				illegal_op = 1'b0;
				w_csr = 1'b1;
				wb = 1'b1;
				casez(funct3)
					3'b?01: csr_alu_func = 2'd0; //RW,RWI
					3'b?10: csr_alu_func = 2'd1; //RS,RSI
					3'b?11: csr_alu_func = 2'd2; //RC,RCI
				endcase
				case (funct3[2])
					1'b1: ctrl_imm = 1'b1; 
				endcase
			end
		endcase
	end
	assign illegal_instr = (opcode == 7'b1100011 & funct3[2:1] == 2'b01)
						 | (opcode == 7'b1101011 & funct3 == 3'b0)
						 | (opcode == 7'b0000011 & (funct3 == 3'b011 | funct3 == 3'b110 | funct3 == 3'b111))
						 | (opcode == 7'b0100011 & (funct3 != 3'b000 & funct3 != 3'b001 & funct3 != 3'b010))
						 | (opcode == 7'b0110011 & (funct7 != 7'd1 & funct7 != 7'd0 & (funct7 != 7'b0100000 & (funct3 != 3'b000 & funct3 != 3'b101))))
						 | (opcode == 7'b0010011 & (funct7 != 7'd1 & funct7 != 7'd0 & (funct7 != 7'b0100000 & funct3 != 3'b101)))
						 | (opcode == 7'b1110011 & !(ecall | ebreak | mret) & (funct3 == 3'b100 | funct3 == 3'b000))
						 | illegal_op ? 1'b1 : 1'b0;
	assign ecall  = inst == 32'h0000_0073;
	assign ebreak = inst == 32'h0010_0073;
	assign mret   = inst == 32'h3020_0073;
endmodule