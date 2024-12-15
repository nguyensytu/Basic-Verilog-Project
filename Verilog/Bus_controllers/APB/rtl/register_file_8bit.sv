// Register file
module register_file_8bit #(
    parameter int NumWords = 64
)(
    input logic clk, reset_n, w_en,
    input logic[$clog2(NumWords)-1:0] offset,
    input logic[7:0] data_in,
    output logic[7:0] data_out
);
    logic[7:0] regs[NumWords-1:0];

    // Register write
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            // Reset
            for (int i = 0; i < NumWords; i++)
                regs[i] <= '0;
        end
        else if(w_en) begin
            regs[offset] <= data_in[7:0];
        end
    end

    // Register read
    assign data_out = regs[offset];
endmodule