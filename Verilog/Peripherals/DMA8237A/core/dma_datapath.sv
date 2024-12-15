module dma_datapath (dma_if.DP dif, dma_tc_if.DP cif, dma_reg_if.DP rif);
    // internal registers
    logic [15:0] currAddrReg[4];
    logic [15:0] currWordReg[4];
    logic [15:0] baseAddrReg[4];
    logic [15:0] baseWordReg[4];
    logic [7:0] tempReg;
    logic [7:0] tempAddrReg;
    logic [7:0] tempWordReg;
    logic TC[4];
    // Datapath Buffers
    // logic [3:0] ioAddrBuf;      
    // logic [3:0] outAddrBuf;      
    // logic [7:0] ioDataBuf;  	
    logic [7:0] readBuf;
    logic [7:0] writeBuf;
    // Register commands
    logic FF;	
    logic [5:0] program_op = {}
    // DMA Registers SW command codes
    localparam READ_CURR_ADDR[4]              = {6'b010000,6'b010010,6'b010100,6'b010110};
    localparam READ_CURR_WORD_COUNT[4]        = {6'b010001,6'b010011,6'b010101,6'b010111};
    localparam WRITE_BASE_CURR_ADDR[4]        = {6'b100000,6'b100010,6'b100100,6'b100110};
    localparam WRITE_BASE_CURR_wORD_COUNT[4]  = {6'b100001,6'b100011,6'b100101,6'b100111};
    localparam READ_STATUS = 6'b011000;
    localparam WRITE_COMMAND = 6'b101000;
    localparam WRITE_REQUEST = 6'b101001;
    localparam WRITE_SINGLE_MASK = 6'b101010; 
    localparam WRITE_MODE = 6'101011;
    localparam CLEAR_FF = 6'b101100;
    localparam READ_TEMP = 6'b011101;
    localparam MASTER_CLEAR = 6'b101101;
    localparam CLEAR_MASK = 6'b101110;
    localparam WRITE_ALL_MASK = 6'b101111;
    
    // Write Base Address Register
    always_ff @(posedge dif.CLK) begin
        if (dif.RESET) begin
                baseAddrReg[0] <= '0;
                baseAddrReg[1] <= '0;
                baseAddrReg[2] <= '0;
                baseAddrReg[3] <= '0;
        end
        else begin
            if(cif.ProgramMode) begin
                if ({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == MASTER_CLEAR) begin
                    baseAddrReg[0] <= '0;
                    baseAddrReg[1] <= '0;
                    baseAddrReg[2] <= '0;
                    baseAddrReg[3] <= '0;
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_ADDR[0]) begin
                    if(FF)    // when FF = 1, upper byte is loaded . when FF = 0, lower byte is loaded                               
                        baseAddrReg[0][15:8] <= writeBuf;
                    else
                        baseAddrReg[0][7:0] <= writeBuf;
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_ADDR[1]) begin
                    if(FF)    // when FF = 1, upper byte is loaded . when FF = 0, lower byte is loaded                               
                        baseAddrReg[1][15:8] <= writeBuf;
                    else
                        baseAddrReg[1][7:0] <= writeBuf;
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_ADDR[2]) begin
                    if(FF)    // when FF = 1, upper byte is loaded . when FF = 0, lower byte is loaded                               
                        baseAddrReg[2][15:8] <= writeBuf;
                    else
                        baseAddrReg[2][7:0] <= writeBuf;
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_ADDR[3]) begin
                    if(FF)    // when FF = 1, upper byte is loaded . when FF = 0, lower byte is loaded                               
                        baseAddrReg[3][15:8] <= writeBuf;
                    else
                        baseAddrReg[3][7:0] <= writeBuf;
                end
            end
            else begin 
                baseAddrReg[0] <= baseAddrReg[0];
                baseAddrReg[1] <= baseAddrReg[1];
                baseAddrReg[2] <= baseAddrReg[2];
                baseAddrReg[3] <= baseAddrReg[3];
            end
        end
    end    
    // Write Base Word Count Register 
    always_ff @(posedge dif.CLK) begin 
        if (dif.RESET) begin
            baseWordReg[0] <= '0;
            baseWordReg[1] <= '0;
            baseWordReg[2] <= '0;
            baseWordReg[3] <= '0;
        end
        else begin 
            if (cif.ProgramMode) begin
                if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == MASTER_CLEAR)begin
                    baseWordReg[0] <= '0;
                    baseWordReg[1] <= '0;
                    baseWordReg[2] <= '0;
                    baseWordReg[3] <= '0;                    
                end
                else if ({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_wORD_COUNT[0]) begin
                    if(FF)    // when FF = 1, upper byte is loaded . when FF = 0, lower byte is loaded 
                        baseWordReg[0][15:8] <= writeBuf;
                    else
                        baseWordReg[0][7:0] <= writeBuf;            
                end
                else if ({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_wORD_COUNT[1]) begin
                    if(FF)    // when FF = 1, upper byte is loaded . when FF = 0, lower byte is loaded 
                        baseWordReg[1][15:8] <= writeBuf;
                    else
                        baseWordReg[1][7:0] <= writeBuf;            
                end
                else if ({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_wORD_COUNT[2]) begin
                    if(FF)    // when FF = 1, upper byte is loaded . when FF = 0, lower byte is loaded 
                        baseWordReg[2][15:8] <= writeBuf;
                    else
                        baseWordReg[2][7:0] <= writeBuf;            
                end
                else if ({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_wORD_COUNT[3]) begin
                    if(FF)    // when FF = 1, upper byte is loaded . when FF = 0, lower byte is loaded 
                        baseWordReg[3][15:8] <= writeBuf;
                    else
                        baseWordReg[3][7:0] <= writeBuf;            
                end
            end
            else begin
                baseWordReg[0] <= baseWordReg[0] ;
                baseWordReg[1] <= baseWordReg[1] ;
                baseWordReg[2] <= baseWordReg[2] ;
                baseWordReg[3] <= baseWordReg[3] ;
            end
        end
    end
    //Temporary Address Register
    always_ff @(posedge dif.CLK) begin
        if(dif.RESET)
            tempAddrReg <= '0;
        else begin
            if(cif.ldCurrAddrTemp)
                if(rif.modeReg[5] == 0)
                    tempAddrReg <= currAddrReg[rif.requestReg[1:0]]  + 16'b0000000000000001;
                else
                    tempAddrReg <= currAddrReg[rif.requestReg[1:0]]  - 16'b0000000000000001;               
            else
                tempAddrReg <= tempAddrReg;
        end
    end
    // Temporary Word Register
    always_ff @(posedge dif.CLK) begin
        if(dif.RESET)
            tempWordReg <= '0;
        else begin
            if(cif.ldCurrWordTemp)
                tempAddrReg <= currWordReg[rif.requestReg[1:0]]  - 16'b0000000000000001;               
            else
                tempWordReg <= tempWordReg;   
        end
    end
    // Write Current Address Register 
    always_ff @(posedge dif.CLK) begin
        if(dif.RESET) begin
            currAddrReg[0] <= '0;
            currAddrReg[1] <= '0;
            currAddrReg[2] <= '0;
            currAddrReg[3] <= '0;            
        end
        else if(TC[rif.requestReg[1:0]]) begin
            if (rif.modeReg[4]) 
                currAddrReg[rif.requestReg[1:0]] <= baseAddrReg[rif.requestReg[1:0]];      
            else
                currAddrReg[rif.requestReg[1:0]] <= '0;           
        end
        else begin
            if(cif.ProgramMode) begin
                if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == MASTER_CLEAR) begin
                    currAddrReg[0] <= '0;
                    currAddrReg[1] <= '0;
                    currAddrReg[2] <= '0;
                    currAddrReg[3] <= '0;                     
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_ADDR[0]) begin
                    if(FF)    // when FF = 1, upper byte is loaded . when FF = 0, lower byte is loaded                               
                        currAddrReg[0][15:8] <= writeBuf;
                    else
                        currAddrReg[0][7:0] <= writeBuf;
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_ADDR[1]) begin
                    if(FF)    // when FF = 1, upper byte is loaded . when FF = 0, lower byte is loaded                               
                        currAddrReg[1][15:8] <= writeBuf;
                    else
                        currAddrReg[1][7:0] <= writeBuf;
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_ADDR[2]) begin
                    if(FF)    // when FF = 1, upper byte is loaded . when FF = 0, lower byte is loaded                               
                        currAddrReg[2][15:8] <= writeBuf;
                    else
                        currAddrReg[2][7:0] <= writeBuf;
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_ADDR[3]) begin
                    if(FF)    // when FF = 1, upper byte is loaded . when FF = 0, lower byte is loaded                               
                        currAddrReg[3][15:8] <= writeBuf;
                    else
                        currAddrReg[3][7:0] <= writeBuf;
                end
            end
            else begin
                if(cif.ldCurrAddr)      //signal to load the temporary address register to current address register value 
                    currAddrReg[rif.requestReg[1:0]] <= tempAddrReg;
                else begin
                    currAddrReg[0] <= currAddrReg[0];
                    currAddrReg[1] <= currAddrReg[1];
                    currAddrReg[2] <= currAddrReg[2];
                    currAddrReg[3] <= currAddrReg[3];
                end
            end
        end
    end
    // Write Current Word Count Register 
    always_ff @(posedge dif.CLK) begin 
        if (dif.RESET) begin
            currWordReg[0] <= '0; 
            currWordReg[1] <= '0; 
            currWordReg[2] <= '0; 
            currWordReg[3] <= '0;             
        end
        else if(TC[rif.requestReg[1:0]]) begin
            if(rif.modeReg[4])
                currWordReg[rif.requestReg[1:0]] <= baseWordReg[rif.requestReg[1:0]];
            else
                currWordReg[rif.requestReg[1:0]] <= '0;
        end
        else begin
            if(cif.ProgramMode) begin
                if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == MASTER_CLEAR) begin
                    currWordReg[0] <= '0; 
                    currWordReg[1] <= '0; 
                    currWordReg[2] <= '0; 
                    currWordReg[3] <= '0;                       
                end
                else if ({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_wORD_COUNT[0]) begin
                    if(FF)    // when FF = 1, upper byte is loaded . when FF = 0, lower byte is loaded 
                        currWordReg[0][15:8] <= writeBuf;
                    else
                        currWordReg[0][7:0] <= writeBuf;            
                end
                else if ({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_wORD_COUNT[1]) begin
                    if(FF)    // when FF = 1, upper byte is loaded . when FF = 0, lower byte is loaded 
                        currWordReg[1][15:8] <= writeBuf;
                    else
                        currWordReg[1][7:0] <= writeBuf;            
                end
                else if ({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_wORD_COUNT[2]) begin
                    if(FF)    // when FF = 1, upper byte is loaded . when FF = 0, lower byte is loaded 
                        currWordReg[2][15:8] <= writeBuf;
                    else
                        currWordReg[2][7:0] <= writeBuf;            
                end
                else if ({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_wORD_COUNT[3]) begin
                    if(FF)    // when FF = 1, upper byte is loaded . when FF = 0, lower byte is loaded 
                        currWordReg[3][15:8] <= writeBuf;
                    else
                        currWordReg[3][7:0] <= writeBuf;            
                end
            end
            else begin
                if(cif.ldCurrWord)      //signal to load the temporary address register to current address register value 
                    currWordReg[rif.requestReg[1:0]] <= tempWordReg;
                else begin
                    currWordReg[0] <= currWordReg[0];
                    currWordReg[1] <= currWordReg[1];
                    currWordReg[2] <= currWordReg[2];
                    currWordReg[3] <= currWordReg[3];
                end
            end            
        end
    end 
    // Write Command Register 
    always_ff @(posedge dif.CLK) begin
        if(dif.RESET)
            rif.commandReg <= '0;
        else begin
            if(cif.ProgramMode) begin
                if ({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == MASTER_CLEAR) 
                    rif.commandReg <= '0;
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_COMMAND) 
                    rif.commandReg <= writeBuf;
            end
            else
                rif.commandReg <= rif.commandReg;
        end        
    end
    // Write Request Register
    always_ff @(posedge dif.CLK) begin
        if(dif.RESET || TC[rif.requestReg[1:0]])
            rif.requestReg <= '0;
        else begin
            if(cif.ProgramMode) begin
                if ({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == MASTER_CLEAR) 
                    rif.requestReg <= '0;
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_REQUEST) 
                    rif.requestReg <= writeBuf;
            end
            else
                rif.requestReg <= rif.requestReg;
        end        
    end
    // Write Mask Register
    always_ff @(posedge dif.CLK) begin
        if(dif.RESET)
            rif.maskReg <= '0;
        else begin
            if(cif.ProgramMode) begin
                if ({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == MASTER_CLEAR ||
                    {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == CLEAR_MASK) 
                    rif.maskReg <= '0;
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_ALL_MASK)
                    rif.maskReg <= writeBuf;
            end
            else
                rif.maskReg <= rif.maskReg;
        end        
    end   
    // Write Temporary Register
    always_ff @(posedge dif.CLK) begin
        if(dif.RESET)
            tempReg <= '0;
        else begin
            tempReg <= tempReg;
        end        
    end
    // Write Status Register
    always_ff @(posedge dif.CLK) begin
        if (dif.RESET || (cif.ProgramMode && {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == MASTER_CLEAR))
            rif.statusReg <= '0;
        else begin
            rif.statusReg[0] <= (TC[0])?1'b1:1'b0;
            rif.statusReg[1] <= (TC[1])?1'b1:1'b0;
            rif.statusReg[2] <= (TC[2])?1'b1:1'b0;
            rif.statusReg[3] <= (TC[3])?1'b1:1'b0;  
            rif.statusReg[4] <= (cif.VALID_DREQ0)?1'b1:1'b0;  
            rif.statusReg[5] <= (cif.VALID_DREQ1)?1'b1:1'b0; 
            rif.statusReg[6] <= (cif.VALID_DREQ2)?1'b1:1'b0; 
            rif.statusReg[7] <= (cif.VALID_DREQ3)?1'b1:1'b0;  
        end    
    end    
    // Write Mode Register
    always_ff @(posedge dif.CLK) begin
        if(dif.RESET) begin
                rif.modeReg[0] <= '0;
                rif.modeReg[1] <= '0;
                rif.modeReg[2] <= '0;
                rif.modeReg[3] <= '0;
        end
        else begin
            if(cif.ProgramMode) begin
                if ({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == MASTER_CLEAR) begin
                    rif.modeReg[0] <= '0;
                    rif.modeReg[1] <= '0;
                    rif.modeReg[2] <= '0;
                    rif.modeReg[3] <= '0;
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_MODE) 
                    rif.modeReg[dif.DB[1:0]] <= writeBuf;
            end
            else begin
                rif.modeReg[0] <=  rif.modeReg[0] ;
                rif.modeReg[1] <=  rif.modeReg[1] ;
                rif.modeReg[2] <=  rif.modeReg[2] ;
                rif.modeReg[3] <=  rif.modeReg[3] ;                
            end
        end        
    end
    // Clear FF
    always_ff @(posedge dif.CLK) begin
        if(dif.RESET)
            FF <= '0;
        else begin
            if(cif.ProgramMode) begin         
                if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == MASTER_CLEAR ||
                    {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == CLEAR_FF)
                    FF <= '0;
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_CURR_ADDR[0]  ||
                        {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_CURR_ADDR[1]  ||
                        {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_CURR_ADDR[2]  ||
                        {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_CURR_ADDR[3]  ||
                        {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_CURR_WORD_COUNT[0] ||
                        {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_CURR_WORD_COUNT[1] ||
                        {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_CURR_WORD_COUNT[2] ||
                        {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_CURR_WORD_COUNT[3] ||
                        {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_ADDR[0] ||
                        {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_ADDR[1] ||
                        {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_ADDR[2] ||
                        {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_ADDR[3] ||
                        {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_wORD_COUNT[0] ||
                        {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_wORD_COUNT[1] ||
                        {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_wORD_COUNT[2] ||
                        {dif.IOR_N, dif.IOW_N, dif.ADDR_L} == WRITE_BASE_CURR_wORD_COUNT[3])
                    FF <= FF + 1'b1;
            else
                FF <= FF;
            end
        end
    end
    // Terminal Count
    always_ff @(posedge dif.CLK) begin
        if(tempWordReg ==0)
            TC[rif.requestReg[1:0]] <= 1;
        else begin
            TC[0] <= 0;
            TC[1] <= 0;
            TC[2] <= 0;
            TC[3] <= 0; 
        end
    end
    // Read Register
    always_ff @(posedge dif.CLK) begin
        if(dif.RESET)
            readBuf <= '0;
        else begin
            if(cif.ProgramMode) begin
                if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == MASTER_CLEAR)
                    readBuf <= '0;
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_CURR_ADDR[0]) begin
                    if(FF)
                        readBuf <= currAddrReg[0][15:8];
                    else
                        readBuf <= currAddrReg[0][7:0];                
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_CURR_ADDR[1]) begin
                    if(FF)
                        readBuf <= currAddrReg[1][15:8];
                    else
                        readBuf <= currAddrReg[1][7:0];                
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_CURR_ADDR[2]) begin
                    if(FF)
                        readBuf <= currAddrReg[2][15:8];
                    else
                        readBuf <= currAddrReg[2][7:0];                
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_CURR_ADDR[3]) begin
                    if(FF)
                        readBuf <= currAddrReg[3][15:8];
                    else
                        readBuf <= currAddrReg[3][7:0];                
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_CURR_WORD_COUNT[0]) begin
                    if(FF)
                        readBuf <= currWordReg[0][15:8];
                    else
                        readBuf <= currWordReg[0][7:0];                
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_CURR_WORD_COUNT[1]) begin
                    if(FF)
                        readBuf <= currWordReg[1][15:8];
                    else
                        readBuf <= currWordReg[1][7:0];                
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_CURR_WORD_COUNT[2]) begin
                    if(FF)
                        readBuf <= currWordReg[2][15:8];
                    else
                        readBuf <= currWordReg[2][7:0];                
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_CURR_WORD_COUNT[3]) begin
                    if(FF)
                        readBuf <= currWordReg[3][15:8];
                    else
                        readBuf <= currWordReg[3][7:0];                
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_STATUS) begin
                    readBuf <= rif.statusReg;             
                end
                else if({dif.IOR_N, dif.IOW_N, dif.ADDR_L} == READ_TEMP) begin
                    readBuf <= tempReg;                
                end
            end
        end 
    end
    // Buffer
    assign writeBuf = dif.DB;
    assign dif.DB = (!dif.IOR_N && dif.IOW_N) ? readBuf : 8'bzzzzzzzz; 
endmodule