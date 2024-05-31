module regfile(
  output reg  [31:0] readData1, readData2, //2 32-bit outputs
  input wire clk,write, 	   		           //2 1-bit inputs
  input wire [4:0] readReg1, readReg2, writeReg,    //3 5-bit inputs
  input wire [31:0] writeData  		         //1 32-bit input
);
  integer i;  //Integer for "for" loop
  reg [31:0] registers [31:0]; //32x32-bit register array
  
  initial 
    begin //Initialize registers to 0
      for(i=0; i<32; i=i+1) begin
        registers[i] = 32'b0;
      end      
    end
  
  
  always @(posedge clk) begin   //Read or write depending on write signal
    if(write) begin             //If write signal is high, write to register
      registers[writeReg] <= writeData;
    end                         //If write signal is low, read from register
    readData1 <= registers[readReg1];
    readData2 <= registers[readReg2];
  end

endmodule
