module dma (
    // control signal 
    input clk, reset, en, start
    input [7:0] addr_base,
    input [7:0] addr_width,
    //
    input [7:0] data_read,
    output [7:0] addr_pointer,
    output [7:0] data_write,
    
);
    
endmodule