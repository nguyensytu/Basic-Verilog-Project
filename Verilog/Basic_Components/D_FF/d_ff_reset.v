module d_ff_reset (
    input pulse, reset_n, d,
    output q
);  
    wire q_0;
    d_flip_flop ff(pulse, reset_n & d, q_0);
    assign q = (!reset_n) ? 1'b0 : q_0;
endmodule