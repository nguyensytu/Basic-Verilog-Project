module addr_strb_decoder #(
    parameter NumWords = 64
)(
    input [31:0] addr,
    input[3:0] strb,
    output [$clog2(NumWords)-1:0] offset,
    output strb_addr_error
);
    reg [31:0] ref_addr;
    assign ref_addr =   strb[3] ? {1'b0,addr[$clog2(NumWords)-1:0]} + 2'b11 :
                        strb[2] ? {1'b0,addr[$clog2(NumWords)-1:0]} + 2'b10 :
                        strb[1] ? {1'b0,addr[$clog2(NumWords)-1:0]} + 2'b01 : {1'b0,addr[$clog2(NumWords)-1:0]};
    assign offset = addr[$clog2(NumWords)-1:0];
    assign strb_addr_error = ref_addr[$clog2(NumWords)];
endmodule