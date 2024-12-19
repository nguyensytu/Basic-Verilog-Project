module ar_decoder (
    input clk,
    input resetn,
    input enable,
    input [31:0] base_addr,
    input [3:0] len,
    input [2:0] size,
    input [1:0] burst,
    input r_done,
    output ar_done,
    output [31:0] addr,
    output ar_done_illegal
);
    reg [31:0] burst_addr;
    wire [7:0] byte_num;
    wire [3:0] len_valid;
    wire ar_done_legal;
    wire [3:0] valid_strb;
    reg [31:0] ref_addr;
    wire decode_err, size_err, strb_addr_err;
    reg align_err, burst_err;
    assign byte_num =   (size == 3'b111) ? 128 :
                        (size == 3'b110) ? 64 :
                        (size == 3'b101) ? 32 :
                        (size == 3'b100) ? 16 :
                        (size == 3'b011) ? 8 :
                        (size == 3'b010) ? 4 :
                        (size == 3'b001) ? 2 : 1;
    assign len_valid =  (len == 4'b0) ? 4'b0 :
                        (len == 4'b1) ? 4'b0001 :  
                        (len == 4'h2 || len == 4'h3) ? 4'b0010 :
                        (len == 4'h4 || len == 4'h5 || len == 4'h6 || len == 4'h7) ? 4'b0100 : 4'b1000;   
    assign boundary = len_valid * byte_num;
    assign addr =   (burst == 2'b00) ? base_addr :
                    (burst == 2'b10 && burst_addr > boundary) ? base_addr + burst_addr - boundary : base_addr + burst_addr;
    always @(posedge clk, negedge resetn) begin
        if(!resetn) burst_addr <= 32'b0;
        else begin 
            if (r_done)
                if(ar_done) burst_addr <= 32'b0;
                else burst_addr <= burst_addr + byte_num; 
        end 
    end 
    assign ar_done = ar_done_legal | ar_done_illegal;
    //
    assign ar_done_legal = enable & r_done & (burst_addr == byte_num * len);
    assign ar_done_illegal = enable & (decode_err | size_err | strb_addr_err | align_err | burst_err);
    // 
    assign decode_err = (addr[31:6] != 26'b0); 
    strb_decoder strb_decoder (
        4'b1111, size, valid_strb, size_err
    );
    assign ref_addr =   valid_strb[3] ? {1'b0,addr[5:0]} + 2'b11 :
                        valid_strb[2] ? {1'b0,addr[5:0]} + 2'b10 :
                        valid_strb[1] ? {1'b0,addr[5:0]} + 2'b01 : {1'b0,addr[5:0]};
    assign strb_addr_err = ref_addr[6];
    //
    always @(*) begin
        align_err = 1'b0;
        burst_err = 1'b0;
        case (burst)
            // 2'b00:
            // 2'b01:
            2'b10: begin // wrap
                case (size)
                    // 3'b000:
                    3'b001: begin
                        if(base_addr[1:0] != 2'b0)
                            align_err = 1'b1;
                    end
                    3'b010: begin
                        if(base_addr[2:0] != 3'b0)
                            align_err = 1'b1;
                    end
                    3'b011: begin
                        if(base_addr[3:0] != 4'b00)
                            align_err = 1'b1;
                    end
                    3'b100: begin
                        if(base_addr[4:0] != 5'b00)
                            align_err = 1'b1;
                    end
                    3'b101: begin
                        if(base_addr[5:0] != 6'b00)
                            align_err = 1'b1;
                    end
                    3'b110: begin
                        if(base_addr[6:0] != 7'b00)
                            align_err = 1'b1;
                    end
                    3'b111: begin
                        if(base_addr[7:0] != 8'b0)
                            align_err = 1'b1;
                    end 
                endcase
            end 
            2'b11: burst_err = 1'b1;
        endcase
    end
endmodule