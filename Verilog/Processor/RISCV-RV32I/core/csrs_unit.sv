`define mstatus_mie mstatus[3]
`define mstatus_mpie mstatus[7]
`define mie_meie mie[11]
`define mip_meip mip[11]
`define mie_mtie mie[7]
`define mip_mtip mip[7]
`define mie_msie mie[3]
`define mip_msip mip[3]
module csrs_controller (
    input clk, reset,
    input meip, mtip, msip, // outside
    input [15:0] fast_irq, // outside
    input inst_access_fault, // outside
    input data_err, // outside 
    input [31:0] pc, // if
    input illegal_instr, ecall, ebreak, // id 
    input [11:0] r_addr, // ex
    input take_branch, inst_addr_misaligned, // ex
    input wmem, // mem  
    input [11:0] w_addr, // wb
    input [31:0] csr_reg_i, // wb
    input w_csr, // wb
    input wb_mret, // wb
    output reg [31:0] csr_reg_o, // ex
    output reg [31:0] mepc,
    output pending_irq, // pending_exception,
    output [31:0] irq_addr,
    output reg irq_ack,
    output reg state
);
    wire state_next, irq_ack_next;
    reg [31:0] mstatus, mie, mip, mcause, mtvec, mscratch;
    wire [31:0] mstatus_next, mie_next, mcause_next, mtvec_next, mscratch_next, mepc_next;
    reg [31:0] mip_next;
    //
    wire [31:0] masked_irq;
    // 
    wire [31:0] direct_mode_addr, vector_mode_addr;
    //
    reg [4:0] fast_irq_index;
    reg PE_valid;

    // exception
    // assign pending_exception = (illegal_instr | inst_addr_misaligned | ecall | ebreak) & ~take_branch;

    // interrupt
    assign masked_irq = mie & mip & {32{`mstatus_mie}};
    assign pending_irq = masked_irq != 32'b0;
    
    // irq_addr decode
    assign direct_mode_addr = mtvec;
    assign vector_mode_addr = mcause[31] ? {mtvec[31:1],1'b0} + (mcause << 2) : {mtvec[31:1],1'b0};
    assign irq_addr = mtvec[0] ? vector_mode_addr : direct_mode_addr;

    // read csrs
    always @(*) begin
        case (r_addr)
                12'h300: csr_reg_o = mstatus;
                12'h304: csr_reg_o = mie;
                12'h305: csr_reg_o = mtvec;
                12'h340: csr_reg_o = mscratch;
                12'h341: csr_reg_o = {mepc[31:2],2'b0};
                12'h342: csr_reg_o = mcause;
                12'h344: csr_reg_o = mip; 
                default: csr_reg_o = 32'h0;
        endcase
    end
    // write csrs
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= 1'b0;
            irq_ack <= 1'b0;
            mstatus <= 32'b0; 
            mie <= 32'b0;
            mip <= 32'b0;
            mcause <= 32'h0;
            mtvec <= 32'b0;
            mscratch <= 32'b0;
            mepc <= 32'b0;
        end
        else begin
            state <= state_next;
            irq_ack <= irq_ack_next;
            mstatus <= mstatus_next;
            mie <= mie_next;
            mip <= mip_next;
            mcause <= mcause_next; 
            mtvec <= mtvec_next;
            mscratch <= mscratch_next;
            mepc <= mepc_next;
        end
    end
    assign state_next = (state) ? 1'b0 :
                        ((masked_irq[31:16] != 16'b0) | 
                        (`mstatus_mie & ((`mie_meie & `mip_meip) | (`mie_msie & `mip_msip) | (`mie_mtie & `mip_mtip))) | 
                        inst_access_fault | 
                        ((!take_branch) & (inst_addr_misaligned | illegal_instr | ecall | ebreak)) |
                        data_err) ? 1'b1 : 1'b0;  
    assign irq_ack_next =   (state) ? 1'b0 :
                            (`mstatus_mie & `mie_meie & `mip_meip) ? 1'b1 : 1'b0;
    assign mstatus_next =   (~w_csr) ? (state ? {24'b0, `mstatus_mie, 3'b0, 4'b0} : mstatus) :  
                            (wb_mret) ? {24'b0, 1'b1, 3'b0, `mstatus_mpie, 3'b0} : 
                            (w_addr == 12'h300) ? {24'b0, csr_reg_i[7], 3'b0, csr_reg_i[3], 3'b0} : mstatus;
    assign mie_next =   (w_csr & w_addr == 12'h304) ? {csr_reg_i[31:16] , 4'b0, csr_reg_i[11], 3'b0, csr_reg_i[7], 3'b0, csr_reg_i[3], 3'b0} : mie;
    // assign mip_next = ;
    assign mcause_next =    (state) ? mcause :
                            (w_csr & w_addr == 12'h342) ? csr_reg_i :
                            (masked_irq[31:16] != 16'b0) ? {1'b1, 26'b0, fast_irq_index} :
                            (`mstatus_mie & `mie_meie & `mip_meip) ? {1'b1, 31'hb} :
                            (`mstatus_mie & `mie_msie & `mip_msip) ? {1'b1, 31'h3} :
                            (`mstatus_mie & `mie_mtie & `mip_mtip) ? {1'b1, 31'h7} :
                            (inst_access_fault) ? 32'h1 :
                            (inst_addr_misaligned & !take_branch) ? 32'h0 :
                            (illegal_instr & !take_branch) ? 32'h2 :
                            (ecall & !take_branch) ? 32'hb :
                            (ebreak & !take_branch) ? 32'h3 :
                            (data_err & wmem) ? 32'h7 :
                            (data_err & !wmem) ? 32'h5 : mcause;
    assign mtvec_next = (w_csr & w_addr == 12'h305) ? csr_reg_i : mtvec;
    assign mscratch_next = (w_csr & w_addr == 12'h340) ? csr_reg_i : mscratch;
    assign mepc_next =  (state_next) ? pc :
                        (w_csr & w_addr == 12'h341) ? csr_reg_i : mepc;
// mip
    //Priority Encoder for fast interrupts.
    always @(*)
    begin
        fast_irq_index = 5'd15;
        PE_valid = 1'b0;
        while(fast_irq_index != 5'd31 && PE_valid != 1'b1)
        begin
            fast_irq_index = fast_irq_index + 5'd1;
            PE_valid = masked_irq[fast_irq_index];
        end
    end
    // mip_next
    integer i;
    always @(*) begin
        mip_next[15:0] = 16'b0;
        mip_next[3] = msip; //software interrupt bit
        mip_next[7] = mtip; //timer interrupt bit
        mip_next[11] = meip; //meip bit is set by the interrupt controller
        for (i = 16; i<32; i=i+1)begin
            if(masked_irq[i] == 1'b1 && i == {27'b0,fast_irq_index})
                mip_next[i] <= fast_irq[i-16];
            else if(mip[i] == 1'b0)
                mip_next[i] <= fast_irq[i-16];
            else 
                mip_next[i] <= mip[i];
        end
    end
endmodule
