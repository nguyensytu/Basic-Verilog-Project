# input
* instruction [31:0]
# output 
## ALU_func [3:0], CSR_ALU_func [1:0], EX_mux1, EX_mux3, EX_mux5, EX_mux6 [1:0], EX_mux7, EX_mux8, J, B, muldiv_start, muldiv_sel, op_mul [1:0], op_div [1:0]
* These signal are saved in IDEX_preg_ex to assign to corresponding outputs in EX.

| Bit | 20:19 | 18:17 | 16 | 15 | 14 | 13 | 12 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| CU_output | op_div | op_mul | muldiv_sel | muldiv_start | B | J | EX_mux8 |
| ctrl_signal_in_EX | op_div | op_mul | muldiv_sel | muldiv_start | B | J | mux8_ctrl_EX |

| Bit | 11 | 10:9 | 8 | 7 | 6 | 5:4 | 3:0 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| CU_output | EX_mux7 | EX_mux6 | EX_mux5 | EX_mux3 | EX_mux1 | CSR_ALU_func | ALU_func | 
| ctrl_signal_in_EX | mux7_ctrl_EX | mux6_ctrl_EX | mux5_ctrl_EX | mux3_ctrl_EX | mux1_ctrl_EX | csr_alu_func | alu_func |
