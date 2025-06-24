`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/25/2025 12:13:10 AM
// Design Name: 
// Module Name: top
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
// Top-level: glue datapath, controller, RAM
//----------------------------------------------------------------------
module top (
    input        clk,
    input        rst,
    input        s,
    output       done
);
    // control & datapath signals
    wire EA, EB, Li, Ei, Lj, Ej;
    wire Csel, WE, Bout;
    wire AgtB, zi, zj;
    wire [2:0] Addr;
    wire [7:0] Din, Dout;

    datapath #(.K(8)) dp (
        .clk(clk), .rst(rst),
        .EA(EA), .EB(EB), .Li(Li), .Ei(Ei), .Lj(Lj), .Ej(Ej),
        .Csel(Csel), .WE(WE), .Bout(Bout),
        .AgtB(AgtB), .zi(zi), .zj(zj),
        .Addr(Addr), .Din(Din), .Dout(Dout)
    );

    controller #(.K(8)) ctrl (
        .clk(clk), .rst(rst), .s(s),
        .AgtB(AgtB), .zi(zi), .zj(zj),
        .EA(EA), .EB(EB), .Li(Li), .Ei(Ei), .Lj(Lj), .Ej(Ej),
        .Csel(Csel), .WE(WE), .Bout(Bout),
        .done(done)
    );

    ram8 ram_inst (
        .clk(clk),
        .we(WE),
        .addr(Addr),
        .din(Din),
        .dout(Dout)
    );
endmodule

