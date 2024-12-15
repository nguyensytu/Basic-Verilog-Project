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
    wire [$clog2(NumWords):0] ref_addr;
    wire [$clog2(NumWords)-1:0] offset;
    assign ref_addr =   p_strb[3] ? {1'b0,p_addr[$clog2(NumWords)-1:0]} + 2'b11 :
                        p_strb[2] ? {1'b0,p_addr[$clog2(NumWords)-1:0]} + 2'b10 :
                        p_strb[1] ? {1'b0,p_addr[$clog2(NumWords)-1:0]} + 2'b01 : {1'b0,p_addr[$clog2(NumWords)-1:0]};
    assign offset = p_addr[$clog2(NumWords)-1:0];
    assign w_en = p_sel & p_write & p_enable & (strb != 4'b0000) & !p_slverr;
    register_file_32bit #(.NumWords(NumWords)) device0 (
        p_clk, p_resetn, w_en, offset, p_wdata, strb, p_rdata
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
    assign p_slverr = p_enable & ref_addr[$clog2(NumWords)];
endmodule