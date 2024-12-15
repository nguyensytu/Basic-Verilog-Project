module i2c_master_fifo_tb;
    reg clk, reset, wr, rd, rd_wr_en, start;
    wire empty_tx, full_tx, empty_rx, full_rx;
    reg [6:0] w_addr;
    reg [7:0] w_fifo_data;
    wire [7:0] r_fifo_data;
    wire scl, sda;
    i2c_master_fifo #() uut (
        clk, reset, wr, rd, rd_wr_en, start,
        empty_tx, full_tx, empty_rx, full_rx,
        w_addr, w_fifo_data, r_fifo_data, scl, sda
    );
    initial begin
        clk <= 0; reset <= 0; rd_wr_en <= 0;
        wr <= 0; rd <= 0; 
        w_addr <= 7'h15; #20
        reset <= 1; #20
        reset <= 0; #20
        w_fifo_data <= 8'haa; wr <= 1; #20 
        wr <= 0; #20 
        w_fifo_data <= 8'hbb; wr <= 1; #20 
        wr <= 0; #20
        w_fifo_data <= 8'h56; wr <= 1; #20 
        wr <= 0; #20
        w_fifo_data <= 8'h37; wr <= 1; #20 
        wr <= 0;      
    end
    initial begin
        start <= 0; #270
        start <= 1; #20
        start <= 0; #5850 //6000
        start <= 1; #20
        start <= 0; 
    end
    always #10 clk <= ~clk;
endmodule