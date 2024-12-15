module d_latch_tb;
    reg  d, enable;
    wire q;

    d_latch uut (enable, d, q);
    initial begin
        enable = 0;
        forever #5 enable = ~enable; 
    end
    initial begin
        forever begin
            d = $random; #5; 
        end
    end
endmodule