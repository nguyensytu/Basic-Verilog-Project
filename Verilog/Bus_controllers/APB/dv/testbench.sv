module apb_slave_tb;
    logic p_clk;
    logic p_resetn;
    logic [31:0] p_addr;
    logic p_sel[1:0];
    logic p_enable[1:0];
    logic p_write;
    logic [31:0] p_wdata;
    logic [3:0] p_strb;
    logic [31:0] p_rdata[1:0];
    logic p_ready[1:0];
    logic p_slverr[1:0];


    APB_slave_32bit #(.NumWords(64)) device0 (
        p_clk, p_resetn, p_addr, p_sel[0], p_enable[0], p_write, p_wdata, p_strb, p_rdata[0], p_ready[0], p_slverr[0]
    );
    APB_slave_8bit #(.NumWords(64)) device1 (
        p_clk, p_resetn, p_addr, p_sel[1], p_enable[1], p_write, p_wdata, p_strb, p_rdata[1], p_ready[1], p_slverr[1]
    );

    initial begin
        p_clk = 0;
        forever begin
            #5 p_clk = ~p_clk;
        end
    end
    `include "apb_task.sv"
    initial begin
        p_resetn = 0;
        apb_init();
        #20 p_resetn = 1;
        #10 apb_write(1, $random);
        apb_write(0, $random);
        apb_write(1, 32'hff);
        apb_write(1, $random);
        apb_write(0, 32'hff);
        apb_write(1, $random);
        apb_write(0, $random);
        apb_write(1, $random);
        apb_write(0, $random);
        apb_write(1, $random);
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        // apb_write();
        apb_read(0);
        apb_read(1);
        apb_read(0);
        apb_read(1);
        apb_read(0);
        apb_read(1);
    end
endmodule