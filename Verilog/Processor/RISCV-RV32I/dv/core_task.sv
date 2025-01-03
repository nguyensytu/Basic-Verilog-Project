task init();
    meip = 1'b0;
    mtip = 1'b0;
    msip = 0;
    inst_access_fault = 1'b0;
    data_err = 1'b0;
    data_stall = 1'b0;
    inst = 32'h13; // nop instruction addi x0,x0,0
    fast_irq = 16'b0;
endtask
task write_inst(logic[6:0] opcode, logic[2:0] funct3);
    inst[6:0] = opcode;
    inst[11:7] = $random;
    inst[14:12] = funct3;
    inst[31:15] = $random;
    $display("[%6t] pc=%8h, opcode=%s", $time, pc, legal_inst0.opcode_to_string(opcode));
    @(posedge clk);
endtask 
task write_load(logic[11:0] offset, logic[4:0] rs1, logic[2:0] funct3, logic[4:0] rd);
    inst[6:0] = load;
    inst[11:7] = rd;
    inst[14:12] = funct3;
    inst[19:15] = rs1;
    inst[31:20] = offset[11:0];
    // $display("[%6t] pc=%8h, funct3 = %1h, offset = %3h", $time, pc, funct3, offset);
    // $display("[%6t] pc=%8h, opcode=%s", $time, pc, legal_inst0.opcode_to_string(load));
    wait_pc_change();
endtask 
task write_store(logic[11:0] offset, logic[4:0] rs2, logic[4:0] rs1, logic[2:0] funct3);
    inst[6:0] = store;
    inst[11:7] = offset[4:0];
    inst[14:12] = funct3;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[31:25] = offset[11:5];
    // $display("[%6t] pc=%8h, funct3 = %1h, offset = %d, rs2 = %2h", $time, pc, funct3, offset, rs2);
    // $display("[%6t] pc=%8h, opcode=%s", $time, pc, legal_inst0.opcode_to_string(store));
    wait_pc_change();
endtask 
task write_alu_imm(logic[11:0] imm, logic[4:0] rs1, logic[2:0] funct3, logic[4:0] rd);
    inst[6:0] = alu_imm;
    inst[11:7] = rd;
    inst[14:12] = funct3;
    inst[19:15] = rs1;
    inst[31:20] = imm[11:0];
    // $display("[%6t] pc=%8h, funct3 = %1h, imm = %d, rs2 = %2h", $time, pc, funct3, , rs2);
    // $display("[%6t] pc=%8h, opcode=%s", $time, pc, legal_inst0.opcode_to_string(store));
    wait_pc_change();
endtask 
task write_alu(logic[6:0] funct7, logic[4:0] rs2, logic[4:0] rs1, logic[2:0] funct3, logic[4:0] rd);
    inst[6:0] = alu;
    inst[11:7] = rd;
    inst[14:12] = funct3;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[31:25] = funct7;
    // $display("[%6t] pc=%8h, funct3 = %1h, offset = %d, rs2 = %2h", $time, pc, funct3, offset, rs2);
    // $display("[%6t] pc=%8h, opcode=%s", $time, pc, legal_inst0.opcode_to_string(store));
    wait_pc_change();
endtask 
task  wait_pc_change();
    @(posedge clk)
    if(pc == if_pc)
        wait_pc_change();
endtask 
task taskName();
    
endtask 

