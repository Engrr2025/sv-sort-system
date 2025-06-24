`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2025 02:46:11 AM
// Design Name: 
// Module Name: datapath
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


module datapath #(
    parameter K = 8
)(
    input        clk,
    input        rst,
    // control signals
    input        EA,  // enable A ? Dout
    input        EB,  // enable B ? Dout
    input        Li,  // load i ? 0
    input        Ei,  // increment i
    input        Lj,  // load j ? i+1
    input        Ej,  // increment j
    input        Csel, // 0?i_cnt, 1?j_cnt for Addr
    input        WE,   // write enable memory
    input        Bout, // select which reg drives Din: 0?A, 1?B
    // flags out
    output       AgtB,
    output       zi,   // i == K-2
    output       zj,   // j == K-1
    // memory interface
    output reg [2:0] Addr,
    output reg [7:0] Din,
    input      [7:0] Dout
);
    // internal registers
    reg [2:0] i_cnt;
    reg [2:0] j_cnt;
    reg [7:0] A_reg;
    reg [7:0] B_reg;

    // sequential updates
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            i_cnt <= 0;
            j_cnt <= 0;
            A_reg <= 0;
            B_reg <= 0;
        end else begin
            // outer index
            if (Li)      i_cnt <= 0;
            else if (Ei) i_cnt <= i_cnt + 1;
            // inner index
            if (Lj)      j_cnt <= i_cnt + 1;
            else if (Ej) j_cnt <= j_cnt + 1;
            // load A, B
            if (EA)      A_reg <= Dout;
            if (EB)      B_reg <= Dout;
        end
    end

    // address multiplexer
    always @* begin
        Addr = (Csel ? j_cnt : i_cnt);
    end

    // data-in multiplexer (for writes)
    always @* begin
        Din = (Bout ? B_reg : A_reg);
    end

    // comparator & zero detectors
    assign AgtB = (A_reg > B_reg);
    assign zi   = (i_cnt == (K - 2));
    assign zj   = (j_cnt == (K - 1));
endmodule

