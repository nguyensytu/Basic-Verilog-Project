module d_flip_flop_tb;
    reg clk, d;
    wire q_0; 
    reg q_1;
    d_flip_flop uut (clk, d, q_0);
    
    always @(posedge clk) begin
        q_1 <= d;
    end

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end 
    initial begin
        #15;
        forever begin
            d = $random; #10;
        end
    end
endmodule