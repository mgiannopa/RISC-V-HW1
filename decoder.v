
module decoder (
  output wire [3:0] op,
  input wire A,B,C
);

// Declare internal wires used in the decoder the names are trying to be as descriptive as possible, but they are explained below as well.
wire An, BxC, AB, ABxC;
wire AB2, Bn, Cn, BnCn, ABC_BnCn;
wire AB3, CnABxAB;
wire AnC, AxnC, AnC_AxnC, AnC_AxnC_B;

//1st bit (alu_op[0])

not U0 (An,A); // NOT gate: An is the negation of A
xor U1(BxC,B,C); // XOR gate: BxC is the XOR of B and C
and U2(AB,An,B); // AND gate: AB is the AND of An and B
and U3(ABxC,A,BxC); // AND gate: ABxC is the AND of A and BxC
or U4(op[0],AB,ABxC); // OR gate: op[0] is the OR of AB and ABxC

//2nd bit (alu_op[1])

and U5 (AB2,A,B); // AND gate: AB2 is the AND of A and B
not U6(Bn,B); // NOT gate: Bn is the negation of B
not U7(Cn,C); // NOT gate: Cn is the negation of C
and U8(BnCn,Bn,Cn); // AND gate: BnCn is the AND of Bn and Cn
or U9(op[1],BnCn,AB2); // OR gate: op[1] is the OR of BnCn and AB2

//3rd bit (alu_op[2])

and U10(AB3,A,B); // AND gate: AB3 is the AND of A and B
xor U11(AxB,A,B); // XOR gate: AxB is the XOR of A and B
not U12(Cn,C); // NOT gate: Cn is the negation of C
or U13(AxB3,AxB,AB3); // OR gate: AxB3 is the OR of AB3 and AxB   
and U14(op[2],AxB3,Cn); // AND gate: op[2] is the AND of AB3 and Cn

//4th bit (alu_op[3])

not U15(An,A); // NOT gate: An is the negation of A
xnor U16(AxnC,A,C); // XNOR gate: AxnC is the XNOR of A and C
and U17(AnC,An,C); // AND gate: AnC is the AND of An and C
or U18(AnC_AxnC,AnC,AxnC); // OR gate: AnC_AxnC is the OR of AnC and AxnC
and U19(op[3],AnC_AxnC,B); // AND gate: op[3] is the AND of AnC_AxnC and B

endmodule