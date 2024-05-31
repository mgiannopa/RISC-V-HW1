`include "calc.v"
`timescale 1ns/1ns


module calc_tb;
    reg clk;
    reg btnc;
    reg btnl;
    reg btnu;
    reg btnr;
    reg btnd;
    reg [15:0] sw;
    wire [15:0] led;

    calc calc1 (
        .clk(clk),
        .btnc(btnc),
        .btnl(btnl),
        .btnu(btnu),
        .btnr(btnr),
        .btnd(btnd),
        .sw(sw),
        .led(led)
    );

        initial begin
    $dumpfile("test2.vcd");
    $dumpvars(0, calc1);
        end
    initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

initial begin
    $monitor("At time %t, led = %h", $time, led);
    begin
    // Reset
    btnu = 1; btnd = 0; btnl = 0; btnc = 0; btnr = 0; sw = 16'hxxxx; #20; btnu = 0; #20;
    end 
    begin
    // OR
    btnd = 1; btnl = 0; btnc = 1; btnr = 1; sw = 16'h1234; #20; btnd = 0; #20;
    end
    begin
    // AND
    btnd = 1; btnl = 0; btnc = 1; btnr = 0; sw = 16'h0ff0; #20; btnd = 0; #20;
    end 
    begin
    // ADD
    btnd = 1; btnl = 0; btnc = 0; btnr = 0; sw = 16'h324f; #20; btnd = 0; #20;
    end
    begin
    // SUB
    btnd = 1; btnl = 0; btnc = 0; btnr = 1; sw = 16'h2d31; #20; btnd = 0; #20;
    end
    begin
    // XOR
    btnd = 1; btnl = 1; btnc = 0; btnr = 0; sw = 16'hffff; #20; btnd = 0; #20;
    end
    begin
    // Less Than
    btnd = 1; btnl = 1; btnc = 0; btnr = 1; sw = 16'h7346; #20; btnd = 0; #20;
    end
    begin
    // Shift Left Logical
    btnd = 1; btnl = 1; btnc = 1; btnr = 0; sw = 16'h0004; #20; btnd = 0; #20;
    end
    begin
    // Shift Right Arithmetic
    btnd = 1; btnl = 1; btnc = 1; btnr = 1; sw = 16'h0004; #20; btnd = 0; #20;
    end
    begin
    // Less Than
    btnd = 1; btnl = 1; btnc = 0; btnr = 1; sw = 16'hffff; #20; btnd = 0; #20;
    end
    $finish;
end
endmodule