module h_burst_decoder (
    input [3:0] aw_len, ar_len,
    input [1:0] aw_burst, ar_burst,
    input write,
    output reg [2:0] h_burst
);
    wire [3:0] len;
    wire [1:0] burst;
    assign len = write ? aw_len : ar_len;
    assign burst = write ? aw_burst : ar_burst;
    always @(*) begin
        h_burst = 3'b0;
        case (burst)
            // 2'b00: 
            2'b01: begin //incr
                if(len == 4'b0 || len == 4'b1)
                    h_burst = 3'b0;
                else if(len == 4'h2 || len == 4'h3)
                    h_burst = 3'b1;
                else if(len == 4'h4 || len == 4'h5 || len == 4'h6 || len == 4'h7)
                    h_burst <=  3'b011;
                else
                    h_burst <= 3'b101;
            end
            2'b10: begin //wrap
                if(len == 4'b0 || len == 4'b1)
                    h_burst = 3'b0;
                else if(len == 4'h2 || len == 4'h3)
                    h_burst = 3'b1;
                else if(len == 4'h4 || len == 4'h5 || len == 4'h6 || len == 4'h7)
                    h_burst <=  3'b010;
                else
                    h_burst <= 3'b100;
            end
        endcase
    end
endmodule