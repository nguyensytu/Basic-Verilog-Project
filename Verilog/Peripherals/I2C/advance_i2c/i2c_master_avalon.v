module i2c_master_avalon #(
    parameter ADDR_BIT = 7,
              W = 10, 
              ACTIVE_W = 5,
              COUNTER_BIT = 3,
              DELAY = 1,
              W_FIFO = 4
) (
    // Avalon interface
	input [2:0] address,
	input chipselect,
	input clk,
	input read,
	input reset_n,
	input write,
	input [31:0] writedata,
    output reg [31:0] readdata,
    // I2C interface
    inout scl, sda
);
    // Signal declaration
    reg [31:0] data_tx, data_rx, addr_tx, status, control;
    wire [7:0] w_fifo_data, r_fifo_data;
    wire start, wr, rd, empty_tx, full_tx, empty_rx, full_rx;
    // Submodule instance
    i2c_master_fifo #(.ADDR_BIT(ADDR_BIT), 
                    .W(W), 
                    .ACTIVE_W(ACTIVE_W), 
                    .COUNTER_BIT(COUNTER_BIT), 
                    .DELAY(DELAY),
                    .W_FIFO(W_FIFO)) 
    i2c_master_fifo (
        clk, ~reset_n, wr, rd, control[3], start, // control[3] ~ rd_wr_en, 
        empty_tx, full_tx, empty_rx, full_rx,
        addr_tx [ADDR_BIT-1:0], w_fifo_data, r_fifo_data, scl, sda
    );
    single_cycle_tick start_cofigure (
        clk, ~reset_n, control[1], start
    );
    single_cycle_tick wr_configure (
        clk, ~reset_n, control[0], wr
    );
    single_cycle_tick rd_cofigure (
        clk, ~reset_n, control[2], rd
    );
    assign w_fifo_data = data_tx [7:0];
    // Avalon write/read
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            status [31:0] <= 32'b0;
            data_rx [31:0] <= 32'b0;
		end
        else begin
            status [31:4] <= 21'b0;
            data_rx [31:8] <= 21'b0; 
			status[3:0] <= {empty_rx, full_rx, empty_tx, full_tx};
            data_rx [7:0] <= r_fifo_data;
        end
    end
    always @ ( posedge clk or negedge reset_n )
	begin
		if ( reset_n == 1'b0 )
		begin
			data_tx <= 32'b0;
			control <= 32'b0;
			readdata <= 32'b0;
		end
		else if ( chipselect && write )
		begin
			case ( address )
				0 : data_tx <= writedata;
				3 : control <= writedata;
                4 : addr_tx <= writedata;
			endcase
		end
		else if ( chipselect && read )
		begin
			case ( address )
				0 : readdata <= data_tx;
                1 : readdata <= data_rx;
				2 : readdata <= status;
				3 : readdata <= control;
                4 : readdata <= addr_tx; 
			endcase
		end
		else
		begin
			data_tx <= data_tx;
			control <= {control[31:3], rd, start, wr};
            addr_tx <= addr_tx;
			readdata <= 32'b0; 
		end
	end
endmodule