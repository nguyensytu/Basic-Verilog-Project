module AXI_bridge (
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
// fifo signals // done
    wire aw_fifo_r, w_fifo_r, ar_fifo_r;
    wire aw_fifo_w, w_fifo_w, ar_fifo_w;
    wire [44:0] aw_fifo_w_data, ar_fifo_w_data, aw_fifo_r_data, ar_fifo_r_data;
    wire [40:0] w_fifo_w_data, w_fifo_r_data;
    wire aw_fifo_empty, w_fifo_empty, ar_fifo_empty;
    wire aw_fifo_full, w_fifo_full, ar_fifo_full;
// fifo controller
    wire [31:0] reg_aw, reg_ar;
    wire [3:0] reg_strb;
    wire aw_done_err, aw_done_illegal, w_id_err, ar_done_illegal;
// 
    wire rw_priority;
//
    wire [31:0] d_addr;
// Write address fifo
    // assign aw_fifo_r //
    assign aw_fifo_w = aw_valid & aw_ready;
    assign aw_fifo_w_data = {aw_id, aw_addr, aw_len, aw_size, aw_burst};
    // assign aw_fifo_empty //
    assign aw_ready = ~ aw_fifo_full;
    // assign aw_fifo_r_data  // 
    fifo #(.B(45), .W(4)) aw_fifo (
        a_clk, ~a_resetn, 
        aw_fifo_r, aw_fifo_w, aw_fifo_w_data, aw_fifo_empty, aw_fifo_full, aw_fifo_r_data 
    );
// Write data fifo
    assign w_fifo_r =  w_en | (w_id_err & (~w_fifo_empty));
    assign w_fifo_w = w_valid & w_ready;
    assign w_fifo_w_data = {w_id, w_data, w_strb, w_last};
    // assign w_fifo_empty //
    assign w_ready = ~w_fifo_full;
    // assign w_fifo_r_data //
    fifo #(.B(41), .W(5)) w_fifo (
        a_clk, ~a_resetn, 
        w_fifo_r, w_fifo_w, w_fifo_w_data, w_fifo_empty, w_fifo_full, w_fifo_r_data 
    );
// Read address fifo
    // assign ar_fifo_r 
    assign ar_fifo_w = ar_valid & ar_ready;
    assign ar_fifo_w_data = {ar_id, ar_addr, ar_len, ar_size, ar_burst};
    // assign ar_fifo_empty //
    assign ar_ready = ~ar_fifo_full;
    // assign ar_fifo_r_data // 
    fifo #(.B(45), .W(4)) ar_fifo (
        a_clk, ~a_resetn, 
        ar_fifo_r, ar_fifo_w, ar_fifo_w_data, ar_fifo_empty, ar_fifo_full, ar_fifo_r_data 
    );
// fifo controller
    aw_decoder aw_decoder (
        a_clk, a_resetn, (b_ready & rw_priority & (~aw_fifo_empty)),
        aw_fifo_r_data[44:41], aw_fifo_r_data[40:9], aw_fifo_r_data[8:5], aw_fifo_r_data[4:2], aw_fifo_r_data[1:0], 
        w_fifo_r_data[40:37], w_fifo_r_data[4:1], w_fifo_r_data[0], w_fifo_r, 
        aw_fifo_r, reg_aw, reg_strb, aw_done_err, aw_done_illegal, w_id_err
    );
    ar_decoder ar_decoder (
        a_clk, a_resetn, (r_ready & ~rw_priority & (~ar_fifo_empty)),
        ar_fifo_r_data[40:9], ar_fifo_r_data[8:5], ar_fifo_r_data[4:2], ar_fifo_r_data[1:0],
        r_ready & r_valid, 
        ar_fifo_r, reg_ar, ar_done_illegal
    );
// Write response channel signals
    assign b_id = aw_fifo_r_data[44:41];
    assign b_resp = ((d_addr[31:6] != 26'b0) & rw_priority) ? 2'b11 :
                    (w_id_err | aw_done_err | aw_done_illegal) ? 2'b10 : 2'b00;
    assign b_valid = w_fifo_r | aw_fifo_r;
    // b_ready
// Read data channel signals
    assign r_id = ar_fifo_r_data[44:41];
    assign r_data = d_rdata;
    assign r_resp = ((d_addr[31:6] != 26'b0) & (~rw_priority)) ? 2'b11 :
                    (ar_done_illegal) ? 2'b10 : 2'b00;
    assign r_last = ar_fifo_r;
    assign r_valid = (~ar_fifo_empty) & (~rw_priority);
    // r_ready
// 
    assign rw_priority = (~aw_fifo_empty);
// device interface
    assign w_en =   b_ready & rw_priority & (~aw_fifo_empty) & (~w_fifo_empty) & 
                    ~(w_id_err | aw_done_illegal) ;
    assign d_addr = (rw_priority) ? reg_aw : reg_ar;
    assign offset = d_addr[5:0];
    assign d_wdata = w_fifo_r_data[36:5];
    assign strb = (rw_priority) ? reg_strb : 4'b1111;
    // d_rdata
endmodule