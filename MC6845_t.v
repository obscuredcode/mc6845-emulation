`timescale 1 ns/10 ps
module MC6845_t;
	reg CSn; // chip enable. active low -> writing or reading from register. 
	reg E; // enable/clock, neg edge -> enables data IO buffers and clocks data
	reg [7:0] D; // biderectional data bus
	reg RS; // register select. low -> writing to address register, high -> writing to register selected by address
	reg RW; // read or write register. low -> write, high -> read 
	
	wire CLK; // character clock, neg edge ->
	wire RSTn; // reset. active low -> all registers cleared and outputs are driven low.

	wire HSYNC; //
	wire VSYNC;
	wire DE; // display enable. high -> addressing in active display area.

	
	
	MC6845 crtc (.CSn(CSn), .E(E), .D(D), .RS(RS), .RW(RW), .CLK(CLK), .RSTn(RSTn), .HSYNC(HSYNC), .VSYNC(VSYNC), .DE(DE));
	
	localparam period = 20;
	
	initial
	begin
		CSn = 0;
		RS = 0;
		RW = 0;
		D = 5'b00001;
		E = 1;
		#period;
		D = 5'b00001;
		E = 0;
		#period;
		RS = 1;
		D = 5'h5e;
		E = 1;
		#period;
		D = 5'h5e;
		E = 0;
		#period;
	end
endmodule