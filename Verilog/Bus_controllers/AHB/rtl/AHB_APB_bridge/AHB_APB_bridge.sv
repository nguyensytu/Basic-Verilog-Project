module AHB_APB_bidge (
// AHB slave interface
    input h_clk,
    input h_resetn,
    input [31:0] h_addr,
    input [2:0] h_burst,
    // input h_mastlock,
    // input h_prot,
    input [2:0] h_size,
    // input h_nonsec,
    // input h_excl,
    // input [] h_master,
    input [1:0] h_trans,
    input [31:0] h_wdata,
    input [3:0] h_wstrb,
    input h_write,
    output [31:0] h_rdata,
    output h_ready,
    output h_resp,
    // output h_exokay
// APB interface
    output p_clk, 
    output p_resetn,
    output [31:0] p_addr, 
    output p_sel, 
    output p_enable, 
    output p_write, 
    output [31:0] p_wdata,
    output [3:0] p_strb,
    input [31:0] p_rdata,
    input p_ready,
    input p_slverr,
//
    input [25:0] base_addr
);
    localparam  idle = 2'b00,
                busy = 2'b01,
                nonseq = 2'b10,
                seq = 2'b11;
    //
    reg [31:0] reg_addr;
    reg [2:0] reg_burst;
    reg [2:0] reg_size;
    reg [1:0] reg_trans;
    reg [3:0] reg_wstrb;
    reg reg_write;
    wire slave_error, burst_err, size_err;
    always @(posedge h_clk, negedge h_resetn) begin
        if(!h_resetn) begin
            reg_addr <= 32'b0;
            reg_burst <= 3'b0;
            reg_size <= 3'b0;
            reg_trans <= idle;
            reg_wstrb <= 4'b0;
            reg_write <= 1'b0;
        end
        else begin
            if(h_ready) begin
                if(h_trans != busy) begin
                    reg_trans <= h_trans;
                    reg_addr <= h_addr;
                    if((h_trans == seq) || (h_trans == nonseq))
                        reg_burst <= h_burst;
                    else
                        reg_burst <= 3'b0;
                    reg_size <= h_size;
                    reg_wstrb <= h_wstrb;
                    reg_write <= h_write;
                end
            end
            else begin
                if(h_resp)
                    reg_trans <= idle;
            end
        end
    end
// APB interface configure
    assign p_clk = h_clk;
    assign p_resetn = h_resetn;
    // assign p_addr;
    // assign p_sel = h_sel;
    // assign p_enable;
    assign p_write = reg_write;
    assign p_wdata = h_wdata;
    // assign p_strb = reg_wstrb & ;
    assign h_rdata = p_rdata;
    assign h_ready = (reg_trans == idle) | (p_ready & !p_slverr);
    // assign h_resp =  p_slverr | burst_err | size_err;
    assign slave_error = burst_err | size_err;
    p_addr_decoder p_addr_decoder (
        reg_addr, base_addr, p_sel, p_addr
    );
    p_enable_decoder p_enable_decoder (
        h_clk, h_resetn, h_trans, reg_trans, p_sel, p_slverr, slave_error, h_ready, p_enable
    );
    p_strb_decoder p_strb_decoder (
        reg_wstrb, reg_size, p_strb, size_err
    );
    burst_err_decode burst_err_decode (
        h_clk, h_resetn, h_addr, reg_addr, h_burst, reg_burst, h_size, reg_size, h_trans, reg_trans,
        burst_err
    ); 
    h_resp_decoder h_resp_decoder(
        h_clk, h_resetn, h_trans, reg_trans, p_sel, p_slverr, slave_error, h_resp
    );
endmodule