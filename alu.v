module alu
#(parameter[3:0] alu_opAND = 4'b0000,  //Logical AND
  parameter[3:0] alu_opOR  = 4'b0001,  //Logical OR
  parameter[3:0] alu_opADD = 4'b0010,  //Addition
  parameter[3:0] alu_opSUB = 4'b0110,  //Subtraction
  parameter[3:0] alu_opLT  = 4'b0111,  //Less than
  parameter[3:0] alu_opSRL = 4'b1000,  //Shift right logical
  parameter[3:0] alu_opSLL = 4'b1001,  //Shift left logical
  parameter[3:0] alu_opSRA = 4'b1010,  //Shift right arithmetic
  parameter[3:0] alu_opXOR = 4'b1101) //Logical XOR
(
  output reg zero, //Output 1-bit
  output reg [31:0] result, //Output 32-bit
  input signed [31:0] op1, //Input 32-bit
  input signed [31:0] op2,//Input 32-bit
  input [3:0] alu_op //Input 4-bit
);
  
  always @(*)begin
    case(alu_op)
      alu_opAND: result = op1 & op2; //And
      alu_opOR : result = op1 | op2; //Or
      alu_opADD: result = op1 + op2; //Addition
      alu_opSUB: result = op1 - op2; //Subtraction
      alu_opLT : result = $signed(op1) < $signed(op2); //Less than
      alu_opSRL: result = op1 >> op2[4:0]; //Shift right logical
      alu_opSLL: result = op1 << op2[4:0]; //Shift left logical
      alu_opSRA: result = $unsigned($signed(op1) >>> op2[4:0]); //Shift right arithmetic
      alu_opXOR: result = op1 ^ op2; //XOR
      default: result = 32'b0; //If there is a problem in one of the cases
  endcase
      zero = (result == 32'b0) ? 1 : 0;
  end

endmodule