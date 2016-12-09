// this will need more ports later

module dataMemory(input logic [31:0] addr, 
		output logic [31:0] read,
		  input logic [31:0] writeData,
		  input logic clk, writeEnable);

// allocate 64 word-sized memory locations
   
logic [31:0] theStuff [6:0];

// initialize some of the dataMemory
initial 
begin
   theStuff[0] = 12;
   theStuff[1] = 10;
   theStuff[2] = 15;
   theStuff[3] = 99;
   theStuff[4] = 99;
   theStuff[5] = 0;
end

assign read = theStuff[addr[6:2]];

// to do writing, you need an always 

always @(posedge clk)
  if (writeEnable)
    begin
       $display("Writing address %d with %d", addr,writeData);		
       theStuff[addr[31:2]] <= writeData;
    end

endmodule