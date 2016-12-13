module Control(clock, ins, memToReg, memWrite, branchEnable, ALUControl, ALUSrc, regDst, regWriteEnable, jump, jumpReg, PCWrite, IorD, IRWrite, ALUSrcA, ALUSrcB, PCSrc, secondRound, alu4, alu3, alu2, alu1, alu0);

   input logic [31:0] ins;
   input logic [0:0]  clock;
   output logic [0:0] memToReg, memWrite, branchEnable, ALUSrc, regDst, regWriteEnable, jump, jumpReg, PCWrite, IorD, IRWrite, ALUSrcA, secondRound, alu4, alu3, alu2, alu1, alu0;
   output logic [1:0] ALUSrcB, PCSrc;
   output logic [4:0] ALUControl;
   
   logic [0:0] andr, jr, jal, norr, nori, notr, rolv, rorv;
   logic [0:0] lw, sw, lw2, sw2, lwen, swen;
   logic [0:0] bleu, bleu2, bleuen;
   logic [0:0] PCSrc1, PCSrc0, srcB1, srcB0;
   logic [31:0] lw32, sw32, bleu32, lw1out, sw1out, bleu1out;

   
   // LW enable lines:
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

   // SW  enable lines:
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

   // BLEU enable lines:
   assign bleu = ~ins[31] & ins[30] & ~ins[29] & ~ins[28] & ~ins[27] & ~ins[26] & ~bleu2;
   // bleu32 is 32-bit version of bleu, with all 0's except least significant bit. used for register.
   assign bleu32 = {31'b0, bleu};
   // bleuen is high if either bleu or bleu2 is high, indicating that the value of bleu2 should be
   // updated on both the first and second clock ticks of a bleu instruction
   assign bleuen = bleu | bleu2;
   // register to save the value of bleu2 (in 32-bit form)
   enabledRegister bleuSave(bleu32, bleu1out, clock, bleuen);
   // take 32-bit version of bleu2 and use only least significant bit
   assign bleu2 = bleu1out[0];
   
   // enable lines for all other instructions
   assign andr = ins[31] & ~ins[30] & ~ins[29] & ~ins[28] & ~ins[27] & ~ins[26];
   assign jr = ~ins[31] & ~ins[30] & ins[29] & ~ins[28] & ~ins[27] & ~ins[26];
   assign jal = ~ins[31] & ~ins[30] & ~ins[29] & ~ins[28] & ins[27] & ins[26];
   assign norr = ins[31] & ~ins[30] & ~ins[29] & ins[28] & ins[27] & ~ins[26];
   assign nori = ~ins[31] & ~ins[30] & ins[29] & ins[28] & ins[27] & ~ins[26];
   assign notr = ~ins[31] & ~ins[30] & ~ins[29] & ins[28] & ~ins[27] & ~ins[26];
   assign rolv = ~ins[31] & ~ins[30] & ~ins[29] & ~ins[28] & ~ins[27] & ~ins[26];
   assign rorv = ~ins[31] & ~ins[30] & ~ins[29] & ~ins[28] & ins[27] & ~ins[26];
   
   assign alu4 = ins[31];
   assign alu3 = ins[30];
   assign alu2 = ins[29];
   assign alu1 = ins[28];
   assign alu0 = ins[27] | bleu2;  // change alu control for bleu2 to indicate to alu
   // that on bleu1 (01000) we add but on bleu2 (01001) we subtract
   
   assign memToReg = lw2 | jal;
   assign memWrite = sw2;
   assign branchEnable = bleu;
   assign ALUControl = {alu4, alu3, alu2, alu1, alu0};
   assign ALUSrc = nori | lw | sw; // don't need
   assign regDst = andr | norr | notr | rolv | rorv;
   assign regWriteEnable = lw2 | andr | norr | nori | notr | rolv | rorv | jal;  
   assign jump = jr | jal;
   assign jumpReg = jr;
   
   assign PCWrite = ~(lw | sw | bleu);
   assign IorD = lw2 | sw2;
   assign IRWrite = lw | sw;
   assign ALUSrcA = ~bleu; // high for everything but bleu first round where we compute next pc
   assign srcB1 = lw | sw | lw2 | sw2 |  nori | jump | bleu;
   assign srcB0 = jump | bleu;
   assign ALUSrcB = {srcB1, srcB0};
   assign PCSrc1 = bleu2 | jumpReg;
   assign PCSrc0 = jal | jumpReg;
   assign PCSrc = {PCSrc1, PCSrc0};
   assign secondRound = lw2 | sw2;
   
   
endmodule