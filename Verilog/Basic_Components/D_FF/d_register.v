module d_register #(
    parameter N = 4
) (
    input pulse, reset_n,
    input [N-1:0] d,
    output [N-1:0] q
);
    genvar i;
    generate
        for (i = 0; i < N ; i = i + 1) begin
            d_ff_reset bit_reg0 (pulse, reset_n, d[i], q[i]); 
        end
    endgenerate    
endmodule