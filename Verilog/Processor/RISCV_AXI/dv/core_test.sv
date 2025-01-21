// semaphore sem = new(1);
int count;
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
    count = 0;
    fork
        begin
            reset = 1'b1; 
            init();
            #20 reset = 1'b0;
        end
        begin
            #15
            testcase();
        end
        begin
            #15
            wait_pc_change();
            forever begin
                #1 inst_check(inst, pc_o, 1);
            end    
        end
        begin
            #15
            wait_pc_change();
            wait_pc_change();
            forever begin
                #1 inst_check(inst, pc_o, 2);
            end    
        end
        begin
            #15
            wait_pc_change();
            wait_pc_change();
            wait_pc_change();
            forever begin
                #1 inst_check(inst, pc_o, 3);
            end    
        end
        begin
            #15
            wait_pc_change();
            wait_pc_change();
            wait_pc_change();
            wait_pc_change();
            forever begin
                #1 inst_check(inst, pc_o, 4);
            end    
        end
        begin
            #15
            wait_pc_change();
            wait_pc_change();
            wait_pc_change();
            wait_pc_change();
            wait_pc_change();
            forever begin
                #1 inst_check(inst, pc_o, 5);
            end    
        end
        //         begin
        //     #15
        //     forever begin
        //         wait_pc_change();
        //         #1 inst_check(inst, pc_o, 1);
        //     end    
        // end
    join
end