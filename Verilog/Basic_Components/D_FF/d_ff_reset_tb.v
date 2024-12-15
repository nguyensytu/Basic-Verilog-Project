module d_ff_reset_tb;
    reg clk, reset_n, d;
    wire q_0; 
    reg q_1;
    d_ff_reset uut (clk, reset_n, d, q_0);
    
    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) q_1 <= 1'b0;
        else q_1 <= d;
    end

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end 
    initial begin
        #15;
        forever begin
            d = $random; #20;
        end
    end
    initial begin
        reset_n = 0;
        #15 reset_n = 1;
        #100 reset_n = 0;
        #20 reset_n = 1;
    end
endmodule