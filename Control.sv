module Control(clock, ins, memToReg, memWrite, branchEnable, ALUControl, ALUSrc, regDst, regWriteEnable, jump, jumpReg, PCWrite, IorD, IRWrite, ALUSrcA, ALUSrcB, PCSrc, secondRound, alu4, alu3, alu2, alu1, alu0);

   input logic [31:0] ins;
   input logic [0:0]  clock;
   output logic [0:0] memToReg, memWrite, branchEnable, ALUSrc, regDst, regWriteEnable, jump, jumpReg, PCWrite, IorD, IRWrite, ALUSrcA, secondRound, alu4, alu3, alu2, alu1, alu0;
   output logic [1:0] ALUSrcB, PCSrc;
   output logic [4:0] ALUControl;
   
   logic [0:0] andr, jr, jal, norr, nori, notr, bleu, rolv, rorv;
   logic [0:0] lw, sw, lw2, sw2, lwen, swen, srcB1, srcB0, PCSrc1, PCSrc0;
   logic [31:0] lw32, sw32, lw1out, sw1out;

   assign andr = ins[31] & ~ins[30] & ~ins[29] & ~ins[28] & ~ins[27] & ~ins[26];
   
   // lw enable lines:
   assign lw = ins[31] & ~ins[30] & ~ins[29] & ~ins[28] & ins[27] & ins[26] & ~sw2 & ~lw2;
   // lw32 is 32-bit version of lw, with all 0's except least significant bit.  used for register.
   assign lw32 = {31'b0, lw};
   // lwen is high if either lw or lw2 is high, indicating that the value of lw2 should be
   // updated on both the first and second clock ticks of a lw instruction
   assign lwen = lw | lw2;
   // register to save the value of lw2 (in 32-bit form)
   enabledRegister lwSave(lw32, lw1out, clock, lwen);
   // take 32-bit version of lw2 and use only least significant bit
   assign lw2 = lw1out[0];

   // sw enable lines:
   assign sw = ins[31] & ~ins[30] & ins[29] & ~ins[28] & ins[27] & ins[26] & ~lw2 & ~sw2;
   // sw32 is 32-bit version of sw, with all 0's except least significant bit. used for register.
   assign sw32 = {31'b0, sw};
   // swen is high if either sw or sw2 is high, indicating that the value of sw2 shoudl be
   // updated on both the first and second clock ticks of a sw instruction
   assign swen = sw | sw2;
   // register to save the value of sw2 (in 32-bit form)
   enabledRegister swSave(sw32, sw1out, clock, swen);
   // take 32-bit version of sw2 and use only least significant bit
   assign sw2 = sw1out[0];
   
   assign jr = ~ins[31] & ~ins[30] & ins[29] & ~ins[28] & ~ins[27] & ~ins[26];
   assign jal = ~ins[31] & ~ins[30] & ~ins[29] & ~ins[28] & ins[27] & ins[26];
   assign norr = ins[31] & ~ins[30] & ~ins[29] & ins[28] & ins[27] & ~ins[26];
   assign nori = ~ins[31] & ~ins[30] & ins[29] & ins[28] & ins[27] & ~ins[26];
   assign notr = ~ins[31] & ~ins[30] & ~ins[29] & ins[28] & ~ins[27] & ~ins[26];
   assign bleu = ~ins[31] & ins[30] & ~ins[29] & ~ins[28] & ~ins[27] & ~ins[26];
   assign rolv = ~ins[31] & ~ins[30] & ~ins[29] & ~ins[28] & ~ins[27] & ~ins[26];
   assign rorv = ~ins[31] & ~ins[30] & ~ins[29] & ~ins[28] & ins[27] & ~ins[26];
	    
   assign alu4 = ins[31];
   assign alu3 = ins[30];
   assign alu2 = ins[29];
   assign alu1 = ins[28];
   assign alu0 = ins[27];
   
   assign memToReg = lw2 | jal;
   assign memWrite = sw2;
   assign branchEnable = bleu;
   assign ALUControl = {alu4, alu3, alu2, alu1, alu0};
   assign ALUSrc = nori | lw | sw; // don't need
   assign regDst = andr | norr | notr | rolv | rorv;
   assign regWriteEnable = lw2 | andr | norr | nori | notr | rolv | rorv | jal;  
   assign jump = jr | jal;
   assign jumpReg = jr;
   
   assign PCWrite = ~(lw | sw);
   assign IorD = lw2 | sw2;
   assign IRWrite = lw | sw;
   assign ALUSrcA = 1'b1; // always high - don't ever want to choose pcQ for
   // source A because we are not computing the PC+4 in the ALU. use external adder.
   assign srcB1 = lw | sw | lw2 | sw2 |  nori | jump;
   assign srcB0 = jump;
   assign ALUSrcB = {srcB1, srcB0};
   assign PCSrc1 = branchEnable | jumpReg;
   assign PCSrc0 = jal | jumpReg;
   assign PCSrc = {PCSrc1, PCSrc0};
   assign secondRound = lw2 | sw2;
   
   
endmodule