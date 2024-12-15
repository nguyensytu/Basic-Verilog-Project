module p_addr_decoder (
    input [31:0] reg_addr,
    input [25:0] base_addr,
    output p_sel,
    output [31:0] p_addr
);
    assign p_sel = (reg_addr[31:6] == base_addr) ? 1'b1 : 1'b0;
    assign p_addr = reg_addr;
endmodule