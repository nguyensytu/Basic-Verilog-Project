// `include "ex_check.sv"
// `include "wb_check.sv"
`include "id_check.sv"
task automatic inst_check(input logic [31:0] inst_check, input logic [31:0] pc_check, input int count);
    automatic logic [6:0] funct7;
    automatic logic [4:0] rs2;
    automatic logic [4:0] rs1;
    automatic logic [2:0] funct3;
    automatic logic [4:0] rd;
    automatic logic [6:0] opcode;
    automatic logic [31:0] ex_src2, ex_src1, wb_rd; 
    automatic logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
    automatic int i, j=5;
    //
    funct7 = inst_check[31:25];
    rs2 = inst_check[24:20];
    rs1 = inst_check[19:15];
    funct3 = inst_check[14:12];
    rd = inst_check[11:7];
    opcode = inst_check[6:0];
    imm_i = {{20{inst_check[31]}}, inst_check[31:20]};
    imm_s = {{20{inst_check[31]}}, inst_check[31:25], inst_check[11:7]};
    imm_b = {{20{inst_check[31]}}, inst_check[7], inst_check[30:25], inst_check[11:8], 1'b0};
    imm_u = {inst_check[31:12], 12'b0};
    imm_j = {{12{inst_check[31]}}, inst_check[19:12], inst_check[20], inst_check[30:21], 1'b0};
    //
    while (i != 5) begin
        if(i == 0 && if_pc == inst_check) i = 0;
        else if(i == 0 && ifid_inst == inst_check) i = 1;
        else if(i == 1 && idex_inst == inst_check) i = 2;
        else if(i == 2 && exmem_inst == inst_check) i = 3;
        else if(i == 3 && memwb_inst == inst_check) i = 4;
        else if(i == 4 && memwb_inst != inst_check) i = 5;
        if(i == 1) begin
            if(i!=j)
                id_check(funct7, rs2, rs1, funct3, rd, opcode, pc_check, imm_i, imm_s, imm_u);
            @(posedge a_clk);
            #1;
        end
        // else if(i == 2) begin
        //     ex_src2 = uut.src2;
        //     ex_src1 = uut.src1;
        //     @(posedge clk);
        //     #1;
        //     ex_check(rs2, rs1, funct3, rd, opcode, pc_check, ex_src2, ex_src1, imm_i, imm_b, imm_j);
        // end
        // // else if (i == 3)
        // else if (i == 4) begin
        //     @(posedge clk);
        //     wb_rd = uut.RF.register_bank[rd];
        //     wb_check(funct7, rs2, rs1, funct3, rd, opcode, pc_check, ex_src2, ex_src1, wb_rd, imm_i, imm_s, imm_u);
        //     #1;
        // end
        else if(i != 5) begin
            // if(i != j)
            //     $display("[%1t] pc = %8h , inst = %8h, i = %0d, count = %0d ", $time, pc_check, inst_check, i, count);
            // else
            //     $display("[%1t] pc = %8h , inst = %8h stall, i = %0d, count = %0d ", $time, pc_check, inst_check, i, count);
            @(posedge a_clk);
            #1;
        end
        j = i;
    end
    if(pc_check + 32'h14 != if_pc) begin   
        $display("[%1t] pc = %8h ,if_pc = %8h done slow count = %0d ", $time, pc_check, if_pc, count);
        wait_pc_change();
    end
    else      
        $display("[%1t] pc = %8h ,if_pc = %8h done rush count = %0d ", $time, pc_check, if_pc, count);
endtask