task apb_init();
    p_addr = 0;
    p_sel[1] = 0;
    p_sel[0] = 0;
    p_enable[1] = 0;
    p_enable[0] = 0;
    p_write = 0;
    p_wdata = 0;
    p_strb = 0;
endtask
task apb_write (logic device, logic[31:0] addr);  
    @(posedge p_clk); #1;
    p_addr = addr;
    p_sel[device] = 1;
    p_enable[device] = 0;
    p_write = 1;
    p_wdata = $random;
    p_strb = $random;
    @(posedge p_clk); #1;
    p_sel[device] = 1;
    p_enable[device] = 1;
    p_write = 1;
    p_wdata = $random;
    apb_wait_ready(device);
    $display("addr = %8h, strb = %8h, wdata = %8h", p_addr, p_strb, p_wdata);
    if (p_slverr[device])
        $display("[%6t] Error: slave raised an error", $time);
    p_addr = $random;
    p_sel[device] = 0;
    p_enable[device] = 0;
    p_wdata = $random;
    p_strb = $random;
endtask
task  apb_read(logic device);
    @(posedge p_clk); #1;
    p_addr = $random;
    p_sel[device] = 1;
    p_enable[device] = 0;
    p_write = 0;
    p_strb = 0;
    @(posedge p_clk); #1
    p_sel[device] = 1;
    p_enable[device] = 1;
    p_write = 0;
    apb_wait_ready(device);
    $display("addr = %8h, strb = %8h, rdata = %8h", p_addr, p_strb, p_rdata[device]);
    if (p_slverr[device])
        $display("[%6t] Error: slave raised an error", $time);
    p_addr = $random;
    p_sel[device] = 0;
    p_enable[device] = 0;
    p_strb = $random;
endtask 

task automatic apb_wait_ready(logic device, int max_clk = 10);
    int i;
    @(posedge p_clk);
    while (~p_ready[device] && i < max_clk) begin
        i++; 
        @(posedge p_clk);
    end
    if(p_ready[device])
        $display("[%6t]Transfer done", $time);
    else 
        $display("[%6t] Error: waited for p_ready for too long", $time);
endtask 