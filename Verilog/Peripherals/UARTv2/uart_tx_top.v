module uart_tx_top (
    input clk, reset_n, wr, 
    input [7:0] data_wr,
    output tdo
);
    wire tx, tick, uart_pulse;
    uart_tx_fsm fsm (clk, reset_n, wr, tick, tx);
    clock_generate clock_generate (clk, tx, uart_pulse);
    bit_counter bit_counter (uart_pulse, tx, tick);
    uart_tdo uart_tdo (uart_pulse, tx, data_wr, tdo);
endmodule