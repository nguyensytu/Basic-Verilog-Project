initial begin
    legal_lui0 = new();
    legal_auipc0 = new();
    legal_load0 = new();
    legal_store0 = new();
    legal_alu0 = new();
    legal_alu_imm0 = new();
    legal_branch0 = new();
    legal_jal0 = new();
    legal_jalr0 = new();
    legal_csr0 = new();
    fork
        begin
            a_resetn = 1'b0; 
            init_riscv();
            #20 a_resetn = 1'b1;
            testcase();
        end
        begin
            #25
            // wait_pc_change();
            forever begin
                #1
                if(~master.inst_stall && ~master.cpu.if_stall)
                    inst_check(master.cpu.inst, master.cpu.if_pc, 1);
                else
                    @(posedge a_clk);
            end    
        end
        begin
            #25
            // wait_pc_change();
            wait_pc_change();
            forever begin
                #1
                if(~master.inst_stall && ~master.cpu.if_stall)
                    inst_check(master.cpu.inst, master.cpu.if_pc, 2);
                else
                    @(posedge a_clk);
            end    
        end
        begin
            #25
            // wait_pc_change();
            wait_pc_change();
            wait_pc_change();
            forever begin
                #1
                if(~master.inst_stall && ~master.cpu.if_stall)
                    inst_check(master.cpu.inst, master.cpu.if_pc, 3);
                else
                    @(posedge a_clk);
            end    
        end
        begin
            #25
            // wait_pc_change();
            wait_pc_change();
            wait_pc_change();
            wait_pc_change();
            forever begin
                #1
                if(~master.inst_stall && ~master.cpu.if_stall)
                    inst_check(master.cpu.inst, master.cpu.if_pc, 4);
                else
                    @(posedge a_clk);
            end    
        end
        begin
            #25
            // wait_pc_change();
            wait_pc_change();
            wait_pc_change();
            wait_pc_change();
            wait_pc_change();
            forever begin
                #1
                if(~master.inst_stall && ~master.cpu.if_stall)
                    inst_check(master.cpu.inst, master.cpu.if_pc, 5);
                else
                    @(posedge a_clk);
            end    
        end
    join
end