module counter(clock,out);

input clock;
output reg [3:0] out = 4'b0000;
parameter MAX = 4'b1111;
//output reg [3:0] out;

always @(posedge clock)
begin
	out <= out + 1;
	if (out == MAX) begin
		out <= 4'b0000;
	end
end


endmodule