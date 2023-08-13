`timescale 1 ns/10 ps
module MC6845_t;
	reg CSn; // chip enable. active low -> writing or reading from register. 
	reg E; // enable/clock, neg edge -> enables data IO buffers and clocks data
	wire [7:0] D; // biderectional data bus
	reg RS; // register select. low -> writing to address register, high -> writing to register selected by address
	reg RW; // read or write register. low -> write, high -> read 
	
	reg CLK; // character clock, neg edge ->
	wire RSTn; // reset. active low -> all registers cleared and outputs are driven low.

	wire hs; //
	wire vs;
	wire red;
	wire grn;
	wire blu;
	wire DE; // display enable. high -> addressing in active display area.

	reg [7:0] WRITE_BUFFER;
	
	wire [7:0] D_input;
	
	assign D_input = D;
	assign D = !RW ? WRITE_BUFFER : 8'bz;
	
	reg [13:0] READ_BUFFER;
	
	wire cc;
	
	MC6845 crtc (.CSn(CSn), .E(E), .D(D), .RS(RS), .RW(RW), .CLK(cc), .RSTn(RSTn), .HSYNC(hs), .VSYNC(vs), .DE(DE));
	
	localparam period = 20;
	
	initial
	begin
		
		CSn = 0;
		write_register(5'b00000,8'h5e);
		write_register(5'b00001,8'h4c);
		write_register(5'b00010,8'h4e); // hsync position = 4e
		write_register(5'b00011,8'h0c);
		write_register(5'b00100,8'h40); // vertical line width
		write_register(5'b00101,8'h05);
		write_register(5'b00110,8'h3c); // vertical displayed
		write_register(5'b00111,8'h3d); // vsync pos = 3d
		
		write_register(5'b01000,8'h00); 
		
		write_register(5'b01001,8'h07);
		
		write_register(5'b01010,8'h00);
		write_register(5'b01011,8'h00);
		
		write_register(5'b01100,8'h00); // start addr
		
		write_register(5'b01101,8'h00); // start addr
		
		write_register(5'b01110,6'hfa); // cursor h
		write_register(5'b01111,8'had); // cursor l
		
		write_register(5'b10000,8'h00);
		write_register(5'b10001,8'h00);
		
		read_register(5'b01110, READ_BUFFER[13:8]);
		#period;
		read_register(5'b01111, READ_BUFFER[7:0]);
		//$display("reading upper: %x at %x", READ_BUFFER[13:8], 5'b01110);
		//$display("reading lower: %x at %x", READ_BUFFER[7:0], 5'b01111);
		
		//$monitor("VSYNC %b at %d micros", VSYNC, $time/1000);
		//CLK = 0;
		
	end
	
	reg MAX10_CLK_50 = 0;
	
	
	//counter #(8, 0, 32) dotcounter(.clock(MAX10_CLK_50), .out(cc));
	clock_divider #(28'd16) cd (.clock_in(MAX10_CLK_50),.clock_out(cc));
	
	always
	begin
		// 24 mghz is 41.66 ns
		// 160 ns is somehow 3.125 mghz
		//#160 CLK = ~CLK; // idk why this is off but this ends up being 3 mghz.
		
		#10 MAX10_CLK_50 = ~MAX10_CLK_50;
	end
	
	
	
	task write_register;
		input [4:0] address;
		input [7:0] data;
		begin
			RW = 0;
			RS = 0;
			WRITE_BUFFER[4:0] = address;
			$display("write_buffer: %x, address: %x\n", WRITE_BUFFER, address);
			E = 1;
			#period;
			E = 0;
			#period;
			RS = 1;
			WRITE_BUFFER = data;
			$display("write_buffer: %x, data: %x\n", WRITE_BUFFER, data);
			E = 1;
			#period;
			E = 0;
			#period;
		end
	endtask
	
	task read_register;
		input [4:0] address;
		output [7:0] data;
		begin
			RW = 0;
			RS = 0;
			WRITE_BUFFER[4:0] = address;
			E = 1;
			#period;
			E = 0;
			#period;
			RW = 1;
			RS = 1;
			E = 1;
			#period;
			E = 0;
			#period;
			data <= D;
		end
	endtask
	
	
	
endmodule