task axi_init ();
    //
    aw_id = 0;
    aw_addr = 0;
    aw_len = 0;
    aw_size = 0;
    aw_burst = 0;
    aw_valid = 0;
    //
    w_id = 0;
    w_data = 0;
    w_strb = 0;
    w_last = 0;
    w_valid = 0;
    //
    b_ready = 0;
    //
    ar_id = 0;
    ar_addr = 0;
    ar_len = 0;
    ar_size = 0;
    ar_burst = 0;
    ar_valid = 0;
    //
    r_ready = 0;
endtask
task axi_aw (logic[3:0] id, logic[25:0] upper_addr, logic[3:0] len, logic[2:0] size, logic[1:0] burst, logic valid);
    aw_id = id;
    aw_addr[31:6] = upper_addr; 
    aw_addr[5:0] = $random;
    aw_len = len;
    aw_size = size;
    aw_burst = burst;
    aw_valid = valid;
    axi_wait_ready(aw_ready);
    aw_valid =1'b0;
endtask
task axi_w (logic[3:0] id, logic[3:0] strb, logic last, logic valid);
    w_id = id;
    w_data = $random;
    w_strb = strb;
    w_last = last;
    w_valid = valid;
    axi_wait_ready(w_ready);
    w_valid = 1'b0;
endtask
task axi_b ();
    axi_wait_ready(b_valid);
    $display("[%0t] b_id = %8h, b_resp = %8h", $time, b_id, b_resp);
endtask
task axi_ar (logic[3:0] id, logic[25:0] upper_addr, logic[3:0] len, logic[2:0] size, logic[1:0] burst, logic valid);
    ar_id = id;
    ar_addr[31:6] = upper_addr; 
    ar_addr[5:0] = $random;
    ar_len = len;
    ar_size = size;
    ar_burst = burst;
    ar_valid = valid;
    axi_wait_ready(ar_ready);
    ar_valid = 1'b0;
endtask
task axi_r ();
    axi_wait_ready(r_valid);
    $display("[%0t] r_id = %8h, r_resp = %8h, r_last = %8h", $time, r_id, r_resp, r_last);
endtask
task axi_r_wait_last ();


endtask
task automatic axi_wait_ready (logic ready, int max_clk = 10);
    int i;
    @(posedge a_clk);
    while (~ready && i < max_clk) begin
        i++; 
        @(posedge a_clk);
    end
    if (ready) 
        $display("[%0t] Transfer done", $time);
    else 
        $display("[%0t] Error: waited for h_ready for too long", $time);
endtask