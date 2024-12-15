module i2c_master_scl_configure #(
    parameter W = 10, 
              ACTIVE_W = 5,
              COUNTER_BIT = 3,
              DELAY = 1
) (
    input clk, reset, start, stop,
    output reg scl_clk, start_o, stop_o, scl_clk_sda
);
// Signal declaration
    reg [COUNTER_BIT-1:0] counter_0, counter_1;
    wire delay_tick, delay_tick_active, delay_tick_inactive;
// Create scl_clk from PWM of clk
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            counter_0 <= 0;
            counter_1 <= 0;
            scl_clk <= 0;     
        end
        else begin
            if(scl_clk) begin
                if (counter_1 == (ACTIVE_W - 1)) begin
                    counter_1 <= 0;
                    scl_clk <= ~scl_clk;
                end 
                else
                    counter_1 <= counter_1 + 1;
            end
            else begin
                if (counter_0 == (W - ACTIVE_W - 1)) begin
                    counter_0 <= 0;
                    scl_clk <= ~scl_clk;
                end 
                else
                    counter_0 <= counter_0 + 1;
            end
        end
    end
// Create start_o, stop_o signal for scl_clk
    always @(posedge clk, posedge reset) begin
        if(reset)
            start_o <= 1'b0;
        else    
            if(start)
                start_o <= 1'b1;
            else if (counter_0 == 1)
                start_o <= 1'b0;
            else
                start_o <= start_o;
    end
    always @(posedge clk, posedge reset) begin
        if(reset)
            stop_o <= 1'b0;
        else    
            if(stop)
                stop_o <= 1'b1;
            else if (counter_0 == 1)
                stop_o <= 1'b0;
            else
                stop_o <= stop_o;
    end
// scl_ctrl_sda
    counter_continuous #(.THRESHOLD_VALUE(DELAY), .COUNTER_BIT_NUMBER(COUNTER_BIT)) delay_active_scl (
        clk, (reset | ~scl_clk) , 1'b1, delay_tick_active
    );
    counter_continuous #(.THRESHOLD_VALUE(DELAY), .COUNTER_BIT_NUMBER(COUNTER_BIT)) delay_inactive_scl (
        clk, (reset | scl_clk) , 1'b1, delay_tick_inactive
    );
    assign delay_tick = delay_tick_active | delay_tick_inactive;
    always @(posedge delay_tick, posedge reset) begin
        if(reset)
            scl_clk_sda <= 1'b0;
        else
            scl_clk_sda <= scl_clk;
    end
endmodule