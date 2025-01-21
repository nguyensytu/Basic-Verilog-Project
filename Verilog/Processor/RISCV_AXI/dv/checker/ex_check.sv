task ex_check(
    logic [4:0] rs2, logic [4:0] rs1, logic [2:0] funct3, logic [4:0] rd, logic [6:0] opcode, logic [31:0] pc_check,
    logic [31:0] value_rs2, logic [31:0] value_rs1, logic [31:0] imm_i, logic [31:0] imm_b, logic [31:0] imm_j
);
    static int count_ex = 0;
    static string inst_string;
    if(idex_inst != ifid_inst) begin
        inst_string = opcode_to_string(opcode);
        case (opcode)
            branch: begin
                write_branch_check(rs2, rs1, funct3, pc_check, value_rs2, value_rs1, imm_b);
                $display(" with offset = %8h", imm_b);
                // $display("count ex = %d", count_ex);
            end 
            jal: begin
                write_check_ex((uut.pc == (pc_check + imm_j)), inst_string, pc_check);
                $display(" with offset = %8h", imm_j);
                // $display("count ex = %d", count_ex);
            end
            jalr: begin
                write_check_ex((uut.pc == (value_rs1 + imm_i)), inst_string, pc_check);
                $display(" with rs1[%2h] = %8h, offset = %8h", rs1, value_rs1, imm_i);
                // $display("count ex = %d", count_ex);
            end 
        endcase
        count_ex = count_ex + 1;
    end
endtask
task write_check_ex(logic bit_check, string inst_string, logic [31:0] pc_check);
    if(bit_check == 1)
        $write("[%1t] pc=%8h, PC %s check correct", $time, pc_check, inst_string);
    else 
        $write("[%1t] pc=%8h, PC %s check incorrect", $time, pc_check, inst_string);
endtask 

task write_branch_check(logic[4:0] rs2, logic[4:0] rs1, logic[2:0] funct3, logic [31:0] pc_check, logic[31:0] value_rs2, logic[31:0] value_rs1, logic[31:0] imm_b);
    static string inst_string;
    logic take_branch;
    inst_string = funct3_branch_to_string(funct3);
    take_branch = 1'b0;
    case(funct3)
        beq: begin
            if(value_rs1 == value_rs2)
                take_branch = 1'b1;
        end
        bne: begin
            if(value_rs1 != value_rs2)
                take_branch = 1'b1;
        end
        blt: begin
            if($signed(value_rs1) < $signed(value_rs2))
                take_branch = 1'b1;
        end
        bge: begin
            if($signed(value_rs1) >= $signed(value_rs2))
                take_branch = 1'b1;
        end
        bltu: begin
            if(value_rs1 < value_rs2)
                take_branch = 1'b1;
        end
        bgeu: begin
            if(value_rs1 >= value_rs2)
                take_branch = 1'b1;
        end
    endcase
    if(take_branch)
        $write("[%1t] pc=%8h, %s take branch, ", $time, pc_check, inst_string);
    else    
        $write("[%1t] pc=%8h, %s do not take branch, ", $time, pc_check, inst_string);        
    $display(" with rs1[%2h] = %8h, rs2[%2h] = %8h ", rs1, value_rs1, rs2, value_rs2);
    write_check_ex((take_branch ? (uut.pc == pc_check + imm_b) : (uut.pc == pc_check + 32'hc)), inst_string, pc_check);
endtask 
