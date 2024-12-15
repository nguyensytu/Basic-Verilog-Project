module uart_tdo (
    input uart_pulse, reset_n,
    input [7:0] data_wr,
    output tdo
);
    reg [8:0] shift_reg;
    wire [8:0] shift_reg_next;
    reg set;
    always @(posedge uart_pulse, negedge reset_n) begin
        if(!reset_n) begin
            shift_reg <= 9'b111111111;
            set <= 1'b1;
        end
        else begin
            shift_reg <= shift_reg_next;
            set <= 0;
        end  
    end
    assign shift_reg_next = set ? {data_wr, 1'b0} : {1'b1, shift_reg[8:1]};
    assign tdo = reset_n ? shift_reg[0] : 1'b1; 
endmodule