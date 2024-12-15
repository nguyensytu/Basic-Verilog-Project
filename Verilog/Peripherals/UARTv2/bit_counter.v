module bit_counter (
    input uart_pulse, reset_n,
    output tick
);
    reg [3:0] counter;
    wire [3:0] counter_next;
    always @(posedge uart_pulse, negedge reset_n) begin
        if(!reset_n) counter <= 4'b0;
        else counter <= counter_next;
    end
    assign counter_next = tick ? 4'b0 : counter + 4'b1;
    assign tick = (counter == 4'b1010);
endmodule