module ahb_slave_tb;
    localparam  idle = 2'b00,
                busy = 2'b01,
                nonseq = 2'b10,
                seq = 2'b11;
    // AHB salve interface
    logic h_clk;
    logic h_resetn;
    logic [31:0] h_addr;
    logic [2:0] h_burst;
    logic [2:0] h_size;
    logic [1:0] h_trans;
    logic [31:0] h_wdata;
    logic [3:0] h_wstrb;
    logic h_write;
    logic [31:0] h_rdata;
    logic h_ready;
    logic h_resp;
    AHB_slave uut (
        h_clk, h_resetn, h_addr, h_burst, h_size, h_trans, h_wdata, h_wstrb, h_write, h_rdata, h_ready, h_resp
    );
    // AHB_APB_slave uut (
    //     h_clk, h_resetn, h_addr, h_burst, h_size, h_trans, h_wdata, h_wstrb, h_write, h_rdata, h_ready, h_resp
    // );
    initial begin
        h_clk = 0;
        forever #5 h_clk = ~h_clk;
    end
    `include "ahb_task.sv"
    initial begin
        h_resetn = 0;
        ahb_init();
        #20 h_resetn = 1;
        #10 @(posedge h_clk);
        ahb_write_nonseq(26'b10, $random, 3'b0, 3'b010, 4'b1111);
        ahb_write_nonseq(26'b10, $random, 3'b0, 3'b110, 4'b1111); // size error
        ahb_write_nonseq(26'b10, $random, 3'b0, 3'b010, 4'b1111);
        ahb_write_nonseq(26'b10, 6'h3f, 3'b0, 3'b010, 4'b1111); // slave error
        ahb_write_nonseq(26'b10, 6'h30, 3'b0, 3'b010, 4'b1111);
        ahb_write_nonseq(26'b10, 6'h30, 3'b1, 3'b010, 4'b1111); // burst error nonseq
        ahb_write_nonseq(26'b10, 6'h30, 3'b0, 3'b010, 4'b1111);
        ahb_write_nonseq(26'b11, $random, 3'b0, 3'b010, 4'b1111); // decode error
        ahb_busy();
        ahb_idle();
        ahb_write_seq(26'b10, 6'h10, 3'b01, 3'b010, 4'b1111);
        ahb_busy();
        ahb_write_seq(26'b10, 6'h14, 3'b01, 3'b010, 4'b1111);
        ahb_write_seq(26'b10, 6'h16, 3'b01, 3'b010, 4'b1111); // burst error seq 
        ahb_idle();
    end
//    initial begin
//     fork
//         // access transfer
//         begin
            
//         end
//         // done transfer
//         begin
            
//         end
//     join
//    end





endmodule