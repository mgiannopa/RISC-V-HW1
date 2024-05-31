`include "regfile.v"
`include "calc.v"



module datapath #(
    parameter [31:0] INITIAL_PC =32'h00400000)
(
  output wire Zero,  // 1-bit output
  output reg [31:0] PC, dWriteData, dAddress, WriteBackData, //5 32-bit outputs
  input  clk,rst,PCSrc,ALUSrc,RegWrite,MemToReg,loadPC, //6 1-bit inputs
  input wire [31:0] instr,dReadData, //32-bit input
  input wire [3:0] ALUCtrl //4-bit input
);
    
    reg [31:0] readData1,readData2; //32-bit registers
    reg [4:0] writeReg,ReadReg1,ReadReg2; //5-bit registers
    wire [31:0] alu_result, var1, var2;   //32-bit wires
    reg [31:0] immediate,store,branch_offset,sign_of_branch_offset,WBData; //32-bit registers
    


regfile regfile2 (//Instantiate the register file
  .clk(clk),
  .write(RegWrite),
  .readReg1(ReadReg1),
  .readReg2(ReadReg2),
  .writeReg(writeReg),
  .readData1(var1),
  .readData2(var2),
  .writeData(WBData)
);
  alu alu2 (//Instantiate the ALU
    .op1(readData1),
    .op2(readData2),
    .alu_op(ALUCtrl),
    .result(alu_result),
    .zero(zero)
  );

always @(instr) begin 
  //Register instructions
  ReadReg1 <= instr[19:15];
  ReadReg2 <= instr[24:20];
  writeReg <= instr[11:7];

  //Immediate instructions
  immediate <= {{20{instr[31]}},instr[31:20]}; //Sign extend

  // Store instructions
  store <= {{20{instr[31]}},instr[31:25],instr[11:7]}; //Sign extend

  //Branch instructions
  sign_of_branch_offset <= {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0}; // sign extend
  branch_offset <= sign_of_branch_offset <<1; //Left shift by 1
  end


always @(posedge clk) begin

  if(rst) begin //Sychronous reset to initial PC
    PC <= INITIAL_PC;
  end
  else if(loadPC) begin //If loadPC is 1
    if(PCSrc) begin     //If PCSrc is 1, PC will be :
      PC <= PC + branch_offset;
    end
    else begin //If PCSrc is 0, PC will be:
      PC <= PC + 4;
    end
  end
end

//Always block for the mux determining which data to write back
always @(*) begin
if(MemToReg) begin //If MemToReg is 1, write back data is the data read from memory
  WBData <= dReadData;
  WriteBackData <= dReadData;
end
else begin //If MemToReg is 0, write back data is the result of the ALU
  WBData <= alu_result;
  WriteBackData <= alu_result;
end
dAddress <= alu_result; //Data address is the result of the ALU
end

always@(*) begin 
  readData1 <= var1; //The 1st operand is the data read from the register file
  if(ALUSrc) begin //If ALUsrc is 1, the 2nd operand is the immediate
    readData2 <= immediate;
  end
  else begin //If ALUsrc is 0, the 2nd operand is the data read from the register file
    readData2 <= var2;
  end
end
endmodule