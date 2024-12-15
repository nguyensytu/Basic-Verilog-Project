interface dma_if(input logic CLK, input logic RESET);

	/* interface to 8086 processor */
	logic 	    MEMR;   	// memory read
	logic 	    MEMW;		// memory write
	wire 	    IOR;		// IO read
	wire 	    IOW;		// IO write
	logic 	    HLDA;		// Hold acknowledge from CPU to indicate it has relinquished bus control
	logic 	    HRQ;		// Hold request from DMA to CPU for bus control
	/* address and data bus interface */
	wire [7:0] ADDR;		
    wire  [7:0] DB;			// data
	logic       CS; 		// Chip select
	/* Request and Acknowledge interface */
	logic  DREQ;		// asynchronous DMA channel request lines
	logic  DACK;		// DMA acknowledge lines to indicate access granted to peripheral who has raised a request
	/* EOP signal */
	logic EOP;		// bi-directional signal to end DMA active transfers
	logic READY;
	// modport for DMA input signal
	modport TR (
		inout  	IOR,
		inout  	IOW,
		input   HLDA,	
		inout 	ADDR,
		inout 	DB,		
		input   CS,
		input   DREQ,
		input   EOP,
		input	READY,
		output 	MEMW
	);
	// modport for DMA top level
	modport TOP(
		input   CLK,
		input   RESET,
		output 	MEMR,	
		output 	MEMW,
		inout  	IOR,
		inout  	IOW,
		input   HLDA,
		output  HRQ,
		inout 	ADDR,
		inout 	DB,		
		input   CS,
		input   DREQ,
		output  DACK,
		input   EOP,
		input	READY
	);
    // modport for Timing Control logic
	modport TC(
		input   CLK,
		input   RESET,
		output 	MEMR,	
		output 	MEMW,
		inout  	IOR,
		inout  	IOW,
		input   HLDA,
		output  HRQ,		
		input   CS,
		input   DREQ,
		output  DACK,
		input   EOP, 
		input 	READY
	);
	
	// modport for Datapath
	modport DP (
		input   CLK,
		input   RESET,
		inout 	ADDR,
		inout 	DB
	);

	/* Clocking Block to drive stimulus at cycle level */
	clocking cb @(posedge CLK);
			default input #0 output #0;
			input 	MEMR;
			input 	MEMW;
			inout  	IOR;
			inout  	IOW;
			output  HLDA;
			input 	HRQ;
			inout  	ADDR;
			inout   DB;
			output	CS;
			output  DREQ;
			input 	DACK;
			inout  	EOP;
			input 	READY;
	endclocking
endinterface