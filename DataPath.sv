module DataPath(clock, pcQ, instr, pcD, regWriteEnable);
///////////////////////////////////
   // The clock will be driven from the testbench 
   // The instruction, pcQ and pcD are sent to the testbench to
   // make debugging easier  

   input logic clock;
   output logic [31:0] instr;
   output logic [31:0] pcQ;
   output logic [31:0] pcD;
   output logic [0:0]  regWriteEnable;
   logic [31:0]        pcPlus4, constant4;
   
   enabledRegister PC(pcD,pcQ,clock,1'b1);

   initial
     constant4 <= 32'b100;

   // ADDER for the PC incrementing circuit.

   logic [31:0] adderIn1, adderIn2, adderOut;
   
   adder psAdd(adderIn1,adderIn2,adderOut);

   assign adderIn1 = pcQ;
   assign adderIn2 = constant4;
   assign pcPlus4 = adderOut;
  
   // INSTRUCTION AND DATA MEMORY
   // input logic addr, writeData, clk, writeEnable
   // output logic read
   logic [31:0] instA;
   logic [31:0] ALUResult, dataA, WD;
   logic [0:0] 	WE;

   assign dataA = ALUResult;
   assign instA = pcQ; // this needs to be changed - either the output from the ALU or the output from the PC register
   
   // dataMemory data(dataA, RD, WD, clk, WE);
   // instructionMemory imem(instA,instr);

   combinedMemroy idmem(instA, instr, WD, clk, WE);
   

   // CONTROL UNIT

   logic [0:0] 	memToReg, memWrite, branchEnable, ALUSrc, regDst, jump, jumpReg, alu4, alu3, alu2, alu1, alu0;
   // new control lines:
   logic [0:0] 	PCWrite, IorO, IRWrite, ALUSrcA, ALUSrcB;
   
   logic [4:0] 	ALUControl;  
   
   Control theControl(instr, memToReg, memWrite, branchEnable, ALUControl, ALUSrc, regDst, regWriteEnable, jump, jumpReg, alu4, alu3, alu2, alu1, alu0);
   
   //REGISTER FILE 
   
   logic [4:0] 	       A3, A2, A1;
   logic 	       WE3, clk;
   logic [31:0]        WD3, RD1, RD2;

   registerFile theRegisters(A1,A2, A3, clk, WE3, WD3, RD1, RD2);

   logic [31:0]   RD;
   logic [4:0] 	  RsOrRt, A3assign, r7default;

   assign r7default = 5'b11111;
   
   mux2to1B5 muxA3(regDst, instr[15:11], instr[20:16], RsOrRt);
   mux2to1B5 muxJal(jump, r7default, RsOrRt, A3assign); 
   
   assign clk = clock;
   assign A1 = instr[25:21];
   assign A3 = A3assign;  // A3 is either 20:16 or 15:11, based on RegDst
   assign A2 = instr[20:16];
   assign WE3 = regWriteEnable;

   logic [31:0]        SignImm, signImm22, pc4AdderIn, branchAdderOut, PCBranch;
   logic [1:0] 	       constant0;
   
   assign constant0 = 2'b0;
   assign SignImm = {{16{instr[15]}}, instr[15:0]};

   //SOME BRANCH THINGS
   
   adder branchAdd(signImm22, pc4AdderIn, branchAdderOut);
   
   assign signImm22 = {SignImm[29:0], constant0};
   assign pc4AdderIn = pcPlus4;
   assign PCBranch = branchAdderOut;
   
  //ALU THINGS

   logic [31:0]        SrcA, SrcB;
   logic [31:0]        muxSrcBin, Result, muxBranchOut;
   
   mux4to1B32 muxRD2(1'b0, ALUSrc, 32'b0, 32'b0, SignImm, RD2, muxSrcBin);

   assign SrcB = muxSrcBin;
   assign SrcA = RD1;

   ALU theALU(SrcA, SrcB, ALUControl, ALUResult);    

   mux4to1B32 muxRD(jump, memToReg, 32'b0, pcPlus4, RD, ALUResult, Result);

   assign WD3 = Result;
   assign WD = RD2;
   assign WE = memWrite;

   //PC THINGS

   mux4to1B32 muxBranch(1'b0, PCBranch[31], 32'b0, 32'b0, SignImm, pcPlus4, muxBranchOut);

   logic [31:0]        PCJump, jumpInst, PCNext, PCJumpReg;

   assign PCJump = {pcQ[31:28], instr[25:0], constant0[1:0]};
   assign PCJumpReg = RD1;
   
   mux8to1B32 muxPC(branchEnable, jump, jumpReg, 32'b0, 32'b0, 32'b0, muxBranchOut, PCJumpReg, PCJump, 32'b0, pcPlus4, PCNext);
   
   assign pcD = PCNext;


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
