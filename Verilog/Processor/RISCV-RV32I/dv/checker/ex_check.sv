task ex_check();
    static int count_ex = 0;
    static string inst_string;
    logic [6:0] funct7;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] rd;
    logic [6:0] opcode;
    logic [31:0] value_rs2;
    logic [31:0] value_rs1;
    logic [31:0] value_rd;
    logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
    @(posedge clk);
    funct7 = idex_inst[31:25];
    rs2 = idex_inst[24:20];
    rs1 = idex_inst[19:15];
    funct3 = idex_inst[14:12];
    rd = idex_inst[11:7];
    opcode = idex_inst[6:0];
    value_rs2 = uut.RF.register_bank[idex_inst[24:20]];
    value_rs1 = uut.RF.register_bank[idex_inst[19:15]];
    value_rd = uut.RF.register_bank[idex_inst[11:7]];
    imm_i = {{20{idex_inst[31]}}, idex_inst[31:20]};
    imm_b = {{20{idex_inst[31]}}, idex_inst[7], idex_inst[30:25], idex_inst[11:8], 1'b0};
    imm_j = {{12{idex_inst[31]}}, idex_inst[19:12], idex_inst[20], idex_inst[30:21], 1'b0};
    if(idex_inst != ifid_inst) begin
        inst_string = opcode_to_string(opcode);
        case (opcode)
            branch: begin
                write_branch_check(rs2, rs1, funct3, value_rs2, value_rs1, imm_b);
                $display(" with offset = %8h", imm_b);
                // $display("count ex = %d", count_ex);
            end 
            jal: begin
                write_check_ex((uut.pc == (idex_pc + imm_j)), inst_string);
                $display(" with offset = %8h", imm_j);
                // $display("count ex = %d", count_ex);
            end
            jalr: begin
                write_check_ex((uut.pc == (value_rs1 + imm_i)), inst_string);
                $display(" with rs1[%2h] = %8h, offset = %8h", rs1, value_rs1, imm_i);
                // $display("count ex = %d", count_ex);
            end 
        endcase
        count_ex = count_ex + 1;
    end
endtask
task write_check_ex(logic bit_check, string inst_string);
    if(bit_check == 1)
        $write("[%6t] pc=%8h, PC %s check correct", $time, idex_pc, inst_string);
    else 
        $write("[%6t] pc=%8h, PC %s check incorrect", $time, idex_pc, inst_string);
endtask 

task write_branch_check(logic[4:0] rs2, logic[4:0] rs1, logic[2:0] funct3, logic[31:0] value_rs2, logic[31:0] value_rs1, logic[31:0] imm_b);
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
        $write("[%6t] pc=%8h, %s take branch, ", $time, idex_pc, inst_string);
    else    
        $write("[%6t] pc=%8h, %s do not take branch, ", $time, idex_pc, inst_string);        
    $display(" with rs1[%2h] = %8h, rs2[%2h] = %8h ", rs1, value_rs1, rs2, value_rs2);
    write_check_ex((take_branch ? (uut.pc == idex_pc + imm_b) : (uut.pc == idex_pc + 32'hc)), inst_string);
endtask 
