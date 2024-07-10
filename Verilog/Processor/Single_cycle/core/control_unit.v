module control_unit (
    input [2:0] opcode,
    output reg rd_mem, wr_A, wr_B, wr_mem, jmp
);
    // symbolic state declaration
    parameter LOAD_A = 3'b000,
              LOAD_B = 3'b001,
              STORE = 3'b010,
              JMP = 3'b100,
              ALU = 3'b111;
    always @(*) begin
        wr_A = 0;
        wr_B = 0;
        rd_mem = 0;
        wr_mem = 0;
        jmp = 0;
        case (opcode)
            LOAD_A: begin
                wr_A = 1;
                rd_mem = 1;
            end
            LOAD_B : begin
                wr_B = 1;
                rd_mem = 1;
            end
            STORE: begin
                wr_mem = 1;
            end 
            JMP: begin
                jmp = 1;
            end
            ALU: begin
                wr_A = 1;
            end 
        endcase
    end
endmodule