module APB_slave_interface ( 
    input p_clk, 
    input p_resetn,
    input [5:0] p_addr, 
    input p_sel, 
    input p_enable, 
    input p_write, 
    input [31:0] p_wdata,
    output [7:0] p_rdata,
    output reg p_ready
);



endmodule