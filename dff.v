module dff(input clock, en,D, output reg Q=0);

	always @(posedge clock) begin
		if(en == 1)
			Q <= D; 
	end

endmodule