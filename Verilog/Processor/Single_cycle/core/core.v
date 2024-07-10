module core (
    input clk, reset,
    // instruction memory
    input [7:0] instruction,
    output [4:0] pc,
    // data memory
    input [7:0] data_i,
    output wr_mem, rd_mem, 
    output [4:0] address,
    output [7:0] data_o
);
    // symbolic state declaration
    // signal declaration
    reg [4:0] pc_next;
	wire [2:0] opcode;
    wire wr_A, wr_B, jmp;
    wire [7:0] A, B;
    wire [7:0] result;
    // body
    // state register
    // FSM data path (counter) next-state logic
    registers register_file (.clk(clk), .wr_A(wr_A), .wr_B(wr_B), .rd_mem(rd_mem), 
                             .result(result), .data_write(data_i), 
                             .A(A), .B(B));
    alu alu (.alu_op(address), .A(A), .B(B), .result(result));
    always @(posedge clk, posedge reset) begin
        if (reset)
            pc_next <= 0;
        else
            if (jmp)
                pc_next <= address;
            else
                pc_next <= pc_next + 1;
    end
	assign {opcode, address} = instruction;  
    assign pc = pc_next;
    assign data_o = A;
    // FSM control path next-state logic
    control_unit cu (.opcode(opcode), 
                     .rd_mem(rd_mem), .wr_A(wr_A), .wr_B(wr_B), 
                     .wr_mem(wr_mem), .jmp(jmp));
    initial begin
        pc_next <= 0;
    end   
endmodule