interface dma_reg_if;
    logic io_to_mem, mem_to_io, mem_to_mem, terminal_count;
    modport TC(
        input io_to_mem, mem_to_io, mem_to_mem, terminal_count
    );
    modport DP (
        output io_to_mem, mem_to_io, mem_to_mem, terminal_count
    );
endinterface //dma_reg_if