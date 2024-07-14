# input
* instruction [31:0]
# output 
## ALU_func [3:0], CSR_ALU_func [1:0], EX_mux1, EX_mux3, EX_mux5, EX_mux6 [1:0], EX_mux7, EX_mux8, J, B, muldiv_start, muldiv_sel, op_mul [1:0], op_div [1:0]
* These signal are saved in IDEX_preg_ex to assign to corresponding outputs in EX.
|Bit|20:19|18:17|16|15|14|13|12|11|10:9|8|7|6|5:4|3:0|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|CU_output|op_div|op_mul|muldiv_sel|muldiv_start|B|J|EX_mux8|EX_mux7|EX_mux6|EX_mux5|EX_mux3|EX_mux1|CSR_ALU_func|ALU_func| 
|ctrl_signal_in_EX|op_div|op_mul|muldiv_sel|muldiv_start|B|J|mux8_ctrl_EX|mux7_ctrl_EX|mux6_ctrl_EX|mux5_ctrl_EX|mux3_ctrl_EX|mux1_ctrl_EX|csr_alu_func|alu_func|

| :————————— | :———————————————— |
|ALU_func    |alu_func           |
|CSR_ALU_func|csr_alu_func       |
|EX_mux1     |mux1_ctrl_EX       |
|EX_mux3     |mux3_ctrl_EX       |
|EX_mux5     |mux5_ctrl_EX       |
|EX_mux6     |mux6_ctrl_EX       |
|EX_mux7     |mux7_ctrl_EX       |
|EX_mux8     |mux8_ctrl_EX       |
|J           |J                  |
|B           |B                  |
|muldiv_start|muldiv_start       |
|muldiv_sel  |muldiv_sel         |
|op_mul      |op_mul             |
|op_div      |op_div             |

| STT | Cột 1 | Cột 2 |
| :--- | :--- | :--- |
| 1 | Dòng 11 | Dòng 21 |
| 2 | Dòng 12 | Dòng 22 |
| 3 | Dòng 13 | Dòng 23 |
| 4 | Dòng 14 | Dòng 24 |