`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2025 02:48:14 AM
// Design Name: 
// Module Name: tb_datapath
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


module tb_datapath;
  // parameters
  localparam K = 8;

  // clock & reset
  reg clk;
  reg rst;

  // control signals
  reg EA, EB;
  reg Li, Ei;
  reg Lj, Ej;
  reg Csel;
  reg WE, Bout;

  // datapath outputs
  wire AgtB;
  wire zi;
  wire zj;
  wire [2:0] Addr;
  wire [7:0] Din;
  wire [7:0] Dout;

  // Instantiate DUT
  datapath #(.K(K)) dp (
    .clk    (clk),
    .rst    (rst),
    .EA     (EA),
    .EB     (EB),
    .Li     (Li),
    .Ei     (Ei),
    .Lj     (Lj),
    .Ej     (Ej),
    .Csel   (Csel),
    .WE     (WE),
    .Bout   (Bout),
    .AgtB   (AgtB),
    .zi     (zi),
    .zj     (zj),
    .Addr   (Addr),
    .Din    (Din),
    .Dout   (Dout)
  );

  // Behavioral memory model 8×8
  reg [7:0] mem [0:K-1];
  assign Dout = mem[Addr];
  always @(posedge clk) if (WE) begin
    mem[Addr] <= Din;
    $display("%0t ns: WRITE mem[%0d] <= %0d", $time, Addr, Din);
  end

  // Clock generator
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test sequence
  initial begin
    integer i;
    // Initialize memory
    mem[0]=90; mem[1]=25; mem[2]=60; mem[3]=15;
    mem[4]=30; mem[5]=75; mem[6]=45; mem[7]=10;

    // Initialize signals
    rst = 1;
    EA=0; EB=0; Li=0; Ei=0; Lj=0; Ej=0;
    Csel=0; WE=0; Bout=0;

    // Display header
    $display("Time | i_cnt j_cnt Addr | A_reg B_reg | AgtB zi zj | Din WE Bout Csel");
    $monitor("%4dns |   %0d      %0d     %0d   |   %0d     %0d  |   %b    %b  %b |   %0d   %b    %b    %b", 
      $time, dp.i_cnt, dp.j_cnt, Addr, dp.A_reg, dp.B_reg, AgtB, zi, zj, Din, WE, Bout, Csel);

    // Release reset
    #12 rst = 0;
    #10;

    //-------------------------------
    // Test: Load A = mem[2] = 60
    //-------------------------------
    // Move i_cnt to 2
    Li = 1; #10; Li = 0; #10;
    repeat (2) begin
      Ei = 1; #10; Ei = 0; #10;
    end
    // Load A
    Csel = 0;
    EA = 1; #10; EA = 0; #10;
    if (dp.A_reg !== 8'd60) $error("A_reg load failed: expected 60, got %0d", dp.A_reg);

    //-------------------------------
    // Test: Load B = mem[5] = 75
    //-------------------------------
    // Move j_cnt to i+1 = 3, then to 5
    Lj = 1; #10; Lj = 0; #10;
    repeat (2) begin
      Ej = 1; #10; Ej = 0; #10;
    end
    // Load B
    Csel = 1;
    EB = 1; #10; EB = 0; #10;
    if (dp.B_reg !== 8'd75) $error("B_reg load failed: expected 75, got %0d", dp.B_reg);

    //-------------------------------
    // Test: Comparator AgtB = 0 (60 > 75?)
    //-------------------------------
    #10;
    if (AgtB !== 1'b0) $error("Comparator failed: expected AgtB=0, got %b", AgtB);

    //-------------------------------
    // Test: Comparator AgtB = 1 using forced regs
    //-------------------------------
    force dp.A_reg = 8'd45;
    force dp.B_reg = 8'd15;
    #1;
    if (AgtB !== 1'b1) $error("Comparator failed: expected AgtB=1, got %b", AgtB);
    release dp.A_reg; release dp.B_reg;

    //-------------------------------
    // Test: Zero detects using forced counters
    //-------------------------------
    force dp.i_cnt = K-2;
    force dp.j_cnt = K-1;
    #1;
    if (zi !== 1'b1) $error("Zero-detect zi failed: expected 1, got %b", zi);
    if (zj !== 1'b1) $error("Zero-detect zj failed: expected 1, got %b", zj);
    release dp.i_cnt; release dp.j_cnt;

    //-------------------------------
    // Test: Write-back mux & WE
    //-------------------------------
    force dp.A_reg = 8'hAA;
    force dp.B_reg = 8'h55;
    // write A to i_cnt
    Csel = 0; Bout = 0; WE = 1; #10; WE = 0; #10;
    if (mem[dp.i_cnt] !== 8'hAA) $error("Writeback A failed: mem[%0d]=%0h", dp.i_cnt, mem[dp.i_cnt]);
    // write B to j_cnt
    Csel = 1; Bout = 1; WE = 1; #10; WE = 0; #10;
    if (mem[dp.j_cnt] !== 8'h55) $error("Writeback B failed: mem[%0d]=%0h", dp.j_cnt, mem[dp.j_cnt]);
    release dp.A_reg; release dp.B_reg;

    $display("\n=== Datapath tests PASSED ===");
    #20; $finish;
  end
endmodule
