module clock_generate (
    input clk, reset_n,
    output reg uart_pulse
);
    reg [13:0] couter_reg;
	wire [13:0] counter_reg_next;
    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) couter_reg <= 14'b0;
        else couter_reg <= counter_reg_next;
    end
    assign counter_reg_next = (couter_reg == 10) ? 14'b0 : couter_reg + {14'b1}; 
    
    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) uart_pulse <= 1'b1;
        else if (couter_reg == 10) uart_pulse <= ~uart_pulse;
        else uart_pulse <= uart_pulse;
    end
endmodule