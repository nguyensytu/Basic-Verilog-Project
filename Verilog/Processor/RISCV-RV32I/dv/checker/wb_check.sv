task wb_check();
    static int count_wb = 0;
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
    logic [31:0] memory_load, memory_store;
    @(posedge clk);
    funct7 = memwb_inst[31:25];
    rs2 = memwb_inst[24:20];
    rs1 = memwb_inst[19:15];
    funct3 = memwb_inst[14:12];
    rd = memwb_inst[11:7];
    opcode = memwb_inst[6:0];
    value_rs2 = uut.RF.register_bank[memwb_inst[24:20]];
    value_rs1 = uut.RF.register_bank[memwb_inst[19:15]];
    value_rd = uut.RF.register_bank[memwb_inst[11:7]];
    imm_i = {{20{memwb_inst[31]}}, memwb_inst[31:20]};
    imm_s = {{20{memwb_inst[31]}}, memwb_inst[31:25], memwb_inst[11:7]};
    imm_b = {{20{memwb_inst[31]}}, memwb_inst[7], memwb_inst[30:25], memwb_inst[11:8], 1'b0};
    imm_u = {memwb_inst[31:12], 12'b0};
    imm_j = {{12{memwb_inst[31]}}, memwb_inst[19:12], memwb_inst[20], memwb_inst[30:21], 1'b0};
    case (funct3)
        lb:
            memory_load = {{24{memory[imm_i + value_rs1][7]}}, memory[imm_i + value_rs1]};
        lh:
            memory_load = {{16{memory[imm_i + value_rs1 + 2'b01][7]}}, memory[imm_i + value_rs1 + 2'b01], memory[imm_i + value_rs1]};
        lbu:
            memory_load = {24'b0, memory[imm_i + value_rs1]};
        lhu:
            memory_load = {16'b0, memory[imm_i + value_rs1 + 2'b01], memory[imm_i + value_rs1]};
        default: 
            memory_load = {memory[imm_i + value_rs1 + 2'b11], memory[imm_i + value_rs1 + 2'b10], memory[imm_i + value_rs1 + 2'b01], memory[imm_i + value_rs1]};
    endcase
    case (funct3)
        sb:
            memory_store = {24'b0, memory[imm_s + value_rs1]};
        sh:
            memory_store = {16'b0, memory[imm_s + value_rs1 + 2'b01], memory[imm_s + value_rs1]};
        default: 
            memory_store = {memory[imm_s + value_rs1 + 2'b11], memory[imm_s + value_rs1 + 2'b10], memory[imm_s + value_rs1 + 2'b01], memory[imm_s + value_rs1]};
    endcase
    if(memwb_inst != exmem_inst) begin
        inst_string = opcode_to_string(opcode);
        case (opcode)
            lui: begin
                write_check(rd, (value_rd == imm_u), inst_string); 
                $display(" with rd[%2h] = %8h, data_lui = %8h", rd, value_rd, imm_u);
            end
            auipc: begin
                write_check(rd, (value_rd == imm_u), inst_string); 
                $display(" with rd[%2h] = %8h, data_auipc = %8h", rd, value_rd, imm_u);
            end
            alu_imm: begin
                write_alu_imm_check(funct7, funct3, rd, value_rs1, value_rd, imm_i);
                $display(" with rs1[%2h] = %8h, imm = %3h, rd[%2h] = %8h", rs1, value_rs1, imm_i, rd, value_rd);
            end
            alu: begin
                write_alu_check(funct7, funct3, rd, value_rs2, value_rs1, value_rd);
                $display(" with rs2[%2h] = %8h, rs1[%2h] = %8h, rd[%2h] = %8h", rs2, value_rs2, rs1, value_rs1, rd, value_rd);
            end
            load: begin
                inst_string = funct3_load_to_string(funct3);
                write_check(rd, (value_rd == memory_load), inst_string); 
                $display(" with rd[%2h] = %8h, memory[%1d] = %8h", rd, value_rd, imm_i + value_rs1, memory_load); 
            end
            store: begin
                write_store_check(funct3, value_rs2, memory_store); 
                $display(" with rs2[%2h] = %8h, memory[%1d] = %8h", rs2, value_rs2, imm_s + value_rs1, memory_store);
            end
            jal: begin
                write_check(rd, (value_rd == memwb_pc + 32'h4), inst_string); 
                $display(" with rd[%2h] = %8h", rd, value_rd);
            end
            jalr: begin
                write_check(rd, (value_rd == memwb_pc + 32'h4), inst_string); 
                $display(" with rd[%2h] = %8h", rd, value_rd);
            end
        endcase
        // $display("count_wb = %d", count_wb);
        count_wb = count_wb + 1;
    end
endtask
task write_check(logic[4:0] rd, logic bit_check, string inst_string);
    if(rd == 5'b0) 
        $write("[%6t] pc=%8h, Data %s to register x0", $time, memwb_pc, inst_string);
    else if(bit_check == 1)
        $write("[%6t] pc=%8h, Data %s check correct", $time, memwb_pc, inst_string);
    else 
        $write("[%6t] pc=%8h, Data %s check incorrect", $time, memwb_pc, inst_string);
endtask 
task write_store_check(logic[2:0] funct3, logic[31:0] value_rs2, logic[31:0] memory_store);
    static string inst_string;
    inst_string = funct3_store_to_string(funct3);
    case (funct3)
        sb: 
            write_check(3'b001, (memory_store[7:0] == value_rs2[7:0]), inst_string); 
        sh: 
            write_check(3'b001, (memory_store[15:0] == value_rs2[15:0]), inst_string);
        sw: 
            write_check(3'b001, (memory_store == value_rs2), inst_string);
    endcase
endtask 
task write_alu_check(logic[6:0] funct7, logic[2:0] funct3, logic[4:0] rd, logic[31:0] value_rs2, logic[31:0] value_rs1, logic[31:0] value_rd);
    static string inst_string;
    inst_string = funct_alu_to_string({funct7, funct3});
    case ({funct7, funct3})
        add: 
            write_check(rd, (value_rd == value_rs1 + value_rs2), inst_string); 
        sub: 
            write_check(rd, (value_rd == value_rs1 - value_rs2), inst_string);
        sll: 
            write_check(rd, (value_rd == value_rs1 << value_rs2[4:0]), inst_string);
        slt:
            write_check(rd, (value_rd == (($signed(value_rs1) < $signed(value_rs2)) ? 32'b1 : 32'b0)), inst_string);
        sltu:
            write_check(rd, (value_rd == ((value_rs1 < value_rs2) ? 32'b1 : 32'b0)), inst_string);
        xorj:
            write_check(rd, (value_rd == (value_rs1 ^ value_rs2)), inst_string);
        srl:
            write_check(rd, (value_rd == value_rs1 >> value_rs2[4:0]), inst_string);
        sra:
            write_check(rd, ($signed(value_rd) == $signed(value_rs1) >>> value_rs2[4:0]), inst_string);
        orj:
            write_check(rd, (value_rd == (value_rs1 | value_rs2)), inst_string);
        andj:
            write_check(rd, (value_rd == (value_rs1 & value_rs2)), inst_string);
    endcase
endtask 
task write_alu_imm_check(logic[6:0] funct7, logic[2:0] funct3, logic[4:0] rd, logic[31:0] value_rs1, logic[31:0] value_rd, logic[31:0] imm_i);
    static string inst_string;
    logic[9:0] funct;
    funct = {((funct3 == 3'b101 | funct3 == 3'b001) ? funct7[6:1] : 6'b0), 1'b0, funct3};
    inst_string = funct_alu_imm_to_string(funct);
    case (funct)
        addi: 
            write_check(rd, (value_rd == value_rs1 + imm_i), inst_string); 
        slli: 
            write_check(rd, (value_rd == value_rs1 << imm_i[4:0]), inst_string);
        slti:
            write_check(rd, (value_rd == (($signed(value_rs1) < $signed(imm_i)) ? 32'b1 : 32'b0)), inst_string);
        sltiu:
            write_check(rd, (value_rd == ((value_rs1 < imm_i) ? 32'b1 : 32'b0)), inst_string);
        xori:
            write_check(rd, (value_rd == (value_rs1 ^ imm_i)), inst_string);
        srli:
            write_check(rd, (value_rd == value_rs1 >> imm_i[4:0]), inst_string);
        srai:
            write_check(rd, ($signed(value_rd) == $signed(value_rs1) >>> imm_i[4:0]), inst_string);
        ori:
            write_check(rd, (value_rd == (value_rs1 | imm_i)), inst_string);
        andi:
            write_check(rd, (value_rd == (value_rs1 & imm_i)), inst_string);
    endcase
endtask 
