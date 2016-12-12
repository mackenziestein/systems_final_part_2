module DataPath(clock, pcQ, instr, pcD, regWriteEnable);
///////////////////////////////////
   // The clock will be driven from the testbench 
   // The instruction, pcQ and pcD are sent to the testbench to
   // make debugging easier  

   input logic clock;
   output logic [31:0] instr, pcQ, pcD;
   logic [31:0] pcPlus4, constant4;
   output logic [0:0]  regWriteEnable;
   // adder
   logic [31:0]        adderIn1, adderIn2, adderOut;
   // control unit
   logic [0:0] 	       memToReg, memWrite, branchEnable, ALUSrc, regDst, jump, jumpReg, alu4, alu3, alu2, alu1, alu0;
   // new control lines:
   logic [0:0] 	       PCWrite, IorD, IRWrite, ALUSrcA;
   logic [1:0] 	       ALUSrcB, PCSrc;
   logic [4:0] 	       ALUControl;
   // memory
   logic [31:0]        instA, ALUResult, dataA, WD, instrFromMem;
   logic [0:0] 	       WE;
   // register file
   logic [4:0] 	       A3, A2, A1, RsOrRt, A3assign, r7default;
   logic 	       WE3, clk;
   logic [31:0]        WD3, RD1, RD2, RD, dataOut;
   logic [31:0]        SignImm, SignImm22, pc4AdderIn, branchAdderOut, PCBranch;
   logic [1:0] 	       constant0;
   // ALU
   logic [31:0]        SrcA, SrcB, muxSrcBin, Result, muxBranchOut, ALUOut, RDA, RDB, SrcAIn, SrcBIn;
   // jump and branch
   logic [31:0]        PCJump, jumpInst, PCNext, PCJumpReg, PCNextJump, PCmux;

   
   // enabledRegister PC(pcD,pcQ,clock,1'b1);

   initial
     constant4 <= 32'b100;

   // ADDER for the PC incrementing circuit.

   
   adder psAdd(adderIn1,adderIn2,adderOut);

   assign adderIn1 = pcQ;
   assign adderIn2 = constant4;
   assign pcPlus4 = adderOut;

   // CONTROL UNIT
    
   Control theControl(clock, instr, memToReg, memWrite, branchEnable, ALUControl, ALUSrc, regDst, regWriteEnable, jump, jumpReg, PCWrite, IorD, IRWrite, ALUSrcA, ALUSrcB, PCSrc, alu4, alu3, alu2, alu1, alu0);
   
   // INSTRUCTION AND DATA MEMORY
   
   assign dataA = ALUResult;
   mux4to1B32 memoryIn(1'b0, IorD, 32'b0, 32'b0, ALUResult, pcQ, instA); // ALURESULT SHOULD BE ALUOUT
   combinedMemory idmem(instA, instrFromMem, WD, clk, WE);  // !!!!!!!!!!!!!! INSTA IS DYING
   
   //assign instA = pcQ; // this needs to be changed - either the output from the ALU or the output from the PC register
   // dataMemory data(dataA, RD, WD, clk, WE);
   // instructionMemory imem(instA,instr);

   
   //REGISTER FILE 

   registerFile theRegisters(A1,A2, A3, clk, WE3, WD3, RD1, RD2);

       // new things
   enabledRegister instructionIn(instrFromMem, instr, clock, IRWrite);
   //assign instr = instrFromMem;
   
   //enabledRegister dataIn(instrFromMem, dataOut, clock, 1'b1);
   assign dataOut = instrFromMem;
   
       // old things
   
   mux2to1B5 muxA3(regDst, instr[15:11], instr[20:16], RsOrRt);
   assign r7default = 5'b11111;
   mux2to1B5 muxJal(jump, r7default, RsOrRt, A3assign);
   mux4to1B32 muxWD3(1'b0, memToReg, 32'b0, 32'b0, dataOut, ALUResult, WD3); // ALURESULT SHOULD BE ALUOUT
   
   assign clk = clock; // WHY DO WE DO THIS? WHY NOT JUST USE CLOCK?
   assign A1 = instr[25:21];
   assign A2 = instr[20:16];
   assign A3 = A3assign;  // A3 is either 20:16 or 15:11 or default to register 7 address
 
   assign WE3 = regWriteEnable;
   
   assign constant0 = 2'b0;
   assign SignImm = {{16{instr[15]}}, instr[15:0]};
   
   //ALU THINGS

   //enabledRegister RD1Out(RD1, RDA, clock, 1'b1);
   assign RDA = RD1;
   //enabledRegister RD2Out(RD2, RDB, clock, 1'b1);
   assign RDB = RD2;
   
   
   assign SignImm22 = {SignImm[29:0], constant0};
   mux4to1B32 ALUA(1'b0, ALUSrcA, 32'b0, 32'b0, RDA, pcQ, SrcAIn);
   mux4to1B32 ALUB(ALUSrcB[1], ALUSrcB[0], SignImm22, SignImm, constant4, RDB, SrcBIn);
   
   
   //mux4to1B32 muxRD2(1'b0, ALUSrc, 32'b0, 32'b0, SignImm, RD2, muxSrcBin);
   
   assign SrcA = SrcAIn;
   assign SrcB = SrcBIn;

   ALU theALU(SrcA, SrcB, ALUControl, ALUResult);    

   // ignore dis for now  mux4to1B32 muxRD(jump, memToReg, 32'b0, pcPlus4, RD, ALUResult, Result);

   assign WD = RDB;
   assign WE = memWrite;

   // enabledRegister ALUResultReg(ALUResult, ALUOut, clock, 1'b1);

			  
   // SOME BRANCH THINGS
   
   adder branchAdd(SignImm22, pc4AdderIn, branchAdderOut);

   assign pc4AdderIn = pcPlus4;
   assign PCBranch = branchAdderOut;

   //JUMP THINGS

   assign PCJump = {pcQ[31:28], instr[25:0], constant0[1:0]};
   assign PCJumpReg = RD1;
   
   mux4to1B32 muxJump(1'b0, jumpReg, 32'b0, 32'b0, PCJumpReg, PCJump, PCNextJump);
   

   // mux pcjumpreg and pcjump based on jumpreg
   // take that and put it into pcsource
   
   // assign pcD = PCNext;

   mux4to1B32 PCSource(PCSrc[1], PCSrc[0], pcPlus4, PCNextJump, ALUResult, ALUResult, PCmux); // I1 ALURESULT SHOULD BE ALUOUT
   assign pcD = PCmux;   
   enabledRegister PCWriteReg(pcD, pcQ, clock, PCWrite);
   


always @ (negedge clock) begin
   $display("---------------pcd %b", pcD);
   $display("---------------PCWrite %b", PCWrite);
   $display("---------------pcsrc %b", PCSrc);
   
   $display("pcq %b", pcQ);
   $display("alu result %b", ALUResult);
   //$display("alu res in alu %b", theALU.finalOut);
   //$display("alu first out %b", theALU.firstOut);
   //$display("alu sumOut %b", theALU.sumOut);
   //$display("alu norOut %b", theALU.norOut);
   //$display("alu norIOut %b", theALU.norIOut);
   $display("ALU add %b norr %b nori %b notr %b", theALU.add, theALU.norr, theALU.nori, theALU.notr);
   $display("ALU rolv %b rorv %b bleu %b", theALU.rolv, theALU.rorv, theALU.bleu);
   $display("CONTROL  andr %b jr %b jal %b norr %b notr %b bleu %b rolv %b rorv %b  be %b nori %b", theControl.andr, theControl.jr, theControl.jal, theControl.norr, theControl.notr, theControl.bleu, theControl.rolv, theControl.rorv, theControl.branchEnable, theControl.nori);
   $display("lw1 %b sw1 %b lw2 %v sw2 %b", theControl.lw, theControl.sw, theControl.lw2, theControl.sw2);
   $display("srcb bit 1 %b", theControl.srcB1);
   $display("srcb bit 0 %b", theControl.srcB0);
   $display("srcb %b", theControl.ALUSrcB);
   
   //$display("I1 %b", theALU.I1);
   //$display("I2 %b", theALU.I2);
   //$display("signimm22 %b", SignImm22);
   //$display("SignImm %b", SignImm);
   //$display("constant4 %b", constant4);
   //$display("RDB %b", RDB);
   $display("IorD %b", IorD);
   $display("instrfrommem %b", instrFromMem);
   $display("instA %b", instA);
   
   
   $display("data out %b", dataOut);
   $display("aluresult %b", ALUResult);
   
   
   // (ALUSrcB[1], ALUSrcB[0], SignImm22, SignImm, constant4, RDB, SrcBIn)
   
   $display("CONTROL SIGNALS");
   $display("Mem to reg enable : %b", memToReg);
   $display("Mem write enable  : %b", memWrite);
   //$display("Branch enable : %b", branchEnable);
   $display("ALUControl : %b", ALUControl);
   $display("ALUSrc : %b", ALUSrc);
   $display("Reg Dst : %b", regDst);
   //$display("Jump enable : %b", jump);
   //$display("Jump register enable : %b", jumpReg);
   //$display("Reg 0 write signal %b", theRegisters.yesWrite0);
   //$display("Reg 1 write signal %b", theRegisters.yesWrite1);
   //$display("Reg 2 write signal %b", theRegisters.yesWrite2);
   //$display("Reg 3 write signal %b", theRegisters.yesWrite3);
   //$display("Reg 4 write signal %b", theRegisters.yesWrite3);
   //$display("Reg 5 write signal %b", theRegisters.yesWrite3);
   //$display("Reg 6 write signal %b", theRegisters.yesWrite3);
   $display("Reg 7 write signal %b", theRegisters.yesWrite7);
end // always
   
endmodule
