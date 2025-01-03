module load_store_unit (
    // 
    input clk, reset,
    input [31:0] addr_i, data_write_mem, data_read_mem, memwb_memout,
    input [1:0] idex_mem_len, exmem_mem_len,
    input idex_L, idex_wmem,
    input exmem_misaligned,

    output reg [31:0] data_o,
    output [31:0] addr_o,
    output reg [3:0] wmask,
    output misaligned_access,
    output reg [31:0] memout
);
    wire addr_misaligned;
    reg [31:0] addr_reg;
// EX stage
    // see if the load/store address is misaligned and 
    // thus requires two seperate load/store operations
    assign addr_misaligned = (idex_mem_len == 2'd2 && addr_i[1:0] != 2'd0) ? 1'b1
                           : (idex_mem_len == 2'd1 && addr_i[1:0] == 2'd3) ? 1'b1
                           : 1'b0;
    //the instruction must be a load or a store, and the address must be misaligned.
    assign misaligned_access = (idex_L | idex_wmem) & ~exmem_misaligned & addr_misaligned; //the instruction must be a load or a store, and the address must be misaligned.
    //output to memory
    assign addr_o = exmem_misaligned ? {addr_reg[31:2],2'b0} + 32'd4 : {addr_reg[31:2],2'b0};

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            addr_reg <= 32'd0;
        end
        else begin
            addr_reg <= addr_i;
        end	
    end
    // MEM stage
    always @(*) begin
        if(!exmem_misaligned) begin
            if(exmem_mem_len == 2'd0)
                wmask = 4'b1 << addr_reg[1:0];
            else if(exmem_mem_len == 2'd1)
                wmask = 4'b11 << addr_reg[1:0];
            else
                wmask = 4'b1111 << addr_reg[1:0];
            data_o = data_write_mem << 8*addr_reg[1:0];
        end
        else begin
            if(exmem_mem_len == 2'd1) begin
                wmask = 4'b1;
                data_o = data_write_mem >> 8;
            end
            else begin
                wmask = 4'b1111 >> (3'd4 - {1'b0,addr_reg[1:0]});
                data_o = data_write_mem >> 8*(3'd4 - {1'b0,addr_reg[1:0]});
            end
        end
    end
    always @(*)
    begin // big endian
        if(exmem_misaligned) begin
            if(exmem_mem_len == 2'd2) begin //32-bit load 
                if(addr_reg[1:0] == 2'd3)
                    memout = {data_read_mem[23:0], 8'b0};
                else if(addr_reg[1:0] == 2'd2)
                    memout = {data_read_mem[15:0], 16'b0};
                else // 2'd1
                    memout = {data_read_mem[7:0], 24'b0};
            end
            else begin //16-bit load
                if(addr_reg[1:0] == 2'd3)
                    memout = {24'b0, data_read_mem[7:0]};
                else
                    memout = 32'b0;
            end
        end
        else begin
            if(exmem_mem_len == 2'd2) begin //32-bit load
                if(addr_reg[1:0] == 2'd3)
                    memout = {memwb_memout[31:8],data_read_mem[31:24]};
                else if(addr_reg[1:0] == 2'd2)
                    memout = {memwb_memout[31:16],data_read_mem[31:16]};
                else if(addr_reg[1:0] == 2'd1)
                    memout = {memwb_memout[31:24],data_read_mem[31:8]};
                else
                    memout = data_read_mem;
            end
            else if(exmem_mem_len == 2'd1) begin //16-bit load
                if(addr_reg[1:0] == 2'd3)
                    memout = {16'b0, memwb_memout[7:0], data_read_mem[31:24]};
                else if(addr_reg[1:0] == 2'd2)
                    memout = {16'b0,data_read_mem[31:16]};
                else if(addr_reg[1:0] == 2'd1)
                    memout = {16'b0,data_read_mem[23:8]};
                else
                    memout = {16'b0,data_read_mem[15:0]};
            end
            else begin //8-bit load
                if(addr_reg[1:0] == 2'd3)
                    memout = {24'b0,data_read_mem[31:24]};
                else if(addr_reg[1:0] == 2'd2)
                    memout = {24'b0,data_read_mem[23:16]};
                else if(addr_reg[1:0] == 2'd1)
                    memout = {24'b0,data_read_mem[15:8]};
                else
                    memout = {24'b0,data_read_mem[7:0]};
            end
        end
    end
endmodule