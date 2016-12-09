module enabledRegister(input logic [31:0] D, output logic [31:0] Q, 
	input logic clock, input logic writeEnable);
	
   // This initializes the register to 0.  This is cheating - it doesn't turn into hardware and would not
   // work in hardware, but it simplifies simulation
   
   initial
     begin
     Q = 32'b0;
     end
	
   logic [31:0]     writeReg;
    
// the always clause that follows happens on the positve edge of the clock

   mux4to1B32 mux0(1'b0,writeEnable,32'b10101010,32'b11001100,D,Q,writeReg);

   always @ (posedge clock)
     begin
	Q = writeReg;
     end

	
   
endmodule