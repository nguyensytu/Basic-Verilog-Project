module i2c_master_fifo #(
    parameter ADDR_BIT = 7,
              W = 10, 
              ACTIVE_W = 5,
              COUNTER_BIT = 3,
              DELAY = 1,
              W_FIFO = 4
) (
    input clk, reset, wr, rd, rd_wr_en, start,
    output empty_tx, full_tx, empty_rx, full_rx,
    input [ADDR_BIT-1:0] w_addr,
    input [7:0] w_fifo_data,
    output [7:0] r_fifo_data,
    inout scl, sda
);
    wire [7:0] i2c_w_data, i2c_r_data;
    wire wr_rd_ctrl, wr_rd_tick;
    i2c_master #(.ADDR_BIT(ADDR_BIT), 
                 .W(W), 
                 .ACTIVE_W(ACTIVE_W), 
                 .COUNTER_BIT(COUNTER_BIT), 
                 .DELAY(DELAY)) 
    i2c_master (
        clk, reset, start, empty_tx, rd_wr_en,
        w_addr, i2c_r_data, i2c_w_data, wr_rd_tick, sda, scl
    );
     fifo #(.B(8), .W(W_FIFO)) i2c_fifo_transmitter (
        clk, reset, (wr_rd_ctrl & ~rd_wr_en), wr, w_fifo_data, empty_tx, full_tx, i2c_r_data
    );
    fifo #(.B(8), .W(W_FIFO)) i2c_fifo_receiver (
        clk, reset, rd, (wr_rd_ctrl & rd_wr_en), i2c_w_data, empty_rx, full_rx, r_fifo_data
    );
    single_cycle_tick wr_rd_ctrl_signal (
        clk, reset, (wr_rd_tick & ~sda), wr_rd_ctrl
    );
endmodule