module i2c_master_sda #(
    parameter ADDR_BIT = 7
) (
    input scl_clk, reset, rd_wr_en,
    input [ADDR_BIT-1:0] w_addr,
    input [7:0] w_data,
    output [7:0] r_data,
    input [2:0] state, 
    output reg sda
);
    localparam IDLE = 3'b000,
               START = 3'b001,
               ADDR = 3'b010,
               ACK_ADDR = 3'b011,
               WR_RD = 3'b100,
               ACK_WR_RD = 3'b101,
               STOP = 3'b110;
// Signal declaration
    reg [ADDR_BIT:0] shift_reg_addr; 
    reg [7:0] shift_reg_data;
    // shift address register
    always @(posedge scl_clk) begin
        if(state == START)
            shift_reg_addr <= {w_addr,rd_wr_en};
        else if(state == ADDR)
            shift_reg_addr <= {shift_reg_addr[ADDR_BIT-1:0], 1'b1};
        else 
            shift_reg_addr <= shift_reg_addr;
    end
    // Shift data register 
    always @(posedge scl_clk) begin
        if ((state == ACK_WR_RD | state == ACK_ADDR) & ~rd_wr_en)
            shift_reg_data <= w_data;
        else if(state == WR_RD)
            if(~rd_wr_en)
                shift_reg_data <= {shift_reg_data[6:0], 1'b1};
            else 
                shift_reg_data <= {shift_reg_data[6:0], sda};
        else
            shift_reg_data <= shift_reg_data;
    end
    assign r_data = shift_reg_data; 
    // sda
    always @(negedge scl_clk, posedge reset) begin
        if(reset)
            sda <= 1'b1;
        else begin
            if (state == START)
                sda <= 1'b0;
            else if (state == ADDR)
                sda <= shift_reg_addr [ADDR_BIT];
            else if (state == WR_RD && ~rd_wr_en)
                sda <= shift_reg_data [7];
            else if (state == ACK_WR_RD & rd_wr_en)
                sda <= 1'b0;
            else sda <= 1'b1;
        end
    end
endmodule