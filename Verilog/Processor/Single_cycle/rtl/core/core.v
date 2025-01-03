module core (
    input clk, reset, 
    // instruction memory
    input [7:0] inst,
    output [4:0] pc,
    // data memory
    input [7:0] data_i,
    input stall,
    output wr_mem, rd_mem, 
    output [4:0] address,
    output [7:0] data_o,
    // // interrupt
    // input [7:0] irq_vector
);
// signal declaration
    //

    // control unit
    wire [2:0] opcode;
    wire [4:0] aluop
    wire load_A, load_B, wb_A, imm, jmp, jmpz, ret;
    // alu r
    wire [7:0] result;
    // register 
    wire [7:0] A_next, B_next;
    reg [7:0] A, B;
    //
    reg [4:0] pc_reg;
    // //
    // wire irq_en;
    // wire [4:0] irq_addr;
    // wire stall;
// Instance submodules 
    // csr_unit csr (
    //     clk, reset, ret, irq_vector, irq_en, irq_addr
    // );
// control unit
    assign {opcode, aluop} = inst; 
    assign sel = inst[4];
    control_unit cu (
        opcode, sel, load_A, load_B, wb_A, wr_mem, imm, jmp, ret
    );
// alu
    alu alu (
        A, B, aluop, result
    );
// register
    assign A_next = (load_A & imm) ? {4'b0, inst_reg[3:0]} :
                    (load_A & data_valid) ? data_i : 
                    (wb) ? result : A;
    always @(posedge clk, posedge reset) begin
        if(reset) A <= 8'b0;
        else A <= A_next;
    end
    assign B_next = (load_B & imm) ? {4'b0, inst_reg[3:0]} :
                    (load_B & data_valid) ? data_i : B;
    always @(posedge clk, posedge reset) begin
        if(reset) B<= 8'b0;
        else B <= B_next;
    end
//
    // assign pc = irq_en ? irq_addr :
    //             ret ? 5'b0 :
    //             jmp ? address :
    //             stall ? pc_reg: 
    //             pc_reg + 1;
    assign pc = ret ? inst[4:0] :
                jmp ? inst[4:0] :
                stall ? pc_reg: 
                pc_reg + 1;
    always @(posedge clk, posedge reset) begin
        if (reset) pc_reg <= 5'b0;
        else pc_reg <= pc;
    end
//
    assign data_o = A;  
    assign rd_mem = load_A | load_B;
endmodule