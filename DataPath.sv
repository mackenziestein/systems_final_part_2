module DataPath(clock, pcQ, instr, pcD, regWriteEnable);
///////////////////////////////////
   // The clock will be driven from the testbench 
   // The instruction, pcQ and pcD are sent to the testbench to
   // make debugging easier  

   input logic clock;
   output logic [31:0] instr, pcQ, pcD, pcPlus4, constant4;
   output logic [0:0]  regWriteEnable;
   // adder
   logic [31:0]        adderIn1, adderIn2, adderOut;
   // control unit
   logic [0:0] 	       memToReg, memWrite, branchEnable, ALUSrc, regDst, jump, jumpReg, alu4, alu3, alu2, alu1, alu0;
   // new control lines:
   logic [0:0] 	       PCWrite, IorD, IRWrite, ALUSrcA, ALUSrcB;
   logic [4:0] 	       ALUControl;
   // memory
   logic [31:0]        instA, ALUResult, dataA, WD, instrFromMem;
   logic [0:0] 	       WE;
   // register file
   logic [4:0] 	       A3, A2, A1, RsOrRt, A3assign, r7default;
   logic 	       WE3, clk;
   logic [31:0]        WD3, RD1, RD2  RD, dataOut;
   logic [31:0]        SignImm, signImm22, pc4AdderIn, branchAdderOut, PCBranch;
   logic [1:0] 	       constant0;
   // ALU
   logic [31:0]        SrcA, SrcB, muxSrcBin, Result, muxBranchOut, ALUOut, RDA, RDB, SrcAIn, SrcBIn;
   // jump and branch
   logic [31:0]        PCJump, jumpInst, PCNext, PCJumpReg;

   
   // enabledRegister PC(pcD,pcQ,clock,1'b1);

   initial
     constant4 <= 32'b100;

   // ADDER for the PC incrementing circuit.

   
   adder psAdd(adderIn1,adderIn2,adderOut);

   assign adderIn1 = pcQ;
   assign adderIn2 = constant4;
   assign pcPlus4 = adderOut;

   // CONTROL UNIT
    
   Control theControl(instr, memToReg, memWrite, branchEnable, ALUControl, ALUSrc, regDst, regWriteEnable, jump, jumpReg, PCWrite, IorD, IRWrite, ALUSrcA, ALUSrcB, alu4, alu3, alu2, alu1, alu0);
   
   // INSTRUCTION AND DATA MEMORY
   
   assign dataA = ALUResult;
   mux4to1B32 memoryIn(1'b0, IorD, 32'b0, 32'b0, ALUOut, pcQ, instA);
   combinedMemroy idmem(instA, instrFromMem, WD, clk, WE); 
   
   //assign instA = pcQ; // this needs to be changed - either the output from the ALU or the output from the PC register
   // dataMemory data(dataA, RD, WD, clk, WE);
   // instructionMemory imem(instA,instr);

   
   //REGISTER FILE 

   registerFile theRegisters(A1,A2, A3, clk, WE3, WD3, RD1, RD2);

       // new things
   enabledRegister instructionIn(instrFromMem, instr, clock, IRWrite);
   enabledRegister instructionIn(instrFromMem, dataOut, clock, 1'b1);
   
       // old things
   assign r7default = 5'b11111;
   
   mux2to1B5 muxA3(regDst, instr[15:11], instr[20:16], RsOrRt);
   mux2to1B5 muxJal(jump, r7default, RsOrRt, A3assign); 
   
   assign clk = clock; // WHY DO WE DO THIS? WHY NOT JUST USE CLOCK?
   assign A1 = instr[25:21];
   assign A3 = A3assign;  // A3 is either 20:16 or 15:11, based on RegDst
   assign A2 = instr[20:16];
   assign WE3 = regWriteEnable;
   
   assign constant0 = 2'b0;
   assign SignImm = {{16{instr[15]}}, instr[15:0]};
   
   //ALU THINGS

   enabledRegister RD1Out(RD1, RDA, clock, 1'b1);
   enabledRegister RD2Out(RD2, RDB, clock, 1'b1);

   mux4to1B32 ALUA(1'b0, ALUSrcA, 32'b0, 32'b0, RDA, pcQ, SrcAIn);
   mux4to1B32 ALUB(1'b0, ALUSrcB, 32'b0, 32'b0, SignImm, constant4, SrcBIn);
   
   
   //mux4to1B32 muxRD2(1'b0, ALUSrc, 32'b0, 32'b0, SignImm, RD2, muxSrcBin);
   
   assign SrcA = SrcAIn;
   assign SrcB = SrcBIn;

   ALU theALU(SrcA, SrcB, ALUControl, ALUResult);    

   mux4to1B32 muxRD(jump, memToReg, 32'b0, pcPlus4, RD, ALUResult, Result);

   assign WD3 = dataOut; // dataOut assigned in register file section based on instrFromMem
   assign WD = RDB;
   assign WE = memWrite;

   enabledRegister(ALUResult, ALUOut, clock, 1'b1);

			  
   //SOME BRANCH THINGS
   
   adder branchAdd(signImm22, pc4AdderIn, branchAdderOut);
   
   assign signImm22 = {SignImm[29:0], constant0}; // ??? what is this used for
   assign pc4AdderIn = pcPlus4;
   assign PCBranch = branchAdderOut;

   //PC THINGS

   mux4to1B32 muxBranch(1'b0, PCBranch[31], 32'b0, 32'b0, SignImm, pcPlus4, muxBranchOut);

   assign PCJump = {pcQ[31:28], instr[25:0], constant0[1:0]};
   assign PCJumpReg = RD1;
   
   mux8to1B32 muxPC(branchEnable, jump, jumpReg, 32'b0, 32'b0, 32'b0, muxBranchOut, PCJumpReg, PCJump, 32'b0, pcPlus4, PCNext);
   
   // assign pcD = PCNext;
   assign pcD = ALUResult;
   

   enabledRegister PCWrite(pcD, pcQ, clock, PCWrite);
   


always @ (negedge clock) begin
   $display("CONTROL SIGNALS");
   $display("Mem to reg enable : %b", memToReg);
   $display("Mem write enable  : %b", memWrite);
   $display("Branch enable : %b", branchEnable);
   $display("ALUControl : %b", ALUControl);
   $display("ALUSrc : %b", ALUSrc);
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
