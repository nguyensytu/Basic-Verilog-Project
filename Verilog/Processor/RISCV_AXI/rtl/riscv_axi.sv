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
    wire rmem_o;
    wire misaligned_o;
    wire if_stall_o;
    wire [31:0] pc_o;
    wire [31:0] data_o;
    wire [31:0] addr_o;
//
    reg [3:0] aw_id_reg;
    reg [31:0] aw_addr_reg;
    reg [1:0] aw_valid_state;
    wire [1:0] aw_valid_state_next;

    wire [3:0] ar_id_inst, ar_id_data;
    reg [3:0] ar_id_inst_reg, ar_id_data_reg;
    reg [31:0] ar_addr_inst_reg;
    wire [31:0] ar_addr_inst;
    reg [1:0] ar_valid_state, ar_valid_state_next;
    
    reg [3:0] r_id_reg;
    reg [31:0] r_data_reg;
    reg r_valid_reg;
//
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
        rmem_o,
        misaligned_o,
        if_stall_o,
        pc_o, 
        data_o, 
        addr_o,
        irq_ack
    );
// core signals 
    assign clk = a_clk;
    assign reset = ~a_resetn;
    assign inst_access_fault = (r_id[3] & (r_resp != 2'b0));
    assign inst_stall = ~((r_valid & r_id == ar_id_inst_reg) | r_id_reg == ar_id_inst_reg);
    assign data_err = ~b_id[3] & (b_resp != 2'b0);
    assign data_stall = (wmem_o & ~(b_valid & b_id == aw_id_reg)) | 
                        (rmem_o & ~(r_valid & r_id == ar_id_data_reg));
    assign inst = r_valid_reg ? r_data_reg : r_data;
    assign data_i = r_data;
    // assign wmask = w_strb;
    // assign wmem_o
    // assign rmem_o
    // assign pc_o
    // assign data_o
    // assign addr_o
// AXI signals
// Write address channel signals
    always @(posedge a_clk, negedge a_resetn) begin
        if(!a_resetn) begin
            aw_id_reg <= 4'b0000;
            aw_valid_state <= 2'b0;
        end
        else begin
            if((aw_valid_state == 2'b00 & wmem_o) || aw_valid_state == 2'b10 || b_valid)begin
                aw_id_reg <= aw_id;
                aw_valid_state <= aw_valid_state_next;
            end
                
        end
    end
    assign aw_valid_state_next = (aw_valid_state == 2'b00) ? 2'b01 :
                                 (aw_valid_state == 2'b10) ? 2'b01 :
                                 (aw_valid_state == 2'b01 & misaligned_o) ? 2'b10 : 2'b00;
    assign aw_id = (aw_valid) ? {1'b0, (aw_id_reg[2:0] + 3'b1)} : aw_id_reg;
    assign aw_addr = addr_o;
    assign aw_len = 4'b0; // 1 transfer
    assign aw_size = 3'b010; // a word
    assign aw_burst = 2'b0; // no burst
    assign aw_valid = aw_ready & ((aw_valid_state == 2'b00 & wmem_o) || (aw_valid_state == 2'b10)) ;
    // assign aw_ready
// Write data channel signals
    assign w_id = aw_id;
    assign w_data = data_o;
    assign w_strb = wmask;
    assign w_last = 1'b1;
    assign w_valid = aw_valid;
    // assign w_ready
// Write response channel signals
    // assign b_id
    // assign b_resp
    // assign b_valid
    assign b_ready = 1'b1;
// Read address channel signals
    always @(posedge a_clk, negedge a_resetn) begin
        if(!a_resetn) begin
            ar_id_data_reg <= 4'b0000;
            ar_id_inst_reg <= 4'b1000;
            ar_addr_inst_reg <= 32'b0;    
            ar_valid_state <= 2'b00;
        end
        else begin
            ar_id_inst_reg <= ar_id_inst;
            ar_id_data_reg <= ar_id_data;
            ar_addr_inst_reg <= ar_addr_inst; 
            ar_valid_state <= ar_valid_state_next;
        end
    end
    assign ar_id_inst = (if_stall_o | inst_stall) ? ar_id_inst_reg : {1'b1, (ar_id_inst_reg[2:0] + 3'b1)};
    assign ar_id_data = (~rmem_o | data_stall) ? ar_id_data_reg : {1'b0, (ar_id_data_reg[2:0] + 3'b1)};
    assign ar_id = (ar_valid_state == 2'b10 | (ar_valid_state == 2'b01 & rmem_o) | (ar_valid_state == 2'b11 & misaligned_o)) ? ar_id_data : ar_id_inst; 
    assign ar_addr = (ar_valid_state == 2'b10 | (ar_valid_state == 2'b01 & rmem_o) | (ar_valid_state == 2'b11 & misaligned_o)) ? addr_o : ar_addr_inst;
    assign ar_addr_inst = (if_stall_o | inst_stall) ? ar_addr_inst_reg : ((ar_valid_state == 2'b00) ? pc_o : pc_o + 32'h4);
    assign ar_len = 4'b0; // 1 transfer
    assign ar_size = 3'b010; // a word
    assign ar_burst = 2'b0;
    assign ar_valid = ar_ready & ((ar_valid_state == 2'b00) | 
                                  (ar_valid_state == 2'b01 & r_valid & ~inst_stall & (~if_stall_o | rmem_o)) |  
                                  (ar_valid_state == 2'b10) |
                                  (ar_valid_state == 2'b11 & ~misaligned_o & r_valid & (r_id_reg != ar_id_inst_reg)));
    always @(*) begin
        case (ar_valid_state)
            2'b00: begin
                ar_valid_state_next = 2'b01;
            end 
            2'b01: begin
                if(r_valid) 
                    if(rmem_o) 
                        ar_valid_state_next = 2'b11;
                    else
                        ar_valid_state_next = 2'b01;
                else if (if_stall_o || inst_stall)
                    ar_valid_state_next = 2'b01;
                else
                    ar_valid_state_next = 2'b00;
            end
            2'b10: begin
                ar_valid_state_next = 2'b11;
            end 
            2'b11: begin
                if(r_valid)
                    if(misaligned_o)
                        ar_valid_state_next = 2'b10;
                    else
                        if(~inst_stall)
                            ar_valid_state_next = 2'b00;
                        else
                            ar_valid_state_next = 2'b01;
                else
                    ar_valid_state_next = 2'b11;
            end
        endcase
    end
    // assign ar_ready
// Read data channel signals
    always @(posedge a_clk, negedge a_resetn) begin
        if(!a_resetn) begin
            r_valid_reg <= 1'b0;
            r_id_reg <= 4'b0000;
            r_data_reg <= 32'b0;
        end
        else begin
            if(r_valid && (r_id == ar_id_inst_reg) && (if_stall_o || inst_stall)) begin
                r_valid_reg <= 1'b1;
                r_id_reg <= r_id;
                r_data_reg <= r_data;
            end
            else if (~if_stall_o && ~inst_stall) begin
                r_valid_reg <= 1'b0;
            end
        end

    end
    // assign r_id
    // assign r_data
    // assign r_last
    // assign r_resp
    // assign r_valid
    assign r_ready = 1'b1;
endmodule