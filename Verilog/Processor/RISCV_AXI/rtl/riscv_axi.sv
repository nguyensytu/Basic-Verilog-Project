module riscv_axi (
// AXI interface
    // Global signals
    input a_clk, // 
    input a_resetn, // 
    
    output [3:0] aw_id,
    output [31:0] aw_addr,
    output [3:0] aw_len,
    output [2:0] aw_size,
    output [1:0] aw_burst,
    output aw_valid,
    input aw_ready,
    // Write data channel signals
    output [3:0] w_id,
    output [31:0] w_data, //
    output [3:0] w_strb,
    output w_last,
    output w_valid,
    input w_ready,
    // Write response channel signals
    input [3:0] b_id,
    input [1:0] b_resp,
    input b_valid,
    output b_ready,
    // Read address channel signals
    output [3:0] ar_id,
    output [31:0] ar_addr,
    output [3:0] ar_len,
    output [2:0] ar_size,
    output [1:0] ar_burst,
    output ar_valid,
    input ar_ready,
    // Read data channel signals
    input [3:0] r_id,
    input [31:0] r_data, //
    input [1:0] r_resp,
    input r_last,
    input r_valid,
    output r_ready,
// Interrupt
    input meip,
    input mtip,
    input msip,
    input [15:0] fast_irq,
    output irq_ack
);
// core interface
    wire clk;
    wire reset;
    reg inst_access_fault;
    reg inst_stall;
    reg data_err;
    reg data_stall; 
    wire [31:0] inst;
    wire [31:0] data_i;
    wire [3:0] wmask;
    wire wmem_o;
    wire req_mem;
    wire [31:0] pc_o;
    wire [31:0] data_o;
    wire [31:0] addr_o;
    core cpu (
        clk, 
        reset, 
        meip, 
        mtip, 
        msip,
        inst_access_fault, 
        inst_stall,
        data_err, 
        data_stall,
        inst, 
        data_i,
        fast_irq,
        wmask,
        wmem_o, 
        req_mem,
        pc_o, 
        data_o, 
        addr_o,
        irq_ack
    );
// core signals 
    assign clk = a_clk;
    assign reset = ~a_resetn;
    assign inst_access_fault = (r_id[3] & (r_resp != 2'b0));
    assign inst_stall = (ar_id[3] & ~ar_ready) | ~ar_id[3] | (r_id[3] & ~r_valid) | ~r_id[3];
    assign data_err = ~b_id[3] & (b_resp != 2'b0);
    assign data_stall = (~aw_id[3] & ~aw_ready) | aw_id[3] | (~w_id[3] & ~w_ready) | w_id[3] | (~b_id[3] & ~b_valid) | b_id[3] | 
                        (~ar_id[3] & ar_valid) | ar_id[3] | (~r_id[3] & r_valid) | r_id[3];
    assign inst = r_id[3] & r_data;
    assign data_i = ~r_id[3] & r_data;
    // assign wmask = w_strb;
    // assign wmem_o
    // assign req_mem
    // assign pc_o
    // assign data_o
    // assign addr_o
// AXI signals
// Write address channel signals
    // assign aw_id
    assign aw_addr = addr_o;
    assign aw_len = 4'b0; // 1 transfer
    assign aw_size = 3'b010; // a word
    assign aw_burst = 2'b0; // no burst
    assign aw_valid = aw_id[3] | (~aw_id[3] & wmem_o);
    // assign aw_ready
// Write data channel signals
    assign w_id = aw_id;
    assign w_data = data_o;
    assign w_strb = wmask;
    assign w_last = 1'b1;
    assign w_valid = wmem_o;
    // assign w_ready
// Write response channel signals
    // assign b_id
    // assign b_resp
    // assign b_valid
    assign b_ready = 1'b1;
// Read address channel signals
    // assign ar_id
    assign ar_addr = ar_id[3] ? pc_o : addr_o;
    assign ar_len = 4'b0; // 1 transfer
    assign ar_size = 3'b010; // a word
    assign ar_burst = 2'b0;
    assign ar_valid = ar[3] | (~ar_id[3] & req_mem & ~wmem_o);
    // assign ar_ready
// Read data channel signals
    // assign r_id
    // assign r_data
    // assign r_resp
    // assign r_valid
    assign r_ready = 1'b1;
endmodule