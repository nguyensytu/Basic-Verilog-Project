module alu (
    input [4:0] alu_op,
	input [7:0] A,
    input [7:0] B,
    output reg [7:0] result
);
    parameter  ADD = 5'b00000,
               SUB = 5'b00001,
               AND = 5'b00010,
               OR = 5'b00011;
    // excute
    always @ (*) begin
        case (alu_op)
            ADD: result = A + B;
            SUB: result = A - B;
            AND: result = A & B;
            OR: result = A | B; 
            default : result = A + B;
        endcase
    end
endmodule