`include "core/core_type.sv"
module riscv_axi_tb;
// 
    legal_inst  legal_inst0;
    legal_lui legal_lui0;
    legal_auipc legal_auipc0;
    legal_load legal_load0;
    legal_store legal_store0;
    legal_alu legal_alu0;
    legal_alu_imm legal_alu_imm0;
    legal_branch legal_branch0;
    legal_jal legal_jal0;
    legal_jalr legal_jalr0;
    legal_csr legal_csr0;
// AXI interface
    logic a_clk;
    logic a_resetn;
    // 
    logic [3:0] aw_id;
    logic [31:0] aw_addr;
    logic [3:0] aw_len;
    logic [2:0] aw_size;
    logic [1:0] aw_burst;
    logic aw_valid;
    logic aw_ready;
    //
    logic [3:0] w_id;
    logic [31:0] w_data;
    logic [3:0] w_strb;
    logic w_last;
    logic w_valid;
    logic w_ready;
    //
    logic [3:0] b_id;
    logic [1:0] b_resp;
    logic b_valid;
    logic b_ready;
    //
    logic [3:0] ar_id;
    logic [31:0] ar_addr;
    logic [3:0] ar_len;
    logic [2:0] ar_size;
    logic [1:0] ar_burst;
    logic ar_valid;
    logic ar_ready;
    //
    logic [3:0] r_id;
    logic [31:0] r_data;
    logic [1:0] r_resp;
    logic r_last;
    logic r_valid;
    logic r_ready;
    // 
    logic meip, mtip, msip;
    logic [15:0] fast_irq;
    logic irq_ack;
//
    //
    wire [31:0] if_pc, ifid_pc, idex_pc; 
    reg [31:0] if_pc_reg, exmem_pc, memwb_pc, wb_pc;
    wire [31:0] ifid_inst;
    reg [31:0] idex_inst, exmem_inst, memwb_inst, wb_inst;
//
    //IF
    assign if_pc = master.cpu.if_pc;
    always @(posedge a_clk, negedge a_resetn) begin
        if(~a_resetn)
            if_pc_reg <= 32'b0;
        else 
            if_pc_reg <= if_pc;
    end
    // ID
    assign ifid_pc = master.cpu.ifid_pc;
    assign ifid_inst = master.cpu.ifid_inst;
    // EX
    assign idex_pc = master.cpu.idex_pc;
    always @(posedge a_clk, negedge a_resetn) begin
        if(!a_resetn | master.cpu.take_branch | master.cpu.id_flush) begin
            idex_inst <= 32'h13;
        end
        else if(master.cpu.ex_stall)
            idex_inst <= idex_inst;
        else
            idex_inst <= ifid_inst;
    end
    // MEM
    always @(posedge a_clk, negedge a_resetn) begin
        if (!a_resetn || master.cpu.ex_flush || master.cpu.csr_stall_ex) begin
            exmem_pc <= 32'b0;
            exmem_inst <= 32'h13;
        end
        else if(master.cpu.mem_stall || master.cpu.csr_stall_mem) begin
            exmem_inst <= exmem_inst;
            exmem_pc <= exmem_pc;
        end
        else begin
            exmem_pc <= idex_pc;
            exmem_inst <= idex_inst;
        end
    end
    // WB
    always @(posedge a_clk, negedge a_resetn) begin
        if (!a_resetn | master.cpu.mem_flush | master.cpu.csr_stall_mem) begin
            memwb_pc <= 32'b0;
            memwb_inst <= 32'h13;
        end
        else begin
            memwb_pc <= exmem_pc;
            memwb_inst <= exmem_inst;
        end
    end
    // 
    always @(posedge a_clk, negedge a_resetn) begin
        if (!a_resetn | master.cpu.mem_flush) begin
            wb_pc <= 32'b0;
            wb_inst <= 32'h13;
        end
        else begin
            wb_pc <= memwb_pc;
            wb_inst <= memwb_inst;
        end
    end
    riscv_axi master (
        a_clk, a_resetn, 
        aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_valid, aw_ready,
        w_id, w_data, w_strb, w_last, w_valid, w_ready,
        b_id, b_resp, b_valid, b_ready,
        ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_valid, ar_ready,
        r_id, r_data, r_resp, r_last, r_valid, r_ready,
        meip, mtip, msip, fast_irq, irq_ack
    );
    AXI_top slave (
        a_clk, a_resetn, 
        aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_valid, aw_ready,
        w_id, w_data, w_strb, w_last, w_valid, w_ready,
        b_id, b_resp, b_valid, b_ready,
        ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_valid, ar_ready,
        r_id, r_data, r_resp, r_last, r_valid, r_ready
    );
    //
    initial begin
        a_clk = 1'b0;
        forever begin
            #5 a_clk = ~a_clk;
        end
    end
    `include "core/checker/inst_check.sv"
    `include "riscv_testcase.sv"
    `include "riscv_test.sv"
endmodule