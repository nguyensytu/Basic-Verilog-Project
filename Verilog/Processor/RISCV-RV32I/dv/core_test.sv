initial begin
    legal_load0 = new();
    legal_store0 = new();
    reset = 1'b1; 
    init();
    #20 reset = 1'b0;
    @(posedge clk);
    fork
        begin
            testcase_3();
        end
        begin
            forever begin
                wb_check();
            end    
        end
        begin
            forever begin
                mem_check();
            end    
        end
    join
end