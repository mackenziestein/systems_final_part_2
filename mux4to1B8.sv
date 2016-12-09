module mux4to1B8 (input logic C1, input logic C0, input logic [7:0] I3, 
	input logic[7:0] I2, input logic [7:0] I1, 
	input logic [7:0] I0, output logic [7:0] O);

	integer i;
	
	mux4to1B4 m0(C1,C0,I3[3:0],I2[3:0],I1[3:0],I0[3:0],O[3:0]);
	mux4to1B4 m1(C1,C0,I3[7:4],I2[7:4],I1[7:4],I0[7:4],O[7:4]);
	


endmodule