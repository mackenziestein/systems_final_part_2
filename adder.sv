/*
 A simple adder
 */

module adder(input logic [31:0] a1,
	input logic [31:0] a2,
	output logic [31:0] answer);
	
assign answer = a1 + a2;

endmodule
