module d_flip_flop (
    input pulse, d,
    output q
);
    wire q_0;
    d_latch latch0 (~pulse, d, q_0);
    d_latch latch1 (pulse, q_0, q);
endmodule