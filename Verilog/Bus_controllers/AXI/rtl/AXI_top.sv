module AXI_top (
// AXI interface
    // Global signals
    input a_clk, // 
    input a_resetn, // 
    // Write address channel signals
    input [3:0] aw_id,
    input [31:0] aw_addr,
    input [3:0] aw_len,
    input [2:0] aw_size,
    input [1:0] aw_burst,
    // input [1:0] aw_lock,
    // input [3:0] aw_cache,
    // input [2:0] aw_prot,
    input aw_valid,
    output aw_ready,
    // Write data channel signals
    input [3:0] w_id,
    input [31:0] w_data, //
    input [3:0] w_strb,
    input w_last,
    input w_valid,
    output w_ready,
    // Write response channel signals
    output [3:0] b_id,
    output [1:0] b_resp,
    output b_valid,
    input b_ready,
    // Read address channel signals
    input [3:0] ar_id,
    input [31:0] ar_addr,
    input [3:0] ar_len,
    input [2:0] ar_size,
    input [1:0] ar_burst,
    // input [1:0] ar_lock,
    // input [3:0] ar_cache,
    // input [2:0] ar_prot,
    input ar_valid,
    output ar_ready,
    // Read data channel signals
    output [3:0] r_id,
    output [31:0] r_data, //
    output [1:0] r_resp,
    output r_last,
    output r_valid,
    input r_ready
);
    // AHB salve interface
    logic [31:0] h_addr;
    logic [2:0] h_burst;
    logic [2:0] h_size;
    logic [1:0] h_trans;
    logic [31:0] h_wdata;
    logic [3:0] h_wstrb;
    logic h_write;
    logic [31:0] h_rdata;
    logic h_ready;
    logic h_resp;

    AXI_AHB_bridge AXI_slave (
        a_clk, a_resetn, 
        aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_valid, aw_ready,
        w_id, w_data, w_strb, w_last, w_valid, w_ready,
        b_id, b_resp, b_valid, b_ready,
        ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_valid, ar_ready,
        r_id, r_data, r_resp, r_last, r_valid, r_ready,
        h_addr, h_burst, h_size, h_trans, h_wdata, h_wstrb, h_write, h_rdata, h_ready, h_resp
    );
    AHB_slave AHB_slave (
        a_clk, a_resetn, h_addr, h_burst, h_size, h_trans, h_wdata, h_wstrb, h_write, h_rdata, h_ready, h_resp
    );
//
    //
    //     wire w_en;
    //     wire[5:0] offset;
    //     wire [3:0] strb;
    //     wire [31:0] d_wdata, d_rdata;
    // //
    // AXI_bridge AXI_slave (
    //     a_clk, a_resetn, 
    //     aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_valid, aw_ready,
    //     w_id, w_data, w_strb, w_last, w_valid, w_ready,
    //     b_id, b_resp, b_valid, b_ready,
    //     ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_valid, ar_ready,
    //     r_id, r_data, r_resp, r_last, r_valid, r_ready,
    //     w_en, offset, d_wdata, strb, d_rdata
    // );
    // register_file_32bit #(.NumWords(64)) device0 (
    //     a_clk, a_resetn, w_en, offset, d_wdata, strb, d_rdata
    // );
//
    // wire [31:0] p_addr;
    // wire p_sel;
    // wire p_enable;
    // wire p_write;
    // wire [31:0] p_wdata;
    // wire [3:0] p_strb;
    // wire [31:0] p_rdata;
    // wire p_ready;
    // wire p_slverr;

    // AXI_APB_bridge AXI_slave (
    //     a_clk, a_resetn, 
    //     aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_valid, aw_ready,
    //     w_id, w_data, w_strb, w_last, w_valid, w_ready,
    //     b_id, b_resp, b_valid, b_ready,
    //     ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_valid, ar_ready,
    //     r_id, r_data, r_resp, r_last, r_valid, r_ready,
    //     p_addr, p_sel, p_enable, p_write, p_wdata, p_strb, p_rdata, p_ready, p_slverr
    // );   
    // APB_slave_32bit #(.NumWords(64)) device0 (
    //     a_clk, a_resetn, p_addr, p_sel, p_enable, p_write, p_wdata, p_strb, p_rdata, p_ready, p_slverr
    // );
endmodule