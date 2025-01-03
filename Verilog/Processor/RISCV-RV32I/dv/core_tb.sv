`include "core_type.sv"
module core_tb; 
    legal_inst  legal_inst0;
    legal_load legal_load0;
    legal_store legal_store0;
// core interface
    reg clk;
    reg reset;
    reg meip;
    reg mtip;
    reg msip;
    reg inst_access_fault;
    reg data_err;
    reg data_stall; 
    reg [31:0] inst;
    wire [31:0] data_i;
    reg [15:0] fast_irq;
    wire [3:0] wmask;
    wire wmem_o;
    wire req_mem;
    wire [31:0] pc;
    wire [31:0] data_o;
    wire [31:0] addr_o;
    wire irq_ack;
//
    wire [31:0] if_pc, ifid_pc, idex_pc; 
    reg [31:0] exmem_pc, memwb_pc, wb_pc;
    wire [31:0] ifid_inst;
    reg [31:0] idex_inst, exmem_inst, memwb_inst, wb_inst;
//
    logic [7:0] memory [4095:0];
//
    //IF
    assign if_pc = uut.if_pc;
    // ID
    assign ifid_pc = uut.ifid_pc;
    assign ifid_inst = uut.ifid_inst;
    // EX
    assign idex_pc = uut.idex_pc;
    always @(posedge clk, posedge reset) begin
        if(reset | uut.take_branch | uut.id_flush) begin
            idex_inst <= 32'h13;
        end
        else if(uut.ex_stall)
            idex_inst <= idex_inst;
        else
            idex_inst <= ifid_inst;
    end
    // MEM
    always @(posedge clk, posedge reset) begin
        if (reset | uut.ex_flush) begin
            exmem_pc <= 32'b0;
            exmem_inst <= 32'h13;
        end
        else begin
            exmem_pc <= idex_pc;
            exmem_inst <= idex_inst;
        end
    end
    // WB
    always @(posedge clk, posedge reset) begin
        if (reset | uut.mem_flush) begin
            memwb_pc <= 32'b0;
            memwb_inst <= 32'h13;
        end
        else begin
            memwb_pc <= exmem_pc;
            if(exmem_inst != idex_inst)
                memwb_inst <= exmem_inst;
            else    
                memwb_inst <= 32'h13;
        end
    end
    // 
    always @(posedge clk, posedge reset) begin
        if (reset | uut.mem_flush) begin
            wb_inst <= 32'h13;
            wb_pc <= 32'b0;
        end
        else begin
            wb_inst <= memwb_inst;
            wb_pc <= memwb_pc;
        end
    end
//    
    core uut (
        clk, reset, meip, mtip, msip,
        inst_access_fault, data_err, data_stall,
        inst, data_i,
        fast_irq,
        wmask,
        wmem_o, req_mem,
        pc, data_o, addr_o,
        irq_ack
    );
//  
    integer i;
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            for (i = 0; i < 4096 ; i = i + 1) begin
                memory[i] <= i[7:0];
            end
        end
        else if(wmem_o) begin
            if(wmask[0])
                memory[addr_o] <= data_o[7:0];
            if(wmask[1])
                memory[addr_o + 1'b1] <= data_o[15:8];
            if(wmask[2])
                memory[addr_o + 2'b10] <= data_o[23:16];
            if(wmask[3])
                memory[addr_o + 2'b11] <= data_o[31:24];
        end
    end
    assign data_i = {memory[addr_o + 2'b11], memory[addr_o + 2'b10], memory[addr_o + 2'b01], memory[addr_o]};
//
    initial begin
        clk = 1'b0;
        forever begin
            #5 clk = ~clk;
        end
    end
    `include "core_task.sv"
    `include "wb_check.sv"
    `include "mem_check.sv"
    `include "core_testcase.sv"
    `include "core_test.sv"
endmodule