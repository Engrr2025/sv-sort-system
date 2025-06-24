`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2025 03:01:04 AM
// Design Name: 
// Module Name: ram8
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//----------------------------------------------------------------------
// Simple single-port RAM 8×8 bytes with init values
//----------------------------------------------------------------------
module ram8 (
    input           clk,
    input           we,
    input   [2:0]   addr,
    input   [7:0]   din,
    output  reg [7:0] dout
);
    reg [7:0] mem [0:7];
    // initialize with predefined values for simulation
    initial begin
        mem[0] = 8'd90;
        mem[1] = 8'd25;
        mem[2] = 8'd60;
        mem[3] = 8'd15;
        mem[4] = 8'd30;
        mem[5] = 8'd75;
        mem[6] = 8'd45;
        mem[7] = 8'd10;
    end
    // read
    always @* dout = mem[addr];
    // write
    always @(posedge clk) if (we) mem[addr] <= din;
endmodule

