module clock_divider(clock_in, clock_out);

input clock_in;
output reg clock_out;
reg [27:0] counter = 28'd0;
parameter DIVISOR = 28'd50000000;

always @(posedge clock_in)
begin
	counter <= counter + 28'd1;
	if(counter>=(DIVISOR-1))
		counter <= 28'd0;
	clock_out <= (counter<DIVISOR/2)?1'b1:1'b0;
end

endmodule