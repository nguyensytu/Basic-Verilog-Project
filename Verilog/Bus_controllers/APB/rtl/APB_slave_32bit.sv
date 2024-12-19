module APB_slave_32bit #(
    parameter int NumWords = 64,
                  AddrBits = 32
)( 
    input p_clk, 
    input p_resetn,
    input [AddrBits-1:0] p_addr, 
    input p_sel, 
    input p_enable, 
    input p_write, 
    input [31:0] p_wdata,
    input [3:0] p_strb,
    output [31:0] p_rdata,
    output p_ready,
    output p_slverr
);
    wire w_en;
    reg [3:0] strb;
    wire [$clog2(NumWords)-1:0] offset;
    wire strb_addr_error;
    //
    register_file_32bit #(.NumWords(NumWords)) device0 (
        p_clk, p_resetn, w_en, offset, p_wdata, strb, p_rdata
    );
    assign w_en = p_sel & p_write & p_enable & (strb != 4'b0000) & !p_slverr;
    addr_strb_decoder #(.NumWords(NumWords)) addr_strb_decoder (
        p_addr, strb, offset, strb_addr_error
    );
    always @(posedge p_clk, negedge p_resetn) begin
        if(!p_resetn) strb <= 4'b0000;
        else if (p_sel && !p_enable) 
            if(p_write)
                strb <= p_strb;
            else 
                strb <= 4'b1111;
    end    
    assign p_ready = p_sel & p_enable;
    assign p_slverr = p_enable & strb_addr_error;
endmodule