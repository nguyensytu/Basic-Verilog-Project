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
typedef enum logic[2:0] {lb     = 3'b000,
                        lh      = 3'b001,
                        lw      = 3'b010,
                        lbu     = 3'b100,
                        lhu     = 3'b101} legal_load_funct3;
typedef enum logic[2:0] {sb     = 3'b000,
                        sh      = 3'b001,
                        sw      = 3'b010} legal_store_funct3;
typedef enum logic[2:0] {beq    = 3'b000,
                        bne     = 3'b001,
                        blt     = 3'b100,
                        bge     = 3'b101,
                        bltu    = 3'b110,
                        bgeu    = 3'b111} legal_branch_funct3;
typedef enum logic[9:0] {addi   = 10'b0000000000,
                        slli    = 10'b0000000001,
                        slti    = 10'b0000000010,
                        sltiu   = 10'b0000000011,
                        xori    = 10'b0000000100,
                        srli    = 10'b0000000101,
                        srai    = 10'b0100000101,
                        ori     = 10'b0000000110,
                        andi    = 10'b0000000111} legal_alu_imm_funct;
typedef enum logic[9:0] {add    = 10'b0000000000,
                        sub     = 10'b0100000000,
                        sll     = 10'b0000000001,
                        slt     = 10'b0000000010,
                        sltu    = 10'b0000000011,
                        xorj    = 10'b0000000100,
                        srl     = 10'b0000000101,
                        sra     = 10'b0100000101,
                        orj     = 10'b0000000110,
                        andj    = 10'b0000000111} legal_alu_funct;
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
function string funct3_branch_to_string(logic [2:0] funct3);
    case (funct3)
        3'b000:  funct3_branch_to_string = "beq";
        3'b001:  funct3_branch_to_string = "bne";
        3'b100:  funct3_branch_to_string = "blt";
        3'b101:  funct3_branch_to_string = "bge";
        3'b110:  funct3_branch_to_string = "bltu";
        3'b111:  funct3_branch_to_string = "bgeu";
        default: funct3_branch_to_string = "unknown";
    endcase
endfunction
function string funct3_load_to_string(logic [2:0] funct3);
    case (funct3)
        3'b000:  funct3_load_to_string = "lb";
        3'b001:  funct3_load_to_string = "lh";
        3'b010:  funct3_load_to_string = "lw";
        3'b100:  funct3_load_to_string = "lbu";
        3'b101:  funct3_load_to_string = "lhu";
        default: funct3_load_to_string = "unknown";
    endcase
endfunction
function string funct3_store_to_string(logic [2:0] funct3);
    case (funct3)
        3'b000:  funct3_store_to_string = "sb";
        3'b001:  funct3_store_to_string = "sh";
        3'b010:  funct3_store_to_string = "sw";
        default: funct3_store_to_string = "unknown";
    endcase
endfunction
function string funct_alu_imm_to_string(logic [9:0] funct);
    case (funct)
        10'b0000000000:  funct_alu_imm_to_string = "addi";
        10'b0000000001:  funct_alu_imm_to_string = "slli";
        10'b0000000010:  funct_alu_imm_to_string = "slti";
        10'b0000000011:  funct_alu_imm_to_string = "sltiu";
        10'b0000000100:  funct_alu_imm_to_string = "xori";
        10'b0000000101:  funct_alu_imm_to_string = "srli";
        10'b0100000101:  funct_alu_imm_to_string = "srai";
        10'b0000000110:  funct_alu_imm_to_string = "ori";
        10'b0000000111:  funct_alu_imm_to_string = "andi";
        default: funct_alu_imm_to_string = "unknown";
    endcase
endfunction
function string funct_alu_to_string(logic [9:0] funct);
    case (funct)
        10'b0000000000:  funct_alu_to_string = "add";
        10'b0100000000:  funct_alu_to_string = "sub";
        10'b0000000001:  funct_alu_to_string = "sll";
        10'b0000000010:  funct_alu_to_string = "slt";
        10'b0000000011:  funct_alu_to_string = "sltu";
        10'b0000000100:  funct_alu_to_string = "xor";
        10'b0000000101:  funct_alu_to_string = "srl";
        10'b0100000101:  funct_alu_to_string = "sra";
        10'b0000000110:  funct_alu_to_string = "or";
        10'b0000000111:  funct_alu_to_string = "and";
        default: funct_alu_to_string = "unknown";
    endcase
endfunction

class legal_inst;
    logic [31:0] inst;
    logic [6:0] funct7;
    rand logic [4:0] rs2;
    rand logic [4:0] rs1;
    logic [2:0] funct3;
    rand logic [4:0] rd;
    rand legal_opcode opcode;
endclass 

class legal_lui extends legal_inst;
    rand logic [19:0] imm;
    randc logic [4:0] rd;
    function void post_randomize();
        funct3 = 3'b000;
        opcode = lui;
        inst = {imm, rd, opcode};
    endfunction
endclass

class legal_auipc extends legal_inst;
    rand logic [19:0] imm;
    randc logic [4:0] rd;
    function void post_randomize();
        funct3 = 3'b000;
        opcode = auipc;
        inst = {imm, rd, opcode};
    endfunction
endclass

class legal_load extends legal_inst;
    rand logic [9:0] offset_upper;
    logic [1:0] offset_lowwer;
    logic [11:0] offset;
    randc logic [4:0] legal_cases;
    constraint funct3_load {legal_cases[4:2] inside {3'b000, 3'b001, 3'b010, 3'b100, 3'b101};};
    function void post_randomize();
        funct3 = legal_cases[4:2];
        offset_lowwer = legal_cases[1:0];
        offset = {offset_upper, offset_lowwer};
        opcode = load;
        inst = {offset, rs1, funct3, rd, opcode};
    endfunction
endclass

class legal_store extends legal_inst;
    rand logic [9:0] offset_upper;
    logic [1:0] offset_lowwer;
    logic [11:0] offset;
    randc logic [4:0] legal_cases;
    constraint funct3_store {legal_cases[4:2] inside {3'b000, 3'b001, 3'b010};}
    function void post_randomize();
        funct3 = legal_cases[4:2];
        offset_lowwer = legal_cases[1:0];
        offset = {offset_upper, offset_lowwer};
        opcode = store;
        inst = {offset[11:5], rs2, rs1, funct3, offset[4:0], opcode};
    endfunction
endclass 

class legal_alu_imm extends legal_inst;
    rand logic [11:0] imm;
    randc logic [2:0] legal_cases;
    constraint funct7_alu_imm {if(legal_cases == 3'b001) {imm[11:5] inside {7'b0000000, 7'b0000001};} // slli
                               if(legal_cases == 3'b101) {imm[11:5] inside {7'b0000000, 7'b0000001, 7'b0100000, 7'b0100001};}} // srli, srai
    function void post_randomize();
        funct3 = legal_cases;
        opcode = alu_imm;
        inst = {imm, rs1, funct3, rd, opcode};
    endfunction
endclass 

class legal_alu extends legal_inst;
    randc logic [9:0] legal_cases;
    constraint funct7_alu {if(legal_cases[2:0] == 3'b000) {legal_cases[9:3] inside {7'b0000000, 7'b0100000};} // add, sub
                           if(legal_cases[2:0] == 3'b001) {legal_cases[9:3] inside {7'b0000000};} // sll
                           if(legal_cases[2:0] == 3'b010) {legal_cases[9:3] inside {7'b0000000};} // slt
                           if(legal_cases[2:0] == 3'b011) {legal_cases[9:3] inside {7'b0000000};} // sltu
                           if(legal_cases[2:0] == 3'b100) {legal_cases[9:3] inside {7'b0000000};} // xor
                           if(legal_cases[2:0] == 3'b101) {legal_cases[9:3] inside {7'b0000000, 7'b0100000};} // srl, sra
                           if(legal_cases[2:0] == 3'b110) {legal_cases[9:3] inside {7'b0000000};} // or
                           if(legal_cases[2:0] == 3'b111) {legal_cases[9:3] inside {7'b0000000};}}// and
    function void post_randomize();
        funct3 = legal_cases[2:0];
        funct7 = legal_cases[9:3];
        opcode = alu;
        inst = {funct7, rs2, rs1, funct3, rd, opcode};
    endfunction
endclass 

class legal_branch extends legal_inst;
    rand logic [11:0] offset;
    randc logic [2:0] legal_cases;
    constraint funct3_branch {legal_cases inside {3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111};}
    constraint offset_branch {offset[0] == 1'b0;};
    function void post_randomize();
        funct3 = legal_cases;
        opcode = branch;
        inst = {offset[11], offset[9:4], rs2, rs1, funct3, offset[3:0], offset[10], opcode};
    endfunction
endclass 

class legal_jal extends legal_inst;
    rand logic [19:0] offset;
    constraint offset_jal {offset[0] == 1'b0;};
    function void post_randomize();
        opcode = jal;
        inst = {offset[19], offset[9:0], offset[10], offset[18:11], rd, opcode};
    endfunction
endclass 

class legal_jalr extends legal_inst;
    rand logic [11:0] offset;
    constraint offset_jalr {offset[1:0] == 2'b00;};
    function void post_randomize();
        funct3 = 3'b000;
        opcode = jalr;
        inst = {offset, rs1, funct3, rd, opcode};
    endfunction
endclass 