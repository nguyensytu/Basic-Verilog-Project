module h_trans_decoder (
    input b_ready, r_ready,
    input aw_fifo_empty, ar_fifo_empty,
    input h_write,
    input [2:0] h_burst,
    input w_fifo_empty,
    input aw_done_illegal, w_id_err, ar_done_illegal,
    output [1:0] h_trans
);
    localparam  idle = 2'b00,
                busy = 2'b01,
                nonseq = 2'b10,
                seq = 2'b11;
    reg [1:0] hw_trans, hr_trans;
    always @(*) begin
        if(b_ready & ~aw_fifo_empty & ~aw_done_illegal) 
            if(~w_fifo_empty & ~w_id_err)
                if(h_burst == 3'b0)
                    hw_trans = nonseq;
                else 
                    hw_trans = seq; 
            else 
                if(h_burst == 3'b0)
                    hw_trans = idle;
                else 
                    hw_trans = busy;  
        else hw_trans = idle;
    end
    always @(*) begin
        if(r_ready & ~ar_fifo_empty & ~ar_done_illegal) begin
            if(h_burst == 3'b0)
                hr_trans = nonseq;
            else 
                hr_trans = seq; 
        end 
        else hr_trans = idle;
    end
    assign h_trans = h_write ? hw_trans : hr_trans;
endmodule