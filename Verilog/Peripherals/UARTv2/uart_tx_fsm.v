module uart_tx_fsm (
    input clk, reset_n, wr, bit_tick,
    output tx
);
    localparam IDLE = 1'b0,
               TX = 1'b1;
    reg state, state_next;
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
        end
        else begin
            state <= state_next;
        end
    end  
    always @(*) begin
        state_next = 1'b0;
        case (state)
            IDLE: begin
                state_next = IDLE;
                if (wr)
                    state_next = TX; 
            end 
            TX: begin
                state_next = TX;
                if (bit_tick) begin
                    state_next = IDLE;
                end
            end    			
        endcase
    end
    assign tx = (state == TX);
endmodule