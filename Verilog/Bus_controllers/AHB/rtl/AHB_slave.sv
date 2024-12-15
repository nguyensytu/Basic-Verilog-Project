module AHB_slave (
// AHB slave interface
    input h_clk,
    input h_resetn,
    input [31:0] h_addr,
    input [2:0] h_burst,
    // input h_mastlock,
    // input h_prot,
    input [2:0] h_size,
    // input h_nonsec,
    // input h_excl,
    // input [] h_master,
    input [1:0] h_trans,
    input [31:0] h_wdata,
    input [3:0] h_wstrb,
    input h_write,
    output [31:0] h_rdata,
    output h_ready,
    output h_resp
    // output h_exokay
);
    localparam  idle = 2'b00,
                busy = 2'b01,
                nonseq = 2'b10,
                seq = 2'b11;
// APB interface
    // p_clk = h_clk;
    // p_resetn = h_resetn;
    // wire [31:0] p_addr;
    wire [2:0] p_sel;
    reg [1:0] p_enable;
    // wire p_write;
    // p_wdata = h_wdata;
    wire [3:0] p_strb;
    wire [31:0] p_rdata [2:0];
    wire p_ready [1:0];
    wire p_slverr [1:0];
// device interface
    wire [5:0] offset;
    wire w_en;
//  
    reg [25:0] base_addr [2:0];
    reg h_enable; 
    wire [6:0] ref_addr;
    wire slave_error, decode_error, burst_err, size_err;
    wire h_readyout;
//
    reg [31:0] reg_addr;
    reg [2:0] reg_burst;
    reg [2:0] reg_size;
    reg [1:0] reg_trans;
    reg [3:0] reg_wstrb;
    reg reg_write;
    always @(posedge h_clk, negedge h_resetn) begin
        if(!h_resetn) begin
            reg_addr <= 32'b0;
            reg_burst <= 3'b0;
            reg_size <= 3'b0;
            reg_trans <= idle;
            reg_wstrb <= 4'b0;
            reg_write <= 1'b0;
        end
        else begin
            if(h_ready) begin
                if(h_trans != busy) begin
                    reg_trans <= h_trans;
                    reg_addr <= h_addr;
                    if((h_trans == seq) || (h_trans == nonseq))
                        reg_burst <= h_burst;
                    else
                        reg_burst <= 3'b0;
                    reg_size <= h_size;
                    reg_wstrb <= h_wstrb;
                    reg_write <= h_write;
                end
            end
            else if(h_resp)
                reg_trans <= idle;
        end
    end
//
    always @(negedge h_resetn) begin
        base_addr[0] <= 26'b00;
        base_addr[1] <= 26'b01;
        base_addr[2] <= 26'b10;
    end
//
    APB_slave_8bit #(.DeviceWords(64), .AddrBits(32)) device0 (
        h_clk, h_resetn, reg_addr, p_sel[0], p_enable[0], reg_write, h_wdata, p_strb, p_rdata[0], p_ready[0], p_slverr[0]
    );
    APB_slave_32bit #(.NumWords(64)) device1 (
        h_clk, h_resetn, reg_addr, p_sel[1], p_enable[1], reg_write, h_wdata, p_strb, p_rdata[1], p_ready[1], p_slverr[1]
    );
    register_file_32bit #(.NumWords(64)) device2 (
        h_clk, h_resetn, w_en, offset, h_wdata, p_strb, p_rdata[2]
    );
//
    assign p_sel[0] = (reg_addr[31:6] == base_addr[0]) ? 1'b1 : 1'b0;
    assign p_sel[1] = (reg_addr[31:6] == base_addr[1]) ? 1'b1 : 1'b0;
    assign p_sel[2] = (reg_addr[31:6] == base_addr[2]) ? 1'b1 : 1'b0;
    assign decode_error = ~(p_sel[0] | p_sel[1] | p_sel[2]);
//
    always @(*) begin
        h_enable = 1'b0;
        case (reg_trans)
            // idle:
            // busy:
            nonseq: begin
                if(h_trans != busy)
                    h_enable = 1;
            end
            seq: begin
                if(h_trans != busy) 
                    h_enable = 1;
            end
        endcase
    end
    always @(posedge h_clk, negedge h_resetn) begin
        if(!h_resetn) begin
            p_enable[0] <= 1'b0;
            p_enable[1] <= 1'b0;
        end
        else begin
            if(h_ready) begin
                p_enable[0] <= 1'b0;
                p_enable[1] <= 1'b0;
            end
            else if (h_enable && !slave_error && !p_slverr[0] && !p_slverr[1]) begin
                p_enable[0] <= p_sel[0];
                p_enable[1] <= p_sel[1];
            end
            else begin
                p_enable[0] <= 1'b0;
                p_enable[1] <= 1'b0;
            end
        end
    end
    assign w_en = p_sel[2] & h_enable & reg_write & !slave_error;
// 
    p_strb_decoder p_strb_decoder (
        reg_wstrb, reg_size, p_strb, size_err
    );
    burst_err_decode burst_err_decode (
        h_clk, h_resetn, h_addr, reg_addr, h_burst, reg_burst, h_size, reg_size, h_trans, reg_trans,
        burst_err
    );
    h_resp_decoder h_resp_decoder(
        h_clk, h_resetn, h_trans, reg_trans, 1'b1, p_resp, slave_error, h_resp
    );
//
    assign ref_addr =   p_strb[3] ? {1'b0,reg_addr[5:0]} + 2'b11 :
                        p_strb[2] ? {1'b0,reg_addr[5:0]} + 2'b10 :
                        p_strb[1] ? {1'b0,reg_addr[5:0]} + 2'b01 : {1'b0,reg_addr[5:0]};
    assign offset = reg_addr[5:0];
//
    assign p_resp = p_slverr[0] | p_slverr[1] | burst_err;
    assign slave_error = decode_error | size_err | (p_sel[2] & ref_addr[6]);
    assign h_rdata = p_sel[2] ? p_rdata[2] : 
                     p_sel[1] ? p_rdata[1] : 
                     p_rdata[0]; 
    assign h_readyout = (p_ready[0] & !p_slverr[0]) | (p_ready[1] & !p_slverr[1]) | w_en;
    assign h_ready = (reg_trans == idle)| (h_readyout & !burst_err) ;
endmodule