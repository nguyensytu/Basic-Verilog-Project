module h_addr_read_count (
    input clk,
    input resetn,
    input [31:0] base_addr,
    input [3:0] len,
    input [2:0] size,
    input r_ready,
    output [31:0] addr,
    output r_last
);
    reg [31:0] burst_addr;
    wire [8:0] byte_num;
    assign byte_num =   (size == 3'b111) ? 128 :
                        (size == 3'b110) ? 64 :
                        (size == 3'b101) ? 32 :
                        (size == 3'b100) ? 16 :
                        (size == 3'b011) ? 8 :
                        (size == 3'b010) ? 4 :
                        (size == 3'b001) ? 2 : 1;
    assign addr = base_addr + burst_addr;
    always @(posedge clk, negedge resetn) begin
        if(!resetn) burst_addr <= 32'b0;
        else begin 
            if (r_ready)
                if(r_last) burst_addr <= 32'b0;
                else burst_addr <= burst_addr + byte_num; 
        end 
    end 
    assign r_last = r_ready & (burst_addr == byte_num * len);
endmodule