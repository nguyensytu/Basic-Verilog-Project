module control_unit (
    input [2:0] opcode,
    output reg load_A, load_B, wb_A, wr_mem, imm, jmp, ret
);
    // symbolic state declaration
    parameter LOAD_A = 3'b000,
              LOAD_B = 3'b001,
              STORE = 3'b010,
              STORE_IMM = 3'b011,
              JMP = 3'b100,
              RET = 3'b110,
              ALU = 3'b111;
    always @(*) begin
        load_A = 0;
        load_B = 0;
        wb_A = 0;
        wr_mem = 0;
        imm = 0;
        jmp = 0;
        ret = 0;
        case (opcode)
            LOAD_A: begin
                load_A = 1;
            end
            LOAD_B : begin
                load_B = 1;
            end
            STORE: begin
                wr_mem = 1;
            end 
            STORE_IMM: begin
                wr_mem = 1;
                imm = 1;
            end
            JMP: begin
                jmp = 1;
            end
            RET: begin
                ret = 1
            end
            ALU: begin
                wb_A = 1;
            end 
        endcase
    end
endmodule