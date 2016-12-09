module mux4to1B32 (input logic C1, input logic C0, input logic [31:0] I3, 
	input logic[31:0] I2, input logic [31:0] I1, 
	input logic [31:0] I0, output logic [31:0] O);

	mux4to1B4 s1(C1,C0,I3[3:0],I2[3:0],I1[3:0],I0[3:0],O[3:0]);
	mux4to1B4 s2(C1,C0,I3[7:4],I2[7:4],I1[7:4],I0[7:4],O[7:4]);
	mux4to1B4 s3(C1,C0,I3[11:8],I2[11:8],I1[11:8],I0[11:8],O[11:8]);
	mux4to1B4 s4(C1,C0,I3[15:12],I2[15:12],I1[15:12],I0[15:12],O[15:12]);
	mux4to1B4 s5(C1,C0,I3[19:16],I2[19:16],I1[19:16],I0[19:16],O[19:16]);
	mux4to1B4 s6(C1,C0,I3[23:20],I2[23:20],I1[23:20],I0[23:20],O[23:20]);
	mux4to1B4 s7(C1,C0,I3[27:24],I2[27:24],I1[27:24],I0[27:24],O[27:24]);
	mux4to1B4 s8(C1,C0,I3[31:28],I2[31:28],I1[31:28],I0[31:28],O[31:28]);
	
endmodule