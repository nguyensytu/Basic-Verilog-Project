module dma_timing_control (dma_if.TC dif, dma_tc_if.TC cif);
    enum {
        SI = 0,
        S0 = 1,
        S1 = 2,
        S2 = 3,
        S3 = 4,
        S4 = 5,
        SW = 6
    } state, nextstate;
    // declaration
    logic ior;		
    logic iow;
    logic memr;		
    logic memw;
    //
    assign dif.IOR_N = dif.HLDA ? ior : 1'bz;
    assign dif.IOW_N = dif.HLDA ? iow : 1'bz;
    assign dif.MEMR_N = dif.HLDA ? memr : 1'bz;
    assign dif.MEMW_N = dif.HLDA ? memw : 1'bz;
    assign dif.EOP_N = dif.HLDA ? eop : 1'bz;
    assign cif.ProgramMode = !dif.CS_N & !dif.HLDA
    // 
    always_ff@(posedge dif.CLK) begin
        if(dif.RESET) begin
            // Reset condition
            dif.AEN    <= '0;
  	        dif.ADSTB  <= '0;
            state      <= SI;       // Initial FSM state
        end
        else begin
            // AEN & ADSTB functionality
            dif.AEN    <= aen;
  	        dif.ADSTB  <= adstb;
            state      <= nextstate;
        end
    end
    // next state logic
    always_comb begin 
        nextstate = state;
        case (state)
            SI: begin
                if(cif.VALID_DREG0 || cif.VALID_DREG1 || cif.VALID_DREG2 || cif.VALID_DREG3) 
                    nextstate = S0;
                else
                    nextstate = SI;
            end 
            S0: begin
                if(!dif.EOP_N)
                    nextstate = SI;
                else 
                    if(dif.HLDA)
                        nextstate = S1;
                    else   
                        nextstate = S0;
            end 
            S1: begin
                if(!dif.EOP_N)
                    nextstate = SI;
                else 
                    nextstate = S2;               
            end
            S2: begin
                if(!dif.EOP_N)
                    nextstate = SI;
                else 
                    nextstate = S3;                   
            end
            S3: begin
                if(!dif.EOP_N)
                    nextstate = SI;
                else 
                    nextstate = S4;                   
            end
            S4: begin
                if(!dif.EOP_N)
                    nextstate = SI;
                else 
                    nextstate = SW;     
            end
            SW: begin
                if(!dif.EOP_N)
                    nextstate = SI;
                else 
                    nextstate = SW;     
            end
        endcase
    end
    // output logic
    always_comb begin 
        cif.hrq = 1'b1;
        cif.dack = 1'b1;
        aen = 1'b1;
        adstb = 1'b0;
        cif.ldCurrAddrTemp = 1'b0;
        cif.ldCurrWordTemp = 1'b0;    
        cif.ldCurrAddr = 1'b0;
        cif.ldCurrWord = 1'b0;    
        case (state)
            SI: begin
                cif.hrq = 1'b0;
                cif.dack = 1'b0;
                aen = 1'b0;
            end
            S0: begin
                cif.dack = 1'b0;
                aen = 1'b0;
            end  
            S1: begin
                adstb = 1'b1;
                cif.ldCurrAddrTemp = 1'b1;
                cif.ldCurrWordTemp = 1'b1;
            end
            S2: begin
                cif.ldCurrAddr = 1'b1;
                cif.ldCurrWord = 1'b1;
            end
            S3: begin
            end
            S4: begin
                
            end 
            SW: begin
                
            end
        endcase
    end
    always_comb begin
        memr = 1'b1;
        memw = 1'b1; 
        ior = 1'b1;
        iow = 1'b1; 
        if(checkWriteExtend && rif.commandReg[5]) begin
            if(rif.modeReg[0][3:2] == 2'b10 || 
               rif.modeReg[1][3:2] == 2'b10 || 
               rif.modeReg[2][3:2] == 2'b10 || 
               rif.modeReg[3][3:2] == 2'b10) begin
                if (rif.commandReg[0]) begin
                    memr = 1'b0; 
                    memw = 1'b0;
                end
                else begin
                    memr = 1'b0; 
                    iow = 1'b0;                
                end
            end
        end
        else if ()
    end
endmodule