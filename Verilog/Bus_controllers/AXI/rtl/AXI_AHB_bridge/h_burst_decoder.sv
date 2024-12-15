module h_burst_decoder (
    input [3:0] valid_len,
    input [1:0] valid_burst,
    output reg [2:0] h_burst,
    output reg burst_error
);
    always @(*) begin
        burst_error = 1'b0;
        case (valid_burst)
            2'b00: begin
                h_burst = 3'b0;
            end 
            2'b01: begin //incr
                case (valid_len)
                    4'b0011:  h_burst = 3'b011;
                    4'b0111:  h_burst = 3'b101;
                    4'b1111:  h_burst = 3'b111;
                    default: h_burst = 3'b001;
                endcase
            end
            2'b10: begin //wrap
                if(valid_len <= 4'b0011)
                    h_burst = 3'b010;
                else if (valid_len <= 4'b0111) 
                    h_burst = 3'b100;
                else 
                    h_burst = 3'b110;
            end
            default: burst_error = 1'b1;
        endcase
    end
endmodule