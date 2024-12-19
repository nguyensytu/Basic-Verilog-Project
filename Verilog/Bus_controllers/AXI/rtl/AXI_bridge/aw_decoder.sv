module aw_decoder (
    input clk,
    input resetn,
    input enable,
    input [3:0] aw_id,
    input [31:0] base_addr,
    input [3:0] len,
    input [2:0] size,
    input [1:0] burst,
    input [3:0] w_id,
    input [3:0] strb,
    input w_last,
    input w_done,
    output aw_done,
    output [31:0] addr,
    output [3:0] valid_strb,
    output aw_done_err,
    output aw_done_illegal,
    output w_id_err 
);
    reg [31:0] burst_addr;
    wire [7:0] byte_num;
    wire [3:0] len_valid;
    wire aw_done_legal;
    wire len_lost_err, len_full_err, len_short_err;
    reg aw_start;
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
                    (burst_addr > boundary) ? base_addr + burst_addr - boundary : base_addr + burst_addr;
    always @(posedge clk, negedge resetn) begin
        if(!resetn) burst_addr <= 32'b0;
        else begin 
            if (w_done)
                if((w_last & !w_id_err) || (burst_addr == byte_num * len)) burst_addr <= 32'b0;
                else if (!w_id_err) burst_addr <= burst_addr + byte_num; 
        end 
    end 
    assign aw_done = aw_done_legal | aw_done_err | aw_done_illegal;
    //
    assign aw_done_legal = enable & w_done & (aw_id == w_id) & (burst_addr == byte_num * len) & w_last;
    assign aw_done_err = enable & (len_lost_err | len_full_err);
    assign aw_done_illegal = enable & (len_short_err | decode_err | size_err | strb_addr_err | align_err | burst_err); 
    //
    assign len_lost_err = w_done & (aw_id == w_id) & (burst_addr < byte_num * len) & w_last;
    assign len_full_err = w_done & (aw_id == w_id) & (burst_addr == byte_num * len) & !w_last;
    assign len_short_err = aw_start & (aw_id != w_id); 
    //
    assign w_id_err = enable & ~aw_start & (aw_id != w_id) & ~aw_done_illegal;
    //
    assign decode_err = (addr[31:6] != 26'b0); 
    strb_decoder strb_decoder (
        strb, size, valid_strb, size_err
    );
    assign ref_addr =   valid_strb[3] ? {1'b0,addr[5:0]} + 2'b11 :
                        valid_strb[2] ? {1'b0,addr[5:0]} + 2'b10 :
                        valid_strb[1] ? {1'b0,addr[5:0]} + 2'b01 : {1'b0,addr[5:0]};
    assign strb_addr_err = ref_addr[6];
    always @(posedge clk, negedge resetn) begin
        if(!resetn || aw_done) aw_start <= 1'b0; 
        else if (w_done & (aw_id == w_id)) aw_start <= 1'b1;
    end 
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