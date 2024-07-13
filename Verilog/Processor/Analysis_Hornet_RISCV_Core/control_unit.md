# input
* instruction [31:0]
# output 
## ALU_func [3:0], CSR_ALU_func [1:0], EX_mux1, EX_mux3, EX_mux5, EX_mux6 [1:0], EX_mux7, EX_mux8, J, B, muldiv_start, muldiv_sel, op_mul [1:0], op_div [1:0]
* These signal are saved in IDEX_preg_ex to assign to corresponding outputs in EX.

|CU output[0:20]|ALU_func|CSR_ALU_func|EX_mux1|EX_mux3|EX_mux5|EX_mux6|EX_mux7|EX_mux8|J|B|muldiv_start|muldiv_sel|op_mul|op_div|
|ctrl signal in EX|alu_func|csr_alu_func|mux1_ctrl_EX|mux2_ctrl_EX|mux5_ctrl_EX|mux6_ctrl_EX|mux7_ctrl_EX|mux8_ctrl_EX|J|b|muldiv_start|muldiv_sel|op_mul|op_div|