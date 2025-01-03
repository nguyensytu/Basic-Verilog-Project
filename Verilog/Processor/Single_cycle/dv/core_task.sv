task loada(logic[4:0] addr);
    inst[7:5] = 3'b000;
    inst[4:0] = addr;
endtask
task loadb(logic[4:0] addr);
    inst[7:5] = 3'b001;
    inst[4:0] = addr;
endtask
task loadaimm();
    inst[7:5] = 3'b010;
    inst[4] = 1'b0;
endtask
task loadbimm();
    inst[7:5] = 3'b010;
    inst[4] = 1'b1;
endtask
task storea(logic[4:0] addr);
    inst[7:5] = 3'b011;
    inst[4:0] = addr;
endtask
task jmp(logic[4:0] addr);
    inst[7:5] = 3'b100;
    inst[4:0] = addr;
endtask
task return();
    inst[7:5] = 3'b101;
    inst[4:0] = 5'b0;
endtask
task add();
    inst[7:5] = 3'b111;
    inst[4:0] = 5'b0;
endtask
task sub();
    inst[7:5] = 3'b111;
    inst[4:0] = 5'b1;
endtask
task and();
    inst[7:5] = 3'b111;
    inst[4:0] = 5'b10;
endtask
task or();
    inst[7:5] = 3'b111;
    inst[4:0] = 5'b11;
endtask
task shift(logic[1:0] numbit);
    inst[7:5] = 3'b111;
    inst[4:3] = numbit;
    inst[2:0] = 3'b100;
endtask