module alu (
	input [7:0] A,
    input [7:0] B,
    input [4:0] alu_op,
    output reg [7:0] result
);
    parameter  ADD = 3'b000,
               SUB = 3'b001,
               AND = 3'b010,
               OR = 3'b011,
               SHIFT = 3'b100;
    // excute
    always @ (*) begin
        case (alu_op[2:0])
            ADD: result = A + B;
            SUB: result = A - B;
            AND: result = A & B;
            OR: result = A | B;
            SHIFT: begin
                case (alu_op[4:3])
                    2'b00: result = A << 1;
                    2'b01: result = A << 2;
                    2'b10: result = A << 3;
                    2'b11: result = A << 4;
                endcase
            end 
            default : result = A + B;
        endcase
    end
endmodule