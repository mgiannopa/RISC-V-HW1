`include "datapath.v"
`include "ram.v"
`include "rom.v"

module multicycle #(
    parameter [31:0] INITIAL_PC = 32'h00400000,
    parameter [6:0] SW=7'b0100011,LW=7'b0000011
    ,IMMEDIATE=7'b0010011,BEQ=7'b1100011,RR=7'b0110011,
    parameter [2:0] IF=3'b000, //Gray code
                    ID=3'b001,
                    EX=3'b011,
                    MEM=3'b010,
                    WB=3'b110
)
 (
output wire [31:0] PC,dAddress,dWriteData,WriteBackData, //4 32-bit outputs
output reg MemRead,MemWrite,                             //2 1-bit outputs
input clk,rst,                                           //2 1-bit inputs
input wire [31:0] instr,dReadData                        //2 32-bit inputs
);

reg memread,memwrite;                                    //2 1-bit registers  
reg alusrc,regwrite,memtoreg,loadpc,pcsrc;               //5 1-bit registers
reg [2:0] current_state,next_state;                      //2 3-bit registers
wire zero;                                               //1 1-bit wire
reg [3:0] aluctrl;                                       //1 4-bit register
reg [6:0] opcode;                                        //1 7-bit register
reg [2:0] funct3;                                        //1 3-bit register
reg [6:0] funct7;                                        //1 7-bit register



   datapath  #(.INITIAL_PC(INITIAL_PC))
    datapath1(//Instantiate the datapath
      .PC(PC),
  .instr(instr),
  .dAddress(dAddress),
  .dReadData(dReadData),
  .dWriteData(dWriteData),
  .ALUSrc(alusrc),
  .ALUCtrl(aluctrl),
  .RegWrite(regwrite),
  .MemToReg(memtoreg),
  .loadPC(loadpc),
  .Zero(zero),
  .PCSrc(pcsrc),
  .clk(clk),
  .rst(rst),
  .WriteBackData(WriteBackData)
    );
    DATA_MEMORY ram( //Inastantiate the data memory
    .we(MemWrite),
    .dout(dReadData),
    .din(dWriteData),
    .addr(dAddress[8:0]),
    .clk(clk));

INSTRUCTION_MEMORY rom(//Instantiate the instruction memory
    .addr(PC[8:0]),
    .dout(instr),
    .clk(clk));
    

always @(instr) begin //Declaring and updating the opcode, funct3 and funct7
    opcode = instr[6:0];  //Declaring the opcode
    funct3 = instr[14:12];//Declaring the funct3
    funct7 = instr[31:25];//Declaring the funct7
end

always @(posedge clk) 
begin : STATE_MEMORY 
if(rst) //Resetting the state to IF
    current_state <= IF;
else //Updating the state
    current_state <= next_state;
end

always @(current_state) //Updating the next state as seen in the state diagram
begin : NEXT_STATE_LOGIC
case(current_state)
    IF : next_state <= ID;
    ID : next_state <= EX;
    EX : next_state <= MEM;
    MEM : next_state <= WB;
    WB : next_state <= IF;
endcase
end

always @(opcode, funct3, funct7) begin
    case(opcode)
        LW, SW: aluctrl = 4'b0010; // Addition
        BEQ: aluctrl = 4'b0110; // Subtraction
        IMMEDIATE: begin
            alusrc = 1'b1;
            case(funct3)
                3'b000: aluctrl = 4'b0010; // ADDI
                3'b010: aluctrl = 4'b0111; // SLTI
                3'b100: aluctrl = 4'b1101; // XORI
                3'b110: aluctrl = 4'b0001; // ORI
                3'b111: aluctrl = 4'b0000; // ANDI
                3'b001: aluctrl = 4'b1001; // SLLI
                3'b101: begin // SRLI or SRAI so we need to check funct7
                    case(funct7)
                        7'b0000000: aluctrl = 4'b1000; // SRLI
                        7'b0100000: aluctrl = 4'b1010; // SRAI
                    endcase
                end
            endcase
        end
        RR: begin
            alusrc = 1'b0;
            case(funct7)
                7'b0000000: begin //Multiple operations possible so we need to check funct3
                    case(funct3)
                        3'b000: aluctrl = 4'b0010; // ADD
                        3'b001: aluctrl = 4'b1001; // SLL
                        3'b010: aluctrl = 4'b0111; // SLT
                        3'b100: aluctrl = 4'b1101; // XOR
                        3'b110: aluctrl = 4'b0001; // OR
                        3'b111: aluctrl = 4'b0000; // AND
                        3'b101: aluctrl = 4'b1000; // SRL
                    endcase
                end
                7'b0100000: begin //SUB or SRA so we need to check funct3
                    case(funct3)
                        3'b000: aluctrl = 4'b0110; // SUB
                        3'b101: aluctrl = 4'b1010; // SRA
                    endcase
                end
            endcase
        end
        default: begin
            alusrc = 1'b0;
            aluctrl = 4'b0010; // ADD
        end
endcase
end


always @(opcode) begin
    case(opcode)
        LW, SW, IMMEDIATE: alusrc = 1'b1; // Immediate data
        default: alusrc = 1'b0; // Output of the second register read
    endcase
end

always @(posedge clk) begin
    if (current_state == MEM) begin //If the current state is MEM, we need to read or write to memory
        case(opcode)
            LW: begin //If the opcode is LW, we need to read from memory
                memread = 1'b1;
                memwrite = 1'b0;
            end
            SW: begin //If the opcode is SW, we need to write to memory
                memread = 1'b0;
                memwrite = 1'b1;
            end
            default: begin 
                memread = 1'b0;
                memwrite = 1'b0;
            end
        endcase
    end
    else begin //If the current state is not MEM, we don't need to read or write to memory
        memread = 1'b0; 
        memwrite = 1'b0;
    end
end

always @(posedge clk) begin
    if (current_state == WB) begin //If the current state is WB, we need to write back to the register file
        case(opcode)
            LW: begin //If the opcode is LW, we need to write back the data read from memory
                regwrite = 1'b1;
                memtoreg = 1'b1;
            end
            default: begin
                regwrite = 1'b1;
                memtoreg = 1'b0;
            end
        endcase
    end
    else begin //If the current state is not WB, we don't need to write back to the register file
        regwrite = 1'b0;
        memtoreg = 1'b0;
    end
end


always @(posedge clk) begin //Updating the data to be written to memory 
    if (current_state == WB) begin
        loadpc = 1'b1;
    end
    else begin 
        loadpc = 1'b0;
    end
end

always @(opcode, zero) begin //Updating the PC
    if (opcode == BEQ && zero == 1'b1) begin
        pcsrc = 1'b1;
    end
    else begin
        pcsrc = 1'b0;
    end
end
endmodule