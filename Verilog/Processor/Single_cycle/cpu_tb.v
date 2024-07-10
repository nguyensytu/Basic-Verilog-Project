`timescale 1ps/1ps
module cpu_tb;
    // signal declaration
    reg clk, reset;
    wire [4:0] pc;
    wire [7:0] inst;
	wire [4:0] addr;
    wire core_wr, core_rd;
	wire [7:0] data_i, data_o;
    // submodule instance
    core uut (
        clk, reset, inst, pc, data_i, core_wr, core_rd, addr, data_o
    ); 
    instruction_memory inst_mem (
        pc, inst
    );
    data_memory data_mem (
        clk, core_wr, core_rd, addr, data_o, data_i
    );
    initial begin
        clk <= 0;
    end
    always #10 clk <= ~clk;
endmodule