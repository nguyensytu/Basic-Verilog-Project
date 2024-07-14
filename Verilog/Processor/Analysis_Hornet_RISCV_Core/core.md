# Instruction Set
## Classify
### Opcode [6:0] = inst [6:0]
1. 1100011: Branch 
    * funct3[2:0] = inst[14:12]
    - 000 : beq
    - 001 : bne
    - 100 : blt
    - 101 : bge
    - 110 : bltu
    - 111 : bgeu
2. 0110111 : Tải giá trị tức thời vào thanh ghi trên
    * lui
3. 0010111 : Thêm một giá trị tức thời vào thanh ghi chỉ số chương trình
    * auipc
4. 1100111 : Lệnh nhảy và liên kết thanh ghi
    * jalr
5. 1101111 : Lệnh nhảy và liên kết 
    * jal 
6. 0000011: Load mem to register
    * funct3[2:0] = inst[14:12]
    - 000 : lb
    - 001 : lh
    - 010 : lw
    - 100 : lbu
    - 101 : lhu
7. 0100011: Store register to mem 
    * funct3[2:0] = inst[14:12]
    - 000 : sb
    - 001 : sh
    - 010 : sw
8. 0110011 : ALU.
    * funct3[2:0] = inst[14:12]
    - 000 : funct7[6:0] = inst[31:25]
        + 0000000 : add
        + 0100000 : sub
    - 001 : 
        + 0000000 : sll
    - 010 :
        + 0000000 : slt
    - 011 :
        + 0000000 : sltu
    - 100 : 
        + 0000000 : xor
    - 101 : 
        + 0000000 : srl
        + 0100000 : sra
    - 110 : 
        + 0000000 : or
    - 111 : 
        + 0000000 : and
9. 0010011 : ALU-Imm
    * funct3[2:0] = inst[14:12]
    - 000 : funct7[6:0] = inst[31:25]
        + 0000000 : addi
    - 001 : 
        + 000000x : slli
    - 010 :
        + 0000000 : slti
    - 011 :
        + 0000000 : sltiu
    - 100 : 
        + 0000000 : xori
    - 101 : 
        + 000000x : srli
        + 010000x : srai
    - 110 : 
        + 0000000 : ori
    - 111 : 
        + 0000000 : andi
10. 1110011 : System
    * funct3[2:0] = inst[14:12]
    - 000 : 
        + 0000000 : ecall
        + 0000000 : ebreak
        + 0000000 : uret
        + 0000000 : sret
        + 0000000 : mret
        + 0000000 : wfi
        + 0000000 : sfence.vma
    - 001 : csrrw
    - 010 : csrrs
    - 011 : csrrc
    - 101 : csrrwi
    - 110 : csrrsi
    - 111 : csrrci
11. 0001111 : Các lệnh bộ nhớ khác.
    * funct3[2:0] = inst[14:12]
    - 000 : fence
    - 001 : fence.i
