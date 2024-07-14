# input
## pc_i
* 
## csr_r_addr_i [11:0], csr_w_addr_i [11:0]
* This input identify which registers of csr_unit to be read/write 
    - 0x300 - mstatus
    - 0x304 - mie
    - 0x305 - mtvec
    - 0x340 - mscratch
    - 0x341 - mepc
    - 0x342 - mcause
    - 0x344 - mip
##
##
##
##
##
##
##
##
##
##
##
##
##

# internal signal
## mstatus [31:0]
### mstatus_mie = mstatus [3]

### mstatus_mpie = mstatus [7]

## mie [31:0]
### mie_meie = mie [11] 
### mie_mtie = mie [7]
### mie_msie = mie [3]

## mip [31:0]
### mip_meip = mie [11] 
### mip_mtip = mie [7]
### mip_msip = mie [3]

## mcause [31:0]

## mtvec [31:0]

## mepc [31:0]

## mscratch [31:0]


# output
## csr_reg_o [31:0]
## irq_addr_o [31:0]
## mepc_0 [31:0] = mepc [31:0]
## mux1_ctrl_o
## mux2_ctrl_o
## ack_o
## csr_if_flush_o = csr_if_flush
## csr_id_flush_o = csr_id_flush
## csr_ex_flush_o = csr_ex_flush
## csr_mem_flush_o = csr_mem_flush
##