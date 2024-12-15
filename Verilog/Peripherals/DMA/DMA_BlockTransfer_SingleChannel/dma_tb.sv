class transaction;
    rand logic IOR = 0;
    rand logic IOW = 0;
    rand bit HLDA;
    rand logic [7:0] ADDR;
    rand logic [7:0] DB;
    rand bit CS;
    rand bit DREQ;
    rand bit EOP;
    rand bit READY;
    bit MEMW;
    constraint Write_Read {
        IOR != IOW;
    };
    // constraint TransferMode {
    //     if(HLDA){
    //         IOR == 1'bz; IOW == 1'bz;
    //         ADDR == 8'bzzzzzzzz; 
    //         if (IOW || MEMW) {
    //             DB == 8'bzzzzzzzz; 
    //         }
    //     }
    // };
    function new();
        
    endfunction //new
        
endclass //transaction

module dma_tb;
    bit CLK, RESET;
    transaction trans;
    dma_if dif (.CLK(CLK), .RESET(RESET));
    dma_top dut (dif);
    logic ior, iow; 
    logic [7:0] addr, db;
    assign dif.IOR = ior;
    assign dif.IOW = iow;
    assign dif.ADDR = addr;
    assign dif.DB = db;
    task trans_assign();
        ior = trans.IOR;
        iow = trans.IOW;
        addr = trans.ADDR;
        db = trans.DB;
        dif.HLDA = trans.HLDA;
        dif.CS = trans.CS;
        dif.DREQ = trans.DREQ;
        dif.EOP = trans.EOP;
        dif.READY = trans.READY; 
        trans.MEMW = dif.MEMW;
    endtask //
    // CLock
    initial begin
        forever #10  CLK = ~CLK; 
    end
    // Reset
    initial begin
        trans = new();
        repeat(5)@(negedge CLK); RESET = 1;
        repeat(10)@(negedge CLK); RESET = 0;
        repeat(10) begin
            @(negedge CLK); 
            trans.randomize() with {HLDA == 0; DREQ == 0; EOP == 0;};
            trans_assign();
        end
        repeat(10) begin
            @(negedge CLK);
            trans.randomize() with {HLDA == 0; DREQ == 1; EOP == 0;};
            trans_assign();
        end
        repeat(10) begin
            @(negedge CLK); 
            trans.randomize() with {HLDA == 1; DREQ == 1; EOP == 0; READY == 1;};
            trans_assign();
        end
    end
endmodule