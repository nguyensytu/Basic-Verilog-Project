module core (
    input clk, reset, 
    // instruction memory
    input [7:0] inst_i,
    output [4:0] pc_o,
    // data memory
    input [7:0] data_i,
    input data_stall,
    output wr_mem, rd_mem, 
    output [4:0] address,
    output [7:0] data_o,
    // interrupt
    input [7:0] irq_vector
);
// signal declaration
    reg inst_reg;
    reg [4:0] pc_reg, pc_ret;
    wire irq_en;
    wire [4:0] irq_addr;
	wire [2:0] opcode;
    wire load_A, load_B, wb_A, imm, jmp, ret;
    wire [7:0] A, B;
    wire [7:0] result;
    wire stall;
// Instance submodules 
    csr_unit csr (
        clk, reset, ret, irq_vector, irq_en, irq_addr
    );
    control_unit cu (
        opcode, load_A, load_B, wb_A, wr_mem, imm, jmp, ret
    );
    registers register_file (
        clk, reset, load_A, load_B, wb_A, data_valid, 
        data_i, result, A, B
    );
    alu alu (
        address, A, B, result
    );
//
    assign {opcode, address} = inst_reg; 
    assign stall = data_stall;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            pc_ret <= 5'b0; 
            inst_reg <= 8'10000000; // JMP 0;
            pc_reg <= 5'b0;
        end
        else begin
            if(irq_en)
                pc_ret <= pc_reg;
            inst_reg <= inst_i;
            pc_reg <= pc_o;
        end
    end
    assign pc_o = irq_en ? irq_addr :
                  ret ? pc_ret :
                  jmp ? address :
                  stall ? pc_reg: 
                  pc_reg + 1;
    assign data_o = imm ? {3{0},address} : A;  
    assign rd_mem = load_A | load_B;
endmodule