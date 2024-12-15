interface dma_tc_if;
    logic ProgramMode;
    logic StateRead;
    logic StateWrite;
    logic StateDone;
    logic ior;
    logic iow;
    modport TC(
        output ProgramMode,
        output StateRead,
        output StateWrite,
        output StateDone,
        output ior,
        output iow
    );
    modport DP(
        input ProgramMode,
        input StateRead,
        input StateWrite,
        input StateDone,
        input ior,
        input iow
    );
endinterface //dma_tc_if