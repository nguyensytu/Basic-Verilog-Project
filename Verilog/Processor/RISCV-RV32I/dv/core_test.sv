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
            forever begin
                wb_check();
            end    
        end
        begin
            forever begin
                ex_check();
            end    
        end
    join
end