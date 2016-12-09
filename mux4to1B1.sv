module mux4to1B1(C1,C0,I3,I2,I1,I0,O1);

input logic C1, C0, I2, I1, I3, I0;
output logic O1;

assign O1 = (C1 & C0 & I3) |
	(C1 & ~C0 & I2) |
	(~C1 & C0 & I1) |
	(~C1 & ~C0 & I0);
	
	endmodule