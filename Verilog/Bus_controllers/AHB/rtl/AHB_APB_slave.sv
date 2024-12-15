module AHB_APB_slave (
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
    output h_resp
    // output h_exokay
);
    // AHB
    wire d_ready;
    wire d_resp;
    // APB interface
    wire p_clk;
    wire p_resetn;
    wire [31:0] p_addr; 
    wire p_sel;
    wire p_enable; 
    wire p_write;
    wire [31:0] p_wdata;
    wire [3:0] p_strb;
    wire [31:0] p_rdata;
    wire p_ready;
    wire p_slverr;
    //
    wire clk;
    wire resetn;
    wire [5:0] offset; 
    wire w_en;
    wire [31:0] wdata;
    wire [3:0] strb;
    wire [31:0] rdata;
    //
    reg [25:0] base_addr;
    always @(posedge h_clk, negedge h_resetn) begin
        if(!h_resetn) begin
            base_addr = 26'b0;
        end
    end
    // AHB_APB_bidge AHB_device0 (
    //     h_clk, h_resetn, h_addr, h_burst, h_size, h_trans, h_wdata, h_wstrb, h_write, h_rdata, d_ready[0], d_resp[0],
    //     p_clk, p_resetn, p_addr, p_sel, p_enable, p_write, p_wdata, p_strb, p_rdata, p_ready, p_slverr,
    //     base_addr
    // );
    // APB_slave_8bit APB_device0 (
    //     p_clk, p_resetn, p_addr, p_sel, p_enable, p_write, p_wdata, p_strb, p_rdata, p_ready, p_slverr
    // );
    AHB_bridge AHB_device1 (
        h_clk, h_resetn, h_addr, h_burst, h_size, h_trans, h_wdata, h_wstrb, h_write, h_rdata, d_ready, d_resp,
        clk, resetn, offset, w_en, wdata, strb, rdata,
        base_addr       
    );
    register_file_32bit #(.NumWords(64)) device1 (
        clk, resetn, w_en, offset, wdata, strb, rdata
    );
    // AHB configure
    assign h_ready = d_ready;
    assign h_resp = d_resp;
endmodule