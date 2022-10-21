// http://bitsavers.trailing-edge.com/components/motorola/_dataSheets/6845.pdf
module MC6845(E, CSn, RS, RW, D,
			  CLK, RSTn,
			  HSYNC, VSYNC, DE);

	input CSn; // chip enable. active low -> writing or reading from register. 
	input E; // enable/clock, neg edge -> enables data IO buffers and clocks data
	inout [7:0] D; // biderectional data bus
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
	/* notes
		minimized size of R3 to necessary 4 bits
		minimized size of R8 to necessary 2 bits
		R12 and R13 were merged together
		R14 and R15 were merged
		R16 and R17 were merged
		TODO: do I want to implement LIGHT_PEN?
	*/
	reg [4:0] ADDRESS;          	// AR  XXXXX address. selects which register to read or write from. write-only
	reg [7:0] HORIZONTAL_TOTAL; 	// R0  00000 horizontal timing. determines HS frequency by defining HS period in character times. (DISPLAYED CHARS + NON_DISPLAYED - 1 character times) write-only
	reg [7:0] HORIZONTAL_DISPLAYED; // R1  00001 displayed horizontal characeters per line. R1 > R0. write-only
	reg [7:0] H_SYNC_POS;			// R2  00010 horizontal sync position. R2 + R3 > R0. R2 > R1. write-only
	reg [3:0] SYNC_WIDTH;			// R3  00011 sync width for HS. VS sync width is fixed to 16. HS pulse width is in character times. write-only
	reg [6:0] VERTICAL_TOTAL;		// R4  00100
	reg [4:0] VERTICAL_TOTAL_ADJ;   // R5  00101
	reg [6:0] VERTICAL_DISPLAYED;	// R6  00110
	reg [6:0] V_SYNC_POS;		 	// R7  00111
	reg [1:0] INTERLACE_MODE_SKEW;	// R8  01000
	reg [4:0] MAX_SCANLINE_ADDRESS; // R9  01001
	reg [6:0] CURSOR_START;			// R10 01010
	reg [4:0] CURSOR_END;			// R11 01011
	reg [13:0] START_ADDRESS;		// R12 01100 high
									// R13 01101 low
	reg [13:0] CURSOR;				// R14 01110 high
									// R15 01111 low
	reg [13:0] LIGHT_PEN;			// R16 10000 high
									// R17 10001 low
									
	reg [7:0] READ_BUFFER;
	always @(negedge E, negedge RSTn)
	begin
		if (!RSTn) begin // reset processor interface
			ADDRESS <= 5'b00000;
			// TODO: pull D low?
		end
		else begin
			if (!CSn) begin
				if(!RS) begin
					if (!RW) ADDRESS <= D[4:0];
				end
				else begin
					case (ADDRESS)
						5'b00000 : HORIZONTAL_TOTAL <= D;
						5'b00001 : HORIZONTAL_DISPLAYED <= D;
						5'b00010 : H_SYNC_POS <= D;
						5'b00011 : SYNC_WIDTH <= D[3:0];
						5'b00100 : VERTICAL_TOTAL <= D[6:0];
						5'b00101 : VERTICAL_TOTAL_ADJ <= D[4:0];
						5'b00110 : VERTICAL_DISPLAYED <= D[6:0];
						5'b00111 : V_SYNC_POS <= D[6:0];
						5'b01000 : INTERLACE_MODE_SKEW <= D[1:0];
						5'b01001 : MAX_SCANLINE_ADDRESS <= D[4:0];
						5'b01010 : CURSOR_START <= D[6:0];
						5'b01011 : CURSOR_END <= D[4:0];
						5'b01100 : START_ADDRESS[13:8] <= D[5:0];
						5'b01101 : START_ADDRESS[7:0] <= D[7:0];
						5'b01110 : 	begin
										if(!RW)
											CURSOR[13:8] <= D[5:0];
										else
											READ_BUFFER[7:6] <= 2'b0;
											READ_BUFFER[5:0] <= CURSOR[13:8]; // TODO set top 2 bits to 0
									end
						5'b01111 :  begin
										if(!RW)
											CURSOR[7:0] <= D[7:0];
										else
											READ_BUFFER[7:0] <= CURSOR[7:0];
									end
						5'b10000 : begin 
										if(!RW)
											LIGHT_PEN[13:8] <= D[5:0]; 
										else
											READ_BUFFER[7:6] <= 2'b0;
											READ_BUFFER[5:0] <= LIGHT_PEN[13:8]; 
									end
						5'b10001 : begin
										if(!RW)
											LIGHT_PEN[7:0] <= D[7:0];
										else 
											READ_BUFFER[7:0] <= LIGHT_PEN[7:0];
									end
					endcase
				end
			end
		end
	end
	assign D[7:0] = RW ? READ_BUFFER : 8'bz;

endmodule