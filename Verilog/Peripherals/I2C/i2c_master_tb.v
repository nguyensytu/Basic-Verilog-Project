module i2c_master_tb;
    reg clk, reset, start, stop, rd_wr_en;
    reg [6:0] w_addr;
    reg [7:0] w_data;
    reg sda_ack;
    wire scl, sda;
    i2c_master #() uut (
        .clk(clk), .reset(reset), .start(start), .stop(stop), .rd_wr_en(rd_wr_en), 
        .w_addr(w_addr), .w_data(w_data), .sda(sda), .scl(scl)
    );
    initial begin
        clk <= 0; reset <= 0; start <= 0; stop <= 0; rd_wr_en <= 0; 
        w_addr <= 7'h15; w_data <= 8'h36;  #20
        reset <= 1; #20
        reset <= 0; #20
        start <= 1; #20
        start <= 0;
    end
    initial begin
        stop <= 0; #3490
        stop <= 1; #201
        stop <= 0;
    end
    always #10 clk <= ~clk;
endmodule