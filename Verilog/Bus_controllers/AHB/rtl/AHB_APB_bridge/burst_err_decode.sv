module burst_err_decode (
    input h_clk, 
    input h_resetn,
    input [31:0] h_addr, reg_addr,
    input [2:0] h_burst, reg_burst,
    input [2:0] h_size, reg_size,
    input [1:0] h_trans, reg_trans,
    output reg burst_err
);
    localparam  idle = 2'b00,
                busy = 2'b01,
                nonseq = 2'b10,
                seq = 2'b11;
    reg [31:0] base_addr;
    wire [31:0] pre_addr;
    wire [7:0] size;
    // reg burst_err_next;
    // base_addr
    always @(posedge h_clk, negedge h_resetn) begin
        if(!h_resetn) base_addr <= 32'b0;
        else if((h_burst != 3'b0) && (reg_burst==3'b0))
            base_addr <= h_addr;
    end
    // pre_addr
    assign size =   (reg_size == 3'b000) ? 8'b1 :
                    (reg_size == 3'b001) ? 8'b10 :
                    (reg_size == 3'b010) ? 8'b100 :
                    (reg_size == 3'b011) ? 8'b1000 :
                    (reg_size == 3'b100) ? 8'b10000 :
                    (reg_size == 3'b101) ? 8'b100000 :
                    (reg_size == 3'b110) ? 8'b1000000 : 8'b10000000;
                    
    assign pre_addr =   (reg_size == 3'b000 & reg_burst == 3'b010 & base_addr[2] != reg_addr[2]) ? reg_addr - 5'b00100 :
                        (reg_size == 3'b000 & reg_burst == 3'b100 & base_addr[3] != reg_addr[3]) ? reg_addr - 5'b01000 :
                        (reg_size == 3'b000 & reg_burst == 3'b110 & base_addr[4] != reg_addr[4]) ? reg_addr - 5'b10000 :
                        (reg_size == 3'b001 & reg_burst == 3'b010 & base_addr[3] != reg_addr[3]) ? reg_addr - 6'b001000 :
                        (reg_size == 3'b001 & reg_burst == 3'b100 & base_addr[4] != reg_addr[4]) ? reg_addr - 6'b010000 :
                        (reg_size == 3'b001 & reg_burst == 3'b110 & base_addr[5] != reg_addr[5]) ? reg_addr - 6'b100000 :
                        (reg_size == 3'b010 & reg_burst == 3'b010 & base_addr[4] != reg_addr[4]) ? reg_addr - 7'b0010000 :
                        (reg_size == 3'b010 & reg_burst == 3'b100 & base_addr[5] != reg_addr[5]) ? reg_addr - 7'b0100000 :
                        (reg_size == 3'b010 & reg_burst == 3'b110 & base_addr[6] != reg_addr[6]) ? reg_addr - 7'b1000000 : reg_addr + size;
    always @(*) begin
        burst_err = 1'b0;
        case (reg_trans)
            // idle:
            // busy:
            nonseq:begin
                if(reg_burst != 3'b0)
                    burst_err <= 1'b1;
            end
            seq: begin
                if(h_trans == seq) begin
                    if((h_addr != pre_addr) || (h_size != reg_size) || (h_burst != reg_burst)) begin
                        burst_err = 1'b1;
                    end
                end
            end
        endcase
    end
endmodule