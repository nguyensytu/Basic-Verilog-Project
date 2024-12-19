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
    output reg [3:0] b_id,
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
    output reg [3:0] r_id,
    output [31:0] r_data, //
    output [1:0] r_resp,
    output reg r_last,
    output r_valid,
    input r_ready,
// AHB interface
    output [31:0] h_addr,
    output [2:0] h_burst,
    output [2:0] h_size,
    output [1:0] h_trans,
    output reg [31:0] h_wdata,
    output [3:0] h_wstrb,
    output h_write,
    input [31:0] h_rdata,
    input h_ready,
    input h_resp
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
    wire [3:0] b_id_next, r_id_next;
    wire [2:0] b_resp_next, r_resp_next;
    wire b_valid_next, r_valid_next;
    wire r_last_next;
    reg [1:0] b_resp_reg, r_resp_reg;
    reg b_valid_reg, r_valid_reg;
    reg aw_done_illegal_reg, w_id_err_reg, ar_done_illegal_reg;
    reg write_reg;
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
    assign w_fifo_r =  ((h_ready & b_ready & h_write) | w_id_err) & (~w_fifo_empty);
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
        a_clk, a_resetn, (b_ready & h_write & (~aw_fifo_empty)),
        aw_fifo_r_data[44:41], aw_fifo_r_data[40:9], aw_fifo_r_data[8:5], aw_fifo_r_data[4:2], aw_fifo_r_data[1:0], 
        w_fifo_r_data[40:37], w_fifo_r_data[4:1], w_fifo_r_data[0], w_fifo_r, 
        aw_fifo_r, reg_aw, reg_strb, aw_done_err, aw_done_illegal, w_id_err
    );
    ar_decoder ar_decoder (
        a_clk, a_resetn, (r_ready & ~h_write & (~ar_fifo_empty)),
        ar_fifo_r_data[40:9], ar_fifo_r_data[8:5], ar_fifo_r_data[4:2], ar_fifo_r_data[1:0],
        r_ready & r_valid_next, 
        ar_fifo_r, reg_ar, ar_done_illegal
    );
// Write response channel signals
    assign b_id_next = aw_fifo_r_data[44:41];
    assign b_resp_next = ((h_addr[31:6] != 26'b0) & h_write) ? 2'b11 :
                    (w_id_err | aw_done_err | aw_done_illegal) ? 2'b10 : 2'b00;
    assign b_valid_next = w_fifo_r | aw_fifo_r;
    // b_ready
// Read data channel signals
    assign r_id_next = ar_fifo_r_data[44:41];
    assign r_data = h_rdata;
    assign r_resp_next = ((h_addr[31:6] != 26'b0) & (~h_write)) ? 2'b11 :
                    (ar_done_illegal) ? 2'b10 : 2'b00;
    assign r_last_next = ar_fifo_r;
    assign r_valid_next = (~ar_fifo_empty) & ((h_ready & r_ready) | ar_done_illegal) & (~h_write);
    // r_ready
//
    always @(posedge a_clk, negedge a_resetn) begin
        if(!a_resetn) begin
            b_id <= 4'b0;
            b_resp_reg <= 2'b0;
            b_valid_reg <= 1'b0;
            r_id <= 4'b0;
            r_resp_reg <= 2'b0;
            r_last <= 1'b0;
            r_valid_reg <= 1'b0;
            write_reg <= 1'b0;
            aw_done_illegal_reg <= 1'b0;
            w_id_err_reg <= 1'b0;
            ar_done_illegal_reg <= 1'b0;
        end
        else begin
            aw_done_illegal_reg <= aw_done_illegal;
            w_id_err_reg <= w_id_err;
            ar_done_illegal_reg <= ar_done_illegal;
            if((h_ready & b_ready) & h_write) begin
                b_id <= b_id_next;
                b_resp_reg <= b_resp_next;
                b_valid_reg <= b_valid_next;
                write_reg <= h_write;
            end
            else if((h_ready & r_ready) & (~h_write)) begin
                r_id <= r_id_next;
                r_resp_reg <= r_resp_next;
                r_last <= r_last_next;
                r_valid_reg <= r_valid_next;
                write_reg <= h_write;
            end
        end
    end
    assign b_resp = (write_reg & h_resp) ? 2'b01 : b_resp_reg;
    assign r_resp = (~write_reg & h_resp) ? 2'b01 : r_resp_reg;
    assign b_valid = (write_reg & (h_ready || aw_done_illegal_reg || w_id_err_reg)) ? b_valid_reg : 1'b0;
    assign r_valid = (~write_reg & (h_ready || ar_done_illegal_reg)) ? r_valid_reg : 1'b0;
// device interface
    assign h_addr = (h_write) ? reg_aw : reg_ar;
    h_burst_decoder h_burst_decoder(
        aw_fifo_r_data[8:5], ar_fifo_r_data[8:5], 
        aw_fifo_r_data[1:0], ar_fifo_r_data[1:0],
        h_write, h_burst
    );
    assign h_size = h_write ? aw_fifo_r_data[4:2] : ar_fifo_r_data[4:2] ;
    h_trans_decoder h_trans_decoder (
        b_ready, r_ready, aw_fifo_empty, ar_fifo_empty, h_write, h_burst, w_fifo_empty, aw_done_illegal, w_id_err, ar_done_illegal, h_trans
    );
    always @(posedge a_clk, negedge a_resetn) begin
        if(!a_resetn) h_wdata <= 32'b0;
        else if(w_fifo_r) h_wdata <= w_fifo_r_data[36:5];
    end
    assign h_wstrb = (h_write) ? reg_strb : 4'b1111;
    assign h_write = (~aw_fifo_empty);
    // h_rdata
endmodule