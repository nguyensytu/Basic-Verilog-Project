module dma_top (dma_if.TOP dif);

    dma_tc_if cif();
    dma_reg_if rif();
    dma_timing_control tc(dif, cif, rif);
    dma_datapath dp(dif, cif, rif);
    
endmodule