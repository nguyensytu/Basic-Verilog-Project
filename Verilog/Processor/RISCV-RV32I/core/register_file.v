module register_file (
    input clk, reset, w_en,
    input [4:0] rs1, rs2, rd,
    input [31:0] w_data,
    output [31:0] r_data1, r_data2
);
    reg [31:0] register_bank [31:0];
    integer i;
    always @(negedge clk, posedge reset) begin
        if(reset) begin
            for(i=0; i < 32; i = i+1)
                register_bank[i] <= 32'b0; //reset all registers to 0.
        end
        else if(w_en)
            register_bank[rd] <= w_data;
    end
    assign r_data1 = register_bank [rs1];
    assign r_data2 = register_bank [rs2];
endmodule