`define mstatus_mie mstatus[3]
`define mstatus_mpie mstatus[7]
`define mie_meie mie[11]
`define mip_meip mip[11]
`define mie_mtie mie[7]
`define mip_mtip mip[7]
`define mie_msie mie[3]
`define mip_msip mip[3]
module csr_unit (
    input clk, reset, meip, mtip, msip, inst_access_fault, data_err,
    input [15:0] fast_irq, //fast interrupts
    input w_csr, wmem, id_mret, wb_mret,
    input illegal_instr, ecall, ebreak, take_branch, idex_misaligned, inst_addr_misaligned,
    input [31:0] pc, csr_reg_i, 
    input [11:0] r_addr, w_addr,
    output reg [31:0] csr_reg_o,
    output [31:0] irq_addr, 
    output reg [31:0] mepc,
    output reg state,
    output reg irq_ack,
    output if_flush, id_flush, ex_flush, mem_flush
);
    // CSRs
    reg [31:0] mstatus, mie, mip, mcause, mtvec, mscratch; // mepc already declarate as output
    //
    reg [31:0] state_next, irq_ack_next, mcause_next;
    //interrupt handler addresses for different interrupt handling modes
    wire [31:0] direct_mode_addr, vector_mode_addr;
    //Priority Encoder index
    reg [4:0] fast_irq_index;
    //Priority Encoder Valid output
    reg PE_valid;

    wire pending_irq, pending_exception;
    wire [31:0] masked_irq;
    //
    assign direct_mode_addr = mtvec;
    assign vector_mode_addr = mcause[31] ? {mtvec[31:1],1'b0} + (mcause << 2) : {mtvec[31:1],1'b0};
    assign irq_addr = mtvec[0] ? vector_mode_addr : direct_mode_addr;

    assign masked_irq = mie & mip & {32{`mstatus_mie}};
    assign pending_exception = (illegal_instr | inst_addr_misaligned | ecall | ebreak) & ~take_branch;
    assign pending_irq = masked_irq != 32'b0;

    assign if_flush = pending_irq | (state == 1'b1) | (id_mret & ~take_branch);
    assign id_flush = ex_flush | pending_irq | pending_exception;
    assign ex_flush = mem_flush | (pending_irq & idex_misaligned) | inst_addr_misaligned;
    assign mem_flush = (pending_irq & wmem) | inst_access_fault;
    // mcause write in WB stage
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 1'b0;
            irq_ack <= 1'b0;
            mcause <= 32'h0; 
        end 
        else begin
            state <= state_next;
            irq_ack <= irq_ack_next;
            mcause <= mcause_next; 
        end
    end
    always @(*) begin
        state_next = 1'b0;
        irq_ack_next = 1'b0;
        mcause_next = mcause;
        case (state)
            1'b0: begin // take interrupts, exceptions
                if (w_csr & w_addr == 12'h342)
                    mcause_next = csr_reg_i;
                else begin
                    if(masked_irq[31:16] != 16'b0) begin //fast interrupts have the highest priority
                        state_next = 1'b1;
                        mcause_next [31] = 1'b1;
                        mcause_next[30:0] = {26'h0, fast_irq_index};
                    end
                    else begin
                        if(`mstatus_mie & `mie_meie & `mip_meip) begin //external interrupts have the second highest priority
                            state_next = 1'b1;
                            irq_ack_next = 1'b1;
                            mcause_next [31] = 1'b1;
                            mcause_next[30:0] = 31'hb;
                        end
                        else if (`mstatus_mie & `mie_msie & `mip_msip) begin //software interrupts have the third highest priority
                            state_next = 1'b1;
                            mcause_next [31] = 1'b1;
                            mcause_next[30:0] = 31'h3;
                        end
                        else if(`mstatus_mie & `mie_mtie & `mip_mtip) begin //timer interrupts have the fourth highest priority
                            state_next = 1'b1;
                            mcause_next [31] = 1'b1;
                            mcause_next[30:0] = 31'h7;
                        end
                        else if(inst_access_fault) begin //exceptions have the lowest priority
                            state_next = 1'b1;
                            mcause_next = 32'h1;
                        end
                        else if(inst_addr_misaligned & !take_branch) begin
                            state_next = 1'b1;
                            mcause_next = 32'h0;
                        end
                        else if(illegal_instr & !take_branch) begin
                            state_next = 1'b1;
                            mcause_next = 32'h2;
                        end
                        else if(ecall & !take_branch) begin
                            state_next = 1'b1;
                            mcause_next = 32'hb;
                        end
                        else if(ebreak & !take_branch) begin
                            state_next = 1'b1;
                            mcause_next = 32'h3;
                        end
                        else if(data_err & wmem) begin //store access fault
                            state_next = 1'b1;
                            mcause_next = 32'h7;
                        end
                        else if(data_err & !wmem) begin //load access fault
                            state_next = 1'b1;
                            mcause_next = 32'h5;
                        end
                    end
                end
            end 
            1'b1: begin // process interrupt, exception and return
                state_next = 1'b0;
                irq_ack_next = 1'b0;
            end
        endcase
    end
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
    // mip
    integer i;
    always @(posedge clk or posedge reset)
    begin
        if(reset)
            mip <= 32'b0;
        else
        begin
            `mip_meip <= meip; //meip bit is set by the interrupt controller
            `mip_mtip <= mtip; //timer interrupt bit
            `mip_msip <= msip; //software interrupt bit

            for (i = 16; i<32; i=i+1)
            begin
                if(masked_irq[i] == 1'b1 && i == {27'b0,fast_irq_index})
                    mip[i] <= fast_irq[i-16];
                else if(mip[i] == 1'b0)
                    mip[i] <= fast_irq[i-16];
                else 
                    mip[i] <= mip[i];
            end
        end
    end
    // read CSRs in ID stage
    always @(posedge clk, posedge reset)begin
        if(reset)
            csr_reg_o <= 32'b0;
        else begin
            case (r_addr)
                12'h300: csr_reg_o <= mstatus;
                12'h304: csr_reg_o <= mie;
                12'h305: csr_reg_o <= mtvec;
                12'h340: csr_reg_o <= mscratch;
                12'h341: csr_reg_o <= {mepc[31:2],2'b0};
                12'h342: csr_reg_o <= mcause;
                12'h344: csr_reg_o <= mip;
                default: csr_reg_o <= 32'h0;
            endcase
        end
    end
    // write CSRs in WB stage
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            mepc <= 32'b0;
            mie <= 32'b0;
            mscratch <= 32'b0;
            mtvec <= 32'b0;
            //unused fields are hardwired to 0
            mstatus[31:13] <= 19'b0; mstatus[10:0] <= 11'b0;
            //mstatus.mpp
            mstatus[12:11] <= 2'b11;
        end
        else begin
            if(w_csr) begin
                if(wb_mret) begin
                    `mstatus_mie <= `mstatus_mpie;
                    `mstatus_mpie <= 1'b1;                    
                end
                else begin
                    case (w_addr)
                        12'h300: begin
                            `mstatus_mie <= csr_reg_i[3];
                            `mstatus_mpie <= csr_reg_i[7];                            
                        end
                        12'h304: begin
                            `mie_meie <= csr_reg_i[11];
                            `mie_mtie <= csr_reg_i[7];
                            `mie_msie <= csr_reg_i[3];
                            mie[31:16] <= csr_reg_i[31:16];                            
                        end
                        12'h305: mtvec <= csr_reg_i;
                        12'h340: mscratch <= csr_reg_i;
                        12'h341: mepc <= csr_reg_i;
                    endcase
                end
            end
            else begin
                if(state == 1'b1) begin
                     mepc <= pc;
                    `mstatus_mpie <= `mstatus_mie;
                    `mstatus_mie <= 1'b0;
                end
            end
        end
    end
endmodule