module core (
    input clk, reset, meip, mtip, msip,
    input inst_access_fault, //instruction access fault exception signal
    input inst_stall,
    input data_err, data_stall,
    input [31:0] inst, data_i,
    input [15:0] fast_irq, //fast interrupts
    output [3:0] wmask,
    output wmem_o, req_mem, // data memory access request output. driven high when a store/load is carried out
    output [31:0] pc_o, data_o, addr_o,
    output wire irq_ack
);
// Pineline registers declaration
    // IFID pineline registers declaration
    wire [31:0] pc;
    reg [31:0] ifid_inst, ifid_pc;
    // IDEX pineline registers declaration
    reg [3:0] idex_alu_func;
    reg idex_ctrl_imm, idex_L, idex_B, idex_J, idex_w_csr, idex_wmem, idex_wb, idex_mem_sign,
        idex_mret, idex_ctrl_branch_addr, idex_ctrl_src1, idex_hazard_stall;
    reg [1:0] idex_csr_alu_func;
    reg [1:0] idex_mem_len;
    reg [31:0] idex_pc, idex_data1, idex_data2, idex_imm;
    reg [11:0] idex_csr_addr;
    reg [4:0] idex_rs1, idex_rs2, idex_rd;
    // EXMEM pineline registers declaration
    reg exmem_L, exmem_w_csr, exmem_wmem, exmem_wb, exmem_mem_sign, exmem_mret, exmem_misaligned;
    reg [1:0] exmem_mem_len;
    reg [31:0] exmem_data2, exmem_result, exmem_csr;
    reg [11:0] exmem_csr_addr;
    reg [4:0] exmem_rd;
    // MEMWB pineline registers declaration
    reg memwb_L, memwb_w_csr, memwb_wb, memwb_mem_sign, memwb_mret;
    reg [1:0] memwb_mem_len;
    reg [31:0] memwb_result, memwb_csr, memwb_memout;
    reg [11:0] memwb_csr_addr;
    reg [4:0] memwb_rd;
// Signal declaration
    // csr
    wire [31:0] csr_reg_o, irq_addr, mepc;
    wire pending_irq, pending_exception;
    wire csr_state;
    // hazard signal declaration
    wire hazard_stall;
    // cu signal declaration
    wire [3:0] alu_func;
    wire [1:0] csr_alu_func;
    wire ctrl_imm, L, B, J, w_csr, wmem, wb, mem_sign, ctrl_branch_addr, ctrl_src1, 
         ecall, ebreak, mret, illegal_instr;
    wire [1:0] mem_len;
    // register file signal declaration
    reg [31:0] reg_write_data;
    wire [31:0] reg_read_data1, reg_read_data2;
    // imm decoder signal declaration
    wire [31:0] imm_out;
    // alu signal declaration
    wire [31:0] src1, src2, alu_out;
    // forward signal declaration
    wire forward_mem_ctrl_src1, forward_wb_ctrl_src1, 
         forward_mem_ctrl_src2, forward_wb_ctrl_src2; 
    // load store signal declaration
    wire lsu_L_out; // lsu_wmem_out;
    wire misaligned_access;
    wire [31:0] memout;
    // other signal declaration
    // pc
    reg [31:0] if_pc;
    // data
    wire [31:0] ex_data1, ex_data2, branch_addr_calc, branch_target_addr, 
                csr_alu_out, ex_result;
    // control
    wire take_branch, inst_addr_misaligned;
    wire if_stall, id_stall, ex_stall, mem_stall, csr_stall_ex, csr_stall_mem;
    wire if_flush, id_flush, ex_flush, mem_flush;
// Intance submodule
    // CSR 
    csrs_controller CSR (
        clk, reset, 
        meip, mtip, msip, 
        fast_irq,
        inst_access_fault, data_err,
        pc_o, // if
        illegal_instr, ecall, ebreak, // id
        idex_csr_addr, // ex 
        take_branch, inst_addr_misaligned, // ex
        exmem_wmem, // mem
        memwb_csr_addr, // wb
        memwb_csr, // wb
        memwb_w_csr, // wb
        memwb_mret, // wb
        csr_reg_o,  // ex
        mepc, 
        pending_irq, 
        irq_addr,
        irq_ack, // outside
        csr_state
    );
    // HDU
    hazard_detection_unit HDU (
        ifid_inst[19:15], ifid_inst[24:20], ifid_inst[6:2], ifid_inst[14], 
        idex_rd, idex_L, hazard_stall
    );
    // CU
    control_unit CU (
        ifid_inst, alu_func, csr_alu_func,
        ctrl_imm, L, B, J, w_csr, wmem, wb, mem_sign, 
        ctrl_branch_addr, ctrl_src1, mem_len, 
        ecall, ebreak, mret, illegal_instr
    );
    //
    register_file RF (
        clk, reset, memwb_wb, ifid_inst[19:15], ifid_inst[24:20], memwb_rd, 
        reg_write_data, reg_read_data1, reg_read_data2
    );
    // IMM_DEC
    imm_decoder IMM_DEC (ifid_inst [31:2], imm_out);
    // ALU
    alu ALU (src1, src2, idex_alu_func, alu_out);
    // FU
    forwarding_unit FU (
        idex_rs1, idex_rs2, exmem_rd, memwb_rd, exmem_wb, memwb_wb,
        forward_mem_ctrl_src1, forward_wb_ctrl_src1, forward_mem_ctrl_src2, forward_wb_ctrl_src2
    );
    // LSU
    load_store_unit LSU (
        clk, reset, alu_out, exmem_result, exmem_data2, data_i, memwb_memout, 
        idex_mem_len, exmem_mem_len,
        idex_L, idex_wmem, exmem_misaligned,
        data_o, addr_o, wmask, 
        misaligned_access, memout
    );
// Others signal
    assign wmem_o = exmem_wmem;
    assign req_mem = idex_L | idex_wmem; // follow the source code
    // assign req_mem = exmem_L | idex_wmem; //driven high if there's a load or a store.
    // stall
    assign if_stall = id_stall | inst_stall; 
    assign id_stall = ex_stall | hazard_stall; // | csr_stall;
    assign csr_stall_ex = idex_w_csr & (idex_csr_addr == exmem_csr_addr && exmem_w_csr);
    assign csr_stall_mem = idex_w_csr & (idex_csr_addr == memwb_csr_addr && memwb_w_csr);
    assign ex_stall = mem_stall | misaligned_access | csr_stall_ex;
    assign mem_stall = ((exmem_L | exmem_misaligned | exmem_wmem) & data_stall) | csr_stall_mem;
    // flush
    assign if_flush = id_flush | pending_irq | csr_state | (mret & ~take_branch);
    assign id_flush = ex_flush | illegal_instr | ecall | ebreak;
    // assign id_flush = ex_flush | pending_irq | illegal_instr | ecall | ebreak;
    assign ex_flush = mem_flush | inst_addr_misaligned;
    assign mem_flush = data_err ;
    // IF stage 
    assign pc = csr_state ? irq_addr : // csr_state = 1 ~ irq
                (~take_branch & mret) ? mepc :
                take_branch ? branch_target_addr : 
                if_stall ? if_pc : if_pc + 32'h4;
    assign pc_o = if_pc;
    // EX stage
    // ALU signal
    assign src1 = idex_ctrl_src1 ? idex_pc : ex_data1; 
    assign ex_data1 = forward_mem_ctrl_src1 ? exmem_result :
                      forward_wb_ctrl_src1 ? reg_write_data : // memwb_result :
                      idex_data1;
    assign src2 = idex_ctrl_imm ? idex_imm : ex_data2;
    assign ex_data2 = forward_mem_ctrl_src2 ? exmem_result :
                      forward_wb_ctrl_src2 ? reg_write_data : //memwb_result :
                      idex_data2;
    // Branch signal
    assign branch_addr_calc = (idex_ctrl_branch_addr ? idex_pc : ex_data1) + idex_imm; // if jalr, pc = data1 + imm_out
    assign branch_target_addr[31:1] = branch_addr_calc[31:1];
    assign branch_target_addr[0] = (!idex_ctrl_branch_addr & J) ? 1'b0 : branch_addr_calc[0]; //clear the least-significant bit if the instruction is JALR.
    assign take_branch = idex_J | (idex_B & alu_out[0]);
    assign inst_addr_misaligned = take_branch & (branch_target_addr[1:0] != 2'd0);
    // LSU signal

    // In system inst, csr_reg_o value will be assigned to register file in WB stage 
    // but the csr_alu_out value will be assigned back to CSRs in WB stage
    assign ex_result = idex_w_csr ? csr_reg_o : alu_out; 
    assign csr_alu_out = idex_csr_alu_func == 2'd2 ? (csr_reg_o & ~(idex_ctrl_imm ? idex_imm : ex_data1)) :
                         idex_csr_alu_func == 2'd1 ? (csr_reg_o | (idex_ctrl_imm ? idex_imm : ex_data1)) :
                         (idex_ctrl_imm ? idex_imm : ex_data1);
    // MEM stage
    // WB stage
    always @(*) begin
        if(memwb_L) begin
            if(memwb_mem_sign) 
                if(memwb_mem_len == 2'b0)
                    reg_write_data = {{24{memwb_memout[7]}}, memwb_memout[7:0]};
                else if(memwb_mem_len == 2'b1)
                    reg_write_data = {{16{memwb_memout[15]}}, memwb_memout[15:0]};
                else 
                    reg_write_data = memwb_memout;
            else 
                if(memwb_mem_len == 2'b0)
                    reg_write_data = {24'b0, memwb_memout[7:0]};
                else if(memwb_mem_len == 2'b1)
                    reg_write_data = {16'b0, memwb_memout[15:0]};
                else 
                    reg_write_data = memwb_memout;
        end
        else reg_write_data = memwb_result;
    end
    // assign reg_write_data = memwb_L ? memwb_memout : memwb_result;
// Pineline register
    always @(posedge clk, posedge reset) begin
        if(reset)
            if_pc <= 32'b0;
        else 
            if_pc <= pc;
    end
    // IFID
    always @(posedge clk, posedge reset) begin
        if (reset || take_branch || if_flush || inst_stall) begin
            ifid_inst <= 32'h13; // nop instruction addi x0,x0,0
            ifid_pc <= 32'h0;
        end
        else if (id_stall) begin
            ifid_inst <= ifid_inst; 
            ifid_pc <= ifid_pc;                
        end
        else begin
            ifid_inst <= inst;
            ifid_pc <= if_pc;
        end
    end
    // IDEX
    always @(posedge clk, posedge reset) begin
        if(reset || take_branch || id_flush) begin
            idex_alu_func <= 4'h0;
            idex_csr_alu_func <= 2'b0;
            idex_ctrl_imm <= 1'b1;
            idex_L <= 1'b0;
            idex_B <= 1'b0;
            idex_J <= 1'b0;
            idex_w_csr <= 1'b0;
            idex_wmem <= 1'b0;
            idex_wb <= 1'b0;
            idex_mem_sign <= 1'b0;
            idex_mret <= 1'b0;
            idex_ctrl_branch_addr <= 1'b0;
            idex_ctrl_src1 <= 1'b0;
            idex_hazard_stall <= 1'b0;
            idex_mem_len <= 2'b0;
            idex_pc <= 32'b0;
            idex_data1 <= 32'h0;
            idex_data2 <= 32'h0;
            idex_imm <= 32'h0;
            idex_csr_addr <= 12'b0;
            idex_rs1 <= 5'h0;
            idex_rs2 <= 5'h0;
            idex_rd <= 5'h0;
        end
        else if (ex_stall) begin
            idex_alu_func <= idex_alu_func;
            idex_csr_alu_func <= idex_csr_alu_func;
            idex_ctrl_imm <= idex_ctrl_imm;
            idex_L <= idex_L;
            idex_B <= idex_B;
            idex_J <= idex_J;
            idex_w_csr <= idex_w_csr;
            idex_wmem <= idex_wmem;
            idex_wb <= idex_wb;
            idex_mem_sign <= idex_mem_sign;
            idex_mret <= idex_mret;
            idex_ctrl_branch_addr <= idex_ctrl_branch_addr;
            idex_ctrl_src1 <= idex_ctrl_src1;
            idex_hazard_stall <= idex_hazard_stall;
            idex_mem_len <= idex_mem_len;
            idex_pc <= idex_pc;
            idex_data1 <= idex_data1;
            idex_data2 <= idex_data2;
            idex_imm <= idex_imm;
            idex_csr_addr <= idex_csr_addr;
            idex_rs1 <= idex_rs1;
            idex_rs2 <= idex_rs2;
            idex_rd <= idex_rd;
        end
        else begin
            idex_alu_func <= alu_func;
            idex_csr_alu_func <= csr_alu_func;
            idex_ctrl_imm <= ctrl_imm;
            idex_L <= L;
            idex_B <= B;
            idex_J <= J;
            idex_w_csr <= w_csr;
            idex_wmem <= wmem;
            idex_wb <= wb;
            idex_mem_sign <= mem_sign;
            idex_mret <= mret;
            idex_ctrl_branch_addr <= ctrl_branch_addr;
            idex_ctrl_src1 <= ctrl_src1;
            idex_hazard_stall <= hazard_stall;
            idex_mem_len <= mem_len;
            idex_pc <= ifid_pc;
            idex_data1 <= reg_read_data1;
            idex_data2 <= reg_read_data2;
            idex_imm <= imm_out;
            idex_csr_addr <= ifid_inst[31:20];
            idex_rs1 <= ifid_inst[19:15];
            idex_rs2 <= ifid_inst[24:20];
            idex_rd <= ifid_inst[11:7];
        end
    end 
    // EXMEM
    always @(posedge clk, posedge reset) begin
        if (reset || ex_flush || csr_stall_ex) begin
            exmem_L <= 1'b0;
            exmem_w_csr <= 1'b0;
            exmem_wmem <= 1'b0;
            exmem_wb <= 1'b0;
            exmem_mem_sign <= 1'b0;
            exmem_mret <= 1'b0;
            exmem_misaligned <= 1'b0;
            exmem_mem_len <= 2'b0;
            exmem_data2 <= 32'b0;
            exmem_result <= 32'h0;
            exmem_csr <= 32'b0;
            exmem_csr_addr <= 12'b0;
            exmem_rd <= 5'h0;
        end
        else if (mem_stall || csr_stall_mem) begin
            exmem_L <= exmem_L;
            exmem_w_csr <= exmem_w_csr;
            exmem_wmem <= exmem_wmem;
            exmem_wb <= exmem_wb;
            exmem_mem_sign <= exmem_mem_sign;
            exmem_mret <= exmem_mret;
            exmem_misaligned <= exmem_misaligned;
            exmem_mem_len <= exmem_mem_len;
            exmem_data2 <= exmem_data2;
            exmem_result <= exmem_result;
            exmem_csr <= exmem_csr;
            exmem_csr_addr <= exmem_csr_addr;
            exmem_rd <= exmem_rd;           
        end
        else begin
            exmem_L <= idex_L;
            exmem_w_csr <= idex_w_csr;
            if(idex_hazard_stall)
                exmem_wmem <= 1'b0;
            else
                exmem_wmem <= idex_wmem;
            if(misaligned_access)
                exmem_wb <= 1'b0;
            else
                exmem_wb <= idex_wb;
            exmem_mem_sign <= idex_mem_sign;
            exmem_mret <= idex_mret;
            exmem_misaligned <= misaligned_access;
            exmem_mem_len <= idex_mem_len;
            exmem_data2 <= ex_data2;
            exmem_result <= ex_result;
            exmem_csr <= csr_alu_out;
            exmem_csr_addr <= idex_csr_addr;
            exmem_rd <= idex_rd;
        end
    end   
    // MEMWB
    always @(posedge clk, posedge reset) begin
        if (reset || mem_flush || csr_stall_mem) begin
            memwb_L <= 1'b0;
            memwb_w_csr <= 1'b0;
            memwb_wb <= 1'b0;
            memwb_mem_sign <= 1'b0;
            memwb_mret <= 1'b0;
            memwb_mem_len <= 2'b0;
            memwb_result <= 32'b0;
            memwb_csr <= 32'b0;
            memwb_memout <= 32'b0;
            memwb_csr_addr <= 12'b0;
            memwb_rd <= 5'b0;
        end
        else begin
            memwb_L <= exmem_L;
            memwb_w_csr <= exmem_w_csr;
            if(mem_stall)
                memwb_wb <= 1'b0;
            else
                memwb_wb <= exmem_wb;
            memwb_mem_sign <= exmem_mem_sign;
            memwb_mret <= exmem_mret;
            memwb_mem_len <= exmem_mem_len;
            memwb_result <= exmem_result;
            memwb_csr <= exmem_csr;
            if(mem_stall)
                memwb_memout <= memwb_memout;
            else
                memwb_memout <= memout;
            memwb_csr_addr <= exmem_csr_addr;
            memwb_rd <= exmem_rd;
        end
    end
endmodule