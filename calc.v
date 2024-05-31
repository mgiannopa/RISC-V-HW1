`include "alu.v"
`include "decoder.v"

module calc ( 
    output [15:0] led,  // 16-bit output
    input clk, btnc,  btnl, btnu, btnr, btnd, // 6 1-bit inputs
    input [15:0] sw  // 16-bit input
);
    reg signed [15:0] accumulator;  // 16-bit signed register
    wire signed [31:0] alu_result;  // 32-bit signed wire
    reg signed [31:0] op1, op2;     // 32-bit signed registers
    wire  [3:0] alu_op;             // 4-bit wire

   alu alu1 ( //Instantiate ALU
        .op1(op1),   
        .op2(op2),
        .alu_op(alu_op),
        .result(alu_result)
    );

    decoder decoder1 ( //Instantiate Decoder
        .op(alu_op),
        .A(btnr),
        .B(btnl),
        .C(btnc)
    );

    always@(posedge clk) begin 
        if (btnu) begin //If btnu is high, reset accumulator
            accumulator <= 16'b0;
        end else if(btnd) begin //If btnd is high, alu_result into accumulator
            accumulator <= alu_result[15:0];
        end 
    end

    always @(accumulator or sw) begin  
        op1<= {{16{accumulator[15]}},accumulator};  //Sign extend
        op2<= {{16{sw[15]}},sw};                    //Sign extend
    end

    assign led = accumulator;  

endmodule