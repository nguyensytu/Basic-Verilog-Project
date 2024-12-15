# input
* instruction [31:0]
# output 
## ALU_func [3:0], CSR_ALU_func [1:0], EX_mux1, EX_mux3, EX_mux5, EX_mux6 [1:0], EX_mux7, EX_mux8, J, B, muldiv_start, muldiv_sel, op_mul [1:0], op_div [1:0]
* These signal are saved in IDEX_preg_ex to assign to corresponding outputs in EX in the next clok. 
* If hazard_stall signal is asserted, IDEX_preg_ex is saved as *21'b0* which EX state đo nothing

| Bit | 20:19 | 18:17 | 16 | 15 | 14 | 13 | 12 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| CU_output | op_div | op_mul | muldiv_sel | muldiv_start | B | J | EX_mux8 |
| ctrl_signal_in_EX | op_div | op_mul | muldiv_sel | muldiv_start | B | J | mux8_ctrl_EX |

| Bit | 11 | 10:9 | 8 | 7 | 6 | 5:4 | 3:0 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| CU_output | EX_mux7 | EX_mux6 | EX_mux5 | EX_mux3 | EX_mux1 | CSR_ALU_func | ALU_func | 
| ctrl_signal_in_EX | mux7_ctrl_EX | mux6_ctrl_EX | mux5_ctrl_EX | mux3_ctrl_EX | mux1_ctrl_EX | csr_alu_func | alu_func |

## MEM_len [1:0], MEM_wen
* These signal are saved in IDEX_preg_mem to assign to corresponding outputs in EX.
* If hazard_stall signal is asserted, IDEX_preg_mem is saved as *3'b1* which EX state đo nothing

## WB_mux [1:0], WB_sign, WB_rf_wen, WB_csr_wen, MEM_len [1:0]
* These signal are saved in IDEX_preg_wb to assign to corresponding outputs in EX.
* If hazard_stall signal is asserted, IDEX_preg_wb is saved as *7'h0c* which EX state đo nothing

## illegal_instr
* This signal is assign to *illegal_instr_i* input signal of csr_unit

## ecall_o
* This signal is assign to *ecall_i* input signal of csr_unit

## ebreak_o
* This signal is assign to *ebreak_i* input signal of csr_unit

## mret_o
* This signal is assign to *mret_id_i* input signal of csr_unit
* This signal are saved in IDEX_preg_mret to assign to corresponding outputs in EX.