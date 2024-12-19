module strb_decoder (
    input [3:0] reg_wstrb,
    input [2:0] reg_size,
    output [3:0] strb,
    output reg size_err
);
    reg [3:0] en_line;
    always @(*) begin
        size_err = 1'b1;
        en_line = 4'b1111;
        case (reg_size)
            3'b000: begin 
                en_line = 4'b1;
                size_err = 1'b0;
            end
            3'b001: begin 
                en_line = 4'b0011;
                size_err = 1'b0;
            end
            3'b010: begin 
                en_line = 4'b1111;
                size_err = 1'b0;
            end
        endcase
    end
    assign strb = reg_wstrb & en_line;
endmodule