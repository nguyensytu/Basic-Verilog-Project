task init();
    meip = 1'b0;
    mtip = 1'b0;
    msip = 0;
    inst_stall = 1'b0;
    inst_access_fault = 1'b0;
    data_err = 1'b0;
    data_stall = 1'b0;
    inst = 32'h13; // nop instruction addi x0,x0,0
    fast_irq = 16'b0;
endtask
task write_inst(output logic[31:0] inst_o, input logic[31:0] inst_i);
    inst_o = inst_i;
    wait_pc_change();
endtask 

task wait_pc_change();
    @(posedge clk)
    if(uut.pc == if_pc)
        wait_pc_change();
endtask 


task wait_pc_o_change();
    while(if_pc == ifid_pc)
        @(posedge clk);
endtask 



