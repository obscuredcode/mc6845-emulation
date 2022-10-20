module counter(clock,out);

input clock;
parameter WIDTH = 4;
parameter RESET_VALUE = {WIDTH{1'b0}};
output reg [WIDTH-1:0] out = RESET_VALUE;
parameter MAX = {WIDTH{1'b1}};
//output reg [3:0] out;

always @(posedge clock)
begin
	out <= out + 1;
	if (out == MAX) begin
		out <= RESET_VALUE;
	end
end


endmodule