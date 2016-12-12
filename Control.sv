module Control(clock, ins, memToReg, memWrite, branchEnable, ALUControl, ALUSrc, regDst, regWriteEnable, jump, jumpReg, PCWrite, IorD, IRWrite, ALUSrcA, ALUSrcB, PCSrc, alu4, alu3, alu2, alu1, alu0);

   input logic [31:0] ins;
   output logic [0:0] memToReg, memWrite, branchEnable, ALUSrc, regDst, regWriteEnable, jump, jumpReg, PCWrite, IorD, IRWrite, ALUSrcA, ALUSrcB, PCSrc, alu4, alu3, alu2, alu1, alu0; 
   output logic [4:0] ALUControl;
   
   logic [0:0] andr, jr, jal, norr, nori, notr, bleu, rolv, rorv;
   logic [0:0] lw, sw, lw2, sw2;

   assign andr = ins[31] & ~ins[30] & ~ins[29] & ~ins[28] & ~ins[27] & ~ins[26];
   assign lw = ins[31] & ~ins[30] & ~ins[29] & ~ins[28] & ins[27] & ins[26];
   mux4to1B1 lwSave(lw, lw2, clock, 1'b1);
   assign sw = ins[31] & ~ins[30] & ins[29] & ~ins[28] & ins[27] & ins[26];
   mux4to1B1 swSave(sw, sw2, clock, 1'b1);  
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
   
   assign PCWrite = ~lw | ~sw;
   assign IorD = sw2;
   assign IRWrite = ~lw | ~sw;
   assign ALUSrcA = nori | lw | sw | lw2 | sw2;
   assign ALUSrcB[1] = lw | sw | lw2 | sw2 | branchEnable | nori;
   assign ALUSrcB[0] = branchEnable;
   assign PCSrc[1] = ~branchEnable;
   assign PCSrc[0] = ~jal;
   
   
   
endmodule