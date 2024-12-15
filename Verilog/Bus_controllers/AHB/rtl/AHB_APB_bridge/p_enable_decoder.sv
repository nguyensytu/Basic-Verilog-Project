module p_enable_decoder (
    input h_clk,
    input h_resetn,
    input [1:0] h_trans, reg_trans,
    input p_sel,
    input p_slverr,
    input slave_error,
    input h_ready,
    output reg p_enable
);
    localparam  idle = 2'b00,
                busy = 2'b01,
                nonseq = 2'b10,
                seq = 2'b11;
    reg h_enable; 
    // reg reg_p_enable;
    always @(*) begin
        h_enable = 1'b0;
        case (reg_trans)
            // idle:
            // busy:
            nonseq: begin
                if(h_trans != busy)
                    h_enable = 1;
            end
            seq: begin
                if(h_trans != busy) 
                    h_enable = 1;
            end
        endcase
    end
    always @(posedge h_clk, negedge h_resetn) begin
        if(!h_resetn)
            p_enable <= 1'b0;
        else begin
            if(h_ready) p_enable <= 1'b0;
            else if (h_enable && !slave_error && !p_slverr) 
                p_enable <= p_sel;
            else 
                p_enable <= 1'b0;
        end
    end
    // assign p_enable = slave_error ? 1'b0 : reg_p_enable;
endmodule