module uart_tx_top_tb;
    reg clk, reset_n, wr;
    reg [7:0] data_wr;
    uart_tx_top uut (clk, reset_n, wr, data_wr);
    initial begin
        clk <= 0;
        reset_n <= 0;
        wr <= 0;
        data_wr <= 8'h55; #10
        reset_n <= 0; #10
        reset_n <= 1; 
        wr <= 1; #20;
		wr <= 0;
    end
    always #10 clk = ~clk;
    
endmodule