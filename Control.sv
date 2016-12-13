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
   assign lw = ins[31] & ~ins[30] & ~ins[29] & ~ins[28] & ins[27] & ins[26] & ~sw2 & ~lw2;
   assign lw32 = {31'b0, lw};
   assign lwen = lw | lw2;
   enabledRegister lwSave(lw32, lw1out, clock, lwen);
   assign lw2 = lw1out[0];
   assign sw = ins[31] & ~ins[30] & ins[29] & ~ins[28] & ins[27] & ins[26] & ~lw2 & ~sw2;
   assign sw32 = {31'b0, sw};
   assign swen = sw | sw2;
   enabledRegister swSave(sw32, sw1out, clock, swen);
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
   assign regDst = andr | norr | notr | rorv;
   assign regWriteEnable = lw2 | andr | norr | nori | notr | rorv | jal;  
   assign jump = jr | jal;
   assign jumpReg = jr;
   
   //assign PCWrite = ~((lw & ~lw2) | (sw & ~sw2));
   assign PCWrite = ~(lw | sw);
   assign IorD = lw2 | sw2;
   assign IRWrite = lw | sw;
   //~(lw2 | sw2);
   assign ALUSrcA = 1'b1;
   // nori | lw | sw | lw2 | sw2;
   assign srcB1 = lw | sw | lw2 | sw2 |  nori | jump;
   assign srcB0 = jump;
   assign ALUSrcB = {srcB1, srcB0};
   assign PCSrc1 = branchEnable | jumpReg;
   assign PCSrc0 = jal | jumpReg;
   assign PCSrc = {PCSrc1, PCSrc0};
   assign secondRound = lw2 | sw2;
   
   
endmodule