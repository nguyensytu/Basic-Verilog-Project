module axi_slave_tb;
// AXI salve interface
    logic a_clk;
    logic a_resetn;
    // 
    logic [3:0] aw_id;
    logic [31:0] aw_addr;
    logic [3:0] aw_len;
    logic [2:0] aw_size;
    logic [1:0] aw_burst;
    logic aw_valid;
    logic aw_ready;
    //
    logic [3:0] w_id;
    logic [31:0] w_data;
    logic [3:0] w_strb;
    logic w_last;
    logic w_valid;
    logic w_ready;
    //
    logic [3:0] b_id;
    logic [1:0] b_resp;
    logic b_valid;
    logic b_ready;
    //
    logic [3:0] ar_id;
    logic [31:0] ar_addr;
    logic [3:0] ar_len;
    logic [2:0] ar_size;
    logic [1:0] ar_burst;
    logic ar_valid;
    logic ar_ready;
    //
    logic [3:0] r_id;
    logic [31:0] r_data;
    logic [1:0] r_resp;
    logic r_last;
    logic r_valid;
    logic r_ready;
// Module instances
    AXI_top uut (
        a_clk, a_resetn, 
        aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_valid, aw_ready,
        w_id, w_data, w_strb, w_last, w_valid, w_ready,
        b_id, b_resp, b_valid, b_ready,
        ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_valid, ar_ready,
        r_id, r_data, r_resp, r_last, r_valid, r_ready
    );
    initial begin
        a_clk = 0;
        forever #5 a_clk = ~a_clk;
    end
    `include "axi_task.sv"
    initial begin
        a_resetn = 0;
        axi_init();
        #20 a_resetn = 1;
        #10 @(posedge a_clk);
        fork
            // aw
            begin
                axi_aw(4'b0, 26'b0, 4'b0, 3'b010, 2'b0, 1'b1);
                axi_aw(4'b0, 26'b0, 4'b0, 3'b010, 2'b0, 1'b1);
                axi_aw(4'b0, 26'b0, 4'b0, 3'b010, 2'b0, 1'b1);
                axi_aw(4'b0, 26'b0, 4'b0, 3'b010, 2'b0, 1'b1);
            end
            // w
            begin
                axi_w(4'b0, 4'b1111, 1'b1, 1'b1);
                axi_w(4'b0, 4'b1111, 1'b1, 1'b1);
                axi_w(4'b0, 4'b1111, 1'b1, 1'b1);
                axi_w(4'b0, 4'b1111, 1'b1, 1'b1);
                b_ready = 1'b1;
            end
            // b
            begin
                
            end
            //ar
            begin
                
            end
            //r
            begin
                
            end
        join
    end
endmodule