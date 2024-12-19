module APB_slave_8bit #(
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
    wire [7:0] data_in, data_out;
    reg [31:0] rdata_reg;
    wire strb_addr_error;
    register_file_8bit #(.NumWords(NumWords)) device0 (
        p_clk, p_resetn, w_en, offset, data_in, data_out
    );
    assign w_en = p_sel & p_write & p_enable & (strb != 4'b0000) & !p_slverr;
    addr_strb_decoder #(.NumWords(NumWords)) addr_strb_decoder (
        p_addr, strb, offset, strb_addr_error
    );
    assign data_in = strb[3] ? p_wdata[31:24] :
                     strb[2] ? p_wdata[23:16] : 
                     strb[1] ? p_wdata[15:8] : p_wdata[7:0];
    assign p_rdata = {rdata_reg[31:8], data_out};
    always @(posedge p_clk, negedge p_resetn) begin
        if(!p_resetn) rdata_reg <= 32'b0;
        else if(strb[3]) rdata_reg[31:24] <= data_out;
        else if(strb[2]) rdata_reg[23:16] <= data_out;
        else if(strb[1]) rdata_reg[15:8] <= data_out;
        else if(strb[0]) rdata_reg[7:0] <= data_out;
    end 

    always @(posedge p_clk, negedge p_resetn) begin
        if(!p_resetn || p_slverr) strb <= 4'b0000;
        else if (p_sel && !p_enable) 
            if(p_write)
                strb <= p_strb;
            else 
                strb <= 4'b1111;
        else if (p_sel && p_enable)begin
            if (strb[3]) begin
                strb[3] <= 1'b0; 
            end
            else if(strb[2]) begin
                strb[2] <= 1'b0;
            end 
            else if(strb[1]) begin
                strb[1] <= 1'b0;
            end 
            else if(strb[0]) begin
                strb[0] <= 1'b0;
            end 
        end
    end
    assign p_ready = p_sel & (p_slverr | (p_enable & (strb==4'b0001 | strb==4'b0010 | strb==4'b0100 | strb==4'b1000 | strb==4'b0000)));
    assign p_slverr = p_enable & strb_addr_error;
endmodule