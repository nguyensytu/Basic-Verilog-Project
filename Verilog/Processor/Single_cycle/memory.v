module memory (
    input clk, reset, wr
    input [4:0] addr_rd, addr_wr,
    input [7:0] data,
    output reg [7:0] instruction
);
// Signal declaration
    reg [7:0] mem [31:0];
// Read mem
    always @(*) begin
        instruction <= mem[addr_rd];
    end
// Write mem
    always @(posedge clk) begin
        if(wr)
            mem [addr_wr] <= data;
    end
endmodule