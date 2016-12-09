module mux2to1B5 (input logic C,
		  input logic [4:0] I1, 
		  input logic [4:0] I0, 
		  output logic [4:0] O);
   
	mux4to1B4 m0(1'b0,C,4'b0,4'b0,I1[3:0],I0[3:0],O[3:0]);
	mux4to1B1 m1(1'b0,C,1'b0,1'b0,I1[4:4],I0[4:4],O[4:4]);
	

endmodule