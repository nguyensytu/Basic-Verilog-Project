task id_check(
    logic[6:0] funct7, logic [4:0] rs2, logic [4:0] rs1, logic [2:0] funct3, logic [4:0] rd, logic [6:0] opcode, logic [31:0] pc_check,
    logic [31:0] imm_i, logic [31:0] imm_s, logic [31:0] imm_u
    );
    static string inst_string;
    logic[9:0] funct;
    if(ifid_pc != if_pc) begin
        inst_string = opcode_to_string(opcode);
        case (opcode)
            lui: begin
                $write("[%1t] pc=%8h, inst %s", $time, pc_check, inst_string);
                $display(" with rd[%2h], data_lui = %8h", rd, imm_u);
            end
            auipc: begin
                $write("[%1t] pc=%8h, inst %s", $time, pc_check, inst_string);
                $display(" with rd[%2h], data_auipc = %8h", rd, imm_u);
            end
            alu_imm: begin
                funct = {((funct3 == 3'b101 | funct3 == 3'b001) ? funct7[6:1] : 6'b0), 1'b0, funct3};
                inst_string = funct_alu_imm_to_string(funct);
                $write("[%1t] pc=%8h, inst %s", $time, pc_check, inst_string);
                $display(" with rs1[%2h] , imm = %3h, rd[%2h]", rs1, imm_i, rd);
            end
            alu: begin
                inst_string = funct_alu_to_string({funct7, funct3});
                $write("[%1t] pc=%8h, inst %s", $time, pc_check, inst_string);
                $display(" with rs2[%2h], rs1[%2h], rd[%2h]", rs2, rs1, rd);
            end
            load: begin
                inst_string = funct3_load_to_string(funct3);
                $write("[%1t] pc=%8h, inst %s", $time, pc_check, inst_string);
                $display(" with rd[%2h], imm = %8h", rd, imm_i); 
            end
            store: begin
                inst_string = funct3_store_to_string(funct3);
                $write("[%1t] pc=%8h, inst %s", $time, pc_check, inst_string);
                $display(" with rs2[%2h], imm = %8h", rs2, imm_s);
            end
            jal: begin
                $write("[%1t] pc=%8h, inst %s", $time, pc_check, inst_string);
                $display(" with rd[%2h]", rd);
            end
            jalr: begin
                $write("[%1t] pc=%8h, inst %s", $time, pc_check, inst_string);
                $display(" with rd[%2h]", rd);
            end
            default:
                $display("[%1t] pc=%8h, inst %s", $time, pc_check, inst_string);
        endcase
    end
endtask