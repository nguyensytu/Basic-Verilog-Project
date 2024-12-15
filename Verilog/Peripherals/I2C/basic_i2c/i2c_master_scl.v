module i2c_master_scl #(
    parameter ADDR_BIT = 7
) (
    input scl_clk, reset, start_i, stop_i, sda,
    output reg [2:0] state,
    output wire scl_next
);
    localparam IDLE = 3'b000,
               START = 3'b001,
               ADDR = 3'b010,
               ACK_ADDR = 3'b011,
               WR_RD = 3'b100,
               ACK_WR_RD = 3'b101,
               STOP = 3'b110;
// Signal declaration
    reg [2:0] state_next;
    wire counter_addr_bit_tick, counter_data_bit_tick;
// scl
    reg scl_stop;
    assign scl_next = (state == IDLE | state == START | scl_stop == 1'b1) ? 1'b1 : scl_clk;
    always @(posedge scl_clk) begin
        if (state == STOP)
            scl_stop <= 1'b1;
        else 
            scl_stop <= 1'b0;


    end
// State logic continuous
    always @(negedge scl_clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end
        else begin 
            state <= state_next;
        end 
    end
// State logic combination
    counter_continuous #(.THRESHOLD_VALUE(ADDR_BIT + 1), .COUNTER_BIT_NUMBER(4)) counter_addr_bit (
        scl_clk, reset, (state == ADDR), counter_addr_bit_tick 
    );
    counter_continuous #(.THRESHOLD_VALUE(8), .COUNTER_BIT_NUMBER(4)) counter_data_bit ( 
        scl_clk, reset, (state == WR_RD), counter_data_bit_tick  
    );
    always @(*) begin
        case (state)
        IDLE: begin
            state_next = IDLE;
            if (start_i)
                state_next = START; 
        end 
        START: begin
            state_next = ADDR;
        end
        ADDR: begin
            state_next = ADDR;
            if(counter_addr_bit_tick)
                state_next <= ACK_ADDR;
        end
        ACK_ADDR: begin
            if (!sda)
                state_next = WR_RD;
            else    
                state_next = STOP;
        end
        WR_RD: begin
            state_next = WR_RD;
            if (counter_data_bit_tick)
                state_next = ACK_WR_RD;
        end
        ACK_WR_RD: begin
            if (!sda) begin
                state_next = WR_RD;
                if (stop_i)
                    state_next = STOP;
            end  
            else
                state_next = STOP;   
        end
        STOP: begin
            state_next <= IDLE;
        end
        default: state_next = IDLE;
        endcase
    end
endmodule