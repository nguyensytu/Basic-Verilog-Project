module i2c_master #(
    parameter ADDR_BIT = 7,
              W = 10, 
              ACTIVE_W = 5,
              COUNTER_BIT = 3,
              DELAY = 1
) (
    input clk, reset, start, stop, rd_wr_en,
    input [ADDR_BIT-1:0] w_addr,
    input [7:0] w_data,
    output [7:0] r_data,
    output wr_rd_tick,
    inout sda, scl
);
    localparam IDLE = 3'b000,
               START = 3'b001,
               ADDR = 3'b010,
               ACK_ADDR = 3'b011,
               WR_RD = 3'b100,
               ACK_WR_RD = 3'b101,
               STOP = 3'b110;
// Signal declaration
    wire scl_clk, start_o, stop_o, scl_clk_sda;
    wire scl_next, sda_next;
    wire [2:0] state;
    // assign
    assign wr_rd_tick = (state == ACK_WR_RD);
// instance
    i2c_master_scl_configure #( .W(W), .ACTIVE_W(ACTIVE_W), .COUNTER_BIT(COUNTER_BIT), .DELAY(DELAY)) 
    scl_configure (
        clk, reset, start, stop, scl_clk, start_o, stop_o, scl_clk_sda
    );
    i2c_master_scl #(.ADDR_BIT(ADDR_BIT)) scl_wire (
        scl_clk, reset, start_o, stop_o, sda, state, scl_next
    );
    i2c_master_sda #(.ADDR_BIT(ADDR_BIT)) sda_wire (
        scl_clk_sda, reset, rd_wr_en, 
        w_addr, w_data, r_data, state, sda_next
    );
    assign scl = (!scl_next) ? 1'b0 : 1'bz;
    assign sda = (!sda_next) ? 1'b0 : 1'bz; 
endmodule