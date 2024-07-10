# core
## Instruction Set
### Opcode 
* 000aaaaa : load addr -> A  
* 001aaaaa : load addr -> B 
* 010aaaaa : store A -> addr
* 011xxxxx :
* 100aaaaa : jmp addr -> pc // jump anyway   
* 101aaaaa : jmpz addr -> pc // jump if zero flag = 1
* 110xxxxx :         
* 111ooooo : alu A, B -> A // add, sub, and, or
### 
* "x" is don't care bit, "a" is mem address bit, "o" is alu opcode bit 
* There are 2 register : A and B 
# core_with_uart

## purpose
* Use UART to write data to instruction memory
* Use UART to write data to data memory a, b, c for calculate a + b - c
* Press send button to transfer data
