typedef enum logic[6:0] {branch = 7'b1100011, 
                        lui     = 7'b0110111, 
                        auipc   = 7'b0010111, 
                        jal     = 7'b1101111, 
                        jalr    = 7'b1100111,
                        load    = 7'b0000011,
                        store   = 7'b0100011,
                        alu_imm = 7'b0010011,
                        alu     = 7'b0110011,
                        csr     = 7'b1110011} legal_opcode;
class legal_inst;
    rand legal_opcode opcode;
    logic [2:0] funct3;
    // constraint legal_funct3 {if(opcode == branch) {funct3 inside {3'b000, 3'b010, 3'b011, 3'b100, 3'b110, 3'b111};}
    //                          if(opcode == load) {funct3 inside {3'b000, 3'b001, 3'b010, 3'b100, 3'b101};}
    //                          if(opcode == store) {funct3 inside {3'b000, 3'b101, 3'b010};}
    //                          if(opcode == csr) {funct3 inside {3'b101, 3'b010, 3'b011, 3'b101, 3'b110, 3'b111};}}
    function string opcode_to_string(logic [6:0] opcode);
        case (opcode)
            branch:  opcode_to_string = "branch";
            lui: opcode_to_string = "lui";
            auipc: opcode_to_string = "auipc";
            jal: opcode_to_string = "jal";
            jalr: opcode_to_string = "jalr";
            load: opcode_to_string = "load";
            store: opcode_to_string = "store";
            alu_imm: opcode_to_string = "alu_imm";
            alu: opcode_to_string = "alu";
            csr: opcode_to_string = "csr";
            default: opcode_to_string = "unknown";
        endcase
    endfunction
endclass 

class legal_load extends legal_inst;
    rand logic [9:0] offset_upper;
    logic [1:0] offset_lowwer;
    randc logic [4:0] rd;
    randc logic [4:0] legal_cases;
    constraint funct3_load {legal_cases[4:2] inside {3'b000, 3'b001, 3'b010, 3'b100, 3'b101};};
    function void post_randomize();
        funct3 = legal_cases[4:2];
        offset_lowwer = legal_cases[1:0];
    endfunction
endclass

class legal_store extends legal_inst;
    rand logic [9:0] offset_upper;
    logic [1:0] offset_lowwer;
    randc logic [4:0] legal_cases;
    constraint funct3_store {legal_cases[4:2] inside {3'b000, 3'b001, 3'b010};}
    function void post_randomize();
        funct3 = legal_cases[4:2];
        offset_lowwer = legal_cases[1:0];
    endfunction
endclass 

class legal_alu_imm extends legal_inst;
    rand logic [11:0] imm;
    constraint funct7_alu_imm {if(funct3 == 3'b001) {imm[11:5] inside {7'b0000000, 7'b0000001};} // slli
                               if(funct3 == 3'b101) {imm[11:5] inside {7'b0000000, 7'b0000001, 7'b0100000, 7'b0100001};}} // srli, srai
endclass 

class legal_alu extends legal_inst;
    rand logic [6:0] funct7;
    constraint funct7_alu {if(funct3 == 3'b000) {funct7 inside {7'b0000000, 7'b0100000};} // add, sub
                           if(funct3 == 3'b001) {funct7 inside {7'b0000000};} // sll
                           if(funct3 == 3'b010) {funct7 inside {7'b0000000};} // slt
                           if(funct3 == 3'b011) {funct7 inside {7'b0000000};} // sltu
                           if(funct3 == 3'b100) {funct7 inside {7'b0000000};} // xor
                           if(funct3 == 3'b101) {funct7 inside {7'b0000000, 7'b0100000};} // srl, sra
                           if(funct3 == 3'b110) {funct7 inside {7'b0000000};} // or
                           if(funct3 == 3'b111) {funct7 inside {7'b0000000};}}// and
endclass 