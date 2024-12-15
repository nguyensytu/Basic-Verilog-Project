module dma_timing_control (dma_if.TC dif, dma_tc_if.TC cif, dma_reg_if.TC rif);
    enum {
    SI = 0, S0 = 1, S1 = 2, S2 = 3, S3 = 4, S4 = 5
    } state, nextstate;
    //
    always_ff@(posedge dif.CLK) begin
        if(dif.RESET) begin
            state <= SI;       // Initial FSM state
        end
        else begin
            state <= nextstate;
        end
    end 
    // next state logic
    always_comb begin 
        nextstate = state;
        case (state)
            SI: begin
                if(dif.DREQ) 
                    nextstate = S0;
                else
                    nextstate = SI;
            end 
            S0: begin
                if(dif.EOP)
                    nextstate = SI;
                else 
                    if(dif.HLDA)
                        nextstate = S1;
                    else   
                        nextstate = S0;
            end 
            S1: begin
                if(dif.EOP)
                    nextstate = SI;
                else  
                    nextstate = S2;               
            end
            S2: begin
                if(dif.EOP)
                    nextstate = SI;
                else if(dif.MEMR && !dif.READY)
                    nextstate = S2;
                else
                    nextstate = S3;                   
            end
            S3: begin
                if(dif.EOP)
                    nextstate = SI;
                else if(dif.MEMW && !dif.READY)
                    nextstate = S3;
                else
                    nextstate = S4;     
            end
            S4: begin
                if(dif.EOP || rif.terminal_count)
                    nextstate = SI;
                else 
                    nextstate = S2; 
            end
        endcase
    end
    // output logic
    assign dif.HRQ = (state != SI);
    assign dif.DACK = (state != SI) & (state != S0);
    assign dif.IOR = dif.HLDA ? ((state == S2) & rif.io_to_mem) : 1'bz;
    assign dif.IOW = dif.HLDA ? ((state == S3) & rif.mem_to_io)  : 1'bz;
    assign dif.MEMR = (state == S2) & (rif.mem_to_io || rif.mem_to_mem);
    assign dif.MEMW = (state == S3) & (rif.io_to_mem || rif.mem_to_mem);
    assign cif.ProgramMode = dif.CS & !dif.HLDA;
    assign cif.StateRead = (state == S2);
    assign cif.StateWrite = (state == S3);
    assign cif.StateDone = (state == S4);
    assign cif.ior = dif.IOR;
    assign cif.iow = dif.IOW;
endmodule