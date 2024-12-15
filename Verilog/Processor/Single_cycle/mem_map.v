module mem_map (
    input clk, reset,
    // memory 
    input wr,
    input [4:0] addr,
    input [7:0] data_i,
    output [7:0] data_o,
    // peripheral

);  
    //peripheral
    dma dma_0 (
        clk, reset, dma_en, dma_rd, addr_base_rd, addr_base_wr, data_width, 
        addr_pointer_rd, addr_pointer_wr, dma_data_i, dma_data_o, dma_irq
    );
    uart_receiver uart_receiver(
        clk, reset, tdi, rx_tick, data_rx
    );
    // memory
    reg [7:0] mem [31:0];
    reg [4:0] i;
    always @(negedge clk, posedge reset) begin
        if(reset) begin
            for (i=0;i<=31;i=i+1) begin
                mem[i] <= 8'b0;
            end
        end
        else begin
            if(wr)
                mem[addr] <= data_i;
        end
    end
    assign data_o = mem [addr];
    assign {uart_en, dma_en} = mem [16] [1:0];
    assign addr_base_rd = mem[17];
    assign addr_base_wr = mem[18];
    assign data_width = mem[19];
    assign dma_data_i = mem[addr_pointer_rd];
endmodule