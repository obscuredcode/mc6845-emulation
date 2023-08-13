module VGA(clk, E,
				VGA_B, VGA_G, VGA_R, VGA_HS, VGA_VS);
				
	input 						clk;
	input 								 E;
	output		     [3:0]		VGA_B;
	output		     [3:0]		VGA_G;
	output		          		VGA_HS;
	output		     [3:0]		VGA_R;
	output		          		VGA_VS;
	

	wire CSn; // chip enable. active low -> writing or reading from register. 
	wire E; // enable/clock, neg edge -> enables data IO buffers and clocks data
	wire [7:0] D; // biderectional data bus
	wire RS; // register select. low -> writing to address register, high -> writing to register selected by address
	wire RW; // read or write register. low -> write, high -> read 
	
	wire CCLK; // character clock, neg edge ->
	wire RSTn; // reset. active low -> all registers cleared and outputs are driven low.

	wire HSYNC; //
	wire VSYNC;
	wire DE; // display enable. high -> addressing in active display area.
	
	
	wire dotclock;
	
	clock_divider #(28'd16) cd (.clock_in(clk), .clock_out(dotclock));
	
	
	
	MC6845 crtc (.CSn(CSn), .E(E), .D(D), .RS(RS), .RW(RW), .CLK(dotclock), .RSTn(RSTn), .HSYNC(HSYNC), .VSYNC(VSYNC), .DE(DE));
	
	
	assign VGA_HS = ~HSYNC;
	assign VGA_VS = ~VSYNC;
	assign VGA_R = 1;
	assign VGA_G = 1;
	assign VGA_B = 0;

endmodule