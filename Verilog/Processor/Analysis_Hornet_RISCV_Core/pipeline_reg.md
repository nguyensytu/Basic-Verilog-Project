# IFID_preg
## IFID_preg_instr [31:0], IFID_preg_pc [31:0]
* IFID_preg_instr and IFID_preg_pc save the current instruction and pc until the next asserted clock

* If these is one of reset signal, take_branch, if_flush, stall_IF, stall_ID, {IFID_preg_pc, IFID_preg_instr} is assign to 64'h13. This mean "nop instruction addi x0,x0,0" is activated.
* Else, IFID_preg_instr is assign to current instruction, IFID_preg_pc is assign to current pc

## IFID_preg_dummy
* If reset signal is asserted, IFID_preg_dummy is assigned to *1'b0*
* If take_b signal is asserted, IFID_preg_dummy is assigned to *1'b0*
