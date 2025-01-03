task testcase_0(); // load
    //lui
    forever begin
        legal_load0.randomize() with {offset_upper[9] == 1'b0;};
        write_load({legal_load0.offset_upper, legal_load0.offset_lowwer}, 5'b0, legal_load0.funct3, legal_load0.rd);
    end
endtask
task testcase_1(); // store
    int i;
    for(i=0; i<32; i = i+1) begin
        legal_load0.randomize() with {offset_upper[9] == 1'b0;};
        write_load({legal_load0.offset_upper, legal_load0.offset_lowwer}, 5'b0, legal_load0.funct3, legal_load0.rd);

    end
    forever begin
        legal_store0.randomize() with{offset_upper[9] == 1'b0;};
        write_store({legal_store0.offset_upper, legal_store0.offset_lowwer}, $random, 5'b0, legal_store0.funct3);
    end
endtask
task testcase_2(); // data hazard & data forward
    forever begin
        legal_load0.randomize() with {offset_upper[9] == 1'b0;};
        legal_store0.randomize() with{offset_upper[9] == 1'b0;};
        write_load({legal_load0.offset_upper, legal_load0.offset_lowwer}, 5'b0, legal_load0.funct3, legal_load0.rd);
        write_store({legal_store0.offset_upper, legal_store0.offset_lowwer}, legal_load0.rd, 5'b0, legal_store0.funct3);
    end
endtask
task testcase_3(); // data stall
    fork
        begin
            forever begin
                legal_load0.randomize() with {offset_upper[9] == 1'b0;};
                legal_store0.randomize() with{offset_upper[9] == 1'b0;};
                write_load({legal_load0.offset_upper, legal_load0.offset_lowwer}, 5'b0, legal_load0.funct3, legal_load0.rd);
                write_store({legal_store0.offset_upper, legal_store0.offset_lowwer}, legal_load0.rd, 5'b0, legal_store0.funct3);
            end
        end
        begin
            forever begin
                @(posedge clk);
                if(req_mem) begin
                    if(exmem_inst[6:0] == load || exmem_inst[6:0] == store) begin
                        data_stall = 1'b1;
                        @(posedge clk);
                        @(posedge clk);
                    end
                end
                data_stall = 1'b0;
            end
        end
    join
endtask