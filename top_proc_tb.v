`include "multicycle.v"
`timescale 1ns/1ns

module top_tb;

    reg clk;
    reg rst;
    wire [31:0] PC;
    wire [31:0] dAddress;
    wire [31:0] dWriteData;
    wire [31:0] WriteBackData;
    wire MemRead;
    wire MemWrite;
    wire [31:0] instr;
    wire [31:0] dReadData;

multicycle multicycle1 (//Instantiate the multicycle processor
    .PC(PC),
    .dAddress(dAddress),
    .dWriteData(dWriteData),
    .WriteBackData(WriteBackData),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .clk(clk),
    .rst(rst),
    .instr(instr),
    .dReadData(dReadData)
);
    always begin //Clock generator
        clk = 0;
        #5 clk = 1;
        #5 clk = 0;
    end

    initial begin //Reset generator at the start of the simulation
        rst = 0;
        #10 rst = 1;
        #10 rst = 0;
    end
initial begin //Dump the waveforms
    $dumpfile("top_tb.vcd");
    $dumpvars(0,top_tb);
    #10000;
    $finish;
end
endmodule