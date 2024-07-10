module instruction_memory (
    // input clk,
    input [4:0] address_read,
    output reg [7:0] instruction
);
    reg [7:0] instruction_file [31:0];
    always @(*) begin
        instruction <= instruction_file [address_read];
    end
    initial begin
        instruction_file [0] = 8'h00; // load a 
        instruction_file [1] = 8'h21; // l0ad b 
        instruction_file [2] = 8'he0; // add
        instruction_file [3] = 8'h22; // load b
        instruction_file [4] = 8'he1; // sub
        instruction_file [5] = 8'h43; // store
        instruction_file [6] = 8'h86; // jmp
    end
endmodule