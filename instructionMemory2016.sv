module instructionMemory(input logic [31:0] addr, 
		output logic [31:0] read);

logic [31:0] instructs [19:0];
initial 
begin
   instructs[0] = 32'b100011_00000_00001_0000000000001000;  // lw r1 <- 15
   instructs[1] = 32'b101011_00000_00001_0000000000010000;  // sw 15 into location 4 (16 as a byte address)
   instructs[2] = 32'b100011_00001_00000_0000000000000001;  // lw r0 <- 15 from location 4
   instructs[3] = 32'b100011_00001_00000_0000000000000101;  // lw r0 <- 0 from location 5  
   instructs[4] = 32'b100011_00000_00001_0000000000000000; //lw r1 <- 1100   (000c)
   instructs[5] = 32'b100011_00000_00010_0000000000000100; //lw r2 <- 1010   (000a)
   instructs[6] = 32'b100000_00001_00010_00011_00000000000; //add r3 <- 10110 (0016)
   instructs[7] = 32'b100110_00001_00010_00011_00000000000; //nor r3 <- fffffff1
   instructs[8] = 32'b001110_00010_00011_0000000011111100; // nori r3 <- ffffff01
   instructs[9] = 32'b000000_00001_00010_00011_00010_000000; // rolv r3 <- a0
   instructs[10] = 32'b000010_00001_00010_00011_00010_000000; // rorv r3 <- a0000000
   instructs[11] = 32'b000100_00001_00001_00011_00000_000000; // not r3 <- FFFFFFF3 
   instructs[12] = 32'b000011_00000_00000_00000_00000_010011; // jal  m2  jump to m2,  r7 <- this address + 4 (52)
   instructs[13] = 32'b010000_00001_00010_00000_00000_000011; // bleu r1,r2, m3      don't branch
   instructs[14] = 32'b100110_00000_00000_00000_00000_000000; // nor r0, r0, r0   r0 <- ffffffff
   instructs[15] = 32'b010000_00010_00001_00000_00000_000001; // bleu r2,r1, m3      branch
   instructs[16] = 32'b111111_00001_00000_00011_00000_000000; // nonsense instruction
   instructs[17] = 32'b001110_00010_00010_00000_00000_001010; // m3: nori $2, $2 , $000a  r2 <-fffffff5
   instructs[18] = 32'b111111_00001_00000_00011_00000_000000; // nonsense instruction
   instructs[19] = 32'b001000_00111_00000_00000_00000_000000; // m2: jr $7   return to first bleu
   
end

assign read = instructs[addr[6:2]];




endmodule



