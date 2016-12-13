/* The beginning of a register set */

module registerFile(input logic [4:0] A1,
		    input logic [4:0] A2,
		    input logic [4:0] A3,
		    input logic [0:0] CLK,
		    input logic [0:0] WE3,
		    input logic [31:0] WD3,
		    output logic [31:0] RD1,
		    output logic [31:0] RD2
		    );
   
   logic  [0:0] yesWrite0, yesWrite1, yesWrite2, yesWrite3, yesWrite4, yesWrite5, yesWrite6, yesWrite7;    
   logic [31:0]  reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7;

   // assign write signals based on last 3 bits of A3
   assign yesWrite0 = WE3 &  ~A3[2] & ~A3[1] & ~A3[0];
   assign yesWrite1 = WE3 &  ~A3[2] & ~A3[1] & A3[0];
   assign yesWrite2 = WE3 &  ~A3[2] & A3[1] & ~A3[0];
   assign yesWrite3 = WE3 &  ~A3[2] & A3[1] & A3[0];
   assign yesWrite4 = WE3 &  A3[2] & ~A3[1] & ~A3[0];
   assign yesWrite5 = WE3 &  A3[2] & ~A3[1] & A3[0];
   assign yesWrite6 = WE3 &  A3[2] & A3[1] & ~A3[0];
   assign yesWrite7 = WE3 &  A3[2] & A3[1] & A3[0];

   // enable registers
   enabledRegister r0(WD3,reg0,CLK,yesWrite0);
   enabledRegister r1(WD3,reg1,CLK,yesWrite1);
   enabledRegister r2(WD3,reg2,CLK,yesWrite2);
   enabledRegister r3(WD3,reg3,CLK,yesWrite3);
   enabledRegister r4(WD3,reg4,CLK,yesWrite4);
   enabledRegister r5(WD3,reg5,CLK,yesWrite5);
   enabledRegister r6(WD3,reg6,CLK,yesWrite6);
   enabledRegister r7(WD3,reg7,CLK,yesWrite7);
 
   // select RD1 and RD2 based on A1 and A2 respectively
   mux8to1B32 mpxA1(A1[2], A1[1], A1[0], reg7, reg6, reg5, reg4, reg3, reg2, reg1, reg0, RD1);
   mux8to1B32 mpxA2(A2[2], A2[1], A2[0], reg7, reg6, reg5, reg4, reg3, reg2, reg1, reg0, RD2);
   
   // print registers
   always @ (negedge CLK)
     begin
	$display("REGISTER VALUES");
	$display("register 0 %h ",reg0);
	$display("register 1 %h ",reg1);
	$display("register 2 %h ",reg2);
	$display("register 3 %h ",reg3);
	$display("register 4 %h ",reg4);
	$display("register 5 %h ",reg5);
	$display("register 6 %h ",reg6);
	$display("register 7 %h ",reg7);
     end // always @ (negedge CLK)
   
   
endmodule


