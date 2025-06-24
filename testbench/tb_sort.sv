`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/25/2025 12:15:01 AM
// Design Name: 
// Module Name: tb_sort
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


module tb_sort;
  // Signals
  reg        clk;
  reg        rst;
  reg        s;
  wire       done;
  integer    addr;  // loop variable for reading memory



  // Instantiate DUT
  top dut (
    .clk  (clk),
    .rst  (rst),
    .s    (s),
    .done (done)
  );

  // Clock generation: 100 MHz
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Stimulus sequence
  initial begin
    // Dump waveforms
    $dumpfile("tb_sort.vcd");
    $dumpvars(0, tb_sort);

    // 1) Assert reset for two cycles
    rst = 1;
    s   = 0;
    @(posedge clk);
    @(posedge clk);
    rst = 0;

    // 2) Wait one cycle to settle
    @(posedge clk);

    // 3) Pulse start
    s = 1;
    @(posedge clk);
    s = 0;

    // 4) Wait for done
    wait(done);
    @(posedge clk);

    // 5) Display sorted results
    $display("\n=== Sorted Results ===");
    for (addr = 0; addr < 8; addr = addr + 1) begin
      $display("mem[%0d] = %0d", addr, dut.ram_inst.mem[addr]);
    end

    // 6) End simulation
    #10 $finish;
  end
endmodule

