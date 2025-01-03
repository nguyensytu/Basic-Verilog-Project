task wb_check();
    static int count_wb = 0;
    @(negedge clk);
    lui_check(count_wb);
    load_check(count_wb);
    // alu_check();
    count_wb = count_wb + 1;
endtask
task lui_check(int count);
    if(wb_inst[6:0] == lui && wb_inst[11:7] == 5'b0) begin
        $display("[%6t] pc=%8h, Data lui to register x0", $time, wb_pc);
    end 
    else if(wb_inst[6:0] == lui) begin
        if(uut.RF.register_bank[wb_inst[11:7]] == {wb_inst[31:12], 12'b0})
            $display("[%6t] pc=%8h, Data lui check correct", $time, wb_pc);
        else 
            $display("[%6t] pc=%8h, Data lui check incorrect", $time, wb_pc);
        $display("reg[%2h] = %8h, data_lui = %8h", wb_inst[11:7], uut.RF.register_bank[wb_inst[11:7]], {wb_inst[31:12], 12'b0});
        $display("count = %d", count);
    end
endtask
task load_check(int count);
    if(wb_inst[6:0] == load && wb_inst[11:7] == 5'b0) begin
        $display("[%6t] pc=%8h, Data load to register x0", $time, wb_pc);
    end 
    else if(wb_inst[6:0] == load && wb_inst[14:12] == 3'b010) begin
        if  (uut.RF.register_bank[wb_inst[11:7]] == {memory[(wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]] + 2'b11)],
                                                     memory[(wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]] + 2'b10)],
                                                     memory[(wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]] + 2'b01)],
                                                     memory[(wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]])]})
            $display("[%6t] pc=%8h, Data load w check correct", $time, wb_pc);
        else
            $display("[%6t] pc=%8h, Data load w check incorrect", $time, wb_pc);
        $display("reg[%2h] = %8h, memory[%3h] = %2h %2h %2h %2h", 
                 wb_inst[11:7], uut.RF.register_bank[wb_inst[11:7]], 
                 (wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]]), 
                 memory[wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]] + 2'b11],
                 memory[wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]] + 2'b10],
                 memory[wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]] + 2'b01],
                 memory[wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]] + 2'b00]);
        $display("count = %d", count);
    end
    else if(wb_inst[6:0] == load && wb_inst[14:12] == 3'b101) begin
        if  (uut.RF.register_bank[wb_inst[11:7]] == {16'b0,
                                                     memory[(wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]] + 2'b01)],
                                                     memory[(wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]])]})
            $display("[%6t] pc=%8h, Data load hu check correct", $time, wb_pc);
        else
            $display("[%6t] pc=%8h, Data load hu check incorrect", $time, wb_pc);
        $display("reg[%2h] = %8h, memory[%3h] = 00 00 %2h %2h", 
                 wb_inst[11:7], uut.RF.register_bank[wb_inst[11:7]], 
                 (wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]]), 
                 memory[wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]] + 2'b01],
                 memory[wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]]]);
        $display("count = %d", count);
    end
    else if(wb_inst[6:0] == load && wb_inst[14:12] == 3'b100) begin
        if  (uut.RF.register_bank[wb_inst[11:7]] == {24'b0,
                                                     memory[(wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]])]})
            $display("[%6t] pc=%8h, Data load bu check correct", $time, wb_pc);
        else
            $display("[%6t] pc=%8h, Data load bu check incorrect", $time, wb_pc);
        $display("reg[%2h] = %8h, memory[%3h] = 00 00 00 %2h", 
                 wb_inst[11:7], uut.RF.register_bank[wb_inst[11:7]], 
                 (wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]]), 
                 memory[wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]]]);
        $display("count = %d", count);
    end
    else if(wb_inst[6:0] == load && wb_inst[14:12] == 3'b001) begin
        if(memory[(wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]] + 2'b01)][7]) begin
            if  (uut.RF.register_bank[wb_inst[11:7]] == {16'hffff,
                                                        memory[(wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]] + 2'b01)],
                                                        memory[(wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]])]})
                $display("[%6t] pc=%8h, Data load h check correct", $time, wb_pc);
            else
                $display("[%6t] pc=%8h, Data load h check incorrect", $time, wb_pc);
            $display("reg[%2h] = %8h, memory[%3h] = ff ff %2h %2h", 
                    wb_inst[11:7], uut.RF.register_bank[wb_inst[11:7]], 
                    (wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]]), 
                    memory[wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]] + 2'b01],
                    memory[wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]] ]);
        end
        else begin
            if  (uut.RF.register_bank[wb_inst[11:7]] == {16'b0,
                                                        memory[(wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]] + 2'b01)],
                                                        memory[(wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]])]})
                $display("[%6t] pc=%8h, Data load h check correct", $time, wb_pc);
            else
                $display("[%6t] pc=%8h, Data load h check incorrect", $time, wb_pc);
            $display("reg[%2h] = %8h, memory[%3h] = 00 00 %2h %2h", 
                    wb_inst[11:7], uut.RF.register_bank[wb_inst[11:7]], 
                    (wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]]), 
                    memory[wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]] + 2'b01],
                    memory[wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]]]);
        end
        $display("count = %d", count);
    end
    else if(wb_inst[6:0] == load && wb_inst[14:12] == 3'b000) begin
        if(memory[(wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]])][7]) begin
            if  (uut.RF.register_bank[wb_inst[11:7]] == {24'hffffff,
                                                        memory[(wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]])]})
                $display("[%6t] pc=%8h, Data load b check correct", $time, wb_pc);
            else
                $display("[%6t] pc=%8h, Data load b check incorrect", $time, wb_pc);
            $display("reg[%2h] = %8h, memory[%3h] = ff ff ff %2h", 
                    wb_inst[11:7], uut.RF.register_bank[wb_inst[11:7]], 
                    (wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]]), 
                    memory[wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]]]);
        end 
        else begin
            if  (uut.RF.register_bank[wb_inst[11:7]] == {24'b0,
                                                        memory[(wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]])]})
                $display("[%6t] pc=%8h, Data load b check correct", $time, wb_pc);
            else
                $display("[%6t] pc=%8h, Data load b check incorrect", $time, wb_pc);
            $display("reg[%2h] = %8h, memory[%3h] = 00 00 00 %2h", 
                    wb_inst[11:7], uut.RF.register_bank[wb_inst[11:7]], 
                    (wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]]), 
                    memory[wb_inst[31:20] + uut.RF.register_bank[wb_inst[19:15]]]);
        end
        $display("count = %d", count);
    end
endtask

task alu_check();
    
endtask
task taskName_check();
    
endtask
