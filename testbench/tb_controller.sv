`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2025 02:56:36 AM
// Design Name: 
// Module Name: tb_controller
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


module tb_controller;
  // parameter
  localparam K = 8;

  // signals
  reg        clk;
  reg        rst;
  reg        s;
  reg        AgtB;
  reg        zi;
  reg        zj;

  wire       EA;
  wire       EB;
  wire       Li;
  wire       Ei;
  wire       Lj;
  wire       Ej;
  wire       Csel;
  wire       WE;
  wire       Bout;
  wire       done;

  // Instantiate controller
  controller #(.K(K)) ctrl (
    .clk  (clk),
    .rst  (rst),
    .s    (s),
    .AgtB (AgtB),
    .zi   (zi),
    .zj   (zj),
    .EA   (EA),
    .EB   (EB),
    .Li   (Li),
    .Ei   (Ei),
    .Lj   (Lj),
    .Ej   (Ej),
    .Csel (Csel),
    .WE   (WE),
    .Bout (Bout),
    .done (done)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test sequence
  initial begin
    // Display header
    $display("Time | state | s AgtB zi zj | EA EB Li Ei Lj Ej Csel WE Bout done");
    $monitor("%4dns |   %0d   |  %b    %b   %b  %b  |  %b  %b  %b  %b  %b   %b    %b    %b   %b", 
      $time, ctrl.state, s, AgtB, zi, zj, EA, EB, Li, Ei, Lj, Ej, Csel, WE, Bout, done);

    // Initialize signals
    rst  = 1; s = 0;
    AgtB = 0; zi = 1; zj = 1;
    #12;
    rst = 0; #10;

    //---------------
    // Test 1: No-swap path (AgtB=0)
    //---------------
    $display("\n--- Starting No-swap Test ---");
    s = 1;
    @(posedge clk);
    s = 0;
    wait(done);
    $display("No-swap: done asserted at %0dns", $time);
    #20;

    //---------------
    // Test 2: Swap path (AgtB=1)
    //---------------
    $display("\n--- Starting Swap Test ---");
    AgtB = 1; zi = 1; zj = 1;
    s = 1;
    @(posedge clk);
    s = 0;
    wait(done);
    $display("Swap: done asserted at %0dns", $time);

    #10;
    $display("\n=== Controller tests PASSED ===");
    #10 $finish;
  end
endmodule
