task init_riscv();
    meip = 1'b0;
    mtip = 1'b0;
    msip = 1'b0;
    fast_irq = 16'b0;
endtask
task wait_pc_change();
    @(posedge a_clk)
    if(if_pc_reg == if_pc) begin
        wait_pc_change();
    end
endtask 
task testcase(); // alu_imm
    int i;
    for(i=0; i<16; i = i+1) begin
        legal_alu_imm0.randomize();
        {slave.AHB_slave.device0.device0.regs[4*i + 3], 
         slave.AHB_slave.device0.device0.regs[4*i + 2], 
         slave.AHB_slave.device0.device0.regs[4*i + 1], 
         slave.AHB_slave.device0.device0.regs[4*i]} = legal_alu_imm0.inst;
    end
endtask       
// task testcase(); // store
//     int i;
//     for(i=0; i<16; i = i+1) begin
//         legal_store0.randomize() with {offset_upper[9:0] == i;};
//         {slave.AHB_slave.device0.device0.regs[4*i + 3], 
//          slave.AHB_slave.device0.device0.regs[4*i + 2], 
//          slave.AHB_slave.device0.device0.regs[4*i + 1], 
//          slave.AHB_slave.device0.device0.regs[4*i]} = legal_store0.inst;
//     end
// endtask   
// task testcase(); // store & alu
//     int i;
//     for(i=0; i<8; i = i+1) begin
//         legal_store0.randomize() with {offset_upper[9:0] == i;};
//         {slave.AHB_slave.device0.device0.regs[8*i + 3], 
//          slave.AHB_slave.device0.device0.regs[8*i + 2], 
//          slave.AHB_slave.device0.device0.regs[8*i + 1], 
//          slave.AHB_slave.device0.device0.regs[8*i]} = legal_store0.inst; 
//         legal_alu0.randomize();
//         {slave.AHB_slave.device0.device0.regs[8*i + 7], 
//          slave.AHB_slave.device0.device0.regs[8*i + 6], 
//          slave.AHB_slave.device0.device0.regs[8*i + 5], 
//          slave.AHB_slave.device0.device0.regs[8*i + 4]} = legal_alu0.inst;   
//     end
// endtask
// task testcase(); // load
//     int i;
//     for(i=0; i<16; i = i+1) begin
//         legal_load0.randomize() with {offset_upper[9:0] == i; rs1 == 5'b0;};
//         {slave.AHB_slave.device0.device0.regs[4*i + 3], 
//          slave.AHB_slave.device0.device0.regs[4*i + 2], 
//          slave.AHB_slave.device0.device0.regs[4*i + 1], 
//          slave.AHB_slave.device0.device0.regs[4*i]} = legal_load0.inst;
//     end
// endtask 

// task testcase(); // store & load
//     int i;
//     for(i=0; i<8; i = i+1) begin
//         legal_store0.randomize() with {offset_upper[9:0] == i;};
//         {slave.AHB_slave.device0.device0.regs[8*i + 3], 
//          slave.AHB_slave.device0.device0.regs[8*i + 2], 
//          slave.AHB_slave.device0.device0.regs[8*i + 1], 
//          slave.AHB_slave.device0.device0.regs[8*i]} = legal_store0.inst; 
//         legal_load0.randomize() with {offset_upper[9:0] == i; rs1 == 5'b0;};
//         {slave.AHB_slave.device0.device0.regs[8*i + 7], 
//          slave.AHB_slave.device0.device0.regs[8*i + 6], 
//          slave.AHB_slave.device0.device0.regs[8*i + 5], 
//          slave.AHB_slave.device0.device0.regs[8*i + 4]} = legal_load0.inst;   
//     end
// endtask