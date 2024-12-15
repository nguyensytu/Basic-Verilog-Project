module AXI_AHB_bridge (
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
    input r_ready,
// device interface
    output w_en,
    output [5:0] offset,
    output [31:0] d_wdata,
    output [3:0] strb,
    input [31:0] d_rdata
);
    localparam  idle = 2'b00,
                busy = 2'b01,
                nonseq = 2'b10,
                seq = 2'b11;   
// fifo signals // done
    wire aw_fifo_r, w_fifo_r, ar_fifo_r;
    wire aw_fifo_w, w_fifo_w, ar_fifo_w;
    wire [44:0] aw_fifo_w_data, ar_fifo_w_data, aw_fifo_r_data, ar_fifo_r_data;
    wire [40:0] w_fifo_w_data, w_fifo_r_data;
    wire aw_fifo_empty, w_fifo_empty, ar_fifo_empty;
    wire aw_fifo_full, w_fifo_full, ar_fifo_full;
// 
    

// Write address fifo
    assign aw_fifo_r = w_fifo_r_data[0] & w_fifo_r & (aw_fifo_r_data[44:41] == w_fifo_r_data[40:37]);
    assign aw_fifo_w = aw_valid & aw_ready;
    assign aw_fifo_w_data = {aw_id, aw_addr, aw_len, aw_size, aw_burst};
    // assign aw_fifo_empty //
    assign aw_ready = ~ aw_fifo_full;
    // assign aw_fifo_r_data = // 
    fifo #(.B(45), .W(4)) aw_fifo (
        a_clk, ~a_resetn, 
        aw_fifo_r, aw_fifo_w, aw_fifo_w_data, aw_fifo_empty, aw_fifo_full, aw_fifo_r_data 
    );
// Write data fifo
    assign w_fifo_r = b_ready & w_en;
    assign w_fifo_w = w_valid & w_ready;
    assign w_fifo_w_data = {w_id, w_data, w_strb, w_last};
    // assign w_fifo_empty = //
    assign w_ready = ~w_fifo_full;
    // assign w_fifo_r_data = //
    fifo #(.B(41), .W(5)) w_fifo (
        a_clk, ~a_resetn, 
        w_fifo_r, w_fifo_w, w_fifo_w_data, w_fifo_empty, w_fifo_full, w_fifo_r_data 
    );
// Read address fifo
    assign ar_fifo_r = r_last & r_ready;
    assign ar_fifo_w = ar_valid & ar_ready;
    assign ar_fifo_w_data = {ar_id, ar_addr, ar_len, ar_size, ar_burst};
    // assign ar_fifo_empty = //
    assign ar_ready = ~ar_fifo_full;
    // assign ar_fifo_r_data = // 
    fifo #(.B(45), .W(4)) ar_fifo (
        a_clk, ~a_resetn, 
        ar_fifo_r, ar_fifo_w, ar_fifo_w_data, ar_fifo_empty, ar_fifo_full, ar_fifo_r_data 
    );
// Write address channel signals
    
// Write response channel signals
    assign b_id = ;
    assign b_resp = slave_error ? 2'b10 :
                    decode_error ? 2'b11 : 2'b00;
    assign b_valid = h_ready & check_w_id;
    // assign b_ready = b_valid & h_ready;
// Read data channel signals
    assign r_id = ar_fifo_r_data[44:41];
    // assign r_data //
    assign r_resp = slave_error ? 2'b10 :
                    decode_error ? 2'b11 : 2'b00;
    // assign r_last
    assign r_valid = (~ar_fifo_empty) & (~rw_priority);
    // assign r_ready = r_valid & h_ready;
// device interface
    assign w_en = sel & (~aw_fifo_empty) & (~w_fifo_empty) & rw_priority & !slave_error;
    h_addr_write_count h_addr_write_count (
        a_clk, a_resetn, aw_fifo_r_data[40:9], aw_fifo_r_data[8:5], aw_fifo_r_data[4:2], b_ready, w_fifo_r_data[0],
        h_addr_write, len_error
    );
endmodule