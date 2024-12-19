// Register file
module register_file_32bit #(
    parameter int NumWords = 64
)(
    input logic clk, reset_n, w_en,
    input logic[$clog2(NumWords)-1:0] offset,
    input logic[31:0] data_in,
    input logic[3:0] strb,
    output logic[31:0] data_out
);
    logic[7:0] regs[NumWords-1:0];
    wire [7:0] en_data [3:0];
    assign en_data[0] = strb[0] ? data_in[7:0] : 8'b0;
    assign en_data[1] = strb[1] ? data_in[15:8] : 8'b0;
    assign en_data[2] = strb[2] ? data_in[23:16] : 8'b0;
    assign en_data[3] = strb[3] ? data_in[31:24] : 8'b0;
    // Register write
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            // Reset
            for (int i = 0; i < NumWords; i++)
                regs[i] <= '0;
        end
        else if(w_en) begin
            regs[offset] <= en_data[0];
            regs[offset + 2'b01] <= en_data[1];
            regs[offset + 2'b10] <= en_data[2];
            regs[offset + 2'b11] <= en_data[3];
        end
    end

    // Register read
    assign data_out = {regs[offset], regs[offset + 2'b01], regs[offset + 2'b10], regs[offset + 2'b11]};
endmodule