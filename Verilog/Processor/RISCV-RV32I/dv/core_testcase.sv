// task testcase(); // lui
//     forever begin
//         legal_lui0.randomize();
//         write_inst(inst, legal_lui0.inst);
//     end
// endtask

// task testcase(); // load
//     forever begin
//         legal_load0.randomize() with {offset_upper[9] == 1'b0; rs1 == 5'b0;};
//         write_inst(inst, legal_load0.inst);
//     end
// endtask

// task testcase(); // store
//     int i;
//     for(i=0; i<32; i = i+1) begin
//         legal_load0.randomize() with {offset_upper[9] == 1'b0; rs1 == 5'b0;};
//         write_inst(inst, legal_load0.inst);    
//     end
//     forever begin
//         legal_store0.randomize() with{offset_upper[9] == 1'b0; rs1 == 5'b0;};
//         write_inst(inst, legal_store0.inst);       
//     end
// endtask

// task testcase(); // data hazard & data forward
//     forever begin
//         legal_load0.randomize() with {offset_upper[9] == 1'b0; rs1 == 5'b0;};
//         legal_store0.randomize() with{offset_upper[9] == 1'b0; rs1 == 5'b0; rs2 == legal_load0.rd;};
//         write_inst(inst, legal_load0.inst);  
//         write_inst(inst, legal_store0.inst);  
//     end
// endtask

// task testcase(); // data stall
//     fork
//         begin
//             forever begin
//                 legal_load0.randomize() with {offset_upper[9] == 1'b0; rs1 == 5'b0;};
//                 legal_store0.randomize() with{offset_upper[9] == 1'b0; rs1 == 5'b0; rs2 == legal_load0.rd;};
//                 write_inst(inst, legal_load0.inst);  
//                 write_inst(inst, legal_store0.inst);
//             end
//         end
//         begin
//             forever begin
//                 if((idex_inst[6:0] == load || idex_inst[6:0] == store) && ~uut.data_stall) begin
//                     data_stall = 1'b1;
//                     @(posedge clk);
//                     @(posedge clk);
//                     data_stall = 1'b0;
//                 end
//                 @(posedge clk);
//             end
//         end
//     join
// endtask

// task testcase(); // alu
//     int i;
//     for(i=0; i<32; i = i+1) begin
//         legal_load0.randomize() with {offset_upper[9] == 1'b0; rs1 == 5'b0;};
//         write_inst(inst, legal_load0.inst);    
//     end
//     forever begin
//         legal_alu0.randomize();
//         write_inst(inst, legal_alu0.inst);  
//     end
// endtask

// task testcase(); // alu_imm
//     int i;
//     for(i=0; i<32; i = i+1) begin
//         legal_load0.randomize() with {offset_upper[9] == 1'b0; rs1 == 5'b0;};
//         write_inst(inst, legal_load0.inst);    
//     end
//     forever begin
//         legal_alu_imm0.randomize();
//         write_inst(inst, legal_alu_imm0.inst); 
//     end
// endtask

// task testcase(); // jal
//     forever begin 
//         legal_jal0.randomize();
//         write_inst(inst, legal_jal0.inst); 
//     end
// endtask

// task testcase(); // jalr
//     // int i;
//     // for(i=0; i<32; i = i+1) begin
//     //     legal_load0.randomize() with {offset_upper[9] == 1'b0;};
//     //     write_load(inst, {legal_load0.offset_upper, legal_load0.offset_lowwer}, 5'b0, legal_load0.funct3, legal_load0.rd);
//     // end
//     forever begin
//         legal_jalr0.randomize();
//        write_inst(inst, legal_jalr0.inst);
//     end
// endtask

// task testcase(); // branch
//     int i;
//     for(i=0; i<32; i = i+1) begin
//         legal_load0.randomize() with {offset_upper[9] == 1'b0; rs1 == 5'b0;};
//         write_inst(inst, legal_load0.inst);   
//     end
//     forever begin
//         legal_branch0.randomize();
//         write_inst(inst, legal_branch0.inst);   
//     end
// endtask

// task testcase(); // csrr
//     int i;
//     for(i=0; i<32; i = i+1) begin
//         legal_load0.randomize() with {offset_upper[9] == 1'b0; rs1 == 5'b0;};
//         write_inst(inst, legal_load0.inst);   
//     end
//     forever begin
//         legal_csr0.randomize() with {legal_cases != 3'b000;};
//         write_inst(inst, legal_csr0.inst);   
//     end
// endtask

// task testcase(); // mret
//     int i;
//     for(i=0; i<32; i = i+1) begin
//         legal_load0.randomize() with {offset_upper[9] == 1'b0; rs1 == 5'b0;};
//         write_inst(inst, legal_load0.inst);   
//     end
//     legal_csr0.randomize() with {legal_cases == 3'b001; imm == 12'h341;};
//     write_inst(inst, legal_csr0.inst); 
//     legal_store0.randomize() with{offset_upper[9] == 1'b0; rs1 == 5'b0;};
//     write_inst(inst, legal_store0.inst); 
//     legal_store0.randomize() with{offset_upper[9] == 1'b0; rs1 == 5'b0;};
//     write_inst(inst, legal_store0.inst); 
//     legal_store0.randomize() with{offset_upper[9] == 1'b0; rs1 == 5'b0;};
//     write_inst(inst, legal_store0.inst);
//     // legal_csr0.randomize() with {legal_cases != 3'b000;};
//     write_inst(inst, mret);   
//     forever begin
//         legal_store0.randomize() with{offset_upper[9] == 1'b0; rs1 == 5'b0;};
//         write_inst(inst, legal_store0.inst);    
//     end
// endtask
task testcase(); // ecall 
    int i;
    for(i=0; i<32; i = i+1) begin
        legal_load0.randomize() with {offset_upper[9] == 1'b0; rs1 == 5'b0;};
        write_inst(inst, legal_load0.inst);   
    end
    legal_csr0.randomize() with {legal_cases == 3'b001; imm == 12'h341;};
    write_inst(inst, legal_csr0.inst); 
    legal_store0.randomize() with{offset_upper[9] == 1'b0; rs1 == 5'b0;};
    write_inst(inst, legal_store0.inst); 
    legal_store0.randomize() with{offset_upper[9] == 1'b0; rs1 == 5'b0;};
    write_inst(inst, legal_store0.inst); 
    legal_store0.randomize() with{offset_upper[9] == 1'b0; rs1 == 5'b0;};
    write_inst(inst, legal_store0.inst);
    // legal_csr0.randomize() with {legal_cases != 3'b000;};
    write_inst(inst, ecall);   
    forever begin
        legal_store0.randomize() with{offset_upper[9] == 1'b0; rs1 == 5'b0;};
        write_inst(inst, legal_store0.inst);    
    end
endtask