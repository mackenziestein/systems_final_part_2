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
   logic [0:0] 	       PCWrite, IorD, IRWrite, ALUSrcA, secondRound;
   logic [1:0] 	       ALUSrcB, PCSrc;
   logic [4:0] 	       ALUControl;
   // memory
   logic [31:0]        instA, ALUResult, dataA, WD, instrFromMem, firstOrSecond;
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


   initial
     constant4 <= 32'b100;

   // ADDER for the PC incrementing circuit. - functionality not put into ALU.
   
   adder psAdd(adderIn1,adderIn2,adderOut);

   assign adderIn1 = pcQ;
   assign adderIn2 = constant4;
   assign pcPlus4 = adderOut;

   // CONTROL UNIT
    
   Control theControl(clock, instr, memToReg, memWrite, branchEnable, ALUControl, ALUSrc, regDst, regWriteEnable, jump, jumpReg, PCWrite, IorD, IRWrite, ALUSrcA, ALUSrcB, PCSrc, secondRound, alu4, alu3, alu2, alu1, alu0);
   
   // INSTRUCTION AND DATA MEMORY
   
   assign dataA = ALUResult;
   mux4to1B32 memoryIn(1'b0, IorD, 32'b0, 32'b0, ALUResult, pcQ, instA); 
   combinedMemory idmem(instA, instrFromMem, WD, clk, WE); 

   
   //REGISTER FILE 

   registerFile theRegisters(A1,A2, A3, clk, WE3, WD3, RD1, RD2);

   // store and (maybe) select previous instruction on lw and sw round 2
   enabledRegister instructionIn(instrFromMem, firstOrSecond, clock, IRWrite);
   mux4to1B32 choose1or2(1'b0, secondRound, 32'b0, 32'b0, firstOrSecond, instrFromMem, instr);
   assign dataOut = instrFromMem;

   // functionality to store instruction in r7 in order to jump back to it on a jr instruction
   mux2to1B5 muxA3(regDst, instr[15:11], instr[20:16], RsOrRt);
   assign r7default = 5'b11111;
   mux2to1B5 muxJal(jump, r7default, RsOrRt, A3assign);
   mux4to1B32 muxRD(jump, memToReg, pcPlus4, 32'b111111, dataOut, ALUResult, WD3);

   assign clk = clock;
   assign A1 = instr[25:21];
   assign A2 = instr[20:16];
   assign A3 = A3assign;  // A3 is either 20:16 or 15:11 or default to register 7 address
 
   assign WE3 = regWriteEnable;
   
   assign constant0 = 2'b0;
   assign SignImm = {{16{instr[15]}}, instr[15:0]};
   
   //ALU THINGS

   //enabledRegister RD1Out(RD1, RDA, clock, 1'b1); --> this would be in full implementation of multicycle, but we did not want to use so many clock ticks
   assign RDA = RD1;
   //enabledRegister RD2Out(RD2, RDB, clock, 1'b1); --> this would be in full implementation of multicycle, but we did not want to use so many clock ticks
   assign RDB = RD2;
   
   assign SignImm22 = {SignImm[29:0], constant0};
   // choose between RDA (register 1) and pcQ (current pc address)
   mux4to1B32 ALUA(1'b0, ALUSrcA, 32'b0, 32'b0, RDA, pcPlus4, SrcAIn);
   // choose between SignImm22 (for jump), SignImm (for lw, sw, nori), constant4 (for PC+4) or RDB (everything else)
   mux4to1B32 ALUB(ALUSrcB[1], ALUSrcB[0], SignImm22, SignImm, constant4, RDB, SrcBIn);   
   assign SrcA = SrcAIn;
   assign SrcB = SrcBIn;

   ALU theALU(SrcA, SrcB, ALUControl, ALUResult);

   assign WD = RDB;
   assign WE = memWrite;

   // enabledRegister ALUResultReg(ALUResult, ALUOut, clock, 1'b1); --> this would be in full implementation of multicycle, but we did not want to use so many clock ticks
			  
   // SOME BRANCH THINGS

   // in first round of branch instruction, save branch address to be used if condition is satisfied
   enabledRegister holdPCBranch(ALUResult, PCBranch, clock, branchEnable);

   // choose to branch or not to branch, based on whether I1-I2 is positive (I1>I2, don't branch) or I1-I2 is negative (I1<I2, do branch)
   mux4to1B32 muxBranch(1'b0, ALUResult[31], 32'b0, 32'b0, PCBranch, pcPlus4, muxBranchOut);
   
   
   //JUMP THINGS

   assign PCJump = {pcQ[31:28], instr[25:0], constant0[1:0]};
   assign PCJumpReg = RD1;
   // choose whether to jump to reg7 or jump to calculated address
   mux4to1B32 muxJump(1'b0, jumpReg, 32'b0, 32'b0, PCJumpReg, PCJump, PCNextJump);
   
   // select next PC address
   mux4to1B32 PCSource(PCSrc[1], PCSrc[0], RD1, muxBranchOut, PCNextJump, pcPlus4, PCmux);
   assign pcD = PCmux;   
   enabledRegister PCWriteReg(pcD, pcQ, clock, PCWrite);
   


always @ (negedge clock) begin
   $display("CONTROL SIGNALS");
   $display("PCSrc %b", PCSrc);
   $display("PCWrite %b", PCWrite);
   $display("IorD %b", IorD);
   $display("LW and SW lines:  lw1 %b | lw2 %b | sw1 %b | sw2 %b", theControl.lw, theControl.lw2, theControl.sw, theControl.sw2);
   $display("Mem to reg enable : %b", memToReg);
   $display("Mem write enable  : %b", memWrite);
   $display("Branch enable : %b", branchEnable);
   $display("ALUControl : %b", ALUControl);
   $display("ALU SrcA %b", theControl.ALUSrcA);
   $display("ALU SrcB %b", theControl.ALUSrcB);
   $display("Reg Dst : %b", regDst);
   $display("Jump enable : %b", jump);
   $display("Jump register enable : %b", jumpReg);
   $display("Reg 0 write signal %b", theRegisters.yesWrite0);
   $display("Reg 1 write signal %b", theRegisters.yesWrite1);
   $display("Reg 2 write signal %b", theRegisters.yesWrite2);
   $display("Reg 3 write signal %b", theRegisters.yesWrite3);
   $display("Reg 4 write signal %b", theRegisters.yesWrite3);
   $display("Reg 5 write signal %b", theRegisters.yesWrite3);
   $display("Reg 6 write signal %b", theRegisters.yesWrite3);
   $display("Reg 7 write signal %b", theRegisters.yesWrite7);
end // always
   
endmodule
