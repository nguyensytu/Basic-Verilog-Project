module forwarding_unit(
    input [4:0] idex_rs1,
    input [4:0] idex_rs2,
    input [4:0] exmem_rd,
    input [4:0] memwb_rd,
    input exmem_wb, memwb_wb,

    output forward_mem_ctrl_src1, forward_wb_ctrl_src1, forward_mem_ctrl_src2, forward_wb_ctrl_src2
    ); 
// src1
assign forward_mem_ctrl_src1 = (exmem_wb & (idex_rs1 == exmem_rd) & (exmem_rd != 5'h0)) ? 1'b1 : 1'b0; 
assign forward_wb_ctrl_src1 = (memwb_wb & (idex_rs1 == memwb_rd) & (memwb_rd != 5'h0)) ? 1'b1 : 1'b0;
// src2
assign forward_mem_ctrl_src2 = (exmem_wb & (idex_rs2 == exmem_rd) & (exmem_rd != 5'h0)) ? 1'b1 : 1'b0;
assign forward_wb_ctrl_src2 = (memwb_wb & (idex_rs2 == memwb_rd) & (memwb_rd != 5'h0)) ? 1'b1 : 1'b0; 
endmodule
