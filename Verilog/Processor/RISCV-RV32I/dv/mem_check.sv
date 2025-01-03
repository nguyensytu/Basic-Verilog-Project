task mem_check();
    static int count_mem = 0;
    @(negedge clk);
    store_check(count_mem);
    // alu_check();
    count_mem = count_mem + 1;
endtask

task store_check(int count);
    if(memwb_inst[6:0] == store && memwb_inst[14:12] == 3'b000) begin
        if  (uut.RF.register_bank[memwb_inst[24:20]][7:0] == 
            memory[{20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]]]
            )
            $display("[%6t] pc=%8h, Data store b check correct", $time, wb_pc);
        else
            $display("[%6t] pc=%8h, Data store b check incorrect", $time, wb_pc);
        $display("reg[%2h] = %8h, memory[%1d] = %1h", 
                memwb_inst[24:20], uut.RF.register_bank[memwb_inst[24:20]], 
                {20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]], 
                memory[{20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]]]
                );
        $display("count = %d", count);
    end
    else if(memwb_inst[6:0] == store && memwb_inst[14:12] == 3'b001) begin
        if  (uut.RF.register_bank[memwb_inst[24:20]][15:0] == 
            {memory[{20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]] +2'b01],
            memory[{20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]]]}
            )
            $display("[%6t] pc=%8h, Data store h check correct", $time, wb_pc);
        else
            $display("[%6t] pc=%8h, Data store h check incorrect", $time, wb_pc);
        $display("reg[%2h] = %8h, memory[%1d] = %1h %1h", 
                memwb_inst[24:20], uut.RF.register_bank[memwb_inst[24:20]], 
                {20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]], 
                memory[{20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]] + 2'b01],
                memory[{20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]]]
                );
        $display("count = %d", count);
    end
    if(memwb_inst[6:0] == store && memwb_inst[14:12] == 3'b010) begin
        if  (uut.RF.register_bank[memwb_inst[24:20]] == 
            {memory[{20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]] + 2'b11],
            memory[{20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]] + 2'b10],
            memory[{20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]] + 2'b01],
            memory[{20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]]]}
            )
            $display("[%6t] pc=%8h, Data store w check correct", $time, wb_pc);
        else
            $display("[%6t] pc=%8h, Data store w check incorrect", $time, wb_pc);
        $display("reg[%2h] = %8h, memory[%1d] =  %1h %1h %1h %1h", 
                memwb_inst[24:20], uut.RF.register_bank[memwb_inst[24:20]], 
                {20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]], 
                memory[{20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]] + 2'b11],
                memory[{20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]] + 2'b10],
                memory[{20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]] + 2'b01],
                memory[{20'b0, memwb_inst[31:25], memwb_inst[11:7]} + uut.RF.register_bank[memwb_inst[19:15]]]
                );
        $display("count = %d", count);
    end
endtask 