task ahb_init ();
    h_addr = 0;
    h_burst = 0;
    h_size = 0;
    h_trans = idle;
    h_wdata = 0;
    h_wstrb = 0;
    h_write = 0;
endtask
task ahb_idle ();
    $display("[%0t] ahb idle", $time); 
    #1 h_addr = 0;
    h_burst = 0;
    h_size = 0;
    h_trans = idle;
    h_wdata = 0;
    h_wstrb = 0;
    h_write = 0;
    ahb_wait_ready();
    if(h_ready) begin
        $display("[%0t] To idle state", $time); 
    end
    else begin
        $display("[%0t] Continue wait state", $time);  
    end
endtask

task ahb_busy ();
    $display("[%0t] ahb busy", $time); 
    #1 h_addr = 0;
    h_burst = 0;
    h_size = 0;
    h_trans = busy;
    h_wdata = 0;
    h_wstrb = 0;
    h_write = 0;
    @(posedge h_clk);
    if(h_ready) begin
        $display("[%0t] To busy state", $time); 
    end
    else begin
        $display("[%0t] Continue wait state", $time);  
    end
endtask
task ahb_write_nonseq (logic[23:0] upper_addr, logic[5:0] lower_addr, logic [2:0] burst, logic [2:0] size, logic [3:0] wstrb);
    $display("[%0t] ahb nonseq", $time);
    #1 h_addr [31:6] = upper_addr;
    h_addr [5:0] = lower_addr;
    h_burst = burst;
    h_size = size;
    h_trans = nonseq;
    h_wdata = $random;
    h_wstrb = wstrb;
    h_write = 1'b1;
    $display("[%0t] Next transfer : device = %8h, addr = %8h", $time, h_addr[31:6], h_addr[5:0]);
    ahb_wait_ready();
endtask
task ahb_write_seq (logic[23:0] upper_addr, logic[5:0] lower_addr, logic [2:0] burst, logic [2:0] size, logic [3:0] wstrb);
    $display("[%0t] ahb seq", $time);
    #1 h_addr [31:6] = upper_addr;
    h_addr [5:0] = lower_addr;
    h_burst = burst;
    h_size = size;
    h_trans = seq;
    h_wdata = $random;
    h_wstrb = wstrb;
    h_write = 1'b1;
    $display("[%0t] Next transfer : device = %8h, addr = %8h", $time, h_addr[31:6], h_addr[5:0]);
    ahb_wait_ready();
endtask

task ahb_read ();

endtask



task automatic ahb_wait_ready(int max_clk = 10);
    int i;
    h_wdata = $random;
    @(posedge h_clk);
    while (~h_ready && ~h_resp && i < max_clk) begin
        i++; 
        @(posedge h_clk);
    end
    if(h_resp) begin
        ahb_idle();
        $display("[%0t] Transfer error", $time); 
    end
    else if (h_ready) begin
        if(uut.reg_trans == idle) 
            $display("[%0t] Start transfer", $time); 
        else begin
            $display("[%0t] Transfer done : device = %8h, addr = %8h, wdata = %8h", $time, uut.reg_addr[31:6], uut.reg_addr[5:0], h_wdata);
        end
    end
    else 
        $display("[%0t] Error: waited for h_ready for too long", $time);
endtask //automatic