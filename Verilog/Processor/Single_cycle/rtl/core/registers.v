module registers (
    input clk, reset,
    input load_A, load_B, wb_A, data_valid,
    input [7:0] data_write, result,
    output reg [7:0] A, B 
); 
    always @(posedge clk, posedge reset) begin
        if (reset)
            A <= 8'b0;
        else if (load_A & data_valid) 
                A <= data_write;
        else if (wb_A)
                A <= result;
        else    
            A <= A;
    end
    always @(posedge clk, posedge reset) begin
        if (reset)
            B <= 8'b0;
        else if (load_B && data_valid)
            B <= data_write;
        else 
            B <= B; 
    end
endmodule