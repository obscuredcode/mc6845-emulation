module pcounter(clock, counter, carry);

	parameter WIDTH = 4;
	parameter RESET_VALUE = {WIDTH{1'b0}};
	parameter INITIAL_LIMIT = {WIDTH{1'b0}};

	input clock;


	reg [WIDTH-1:0] limit = INITIAL_LIMIT;
	output reg [WIDTH-1:0] counter = RESET_VALUE;

	output reg carry;

	always @(posedge clock)
	begin
		counter <= counter + 1;
		carry <= 0;
		if (counter == limit) begin
			counter <= RESET_VALUE;
			carry <= 1;
		end
	end


endmodule