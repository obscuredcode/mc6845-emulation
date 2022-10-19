// http://bitsavers.trailing-edge.com/components/motorola/_dataSheets/6845.pdf
module MS6845(E, CSn, RS, RW, D,
			  CLK, RSTn,
			  HSYNC, VSYNC, DE);

	input CSn; // chip enable. active low -> writing or reading from register. 
	input E; // enable/clock, neg edge -> enables data IO buffers and clocks data
	input [7:0] D; // biderectional data bus
	input RS; // register select. low -> writing to address register, high -> writing to register selected by address
	input RW; // read or write register. low -> write, high -> read 
	/* MDA notes
		RW is driven directly by ~IOW
	*/
	
	
	input CLK; // character clock, neg edge ->
	input RSTn; // reset. active low -> all registers cleared and outputs are driven low.

	output HSYNC; //
	output VSYNC;
	output DE; // display enable. high -> addressing in active display area.

	// registers
	reg AR [4:0]; // address register. selects which register to read or write from
	
	always @(negedge E, negedge RSTn)
	begin
		if (!RSTn) begin // reset processor interface
			AR <= 5b'00000;
			// TODO: pull D low?
		end
		else begin
			if (!CSn) begin
				if(!RS) begin
					if (!RW) AR <= D[4:0];
				end
			end
		end
	end
	

endmodule