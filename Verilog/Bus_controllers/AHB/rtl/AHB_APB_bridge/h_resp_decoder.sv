module h_resp_decoder (
    input h_clk,
    input h_resetn,
    input [1:0] h_trans, reg_trans,
    input p_sel,
    input p_slverr, 
    input slave_error, 
    output h_resp
);
    localparam  idle = 2'b00,
                busy = 2'b01,
                nonseq = 2'b10,
                seq = 2'b11;
    reg reg_resp;
    always @(posedge h_clk, negedge h_resetn) begin
        if(!h_resetn || (reg_trans == idle) || (reg_trans == busy)) reg_resp <= 1'b0;
        else if(p_sel & (slave_error | p_slverr))
                reg_resp <= 1'b1; 
    end
    assign h_resp = p_slverr ? 1'b1 : reg_resp;
endmodule