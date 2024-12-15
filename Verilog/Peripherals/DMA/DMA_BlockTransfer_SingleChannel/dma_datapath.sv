module dma_datapath (dma_if.DP dif, dma_tc_if.DP cif, dma_reg_if.DP rif);
    //
    logic [1:0] modeReg;
    logic [7:0] baseAddrReg0, baseAddrReg1;
    logic [7:0] baseWordReg; 
    logic [7:0] currAddrReg0, currAddrReg1;
    logic [7:0] currWordReg;

          
    logic [7:0] io_data_buff;
    logic [7:0] io_addr_buff;
    assign rif.io_to_mem = modeReg == 2'b00;
    assign rif.mem_to_io = modeReg == 2'b01;
    assign rif.mem_to_mem = modeReg == 2'b10;
    assign rif.terminal_count = (cif.StateDone && currWordReg == '0);
    assign io_addr_buff = (rif.mem_to_mem && cif.StateWrite) ? currAddrReg1 : currAddrReg0;
    assign dif.ADDR = cif.ProgramMode ? 8'bzzzzzzzz : io_addr_buff;
    assign dif.DB = (cif.StateRead || (cif.ProgramMode && {cif.ior, cif.iow} == 2'b01)) ? 8'bzzzzzzzz : io_data_buff;
    // Base Register
    always_ff @(posedge dif.CLK) begin 
        if(dif.RESET) begin
            baseAddrReg0 <= '0;
            baseAddrReg1 <= '0;
            baseWordReg <= '0;
            modeReg <= '0;
        end
        else begin
            if(cif.ProgramMode) begin
                if({cif.ior, cif.iow} == 2'b01) begin // write
                    if(dif.ADDR[1:0] == 2'b00)
                        baseAddrReg0 <= dif.DB;
                    else if(dif.ADDR[1:0] == 2'b01)
                        baseAddrReg1 <= dif.DB;                    
                    else if(dif.ADDR [1:0] == 2'b10)
                        baseWordReg <= dif.DB;
                    else if(dif.ADDR [1:0] == 2'b11)
                        modeReg <= dif.DB[1:0];
                end
            end 
            else begin
                baseAddrReg0 <= baseAddrReg0;
                baseAddrReg1 <= baseAddrReg1;
                baseWordReg <= baseWordReg;
                modeReg <= modeReg;
            end
        end
    end 
    // Current Register
    always_ff @(posedge dif.CLK) begin 
        if(dif.RESET || rif.terminal_count) begin
            currAddrReg0 <= baseAddrReg0;
            currAddrReg1 <= baseAddrReg1;
            currWordReg <= baseWordReg;
        end
        else begin
            if(cif.StateDone) begin;
                currAddrReg0 <= currAddrReg0 + 8'b1;
                if(rif.mem_to_mem)
                    currAddrReg1 <= currAddrReg1 + 8'b1;
                currWordReg <= currWordReg - 8'b1;
            end
            else begin
                currAddrReg0 <= currAddrReg0;
                currAddrReg1 <= currAddrReg1;
                currWordReg <= currWordReg;
            end
        end
    end
    // Transfer Mode
    always_ff @(posedge dif.CLK) begin 
        if(dif.RESET)
            io_data_buff <='0;
        else if(cif.StateRead)
            io_data_buff <= dif.DB;
        else if(cif.ProgramMode) begin
            if({cif.ior, cif.iow} == 2'b10) begin
                if(dif.ADDR[1:0] == 2'b00)
                    io_data_buff <= currAddrReg0;
                else if(dif.ADDR[1:0] == 2'b01)
                    io_data_buff <= currAddrReg1;
                else if(dif.ADDR == 2'b10)
                    io_data_buff <= currWordReg;             
            end
        end 
        else 
            io_data_buff <= io_data_buff;
    end
endmodule