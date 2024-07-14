# input
## pc_i
## csr_r_addr_i [11:0], csr_w_addr_i [11:0]
* This input identify which registers of csr_unit to be read/write 
    - 0x300 - mstatus
    - 0x304 - mie
    - 0x305 - mtvec
    - 0x340 - mscratch
    - 0x341 - mepc
    - 0x342 - mcause
    - 0x344 - mip
## csr_reg_i [31:0]
* Contain value which write to the register that map to *csr_w_addr_i*
## csr_wen_i
* CSR write enable
## meip_i, mtip_i, msip_i
* meip_i: machine external interrupt
* mtip_i: machine timer interrupt
* msip_i: machine software interrupt
* These signal are controlled form outside the core

## fast_irq_i [15:0]
## take_branch_i
## mem_wen_i
## ex_dummy_i
## mem_dummy_i
## mret_id_i
* When instruction is mret, *mret_id_i* is asserted
## mret_wb_i
* Machine return
* Return from traps in M-mode, and MRET copies MPIE into MIE, then sets MPIE.

## misaligned_ex
## instr_access_fault_i, data_err_i
* These signal are controlled form outside the core

## illegal_instr_i, instr_addr_misaligned_i, ecall_i, ebreak_i

# internal signal

## mstatus [31:0]
### mstatus_mie = mstatus [3]
* Machine interrupt enable
### mstatus_mpie = mstatus [7] <= mstatus_mie
* Machine previous interrupt enabler

## mie [31:0] <=  csr_reg_i [31:0]
### mie_meie = mie [11] 
### mie_mtie = mie [7]
### mie_msie = mie [3]

## mip [31:0]
### mip_meip = mie [11] <= meip_i
### mip_mtip = mie [7] <= mtip_i
### mip_msip = mie [3] <= msip_i

## mcause [31:0]

## mtvec [31:0]

## mepc [31:0]
* Machine exception program counter

## mscratch [31:0]


# output
## csr_reg_o [31:0]
* Contain value of register which map to *csr_r_addr_i*

## irq_addr_o [31:0]
## mepc_0 [31:0] = mepc [31:0]
## mux1_ctrl_o
## mux2_ctrl_o
## ack_o
* Asserted when external interrupts is active
## csr_if_flush_o = csr_if_flush
* mstatus_mie & pending_irq
* or STATE == S1
* or mret_id_i & ~take_branch_i
* or pending_exception
## csr_id_flush_o = csr_id_flush
* mstatus_mie & pending_irq
* or pending_exception
* or csr_ex_flush
## csr_ex_flush_o = csr_ex_flush
* mstatus_mie & pending_irq & !ex_dummy_i & !misaligned_ex
* or instr_addr_misaligned_i
* or csr_mem_flush
## csr_mem_flush_o = csr_mem_flush
* mstatus_mie & pending_irq & mem_wen_i & !mem_dummy_i
* instr_access_fault_i
##