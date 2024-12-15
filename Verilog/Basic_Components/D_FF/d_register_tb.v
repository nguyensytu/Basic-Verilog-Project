module d_register_tb;
    reg clk, reset_n;
    reg [3:0] d;
    wire [3:0] q_0; 
    reg [3:0] q_1;
    d_register #(.N(4)) uut (clk, reset_n, d, q_0);
    
    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) q_1 <= 4'b0;
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