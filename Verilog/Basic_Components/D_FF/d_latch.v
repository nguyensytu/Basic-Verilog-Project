module d_latch (
    input enable, d,
    output q
);
    wire r, s, q_op;
    assign r = ~d & enable;
    assign s = d & enable; 
    assign q_op = ~(q | s);
    assign q = ~(q_op | r); 
endmodule