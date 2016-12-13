`timescale 1 ns/1 ns

module tester3;

logic [31:0] pcQ, pcD,instruction, addIn1, addIn2, addOut;
logic clock;
logic regWriteEnable;

int clockCount;

DataPath dut (clock, pcQ, instruction,pcD, regWriteEnable);

   
// start a clock with a counter of clock cycle
   

always 
	begin
	clock <= 0;
	#20;
	clock <= 1;
	#20;
	clockCount <= clockCount + 1;
	end

   
// set up debugging display and a way to end the simulation
   
always @ (negedge clock) begin
   $display("PC INFO");
   $display("Reg write enable %b", regWriteEnable);
   $display("PC Address : %h",pcQ);
   $display("PC D: %h ",pcD);
   $display("Instruction : %h", instruction);
   $display(" - ");
   
   
   if (clockCount == 30)
     begin
	$display("Simulation ending after %d clock cycles ",clockCount);
	$stop;
     end
end // always

endmodule